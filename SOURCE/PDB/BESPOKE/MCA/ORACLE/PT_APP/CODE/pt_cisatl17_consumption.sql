DROP PACKAGE PT_APP.PT_CISATL17_CONSUMPTION;

CREATE OR REPLACE PACKAGE PT_APP.Pt_Cisatl17_Consumption
AS
/******************************************************************************
   NAME:       PT_SEND_CONSUMPTION
   PURPOSE:    send consumption records to Atlas
               with  multiple entries to reduce messages

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/09/2007  Jeff Phillipson           1. Created this package.
   1.1        29-Nov-2007 Jeff Phillipson           changed to send individual entries 
                                                    instaed of grouping like matls together
******************************************************************************/
  

   PROCEDURE EXECUTE;
   
END Pt_Cisatl17_Consumption;
/


DROP PACKAGE BODY PT_APP.PT_CISATL17_CONSUMPTION;

CREATE OR REPLACE PACKAGE BODY PT_APP.Pt_Cisatl17_Consumption AS
/******************************************************************************
   NAME:       PT_SEND_CONSUMPTION
   PURPOSE:    send consumption records to Atlas
               with multiple entries to reduce messages
******************************************************************************/
    
    /*-*/
	/* this value defines the interface sand server directory 
	/*-*/
	cst_file_name	   CONSTANT	VARCHAR2(20) := 'CISATL17';   
    cst_file_interface CONSTANT VARCHAR2(20) := 'PDBICS17';
    cst_extension      CONSTANT VARCHAR2(2) := '.3';
	
    MAX_ROWS_PER_FILE  CONSTANT NUMBER  := 101;
    
    /*-*/
    /* local variables */
    /*-*/
    var_success                 NUMBER DEFAULT 0;
    var_db_value                VARCHAR2(4);
     
    /*-*/
    /* cursor definition */
    /*-*/
    CURSOR csr_chk 
    IS
    SELECT plt_cnsmptn_id,
           proc_order,
           matl_code,
           qty,
           uom,
           plant_code,
           store_locn,
           trans_id,
           CASE 
               WHEN trans_type = 'CREATE' THEN 'ZPI_CONS'
               ELSE 'Z_PI4' -- has to be 'cancel'
           END AS trans_type,
           TO_CHAR(TRUNC(upd_datime),'YYYYMMDD') AS xactn_date,
           TO_CHAR(upd_datime,'HH24') || TO_CHAR(upd_datime,'MI') || '00' AS xactn_time
      FROM plt_cnsmptn
     WHERE sent_flag IS  NULL 
       AND SUBSTR(proc_order,1,2) <> '99' 
       AND proc_order <> '1'
       AND  ROWNUM < MAX_ROWS_PER_FILE
     ORDER BY xactn_date, xactn_time;
     
     rcd_chk csr_chk%ROWTYPE;       -- used to store current record
    
    
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
              
          
 PROCEDURE EXECUTE IS
    
   BEGIN
       OPEN csr_db;
          FETCH csr_db INTO var_db_value;
          IF csr_db%NOTFOUND THEN
              var_db_value := '.1';
          END IF;
       CLOSE csr_db;
        
       /*-*/
       /* check any Create and Cancel Pallets for a send flag = null 
       /*-*/ 
       OPEN csr_chk;
       LOOP
           FETCH csr_chk INTO rcd_chk;
           EXIT WHEN csr_chk%NOTFOUND; 
           /*-*/
	       /* Create interface */
	       /*-*/ 
           IF NOT lics_outbound_loader.is_created THEN
               var_success := lics_outbound_loader.create_interface(cst_file_interface || var_db_value, cst_file_name || '_' ||  TO_CHAR(SYSTIMESTAMP,'yyyymmddhh24missff') || cst_extension, cst_file_name || cst_extension);
	       END IF;
	                         
           /*-*/
           /* HEADER: Header Record */
	       /*-*/
	       lics_outbound_loader.append_data('HDR000000000000000001'
                                           ||RPAD(rcd_chk.plant_code,4,' ')
                                           ||RPAD(rcd_chk.trans_type,8,' ')
                                           ||RPAD(' ',32,' ')
								   	       ||' ');
           /*-*/
           /* CREATE DATA LINES FOR MESSAGE  */
           /*-*/                        
           lics_outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('PPPI_PROCESS_ORDER',30,' ')
                                           ||RPAD(LPAD(rcd_chk.proc_order,12,0),30,' ')
                                           ||'CHAR');                         
           
           lics_outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('PPPI_EVENT_DATE',30,' ')
                                           ||RPAD(rcd_chk.xactn_date,30,' ')
                                           ||'DATE');

           lics_outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('PPPI_EVENT_TIME',30,' ')
                                           ||RPAD(rcd_chk.xactn_time,30,' ')
                                           ||'TIME');  
           
           --DET: MATERIAL CODE
           lics_outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('PPPI_MATERIAL',30,' ')
                                           ||RPAD(LPAD(rcd_chk.matl_code,18,'0'),30,' ')
                                           ||'CHAR');
                                                                                       
           lics_outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('PPPI_MATERIAL_CONSUMED',30,' ')
                                           ||RPAD(TO_CHAR(rcd_chk.qty),30,' ')
                                           ||'NUM');
           
           --DET: UNIT OF MEASURE (UOM)
           lics_outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('PPPI_UNIT_OF_MEASURE',30,' ')
                                           ||RPAD(UPPER(rcd_chk.uom),30,' ')
                                           ||'CHAR');
           
           --DET: STORAGE LOCATION
	       IF (rcd_chk.store_locn IS NOT NULL) THEN
               lics_outbound_loader.append_data('DET000000000000000001'
                                               ||RPAD('PPPI_STORAGE_LOCATION',30,' ')
                                               ||RPAD(LPAD(TO_CHAR(rcd_chk.store_locn),4,0),30,' ')
                                               ||'CHAR');
	       END IF;
                                                        
           UPDATE PLT_CNSMPTN
              SET sent_flag = 'Y'
            WHERE plt_cnsmptn_id = rcd_chk.plt_cnsmptn_id;
                        
       END LOOP;
       CLOSE csr_chk;
       COMMIT;
	   /*-*/
	   /*Close Remote Interface 
	   /*-*/
       IF lics_outbound_loader.is_created THEN
	       lics_outbound_loader.finalise_interface();
       END IF;
       
       
   EXCEPTION
       WHEN OTHERS THEN
           RAISE_APPLICATION_ERROR(-20000, 'Pt_Cisatl17_Consumption - procedure order = ' || rcd_chk.proc_order || CHR(13)
                                           || 'Material code = ' || rcd_chk.matl_code || CHR(13)
                                           || 'Oracle error ' || SUBSTR(SQLERRM, 1, 1000));
      ROLLBACK;
   END;
  
   
END Pt_Cisatl17_Consumption;
/


DROP PUBLIC SYNONYM PT_CISATL17_CONSUMPTION;

CREATE PUBLIC SYNONYM PT_CISATL17_CONSUMPTION FOR PT_APP.PT_CISATL17_CONSUMPTION;


GRANT EXECUTE ON PT_APP.PT_CISATL17_CONSUMPTION TO APPSUPPORT;

GRANT EXECUTE ON PT_APP.PT_CISATL17_CONSUMPTION TO LICS_APP WITH GRANT OPTION;

