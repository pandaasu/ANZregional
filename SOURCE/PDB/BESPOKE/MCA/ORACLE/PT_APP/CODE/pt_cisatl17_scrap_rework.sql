DROP PACKAGE PT_APP.PT_CISATL17_SCRAP_REWORK;

CREATE OR REPLACE PACKAGE PT_APP.Pt_Cisatl17_Scrap_Rework AS
/******************************************************************************
   NAME:       SCRAP_REWORK_SEND
   PURPOSE:    This procedure will be called from an Oracle job running
               every 30mins typical
               It will collect all scrap or rework records and
               send grouped by proc-order and material
   REVISIONS:
   Ver        Date          Author             Description
   ---------  ----------    ---------------    ------------------------------------
   1.0        18-05-2007    Jeff Phillipson    1. Created this package.
   1.1        21-Nov-2007   Jeff Phillipson    Added proc order filter to sending material count
   1.2        20-Dec-2007   Jeff Phillipson    Added purge of INTERFACE_ERROR tableafter 4 days
   1.3        20-Dec-2007   Jeff Phillipson    Changed material for a GR reversal to POs matl code
******************************************************************************/

  PROCEDURE EXECUTE;

END Pt_Cisatl17_Scrap_Rework;
/


DROP PACKAGE BODY PT_APP.PT_CISATL17_SCRAP_REWORK;

