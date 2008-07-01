DROP PROCEDURE MANU_APP.TARGET_WEIGHT_CREATE;

CREATE OR REPLACE PROCEDURE MANU_APP.Target_Weight_Create IS
/******************************************************************************
   NAME:       BDS_TARGET_WEIGHT_CREATE
   PURPOSE:    Build ebntries in the BDS_TARGET_WEIGHT table
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        27-Aug-2007   Jeff Phillipson       1. Created this procedure.
   1.1        08-Oct-2007   Jeff Phillipson       2. changed to hard coded plant codes in query
   1.2        01-Nov-2007  Jeff Phillipson       Added new rules as below and limited to AU40 and 45
   RULE:
              1. The CHILD_RSU_FLAG specifies the associated RSU for the selected material
              2. If the Item_base_uom is 'PCE' the PCE value is obtained for the asscociated RSU
              3. mars_plant_Material_type is used to define the Nake component (=7)
              4. Nake value at (7) = item_base_qty / PCE value - (PCE value will usually = 1)
              5. RSU value  = Nake value * (RSU Item_base_qty / Bom_base_qty)
               
******************************************************************************/

	 /*-*/
	 /* variables
	 /*-*/
	 var_ratio      NUMBER;
	 var_value      NUMBER;
     var_pce        NUMBER;
  
     /*-*/
     /* constants
     /*-*/
     cst_plant_material_type CONSTANT VARCHAR2(1) := '7';
     
	 /*-*/
	 /* Private exceptions
	 /*-*/
	 application_exception EXCEPTION;
	 PRAGMA EXCEPTION_INIT(application_exception, -20000);
  
    /*-*/
    /* cursor definition
    /*-*/
    CURSOR csr_matl
    IS
    SELECT LTRIM(t01.sap_material_code,'0') matl_code, 
           t01.plant_code,
           CASE
            WHEN t01.mars_intrmdt_prdct_compnt_flag = 'X' THEN 'INT'
            WHEN t01.mars_merchandising_unit_flag = 'X' THEN 'MCU'
            WHEN t01.mars_prmotional_material_flag = 'X' THEN 'PRM'
            WHEN t01.mars_retail_sales_unit_flag = 'X' THEN 'RSU'
            WHEN t01.mars_semi_finished_prdct_flag = 'X' THEN 'SFR'
            WHEN t01.mars_rprsnttv_item_flag = 'X' THEN 'REP'
            WHEN t01.mars_traded_unit_flag = 'X' THEN 'TDU'
            ELSE t01.material_type
           END TYPE
      FROM bds_material_plant_mfanz t01
     WHERE ((material_type = 'FERT' AND material_division = '01' AND (procurement_type = 'E' AND special_procurement_type IS NULL) OR (procurement_type = 'F' AND special_procurement_type = '30')) 
          OR (material_type = 'ROH' AND procurement_type = 'E' AND special_procurement_type IS NULL)
          OR (material_type = 'VERP' AND procurement_type = 'E' AND special_procurement_type IS NULL))
      AND xplant_status <> 90
      AND plant_specific_status <> 99
      AND t01.plant_code IN ('AU40','AU45'); 
    rcd_matl csr_matl%ROWTYPE;
                   
    CURSOR csr_bom
    IS
    SELECT t01.*, t02.child_rsu_flag
      FROM (SELECT LTRIM(rcd_matl.matl_code,'0') material_code,
                   t01.hierarchy_rownum,
                   t01.hierarchy_level,
                   t01.bom_material_code,
                   t01.bom_plant,   
                   t01.bom_base_qty,
                   t01.bom_base_uom,
                   t01.item_material_code,
                   t01.item_base_qty,
                   t01.item_base_uom,
                   t02.mars_plant_material_type
              FROM TABLE(bds_bom.get_hierarchy(SYSDATE,LTRIM(rcd_matl.matl_code,'0'),rcd_matl.plant_code)) t01,
                   bds_material_plant_mfanz t02,
                   bds_material_plant_mfanz t03
             WHERE t01.item_material_code = LTRIM(t02.sap_material_code,'0')
               AND t01.bom_material_code = LTRIM(t03.sap_material_code,'0')
               AND t01.bom_plant = t02.plant_code
               AND t01.bom_plant = t03.plant_code) t01,
           bds_material_bom_all t02
     WHERE t01.material_code = LTRIM(t02.parent_material_code(+),'0')
       AND t01.bom_material_code = LTRIM(t02.child_material_code(+),'0')
       AND t02.bom_usage(+) = 5
       --AND t01.mars_plant_material_type IN (0,1,3,7)
     ORDER BY 2;
    rcd_bom csr_bom%ROWTYPE;
         
    rcd_matl_target_wght MATERIAL_TARGET_WEIGHT%ROWTYPE;
    
    CURSOR csr_get_pce
    IS
    SELECT bds_pce_factor_from_base_uom
    FROM bds_material_plant_mfanz
    WHERE LTRIM(sap_material_code,'0') = rcd_bom.item_material_code
    AND plant_code = rcd_bom.bom_plant;
    
    
