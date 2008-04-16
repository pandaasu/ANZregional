CREATE OR REPLACE PACKAGE PT_APP.PT_CISATL17_GR AS
/******************************************************************************
   NAME:       PT_CISATL17_GR
   PURPOSE:    Transfer data through ICS to Atlas

   REVISIONS:
   Ver        Date        Author                    Description
   ---------  ----------  ---------------------  ------------------------------------
   1.0        20/09/2007      Jeff Phillipson       1. Created this package.
   1.1        13/02/2008      Scott R. Harding      Added msg type to filename for uniqueness
******************************************************************************/

  PROCEDURE EXECUTE(o_result          OUT NUMBER,
                o_result_msg        OUT VARCHAR2,
                i_message_type  IN VARCHAR2, -- Z_PI1 Create or Z_PI2 Reverse , Z_PI6 HU Reversal 
                i_plant_code  IN VARCHAR2,
                i_sender_name  IN VARCHAR2,
                i_test_flag   IN BOOLEAN,  -- IF TRUE, THEN CREATE TEST ATLAS MESSAGE
                i_proc_order  IN NUMBER,
                i_xactn_date  IN DATE,
                i_xactn_time  IN NUMBER,
                i_material_code     IN VARCHAR2,
                i_qty    IN NUMBER,     -- Material Produced
                i_uom    IN VARCHAR2,
                i_stor_loc_code     IN NUMBER,
                i_dispn_code  IN VARCHAR2, -- Stock Type
                i_ZPPPI_batch  IN VARCHAR2, -- ATLAS BATCH CODE
                i_last_gr_flag  IN BOOLEAN,  -- IF TRUE, THEN LAST MESSAGE
                i_bb_date   IN NUMBER,  -- Best Before Date 
                i_plt_code   IN VARCHAR2,
                i_plt_type   IN VARCHAR2,
                i_pkg_matl    IN VARCHAR2,
                i_start_prodn_date  IN DATE,
                i_start_prodn_time  IN NUMBER,
                i_end_prodn_date IN DATE,
                i_end_prodn_time IN NUMBER);

END PT_CISATL17_GR; 
/

CREATE OR REPLACE PACKAGE BODY PT_APP.Pt_Cisatl17_Gr AS
/******************************************************************************
   NAME:       PT_CISATL17_GR
   PURPOSE:    Transfer data through ICS to Atlas

******************************************************************************/


PROCEDURE EXECUTE(o_result          OUT NUMBER,
               	o_result_msg        OUT VARCHAR2,
               	i_message_type		IN VARCHAR2,	-- Z_PI1 Create or Z_PI2 Reverse , Z_PI6 HU Reversal 
               	i_plant_code		IN VARCHAR2,
               	i_sender_name		IN VARCHAR2,
               	i_test_flag			IN BOOLEAN,		-- IF TRUE, THEN CREATE TEST ATLAS MESSAGE
               	i_proc_order		IN NUMBER,
               	i_xactn_date		IN DATE,
               	i_xactn_time		IN NUMBER,
               	i_material_code	    IN VARCHAR2,
               	i_qty				IN NUMBER,	   	-- Material Produced
               	i_uom				IN VARCHAR2,
               	i_stor_loc_code	    IN NUMBER,
               	i_dispn_code		IN VARCHAR2,	-- Stock Type
               	i_ZPPPI_batch		IN VARCHAR2,	-- ATLAS BATCH CODE
               	i_last_gr_flag		IN BOOLEAN,		-- IF TRUE, THEN LAST MESSAGE
               	i_bb_date			IN NUMBER,		-- Best Before Date 
               	i_plt_code			IN VARCHAR2,
               	i_plt_type			IN VARCHAR2,
               	i_pkg_matl 			IN VARCHAR2,
               	i_start_prodn_date 	IN DATE,
               	i_start_prodn_time  IN NUMBER,
               	i_end_prodn_date	IN DATE,
               	i_end_prodn_time	IN NUMBER)
	