CREATE OR REPLACE PACKAGE BODY PT_APP.Pt_Cisatl17_Scrap_Rework AS
/******************************************************************************
   NAME:       SCRAP_REWORK_SEND
   PURPOSE:    This procedure will be called from an Oracle job running
               every 30mins typical
               It will collect all scrap or rework records and
               send grouped by proc-order and material

******************************************************************************/
	/*-*/
	/* Private exceptions
	/*-*/
	application_exception EXCEPTION;
	PRAGMA EXCEPTION_INIT(application_exception, -20000);

  PROCEDURE EXECUTE IS
    
      /*-*/
	  /* these values defines the interface and file constants 
	  /*-*/
      cst_file_interface CONSTANT VARCHAR2(20) := 'PDBICS17';
	  cst_file_name	     CONSTANT VARCHAR2(20) := 'CISATL17';
      cst_extension      CONSTANT VARCHAR2(2) := '.3';
      cst_message_type   CONSTANT VARCHAR2(10) := 'Z_PI8';
      cst_max_files      CONSTANT NUMBER := 100;
      
      var_timestamp             VARCHAR2(500);
      var_success               NUMBER;
      var_db_value              VARCHAR2(4);
      var_count                 NUMBER;
      var_stockable             NUMBER;
      var_scale                 NUMBER;
      var_result                NUMBER;
      var_result_msg            VARCHAR2(2000);
      
      
      CURSOR csr_scrap_rework 
      IS
      SELECT * FROM scrap_rework
       WHERE sent_flag IS NULL AND ROWNUM < cst_max_files + 1
       ORDER BY event_datime;
       
      rcd_scrap_rework csr_scrap_rework%ROWTYPE;
      
      
      CURSOR csr_db
      IS
      SELECT CASE
                 WHEN db IN ('AP0126D', 'DB0719P') THEN '.5'
                 WHEN db IN ('AP0132D', 'DB0720P') THEN '.6'
                 WHEN db IN ('AP0068T', 'AP0065P') THEN '.2'
                 WHEN db IN ('MFA002', 'MFA005') THEN '.1'
                 WHEN db IN ('WOD023', 'WOD013') THEN '.3'
                 WHEN db IN ('BTH005', 'BTH001') THEN '.4'
            END VALUE 
      FROM (SELECT UPPER(sys_context('USERENV', 'DB_NAME')) AS  db
              FROM dual); 
      
      CURSOR csr_gr
      IS
      SELECT * FROM scrap_rework_reversal
      WHERE sent_flag IS NULL;
      
      rcd_gr csr_gr%ROWTYPE;
                  
  BEGIN 
         
      var_timestamp := TO_CHAR(SYSDATE,'yyyymmddhh24miss') ||  'SR' || rcd_scrap_rework.plant_code || '.3';	
      
      OPEN csr_db;
          FETCH csr_db INTO var_db_value;
          IF csr_db%NOTFOUND THEN
              var_db_value := '.1';
          END IF;
      CLOSE csr_db;
      
      OPEN csr_scrap_rework;
      LOOP
         FETCH csr_scrap_rework INTO rcd_scrap_rework;
         EXIT WHEN csr_scrap_rework%NOTFOUND;
         IF NOT lics_outbound_loader.is_created THEN
             var_success := lics_outbound_loader.create_interface(cst_file_interface  || var_db_value, cst_file_name || '_' ||  var_timestamp || cst_extension, cst_file_name || cst_extension);
         END IF; 
         
         /*-*/
         /* determine if material code is stockable */
         /*-*/
         SELECT COUNT(*) INTO var_stockable
           FROM bds_material_plant_mfanz
          WHERE LTRIM(sap_material_code,'0') = rcd_scrap_rework.matl_code
            AND plant_code = rcd_scrap_rework.plant_code
            AND procurement_type || special_procurement_type <> 'E50';
  
         
         lics_outbound_loader.append_data('HDR000000000000000001'
                                       ||RPAD(TRIM(rcd_scrap_rework.PLANT_CODE),4,' ')
                                       ||RPAD(cst_MESSAGE_TYPE,8,' ')
                                       ||RPAD(' ',32,' ')
								   	   ||TRIM(' '));  -- test flag    
           
         IF rcd_scrap_rework.proc_order IS NOT NULL AND var_stockable = 0 THEN            
             lics_outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('PPPI_PROCESS_ORDER',30,' ')
                                           ||RPAD(LPAD(rcd_scrap_rework.proc_order,12,'0'),30,' ')
                                           ||'CHAR');
         END IF; 
                                        
         lics_outbound_loader.append_data('DET000000000000000001'
                                       ||RPAD('PPPI_EVENT_DATE',30,' ')
                                       ||NVL(RPAD(TO_CHAR(rcd_scrap_rework.event_datime, 'YYYYMMDD'),30,' '),'0')
                                       ||'DATE');   
         lics_outbound_loader.append_data('DET000000000000000001'
                                       ||RPAD('PPPI_EVENT_TIME',30,' ')
                                       ||NVL(RPAD(TO_CHAR(rcd_scrap_rework.event_datime, 'HH24MISS'),30,' '),'0')
                                       ||'TIME');
                                       
         
         lics_outbound_loader.append_data('DET000000000000000001'
                                       ||RPAD('PPPI_MATERIAL',30,' ')
                                       ||RPAD(LPAD(TRIM(rcd_scrap_rework.matl_code),18,'0'),30,' ')
                                       ||'CHAR'); 
        
         
         lics_outbound_loader.append_data('DET000000000000000001'
                                       ||RPAD('PPPI_MATERIAL_QUANTITY',30,' ')
                                       ||RPAD(NVL(TO_CHAR(rcd_scrap_rework.qty),'0'),30,' ')
                                       ||'NUM');
         lics_outbound_loader.append_data('DET000000000000000001'
                                       ||RPAD('PPPI_UNIT_OF_MEASURE',30,' ')
                                       ||RPAD(TRIM(rcd_scrap_rework.uom),30,' ')
                                       ||'CHAR');
         lics_outbound_loader.append_data('DET000000000000000001'
                                       ||RPAD('PPPI_STORAGE_LOCATION',30,' ')
                                       ||RPAD(LPAD(rcd_scrap_rework.storage_locn,4,'0'),30,' ')
                                       ||'CHAR');
         lics_outbound_loader.append_data('DET000000000000000001'
                                       ||RPAD('ZPPPI_PLANT',30,' ')
                                       ||RPAD(TRIM(rcd_scrap_rework.plant_code),30,' ')
                                       ||'CHAR');
         lics_outbound_loader.append_data('DET000000000000000001'
                                       ||RPAD('Z_SNR_REASON_CODE',30,' ')
                                       ||RPAD(LPAD(rcd_scrap_rework.reason_code,4,'0'),30,' ')
                                       ||'CHAR'); 
         IF (rcd_scrap_rework.proc_order IS NULL OR var_stockable = 1)  THEN                            
             lics_outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('ZPPPI_COSTCENTER',30,' ')
                                           ||RPAD(rcd_scrap_rework.cost_centre,30,' ')
                                           ||'CHAR');  
         END IF;                                                           
         lics_outbound_loader.append_data('DET000000000000000001'
                                       ||RPAD('Z_SNR_RW_INDICATOR',30,' ')
                                       ||RPAD(TRIM(rcd_scrap_rework.scrap_rework_code),30,' ')
                                       ||'CHAR'); 
                              
         IF LENGTH(LTRIM(rcd_scrap_rework.matl_code,'0')) = 8 THEN
             lics_outbound_loader.append_data('DET000000000000000001'
                                            ||RPAD('PPPI_BATCH',30,' ')
                                            ||RPAD(rcd_scrap_rework.batch_code,30,' ')
                                            ||'CHAR');
         END IF;
                                    
         IF rcd_scrap_rework.scrap_rework_code = 'R' THEN 
             IF rcd_scrap_rework.rework_code IS NOT NULL THEN
                 lics_outbound_loader.append_data('DET000000000000000001'
                                               ||RPAD('Z_SNR_REWORK',30,' ')
                                               ||RPAD(LPAD(rcd_scrap_rework.rework_code,18,'0'),30,' ')
                                               ||'CHAR'); 
             END IF; 
             IF rcd_scrap_rework.rework_exp_date IS NOT NULL THEN
                 lics_outbound_loader.append_data('DET000000000000000001'
                                               ||RPAD('Z_SNR_REWORK_EXPDATE',30,' ')
                                               ||RPAD(TO_CHAR(rcd_scrap_rework.rework_exp_date,'YYYYMMDD'),30,' ')
                                               ||'DATE');  
             END IF;    
             IF rcd_scrap_rework.rework_sloc IS NOT NULL THEN
                 lics_outbound_loader.append_data('DET000000000000000001'
                                               ||RPAD('Z_SNR_REWORK_SLOC',30,' ')
                                               ||RPAD(LPAD(rcd_scrap_rework.rework_sloc,4,'0'),30,' ')
                                               ||'CHAR'); 
             END IF; 
                                  
         END IF;                   
    	     
         /*-*/
         /* update sent flag
         /*-*/
         BEGIN
             SELECT * INTO rcd_scrap_rework
               FROM scrap_rework 
              WHERE scrap_rework_id = rcd_scrap_rework.scrap_rework_id
                FOR UPDATE NOWAIT;
             UPDATE scrap_rework
                SET sent_flag = 'Y'
              WHERE scrap_rework_id = rcd_scrap_rework.scrap_rework_id;
         EXCEPTION
             WHEN OTHERS THEN
                 IF NOT lics_logging.is_created THEN
                     lics_logging.start_log('PT_CISATL17_Scrap_Rework.execute','Send file');
                 END IF;
                 lics_logging.write_log('Failed to update scrap_rework table - date: ' || ' Material code ' || rcd_scrap_rework.matl_code);
         END;
         
         /*-*/
         /* check if a reversal of this material has to be sent to Atlas
         /* not stockable
         /*-*/
         IF var_stockable = 0  THEN
	         /*-*/
	         /* check if this is a Choc addition component */
	         /*-*/
             var_scale := Rework_Matl_Scale(var_result, var_result_msg, rcd_scrap_rework.proc_order, rcd_scrap_rework.matl_code);
	         IF var_scale > 0 AND var_result = 0 THEN
                 
	             rcd_scrap_rework.qty := rcd_scrap_rework.qty / var_scale;
	             
                 begin
                     select material, storage_locn into rcd_scrap_rework.matl_code, rcd_scrap_rework.storage_locn
                      from bds_recipe_header
                     where ltrim(proc_order,'0') = ltrim(rcd_scrap_rework.proc_order,'0');
                 exception
                     when others then
                         rcd_scrap_rework.matl_code := rcd_scrap_rework.matl_code;
                 end;
                 
                 BEGIN
                     INSERT INTO scrap_rework_reversal
                            (scrap_rework_id,
                            proc_order,
                            matl_code,
                            qty,
                            uom,
                            event_datime,
                            sent_flag,
                            message_type,
                            sender_name,
                            storage_locn,
                            plant_code)
                     VALUES (rcd_scrap_rework.scrap_rework_id,
                            rcd_scrap_rework.proc_order,
                            rcd_scrap_rework.matl_code,
                            ROUND(rcd_scrap_rework.qty,1),
                            rcd_scrap_rework.uom,
                            SYSDATE,
                            NULL,
                            'Z_PI2',
                            'REWORK',
                            rcd_scrap_rework.storage_locn,
                            rcd_scrap_rework.plant_code);
                 EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                         UPDATE scrap_rework_reversal
                            SET proc_order = rcd_scrap_rework.proc_order,
                                matl_code = rcd_scrap_rework.matl_code,
                                qty = ROUND(rcd_scrap_rework.qty,1),
                                uom = rcd_scrap_rework.uom,
                                storage_locn = rcd_scrap_rework.storage_locn    
                          WHERE scrap_rework_id = rcd_scrap_rework.scrap_rework_id;
                 END;
             END IF;
         END IF;
         
      END LOOP;
      CLOSE csr_scrap_rework;
          
      IF lics_outbound_loader.is_created THEN
          lics_outbound_loader.finalise_interface();
      END IF;
      IF lics_logging.is_created THEN
          lics_logging.end_log;
      END IF;
      COMMIT;
      
      /*-*/
      /* check if a goods reversal has to be sent
      /*-*/
      /* commented out until we are happy to send a GR reversal for a material that */
      /* hasn't had  a create in the first place */
      --/*
      OPEN csr_gr;
      LOOP
          FETCH csr_gr INTO rcd_gr;
          EXIT WHEN csr_gr%NOTFOUND;
          Pt_Cisatl17_Gr.EXECUTE(var_result,
                                 var_result_msg,
                                 rcd_gr.message_type,  -- Recverse process in Atlas
                                 rcd_gr.plant_code,
                                 rcd_gr.sender_name, -- sender name
                                 FALSE,    
                                 TO_NUMBER(rcd_gr.proc_order),
                                 TRUNC(rcd_gr.event_datime),
                                 TO_NUMBER(TO_CHAR(rcd_gr.event_datime,'hh24miss')),
                                 rcd_gr.matl_code,
                                 rcd_gr.qty,
                                 rcd_gr.uom,
                                 TO_NUMBER(rcd_gr.storage_locn),
                                 ' ',
                                 '',
                                 FALSE,
                                 0,
                                 TO_NUMBER(rcd_gr.scrap_rework_id),  -- pallet code
                                 '',
                                 '',
                                 TRUNC(SYSDATE),
                                 0,
                                 TRUNC(SYSDATE),
                                 0);
                                   
             UPDATE scrap_rework_reversal
               SET sent_flag = 'Y'
               WHERE scrap_rework_id = rcd_gr.scrap_rework_id;
                                      
             IF var_result > 0 THEN
                 RAISE application_exception;
             END IF;                       
      END LOOP;
      CLOSE csr_gr;
      --*/
      
      /*-*/
      /* cleanup the logging table in PM schema
      /* INTERFACE_ERROR 
      /*-*/
      delete from interface_error
      where result_datime < sysdate - 4;
      
      
   EXCEPTION
      WHEN OTHERS THEN
	      IF (lics_outbound_loader.is_created()) THEN
	   	      lics_outbound_loader.finalise_interface();
	      END IF;
          IF NOT lics_logging.is_created THEN
             lics_logging.start_log('PT_CISATL17_Scrap_Rework.execute','Send file');
          END IF;
         lics_logging.write_log('PDBICS15 failed - ' || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512));
         IF lics_logging.is_created THEN
             lics_logging.end_log;
         END IF;
         RAISE_APPLICATION_ERROR(-20000, 'Pt_Cisatl17_Scrap_Rework - failed' || CHR(13)
                                           || 'Oracle error ' || SUBSTR(SQLERRM, 1, 1000));
   END;

END Pt_Cisatl17_Scrap_Rework;
/


DROP PUBLIC SYNONYM PT_CISATL17_SCRAP_REWORK;

CREATE PUBLIC SYNONYM PT_CISATL17_SCRAP_REWORK FOR PT_APP.PT_CISATL17_SCRAP_REWORK;


GRANT EXECUTE ON PT_APP.PT_CISATL17_SCRAP_REWORK TO APPSUPPORT;

GRANT EXECUTE ON PT_APP.PT_CISATL17_SCRAP_REWORK TO LICS_APP WITH GRANT OPTION;