BEGIN
    
   -- GOTO FINISH;
    DELETE FROM MATERIAL_TARGET_WEIGHT;
    OPEN csr_matl;
    LOOP
       FETCH csr_matl INTO rcd_matl;
       EXIT WHEN csr_matl%NOTFOUND;
       var_ratio := 1;
      
       OPEN csr_bom;
       LOOP
           FETCH csr_bom INTO rcd_bom;
           EXIT WHEN csr_bom%NOTFOUND;
           IF rcd_bom.child_rsu_flag = 'X' AND rcd_bom.mars_plant_material_type = cst_plant_material_type THEN
               var_ratio := 1;
               var_pce := 1;
           ELSIF rcd_bom.child_rsu_flag = 'X' THEN
               var_ratio := rcd_bom.item_base_qty/rcd_bom.bom_base_qty;
               /*-*/
               /* check for PCE definition
               /*-*/
               IF rcd_bom.item_base_uom = 'PCE' THEN
                   OPEN csr_get_pce;
                       FETCH csr_get_pce INTO var_pce;
                       IF csr_get_pce%NOTFOUND THEN
                           var_pce := 1;
                       END IF;
                   CLOSE csr_get_pce;
               ELSE
                   var_pce := 1;
               END IF;
           END IF; 
           
           IF rcd_bom.mars_plant_material_type = cst_plant_material_type THEN
               var_value := rcd_bom.item_base_qty / rcd_bom.bom_base_qty / var_pce;
               /*-*/
               /* save data
               /*-*/
               rcd_matl_target_wght.matl_code := rcd_matl.matl_code;
		       rcd_matl_target_wght.plant_code := rcd_matl.plant_code;
		       rcd_matl_target_wght.matl_type := rcd_matl.TYPE;
		       rcd_matl_target_wght.nake_matl_code := rcd_bom.item_material_code;
		       rcd_matl_target_wght.nake_target_wght := ROUND(var_value,6);
		       rcd_matl_target_wght.nake_uom := rcd_bom.item_base_uom;
		       rcd_matl_target_wght.upd_datime := SYSDATE;
               rcd_matl_target_wght.rsu_target_wght :=  ROUND(var_ratio * rcd_matl_target_wght.nake_target_wght,6);
               /* TEMP FIX 5 Nov 2007 */
               IF rcd_matl.matl_code IN ('10044252','10047191') AND rcd_matl.plant_code = 'AU45' THEN
                   rcd_matl_target_wght.rsu_target_wght := ROUND(var_value,6);
               END IF;
               BEGIN
                   INSERT INTO MATERIAL_TARGET_WEIGHT
		               (matl_code,
		               plant_code,
		               matl_type,
		               nake_matl_code,
		               nake_target_wght,
		               nake_uom,
		               upd_datime,
                       rsu_target_wght )
                VALUES (rcd_matl_target_wght.matl_code,
                       rcd_matl_target_wght.plant_code,
                       rcd_matl_target_wght.matl_type,
                       rcd_matl_target_wght.nake_matl_code,
                       rcd_matl_target_wght.nake_target_wght,
                       rcd_matl_target_wght.nake_uom,
                       rcd_matl_target_wght.upd_datime,
                       rcd_matl_target_wght.rsu_target_wght );
               EXCEPTION
                   WHEN DUP_VAL_ON_INDEX THEN
                       UPDATE MATERIAL_TARGET_WEIGHT
                          SET matl_type = rcd_matl_target_wght.matl_type,
                              nake_target_wght = rcd_matl_target_wght.nake_target_wght,
                              nake_uom = rcd_matl_target_wght.nake_uom,
                              upd_datime = rcd_matl_target_wght.upd_datime,
                              rsu_target_wght = rcd_matl_target_wght.rsu_target_wght 
                        WHERE matl_code = rcd_matl_target_wght.matl_code
                          AND plant_code = rcd_matl_target_wght.plant_code
                          AND nake_matl_code = rcd_matl_target_wght.nake_matl_code;
                  
               END;
               /*-*/
               /* add nake record
               /*-*/
               BEGIN
                   INSERT INTO MATERIAL_TARGET_WEIGHT
                          (matl_code,
                          plant_code,
                          matl_type,
                          nake_matl_code,
                          nake_target_wght,
                          nake_uom,
                          upd_datime,
                          rsu_target_wght)
                   VALUES (rcd_matl_target_wght.nake_matl_code,
                          rcd_matl_target_wght.plant_code,
		                  'NAKE',
		                  rcd_matl_target_wght.nake_matl_code,
		                  rcd_matl_target_wght.nake_target_wght,
		                  rcd_matl_target_wght.nake_uom,
		                  rcd_matl_target_wght.upd_datime,
                          rcd_matl_target_wght.rsu_target_wght );
               EXCEPTION
                   WHEN DUP_VAL_ON_INDEX THEN
                       UPDATE MATERIAL_TARGET_WEIGHT
                          SET matl_type = rcd_matl_target_wght.matl_type,
                              nake_target_wght = rcd_matl_target_wght.nake_target_wght,
                              nake_uom = rcd_matl_target_wght.nake_uom,
                              upd_datime = rcd_matl_target_wght.upd_datime,
                              rsu_target_wght = rcd_matl_target_wght.rsu_target_wght 
                        WHERE matl_code = rcd_matl_target_wght.matl_code
                          AND plant_code = rcd_matl_target_wght.plant_code
                          AND  nake_matl_code = rcd_matl_target_wght.nake_matl_code;
                  
               END;  
               var_ratio := 1;   
               EXIT;  -- only get the first nake
           END IF;
           
       END LOOP;
       CLOSE csr_bom;
    END LOOP;
    CLOSE csr_matl;
<<FINISH>>   
 var_ratio := 1; -- temp
EXCEPTION
    WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR(-20000, 'Target_Weight_Create_Test - Nake material code = ' || rcd_matl_target_wght.nake_matl_code || CHR(13)
             || 'Material code = ' || rcd_matl_target_wght.matl_code || CHR(13)
             || 'Planr code = ' || rcd_matl_target_wght.matl_code || CHR(13)
    || 'Oracle error ' || SUBSTR(SQLERRM, 1, 1000));
END Target_Weight_Create;
/


DROP PUBLIC SYNONYM TARGET_WEIGHT_CREATE;

CREATE PUBLIC SYNONYM TARGET_WEIGHT_CREATE FOR MANU_APP.TARGET_WEIGHT_CREATE;


GRANT EXECUTE ON MANU_APP.TARGET_WEIGHT_CREATE TO APPSUPPORT;

GRANT EXECUTE ON MANU_APP.TARGET_WEIGHT_CREATE TO LICS_APP;