AS
	
	/*-*/
	/* variables
	/*-*/
	var_timestamp     	VARCHAR2(200);
	var_test_flag		VARCHAR2(1)  := '';
	var_success         NUMBER;
	var_db_value        VARCHAR2(4);
    var_extension       VARCHAR2(2);
    exc_process_exception	EXCEPTION;
	
	
	/*-*/
	/* this value defines the interface sand server directory 
	/*-*/
	cst_file_name	   CONSTANT	VARCHAR2(20) := 'CISATL17';   
    cst_file_interface CONSTANT VARCHAR2(20) := 'PDBICS17';
    --cst_extension      CONSTANT VARCHAR2(2) := '.3';
	
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
              
    CURSOR csr_extension
    IS
    SELECT CASE
               WHEN db IN ('AP0126D', 'DB0719P') THEN '.3'  -- snack 
               WHEN db IN ('AP0132D', 'DB0720P') THEN '.3' -- snack
               WHEN db IN ('AP0068T', 'AP0065P') THEN '.2' -- food
               WHEN db IN ('MFA002', 'MFA005') THEN '.2' -- food
               WHEN db IN ('WOD023', 'WOD013') THEN '.1' -- petcare
               WHEN db IN ('BTH005', 'BTH001') THEN '.1' -- petcare
            END VALUE 
      FROM (SELECT UPPER(sys_context('USERENV', 'DB_NAME')) AS  db
              FROM dual); 
	
  BEGIN
      
      o_result := 0;
      o_result_msg := 'OK';
	  
      OPEN csr_db;
          FETCH csr_db INTO var_db_value;
          IF csr_db%NOTFOUND THEN
              var_db_value := '.1';
          END IF;
      CLOSE csr_db;
        
        
	  IF UPPER(trim(i_message_type)) = 'ZPI_CONS' OR UPPER(trim(i_message_type)) = 'Z_PI4' THEN
	      var_timestamp := TO_CHAR(SYSTIMESTAMP,'yyyymmddhh24missff') || 'C' || trim(i_PLANT_CODE) || 'PO' || trim(i_proc_order) || 'M' || trim(i_material_code) ;
	  ELSE
	      var_timestamp := TO_CHAR(SYSTIMESTAMP,'yyyymmddhh24missff') ||  'P' || i_plt_code || 'MT' || UPPER(trim(i_message_type));
	  END IF;
	 
	  IF i_TEST_FLAG THEN
	      var_test_flag := 'X';
	  END IF;

      /*-*/
	  /* Create REMOTE interface on MANU for GR or RGR message to Atlas 
	  /*-*/ 
      var_success := lics_outbound_loader.create_interface(cst_file_interface || var_db_value, cst_file_name || '_' ||  var_timestamp || var_extension, cst_file_name || var_extension);
	 
	  /*-*/
      /* CREATE DATA LINES FOR MESSAGE 
      /* HEADER: Header Record 
      /* Including 'X' at the end of the header record will cause Atlas
      /* to treat the message as a test, meaning no further processing
      /* will be completed once it reaches Atlas.
	  /*-*/
	  lics_outbound_loader.append_data('HDR000000000000000001'
                                    ||RPAD(TRIM(i_PLANT_CODE),4,' ')
                                    ||RPAD(i_MESSAGE_TYPE,8,' ')
                                    ||RPAD(TRIM(i_SENDER_NAME),32,' ')
								   	||TRIM(var_test_flag));

		
	  IF (i_plt_Type IS NOT NULL AND i_plt_Type <> ' ' ) THEN
	      IF i_MESSAGE_TYPE  = 'Z_PI1' THEN
			    lics_outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('ZPPPI_VHILM',30,' ')
                                           ||RPAD(TRIM(i_pkg_matl),30,' ')
                                           ||'CHAR');
			END IF;
	  END IF;
	  												 
      --DET: PROCESS ORDER
      lics_outbound_loader.append_data('DET000000000000000001'
                                    ||RPAD('PPPI_PROCESS_ORDER',30,' ')
                                    ||RPAD(LPAD(TRIM(TO_CHAR(i_PROC_ORDER)),12,0),30,' ')
                                    ||'CHAR');

      --DET: EVENT DATE
      lics_outbound_loader.append_data('DET000000000000000001'
                                    ||RPAD('PPPI_EVENT_DATE',30,' ')
                                    ||RPAD(TO_CHAR(i_XACTN_DATE,'YYYYMMDD'),30,' ')
                                    ||'DATE');

      --DET: EVENT TIME
      lics_outbound_loader.append_data('DET000000000000000001'
                                    ||RPAD('PPPI_EVENT_TIME',30,' ')
                                    ||RPAD(TRIM(TO_CHAR(i_XACTN_TIME)),30,' ')
                                    ||'TIME');

      IF ASCII(RTRIM(LTRIM(SUBSTR(i_MATERIAL_CODE,1,1)))) >= 48 AND  ASCII(RTRIM(LTRIM(SUBSTR(i_MATERIAL_CODE,1,1)))) <= 57 THEN
          --DET: MATERIAL CODE
          lics_outbound_loader.append_data('DET000000000000000001'
                                        ||RPAD('PPPI_MATERIAL',30,' ')
                                        ||RPAD(LPAD(TRIM(i_MATERIAL_CODE),18,'0'),30,' ')
                                        ||'CHAR');
      ELSE
          lics_outbound_loader.append_data('DET000000000000000001'
                                        ||RPAD('PPPI_MATERIAL',30,' ')
                                        ||RPAD(trim(i_MATERIAL_CODE),30,' ')
                                        ||'CHAR');
      END IF;

      --DET: MATERIAL PRODUCED (QTY) 
		IF UPPER(trim(i_MESSAGE_TYPE))  = 'ZPI_CONS' OR UPPER(trim(i_MESSAGE_TYPE)) = 'Z_PI4' THEN
		    lics_outbound_loader.append_data('DET000000000000000001'
                                    ||RPAD('PPPI_MATERIAL_CONSUMED',30,' ')
                                    ||RPAD(TRIM(TO_CHAR(i_QTY)),30,' ')
                                    ||'NUM');
		ELSE
          lics_outbound_loader.append_data('DET000000000000000001'
                                    ||RPAD('PPPI_MATERIAL_PRODUCED',30,' ')
                                    ||RPAD(TRIM(TO_CHAR(i_QTY)),30,' ')
                                    ||'NUM');
		END IF;

      --DET: UNIT OF MEASURE (UOM)
      lics_outbound_loader.append_data('DET000000000000000001'
                                    ||RPAD('PPPI_UNIT_OF_MEASURE',30,' ')
                                    ||RPAD(i_UOM,30,' ')
                                    ||'CHAR');

      --DET: STORAGE LOCATION
	  IF (i_STOR_LOC_CODE IS NOT NULL) THEN
         lics_outbound_loader.append_data('DET000000000000000001'
                                       ||RPAD('PPPI_STORAGE_LOCATION',30,' ')
                                       ||RPAD(LPAD(TO_CHAR(i_STOR_LOC_CODE),4,0),30,' ')
                                       ||'CHAR');
	  END IF;

      --DET: STOCK TYPE (DISPN)
	  IF (i_DISPN_CODE IS NOT NULL) THEN
         lics_outbound_loader.append_data('DET000000000000000001'
                                       ||RPAD('Z_PPPI_STOCK_TYPE',30,' ')
                                       ||RPAD(i_DISPN_CODE,30,' ')
                                       ||'CHAR');
	  END IF;

	  --DET: ZPPPI BATCH CODE 
	  IF (i_ZPPPI_BATCH IS NOT NULL AND i_ZPPPI_BATCH <> ' ') THEN
          IF i_MESSAGE_TYPE  = 'Z_PI2' OR i_MESSAGE_TYPE  = 'Z_PI6'  THEN
              lics_outbound_loader.append_data('DET000000000000000001'
                                            ||RPAD('PPPI_BATCH',30,' ')
                                            ||RPAD(i_ZPPPI_BATCH,30,' ')
                                            ||'CHAR');
          ELSE 
              lics_outbound_loader.append_data('DET000000000000000001'
                                            ||RPAD('ZPPPI_BATCH',30,' ')
                                            ||RPAD(i_ZPPPI_BATCH,30,' ')
                                            ||'CHAR');
          END IF;
	  END IF;

	  --DET: DELIVER COMPLETE (LAST GR/RGR) 
	  IF (i_LAST_GR_FLAG = TRUE) THEN
         lics_outbound_loader.append_data('DET000000000000000001'
                                       ||RPAD('PPPI_DELIVERY_COMPLETE',30,' ')
                                       ||RPAD(TRIM('X'),30,' ')
                                       ||'CHAR');
	  END IF;
										   
	  --DET: BEST BEFORE DATE (SHELF LIFE EXPIRATION DATE = SLED) 
	  IF (i_BB_DATE IS NOT NULL) THEN
          IF i_MESSAGE_TYPE  = 'Z_PI1' THEN
              lics_outbound_loader.append_data('DET000000000000000001'
                                            ||RPAD('ZPPPI_SLED',30,' ')
                                            ||RPAD(TRIM(i_BB_DATE),30,' ')
                                            ||'DATE');
          END IF;
	  END IF;

	  
	  IF (i_plt_Type IS NOT NULL AND i_plt_Type <> ' ') THEN
	      IF (i_MESSAGE_TYPE  = 'Z_PI1' OR i_MESSAGE_TYPE = 'Z_PI6') THEN
			    lics_outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('ZPPPI_EXIDV',30,' ')
                                           ||RPAD(TRIM(i_plt_code),30,' ')
                                           ||'CHAR');
			END IF;
	  END IF;
	  
	  IF (i_plt_Type IS NOT NULL AND i_plt_Type <> ' ' ) THEN
	      IF i_MESSAGE_TYPE  = 'Z_PI1' THEN
			    lics_outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('ZPPPI_ZZPALETCHAR',30,' ')
                                           ||RPAD(TRIM(i_plt_type),30,' ')
                                           ||'CHAR');
			END IF;
	  END IF;
	  
	  IF (i_plt_Type IS NOT NULL AND i_plt_Type <> ' ' ) THEN
	      IF i_MESSAGE_TYPE  = 'Z_PI1' THEN
			    lics_outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('ZPPPI_ZZSRTPRDATE',30,' ')
                                           ||RPAD(TO_CHAR(i_start_prodn_date,'YYYYMMDD'),30,' ')
                                           ||'DATE');
			    lics_outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('ZPPPI_ZZSRTPRTIME',30,' ')
                                           ||RPAD(LPAD(TRIM(i_start_prodn_time),6,'0'),30,' ')
                                           ||'TIME');
				 lics_outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('ZPPPI_ZZENDPRDATE',30,' ')
                                           ||RPAD(TO_CHAR(i_end_prodn_date,'YYYYMMDD'),30,' ')
                                           ||'DATE');
			    lics_outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('ZPPPI_ZZENDPRTIME',30,' ')
                                           ||RPAD(LPAD(TRIM(i_end_prodn_time),6,'0'),30,' ')
                                           ||'TIME');
			END IF;
	  END IF;
	  
	
     /*-*/
	 /*Close Remote Interface and send Unix script 
	 /*-*/
	 lics_outbound_loader.finalise_interface();
     lics_logging.start_log('Goods Recipt & Consumption', 'Message type' || i_message_type);
     lics_logging.write_log('Pallet: ' || i_plt_code || ' Material code: ' || i_material_code || ' Quantity: ' || i_qty);
 	 lics_logging.end_log;
     /*-*/
	 /* add file name to error message
	 /*-*/
	 o_result_msg := var_timestamp;

   <<FINISH>>
       o_result := 0;
   EXCEPTION
     WHEN OTHERS THEN
	     IF lics_outbound_loader.is_created() THEN
	   	     lics_outbound_loader.finalise_interface();
	     END IF;
         IF NOT lics_logging.is_created THEN
             lics_logging.start_log('Goods Recipt & Consumption', 'Message type' || i_message_type);
         END IF;
         lics_logging.write_log('Creation of Idoc failed [' || SUBSTR(SQLERRM,0,1900) || ']');
 	     lics_logging.end_log;
         
         o_result := 1;
	     o_result_msg := 'Creation of Idoc failed [' || SUBSTR(SQLERRM,0,1900) || ']';
   END EXECUTE;
       
END Pt_Cisatl17_Gr; 
/

