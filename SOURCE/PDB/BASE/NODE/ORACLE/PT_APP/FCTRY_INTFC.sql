CREATE OR REPLACE PACKAGE PT_APP.Fctry_Intfc AS
/******************************************************************************
   NAME:       FCTRY_INTFC
   PURPOSE:    Provide a number of procedures for creating scrap or rework
   RULES:      1       Finished Good - FERT needs a BATCH Code
               2       Quantity cannot be 0
               3       Material_code cannot be null
               4       If proc_order it has to be valid
               5       material_code has to be valid in grd
               6       uom for material and rework has to be equal

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        7-May-2007     Jeff Phillipson       1. Created this package.
   1.1        5-Dec-2007     Jeff Phillipson       added check for UOM == in both materials
******************************************************************************/

/******************************************************************************
   OUTPUT:    result            number 0: success, 1: oracle error, 2: process error
              result_msg        string 2000chars message if above is 1 or 2
   INPUT:     process order     string
              material          string
              qty               number
              batch_code        string
              plant_code        string
              event datime      date
              scrap_rework      string      R = rework; S = scrap    
              reason code       string      4 char as per RESASON_CODES_VW
              rework code       string      reworked material
              rework batch      string      reworked batch code
              rework expiration date date
              rework storage location string 4 chars
******************************************************************************/
  PROCEDURE CREATE_SCRAP_REWORK(o_result OUT NUMBER,
                               o_result_msg OUT VARCHAR2,
                               i_proc_order IN VARCHAR2,
                               i_plt_code IN VARCHAR2 DEFAULT 0,
                               i_matl_code IN VARCHAR2,
                               i_qty IN NUMBER,
                               i_batch_code IN VARCHAR2,
                               i_plant_code IN VARCHAR2,
                               i_event_datime IN DATE,
                               i_scrap_rework IN VARCHAR2,
                               i_reason_code IN VARCHAR2,
                               i_rework_code IN VARCHAR2,
                               i_rework_batch IN VARCHAR2,
                               i_rework_exp_date IN DATE,
                               i_rework_storage_locn IN VARCHAR2,
                               i_bin_code IN VARCHAR2,
                               i_area_in_code IN VARCHAR2,
                               i_area_out_code IN VARCHAR2,
                               i_status_code IN VARCHAR2); 

 /******************************************************************************
 INPUT:       pallet code       sscc code     string
              status            string        values - not known yet
 ******************************************************************************/
 PROCEDURE UPDATE_STATUS(o_result OUT NUMBER,
                        o_result_msg OUT VARCHAR2,
                        i_plt_code IN VARCHAR2,
                        i_status IN VARCHAR2);
                          
END Fctry_Intfc; 
/



