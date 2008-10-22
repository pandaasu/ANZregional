DROP PACKAGE BDS_APP.BDS_BOM_PPLAN;

CREATE OR REPLACE PACKAGE BDS_APP.Bds_Bom_Pplan AS
/******************************************************************************
   NAME:       BDS_BOM_PPLAN
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        13/11/2007      Jeff Phillipson       1. Created this package.
******************************************************************************/

     FUNCTION get_component_qty(par_eff_date IN DATE, par_material_code IN VARCHAR2, par_plant_code IN VARCHAR2) RETURN bds_bom_component_qty pipelined;


END Bds_Bom_Pplan;
/


DROP PACKAGE BODY BDS_APP.BDS_BOM_PPLAN;

CREATE OR REPLACE PACKAGE BODY BDS_APP.Bds_Bom_Pplan AS
/******************************************************************************
   NAME:       BDS_BOM_PPLAN
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        13/11/2007  Jeff Phillipson  1. Created this package body.
                                           Commented out BOM_plant = var_plant_code
   1.1        17/12/2007  Bronwen Feenstra Removed BOM_plant from partition
                                           Added BOM_number to partition
                                           commented out BOM_plant line from 
                                           start with clause                            
******************************************************************************/

    /*-*/
    /* variables
    /*-*/
    o_result NUMBER;
    o_result_msg VARCHAR2(2000);
  
    /*-*/
    /* Private exceptions
    /*-*/
    application_exception EXCEPTION;
    PRAGMA EXCEPTION_INIT(application_exception, -20000);

   /*********************************************************/
   /* This procedure performs the get component quantity routine */
   /*********************************************************/
   FUNCTION get_component_qty(par_eff_date IN DATE, par_material_code IN VARCHAR2, par_plant_code IN VARCHAR2) RETURN bds_bom_component_qty pipelined IS

      /*-*/
      /* Declare Variables
      /*-*/
      var_eff_date bds_bom_all.bom_eff_from_date%TYPE;
      var_material_code bds_bom_all.bom_material_code%TYPE;
      var_plant_code bds_bom_all.bom_plant%TYPE;
      var_scale bds_bom_all.bom_base_qty%TYPE;
      var_bom_qty bds_bom_all.bom_base_qty%TYPE;
      var_count NUMBER DEFAULT 0;
      var_assembly_scrap_percntg bds_material_plant_mfanz.assembly_scrap_percntg%TYPE;
      var_scrap_hierarchy_level NUMBER;
      
      TYPE id_table_object IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      id_table id_table_object;
      
      /*-*/
      /* Cursor definitions
      /*-*/
      CURSOR csr_bom_hierarchy IS
      SELECT t01.*,
       CASE
           WHEN t02.assembly_scrap_percntg IS NULL THEN 0
           WHEN t02.assembly_scrap_percntg = '' THEN 0
           WHEN t02.assembly_scrap_percntg = 0 THEN 0
           ELSE t02.assembly_scrap_percntg
       END assembly_scrap_percntg,
       CASE
           WHEN t01.item_base_uom = 'PCE' THEN t02.bds_pce_factor_from_base_uom
           ELSE 1
       END factor_from_base_uom    
      FROM (SELECT ROWNUM AS hierarchy_rownum,
                   LEVEL AS hierarchy_level,
                   t01.*, 
           CONNECT_BY_ISCYCLE AS CYCLE 
             FROM (SELECT t01.bom_material_code,
                          t01.bom_alternative,
                          t01.bom_plant,
                          t01.bom_number,
                          t01.bom_msg_function,
                          t01.bom_usage,
                          t01.bom_eff_from_date,
                          t01.bom_eff_to_date,
                          t01.bom_base_qty,
                          t01.bom_base_uom,
                          t01.bom_status,
                          t01.item_sequence,
                          t01.item_number,
                          t01.item_msg_function,
                          t01.item_material_code,
                          t01.item_category,
                          t01.item_base_qty,
                          t01.item_base_uom,
                          t01.item_eff_from_date,
                          t01.item_eff_to_date
                     FROM (SELECT t01.*,
                                  rank() OVER (PARTITION BY t01.bom_material_code
--                                                            t01.bom_plant
                                                   ORDER BY t01.bom_eff_from_date DESC,
                                                            t01.bom_alternative DESC,
                                                            t01.bom_number DESC) AS rnkseq
                             FROM bds_bom_all t01
                            WHERE TRUNC(t01.bom_eff_from_date) <= TRUNC(var_eff_date)) t01
                    WHERE t01.rnkseq = 1
                      AND t01.item_sequence != 0
                      --AND t01.bom_plant = var_plant_code
                      ) t01
            START WITH t01.bom_material_code = var_material_code
--                   AND t01.bom_plant = var_plant_code
            CONNECT BY NOCYCLE PRIOR t01.item_material_code = t01.bom_material_code
            ORDER SIBLINGS BY TO_NUMBER(t01.item_number)) t01,
           (SELECT assembly_scrap_percntg, sap_material_code, plant_code,
                   bds_pce_factor_from_base_uom 
              FROM bds_material_plant_mfanz) t02
      WHERE t01.item_material_code = LTRIM(t02.sap_material_code(+),'0')
        AND t01.bom_plant = t02.plant_code(+)
      ORDER BY 1;
          
      rcd_bom_hierarchy csr_bom_hierarchy%ROWTYPE;

    
      
   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Initialise variables
      /*-*/
      var_eff_date := par_eff_date;
      IF par_eff_date IS NULL THEN
         var_eff_date := SYSDATE;
      END IF;
      var_material_code := par_material_code;
      IF par_material_code IS NULL THEN
         RAISE_APPLICATION_ERROR(-20000, 'Hierarchy material code must be supplied');
      END IF;
      var_plant_code := par_plant_code;
      IF par_plant_code IS NULL THEN
         RAISE_APPLICATION_ERROR(-20000, 'Hierarchy plant code must be supplied');
      END IF;
      var_assembly_scrap_percntg := 0;
      var_scrap_hierarchy_level := 0;
      
      id_table.DELETE;
      
      /*-*/
      /* Retrieve the BOM header information and pipe to output
      /*-*/
      OPEN csr_bom_hierarchy;
      LOOP
         FETCH csr_bom_hierarchy INTO rcd_bom_hierarchy;
         IF csr_bom_hierarchy%NOTFOUND THEN
            EXIT;
         END IF;
         
         IF var_count = 0 THEN
             var_bom_qty := rcd_bom_hierarchy.bom_base_qty;
             var_count := 1;
         END IF;
         
         /*-*/
         /* save each levels bo qty
         /*-*/
         id_table(rcd_bom_hierarchy.hierarchy_level) :=
              (rcd_bom_hierarchy.item_base_qty/rcd_bom_hierarchy.factor_from_base_uom)
               /rcd_bom_hierarchy.bom_base_qty;
         /*-*/
         /* convert bom ratio
         /*-*/
         var_scale := 1;
         FOR i IN 1 .. rcd_bom_hierarchy.hierarchy_level
             LOOP
             var_scale :=  var_scale * id_table(i);
         END LOOP;
         --var_scale := var_scale; --* var_bom_qty;
         /*-*/
         /* add losses to values
         /*-*/
         /* 2-Nov-2007 JP added '<' to the next statement to reset scrap if the hierarchy level drops */
         IF var_scrap_hierarchy_level <= rcd_bom_hierarchy.hierarchy_level THEN
             var_assembly_scrap_percntg := 0;
         END IF;
         IF rcd_bom_hierarchy.assembly_scrap_percntg <> 0 THEN
             var_assembly_scrap_percntg := rcd_bom_hierarchy.assembly_scrap_percntg;
             var_scrap_hierarchy_level := rcd_bom_hierarchy.hierarchy_level;
         END IF;
         var_scale := var_scale * (1 +  var_assembly_scrap_percntg/100);
         IF rcd_bom_hierarchy.item_material_code = '1104205' OR rcd_bom_hierarchy.item_material_code = '1104209' THEN
             DBMS_OUTPUT.PUT_LINE('Scale:' || var_scale || '-' || rcd_bom_hierarchy.hierarchy_level);
         END IF;
         /*-*/
         /* Pipe the output to the consumer
         /*-*/
         pipe ROW(bds_bom_component_qty_object(rcd_bom_hierarchy.hierarchy_rownum,
                                           rcd_bom_hierarchy.hierarchy_level,
                                           rcd_bom_hierarchy.bom_material_code,
                                           rcd_bom_hierarchy.bom_alternative,
                                           rcd_bom_hierarchy.bom_plant,
                                           rcd_bom_hierarchy.bom_number,
                                           rcd_bom_hierarchy.bom_msg_function,
                                           rcd_bom_hierarchy.bom_usage,
                                           rcd_bom_hierarchy.bom_eff_from_date,
                                           rcd_bom_hierarchy.bom_eff_to_date,
                                           rcd_bom_hierarchy.bom_base_qty,
                                           rcd_bom_hierarchy.bom_base_uom,
                                           rcd_bom_hierarchy.bom_status,
                                           rcd_bom_hierarchy.item_sequence,
                                           rcd_bom_hierarchy.item_number,
                                           rcd_bom_hierarchy.item_msg_function,
                                           rcd_bom_hierarchy.item_material_code,
                                           rcd_bom_hierarchy.item_category,
                                           rcd_bom_hierarchy.item_base_qty,
                                           rcd_bom_hierarchy.item_base_uom,
                                           rcd_bom_hierarchy.item_eff_from_date,
                                           rcd_bom_hierarchy.item_eff_to_date,
                                           ROUND(var_scale,4)));

      END LOOP;
      CLOSE csr_bom_hierarchy;

      /*-*/
      /* Return
      /*-*/  
      RETURN;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   EXCEPTION

      /**/
      /* Exception trap
      /**/
      WHEN OTHERS THEN

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         RAISE_APPLICATION_ERROR(-20000, 'BDS_BOM - GET_COMPONENT_QTY (' || par_eff_date || ',' || NVL(par_material_code,'NULL') || ',' || NVL(par_plant_code,'NULL') || ') - ' || SUBSTR(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   END get_component_qty;

END Bds_Bom_Pplan;
/


DROP PUBLIC SYNONYM BDS_BOM_PPLAN;

CREATE PUBLIC SYNONYM BDS_BOM_PPLAN FOR BDS_APP.BDS_BOM_PPLAN;


GRANT EXECUTE ON BDS_APP.BDS_BOM_PPLAN TO APPSUPPORT;

GRANT EXECUTE ON BDS_APP.BDS_BOM_PPLAN TO PPLAN_APP;