CREATE OR REPLACE PACKAGE BODY PT_APP.Fctry_Intfc IS
/******************************************************************************
   NAME:       FCTRY_INTFC
   PURPOSE:    Provide a number of procedures for creating scrap or rework

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

  PROCEDURE CREATE_SCRAP_REWORK(o_result OUT NUMBER,
                               o_result_msg OUT VARCHAR2,
                               i_proc_order IN VARCHAR2,
                               i_plt_code IN VARCHAR2 DEFAULT 0,
                               i_matl_code IN VARCHAR2,
                               i_qty IN NUMBER,
                               i_batch_code IN VARCHAR2,
                               i_plant_code IN VARCHAR2,
                               i_event_datime IN DATE,
                               i_scrap_rework IN VARCHAR2,
                               i_reason_code IN VARCHAR2,
                               i_rework_code IN VARCHAR2,
                               i_rework_batch IN VARCHAR2,
                               i_rework_exp_date IN DATE,
                               i_rework_storage_locn IN VARCHAR2,
                               i_bin_code IN VARCHAR2,
                               i_area_in_code IN VARCHAR2,
                               i_area_out_code IN VARCHAR2,
                               i_status_code IN VARCHAR2)  IS 
                               
      e_process_exception      EXCEPTION;
      e_oracle_exception       EXCEPTION;
     
      var_count                  NUMBER;
      var_count01                NUMBER;
      var_rework_sloc            VARCHAR2(4);
      var_rework_expiry          DATE;
      
      rcd_scrap_rework scrap_rework%ROWTYPE;
      
      /*-*/
      /* Cursor definitions
      /*-*/
      CURSOR csr_proc_order
      IS
      SELECT t01.plant_code, 
             t01.uom,
             LTRIM(t01.material,'0') material,
             t01.storage_locn
        FROM bds_recipe_header t01
       WHERE LTRIM(t01.proc_order,'0') = i_proc_order
         AND LTRIM(t01.material,'0') = i_matl_code
       UNION ALL
      SELECT t01.plant_code, 
             t02.material_uom uom, 
             LTRIM(t02.material_code,'0') AS material,
             t03.issue_storage_location
        FROM bds_recipe_header t01,
             bds_recipe_bom t02,
             bds_material_plant_mfanz t03
       WHERE t01.proc_order = t02.proc_order
         AND t02.material_code = t03.sap_material_code(+)
         AND t02.plant_code = t03.plant_code(+)
         AND LTRIM(t01.proc_order,'0') = i_proc_order
         AND LTRIM(t02.material_code,'0') = i_matl_code;
      rcd_proc_order csr_proc_order%ROWTYPE;
     
      CURSOR csr_reason_code
      IS
      SELECT cost_centre
        FROM reason_codes
       WHERE reason_code = i_reason_code;
      rcd_reason_code csr_reason_code%ROWTYPE;
      
  BEGIN
    o_result := constants.SUCCESS;
    o_result_msg := '';
    
    /*-*/
    /* validate data 
    /*-*/
    /* check for valid proc order */
    IF i_proc_order IS NOT NULL THEN
        SELECT COUNT(*) INTO var_count
         FROM cntl_rec 
        WHERE LTRIM(proc_order,'0') = LTRIM(i_proc_order,'0');
         -- AND teco_stat = 'NO';
        IF var_count = 0 THEN
            o_result_msg := 'Process order is not valid: ' || i_proc_order;
            o_result := constants.ERROR;
            RAISE e_process_exception;
        END IF;
    END IF;
    /* check validity of qty */ 
    IF i_Qty = 0 OR i_qty IS NULL THEN
        o_result_msg := 'Quantity cannot be Null or zero.';
        o_result := constants.ERROR;
        RAISE e_process_exception;
    END IF;
    /* check material code */
    /*  material can be a substitution so it doesnt have to be in the process order bom */
    IF i_matl_code IS NULL THEN
        o_result_msg := 'Material Code cannot be Null.';
        o_result := constants.ERROR;
        RAISE e_process_exception;
    ELSE
        /*-*/
        /* check the matl is in the PO or the header of the po
        /*-*/
        SELECT SUM(COUNT) INTO var_count
          FROM (SELECT COUNT(*) AS COUNT FROM bds_recipe_header 
                 WHERE LTRIM(proc_order,'0') = i_proc_order
                   AND LTRIM(material,'0') = i_matl_code
                 UNION ALL
                SELECT COUNT(*) AS COUNT  FROM bds_recipe_bom
                 WHERE LTRIM(proc_order,'0') = i_proc_order
                   AND LTRIM(material_code,'0') = i_matl_code);
        IF var_count = 0 THEN
            o_result_msg := 'Material Code is not part of the Processder.' || i_matl_code;
            o_result := constants.ERROR;
        END IF;
    END IF;
    /* check reason code is valid */
    SELECT COUNT(*) INTO var_count FROM reason_codes WHERE reason_code = i_reason_code;
    IF var_count = 0 THEN
        o_result_msg := 'Reason Code is incorrect: ' || i_reason_code;
        o_result := constants.ERROR;
        RAISE e_process_exception;
    END IF;
    /* batch code needed if material is FERT */
    SELECT COUNT(*) INTO var_count FROM bds_material_plant_mfanz WHERE material_type = 'FERT'
       AND LTRIM(sap_material_code,'0') = LTRIM(i_matl_code,'0');
    IF var_count > 0 THEN -- Finished Good
        /*-*/
        /* check batch code
        /*-*/
        IF i_batch_code IS NULL OR i_batch_code = '' THEN
            o_result_msg := 'Batch code required for a Finished Good: ' || i_matl_code;
            o_result := constants.ERROR;
            RAISE e_process_exception;
        ELSE
            SELECT COUNT(*) INTO var_count01
              FROM batch_date
             WHERE calendar_date = TRUNC(SYSDATE)
               AND atlas_batch = SUBSTR(i_batch_code,1,4);
            IF var_count01 = 0 THEN
                 o_result_msg := 'Batch code not valid: ' || i_batch_code;
                 o_result := constants.ERROR;
                 RAISE e_process_exception;
            END IF;
        END IF;
        /*-*/
        /* check rework batch code
        /*-*/
        IF i_scrap_rework = 'R' THEN
            IF i_rework_batch IS NULL OR i_rework_batch = '' THEN
                o_result_msg := 'Rework Batch code required for a Finished Good: ' || i_matl_code ;
                o_result := constants.ERROR;
                RAISE e_process_exception;
            END IF;
        END IF;
    END IF;
    
    /*-*/
    /* check uom's are equal
    /*-*/
    IF i_scrap_rework = 'R' THEN
        SELECT COUNT (*) INTO var_count
          FROM (SELECT DISTINCT base_uom  
                  FROM bds_material_plant_mfanz
                 WHERE (LTRIM(sap_material_code,'0') = LTRIM(i_rework_code,'0')
                        OR LTRIM(sap_material_code,'0') = LTRIM(i_matl_code,'0'))
                   AND plant_code = i_plant_code);
        IF var_count =2 THEN
            o_result_msg := 'Rework code and Material code have to have the same UOM. Rework code= ' || i_rework_code  || ' Material code= ' || i_matl_code ;
            o_result := constants.ERROR;
            RAISE e_process_exception;
        END IF;
    END IF;
    
    /*-*/
    /* validation complete
    /*-*/
    
    
    /*-*/
    /* get extra proc order data required for saving to table
    /*-*/
    IF i_proc_order IS NOT NULL THEN
        OPEN csr_proc_order;
            FETCH csr_proc_order INTO rcd_proc_order;
            IF csr_proc_order%NOTFOUND THEN
                o_result_msg := 'Material code is not valid.';
                o_result := constants.ERROR;
                RAISE e_process_exception;
            ELSE
                rcd_scrap_rework.uom := rcd_proc_order.uom;
                rcd_scrap_rework.storage_locn := rcd_proc_order.storage_locn;
            END IF;
        CLOSE csr_proc_order;
    ELSE
       /* get data from material table */
       BEGIN
       SELECT DECODE(base_uom,'KGM','KG',base_uom), 
              DECODE(issue_storage_location,NULL,'0020',issue_storage_location) 
         INTO rcd_scrap_rework.uom, rcd_scrap_rework.storage_locn
         FROM bds_material_plant_mfanz
        WHERE LTRIM(sap_material_code,'0') = LTRIM(i_matl_code,'0')
          AND plant_code = i_plant_code;
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
               rcd_scrap_rework.uom := 'ERR';
               rcd_scrap_rework.storage_locn := '0020';
           WHEN OTHERS THEN
               o_result_msg := 'Material/plant code is not valid.';
               o_result := constants.ERROR;
               RAISE e_process_exception;
       END;
    END IF;
    /*-*/
    /* get cost centre data
    /*-*/
    OPEN csr_reason_code;
        FETCH csr_reason_code INTO rcd_reason_code;
        IF csr_reason_code%NOTFOUND THEN
            o_result_msg := 'Storage Location and or UOM not found in GDR material table.';
            o_result := constants.ERROR;
            RAISE e_process_exception;
        END IF;
    CLOSE csr_reason_code;
    
    /*-*/
    /* get rework expiry date and sloc
    /*-*/
    IF i_rework_code IS NOT NULL THEN
        BEGIN
            SELECT issue_storage_location,
                   TRUNC(SYSDATE) + TO_NUMBER(max_storage_prd)  
              INTO var_rework_sloc, var_rework_expiry
              FROM bds_material_plant_mfanz
             WHERE LTRIM(sap_material_code,'0') = i_rework_code
               AND plant_code = i_plant_code;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                var_rework_sloc := '0020';
                var_rework_expiry := TRUNC(SYSDATE);
        END;
    END IF;
   
    /*-*/
 /* save data to table 
 /*-*/
 BEGIN
        
     SELECT SCRAP_REWORK_ID_SEQ.NEXTVAL INTO rcd_scrap_rework.scrap_rework_id FROM dual;
        rcd_scrap_rework.proc_order := i_proc_order;
        rcd_scrap_rework.matl_code := i_matl_code;
        rcd_scrap_rework.qty := i_qty;
        IF rcd_scrap_rework.storage_locn IS NULL OR rcd_scrap_rework.storage_locn = ''  THEN
           rcd_scrap_rework.storage_locn := '0020';
        END IF;
        IF rcd_scrap_rework.uom IS NULL OR rcd_scrap_rework.uom = '' THEN
            rcd_scrap_rework.uom := 'KG';
        END IF;
        rcd_scrap_rework.plant_code := trim(i_plant_code);
        rcd_scrap_rework.event_datime := i_event_datime;
        rcd_scrap_rework.scrap_rework_code := i_scrap_rework;
        rcd_scrap_rework.reason_code := i_reason_code;
        rcd_scrap_rework.sent_flag := '';
        rcd_scrap_rework.rework_code := i_rework_code;
        rcd_scrap_rework.rework_batch_code := i_rework_batch;                                                                                                                                                                                                                                                                                                                                                                                                                         
        rcd_scrap_rework.rework_exp_date := var_rework_expiry;
        rcd_scrap_rework.rework_sloc := var_rework_sloc; 
        rcd_scrap_rework.cost_centre := rcd_reason_code.cost_centre;
        rcd_scrap_rework.bin_code := i_bin_code;
        rcd_scrap_rework.plt_code := i_plt_code;
        rcd_scrap_rework.area_in_code := i_area_in_code;
        rcd_scrap_rework.area_out_code := i_area_out_code;
        rcd_scrap_rework.status_code := i_status_code;
        rcd_scrap_rework.batch_code := trim(i_batch_code);
        
     INSERT INTO SCRAP_REWORK
               (scrap_rework_id,
               proc_order,
               matl_code,
               qty,
               uom,
               storage_locn,
               plant_code,
               event_datime,
               scrap_rework_code,
               reason_code,
               sent_flag,
               rework_code,
               rework_batch_code,
               rework_exp_date,
               rework_sloc,
               cost_centre,
               bin_code,
               plt_code,
               area_in_code,
               area_out_code,
               status_code,
               batch_code)
  VALUES (rcd_scrap_rework.scrap_rework_id,
      rcd_scrap_rework.proc_order,
      rcd_scrap_rework.matl_code,
      rcd_scrap_rework.qty,
               rcd_scrap_rework.uom,
               rcd_scrap_rework.storage_locn,
               rcd_scrap_rework.plant_code,
               rcd_scrap_rework.event_datime,
               rcd_scrap_rework.scrap_rework_code,
               rcd_scrap_rework.reason_code,
               rcd_scrap_rework.sent_flag,
               NVL(rcd_scrap_rework.rework_code,''),
               NVL(rcd_scrap_rework.rework_batch_code,''),
               NVL(rcd_scrap_rework.rework_exp_date,''),
               NVL(rcd_scrap_rework.rework_sloc,''),
               rcd_scrap_rework.cost_centre,
               NVL(rcd_scrap_rework.bin_code,''),
               NVL(rcd_scrap_rework.plt_code,''),
               NVL(rcd_scrap_rework.area_in_code,''),
               NVL(rcd_scrap_rework.area_out_code,''),
               NVL(rcd_scrap_rework.status_code,''),
               NVL(rcd_scrap_rework.batch_code,'')); 
     COMMIT;
   
  EXCEPTION
      WHEN OTHERS THEN
            ROLLBACK;
            o_result_msg := 'ERROR OCCURED saving data to SCRAP_REWORK table. '||SUBSTR(SQLERRM(SQLCODE),0,1900);
            RAISE e_oracle_exception;
  END;
 
  EXCEPTION
      WHEN e_process_exception THEN
           o_result := constants.ERROR;
     ROLLBACK;
     WHEN e_oracle_exception THEN
           ROLLBACK;
           o_result := constants.FAILURE;
       WHEN OTHERS THEN
           o_result := constants.FAILURE;
           ROLLBACK;
           o_result_msg := 'ERROR OCCURED in CREATE_REWORK_SCRAP: ' || CHR(13) 
                        ||SQLCODE || '-' || SUBSTR(SQLERRM,1,1900);
                        
  END CREATE_SCRAP_REWORK;

  /******************************************************************************
 INPUT:       pallet code       sscc code     string
              status            string        values - not known yet
 ******************************************************************************/
 PROCEDURE UPDATE_STATUS(o_result OUT NUMBER,
                        o_result_msg OUT VARCHAR2,
                        i_plt_code IN VARCHAR2,
                        i_status IN VARCHAR2) IS
                        
       e_process_exception      EXCEPTION;
    e_oracle_exception       EXCEPTION;
       var_count                NUMBER;
      
  BEGIN
      o_result := constants.SUCCESS;
      o_result_msg := '';
      
      SELECT COUNT(*) INTO var_count
        FROM scrap_rework
       WHERE plt_code = i_plt_code;
      IF var_count = 1 THEN
          UPDATE scrap_rework
             SET status_code = i_status
           WHERE plt_code = i_plt_code;
      ELSE
          o_result_msg := 'SSCC code does not exist.';
          o_result := constants.ERROR;
          RAISE e_process_exception;
      END IF;
      COMMIT;
  
  EXCEPTION
      WHEN e_process_exception THEN
           o_result := constants.ERROR;
     ROLLBACK;
   WHEN e_oracle_exception THEN
           ROLLBACK;
           o_result := constants.FAILURE;
      WHEN OTHERS THEN
           o_result := constants.FAILURE;
           ROLLBACK;
           o_result_msg := 'ERROR OCCURED in UPDATE_STATUS: ' || CHR(13) 
                        ||SQLCODE || '-' || SUBSTR(SQLERRM,1,1900);
  END UPDATE_STATUS;
  
  
END Fctry_Intfc; 
/

grant execute on pt_app.Fctry_Intfc to appsupport;
create public synonym Fctry_Intfc for  pt_app.Fctry_Intfc;