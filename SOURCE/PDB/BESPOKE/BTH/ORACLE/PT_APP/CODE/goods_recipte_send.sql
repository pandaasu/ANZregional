DROP PROCEDURE PT_APP.GOODS_RECIPTE_SEND;

CREATE OR REPLACE PROCEDURE PT_APP.Goods_Recipte_Send(
   o_result          IN OUT NUMBER,
	o_result_msg      IN OUT VARCHAR2,
	i_MESSAGE_TYPE		IN VARCHAR2,	-- Z_PI1 Create or Z_PI2 Reverse , Z_PI6 HU Reversal 
	i_PLANT_CODE		IN VARCHAR2,
	i_SENDER_NAME		IN VARCHAR2,
	i_TEST_FLAG			IN BOOLEAN,		-- IF TRUE, THEN CREATE TEST ATLAS MESSAGE
	i_PROC_ORDER		IN NUMBER,
	i_XACTN_DATE		IN DATE,
	i_XACTN_TIME		IN NUMBER,
	i_MATERIAL_CODE	IN VARCHAR2,
	i_QTY					IN NUMBER,	   	-- Material Produced
	i_UOM					IN VARCHAR2,
	i_STOR_LOC_CODE	IN NUMBER,
	i_DISPN_CODE		IN VARCHAR2,	-- Stock Type
	i_ZPPPI_BATCH		IN VARCHAR2,	-- ATLAS BATCH CODE
	i_LAST_GR_FLAG		IN BOOLEAN,		-- IF TRUE, THEN LAST MESSAGE
	i_BB_DATE			IN NUMBER,		-- Best Before Date 
	i_plt_code			IN VARCHAR2,
	i_plt_type			IN VARCHAR2,
	i_pkg_matl 			IN VARCHAR2,
	i_START_PRODN_DATE IN DATE,
	i_START_PRODN_TIME IN NUMBER,
	i_END_PRODN_DATE	IN DATE,
	i_END_PRODN_TIME	IN NUMBER)
	
AS
	
	/*-*/
	/* variables
	/*-*/
	--v_intfc_rtn		NUMBER(15,0);
	v_timestamp    VARCHAR2(500);
	v_test_flag		VARCHAR2(1)  := '';
	
   exc_process_exception	EXCEPTION;
	
	
	/*-*/
	/* this value defines the interface sand server directory 
	/*-*/
	cst_fil_path	CONSTANT	VARCHAR2(60) := 'MANU_OUTBOUND';
	cst_fil_name	CONSTANT	VARCHAR2(20) := 'CISATL17_';  -- the .1 will be added with the time stamp 
	
	/*-*/
	/* Unix command to send the file over MQ series  
	/*-*/
	cst_prc_script	 CONSTANT	VARCHAR2(100):= '/manu/prod/bin/send_file.sh -f ' || cst_fil_name;
	
	
BEGIN

     o_result := 0;
     o_result_msg := 'OK';
	
	 /* 26 Jul 2006 J Phillipson */
	 /* added to provide a unique file name when saved on the server */
	 IF UPPER(trim(i_MESSAGE_TYPE)) = 'ZPI_CONS' OR UPPER(trim(i_MESSAGE_TYPE)) = 'Z_PI4' THEN
	     v_timestamp := TO_CHAR(SYSDATE,'yyyymmddhh24miss') || 'C' || trim(i_PLANT_CODE) || 'PO' || trim(i_proc_order) || 'M' || trim(i_material_code) || '.1';
	 ELSE
	     v_timestamp := TO_CHAR(SYSDATE,'yyyymmddhh24miss') ||  'P' || i_plt_code || '.1';
	 END IF;
	
	 
	 IF (i_TEST_FLAG = TRUE) THEN
	     v_test_flag := 'X';
	 END IF;

         
      /*-*/
	  /* Create REMOTE interface on MANU for GR or RGR message to Atlas 
	  /*-*/
      Manu_Remote_Loader.create_interface(cst_fil_path, cst_fil_name ||  v_timestamp);

      --CREATE DATA LINES FOR MESSAGE

	  /*-*/
      /* HEADER: Header Record 
      /* Including 'X' at the end of the header record will cause Atlas
      /* to treat the message as a test, meaning no further processing
      /* will be completed once it reaches Atlas.
	  /*-*/
			
      Manu_Remote_Loader.append_data('HDR000000000000000001'
                                    ||RPAD(TRIM(i_PLANT_CODE),4,' ')
                                    ||RPAD(i_MESSAGE_TYPE,8,' ')
                                    ||RPAD(TRIM(i_SENDER_NAME),32,' ')
									||TRIM(v_test_flag));

		
		IF (i_plt_Type IS NOT NULL AND i_plt_Type <> ' ' ) THEN
	      IF i_MESSAGE_TYPE  = 'Z_PI1' THEN
			    Manu_Remote_Loader.append_data('DET000000000000000001'
                                           ||RPAD('ZPPPI_VHILM',30,' ')
                                           ||RPAD(TRIM(i_pkg_matl),30,' ')
                                           ||'CHAR');
			END IF;
	   END IF;
	  												 
      --DET: PROCESS ORDER
      Manu_Remote_Loader.append_data('DET000000000000000001'
                                    ||RPAD('PPPI_PROCESS_ORDER',30,' ')
                                    ||RPAD(LPAD(TRIM(TO_CHAR(i_PROC_ORDER)),12,0),30,' ')
                                    ||'CHAR');

      --DET: EVENT DATE
      Manu_Remote_Loader.append_data('DET000000000000000001'
                                    ||RPAD('PPPI_EVENT_DATE',30,' ')
                                    ||RPAD(TO_CHAR(i_XACTN_DATE,'YYYYMMDD'),30,' ')
                                    ||'DATE');

      --DET: EVENT TIME
      Manu_Remote_Loader.append_data('DET000000000000000001'
                                    ||RPAD('PPPI_EVENT_TIME',30,' ')
                                    ||RPAD(TRIM(TO_CHAR(i_XACTN_TIME)),30,' ')
                                    ||'TIME');

      IF ASCII(RTRIM(LTRIM(SUBSTR(i_MATERIAL_CODE,1,1)))) >= 48 AND  ASCII(RTRIM(LTRIM(SUBSTR(i_MATERIAL_CODE,1,1)))) <= 57 THEN
          --DET: MATERIAL CODE
          Manu_Remote_Loader.append_data('DET000000000000000001'
                                        ||RPAD('PPPI_MATERIAL',30,' ')
                                        ||RPAD(LPAD(TRIM(i_MATERIAL_CODE),18,'0'),30,' ')
                                        ||'CHAR');
      ELSE
          Manu_Remote_Loader.append_data('DET000000000000000001'
                                        ||RPAD('PPPI_MATERIAL',30,' ')
                                        ||RPAD(trim(i_MATERIAL_CODE),30,' ')
                                        ||'CHAR');
      END IF;

      --DET: MATERIAL PRODUCED (QTY) 
		IF i_MESSAGE_TYPE  = 'ZPI_CONS' OR UPPER(trim(i_MESSAGE_TYPE)) = 'Z_PI4' THEN
		    Manu_Remote_Loader.append_data('DET000000000000000001'
                                    ||RPAD('PPPI_MATERIAL_CONSUMED',30,' ')
                                    ||RPAD(TRIM(TO_CHAR(i_QTY)),30,' ')
                                    ||'NUM');
		ELSE
          Manu_Remote_Loader.append_data('DET000000000000000001'
                                    ||RPAD('PPPI_MATERIAL_PRODUCED',30,' ')
                                    ||RPAD(TRIM(TO_CHAR(i_QTY)),30,' ')
                                    ||'NUM');
		END IF;

      --DET: UNIT OF MEASURE (UOM)
      Manu_Remote_Loader.append_data('DET000000000000000001'
                                    ||RPAD('PPPI_UNIT_OF_MEASURE',30,' ')
                                    ||RPAD(TRIM(i_UOM),30,' ')
                                    ||'CHAR');

      --DET: STORAGE LOCATION
	  IF (i_STOR_LOC_CODE IS NOT NULL) THEN
         Manu_Remote_Loader.append_data('DET000000000000000001'
                                       ||RPAD('PPPI_STORAGE_LOCATION',30,' ')
                                       ||RPAD(LPAD(TRIM(TO_CHAR(i_STOR_LOC_CODE)),4,0),30,' ')
                                       ||'CHAR');
	  END IF;

      --DET: STOCK TYPE (DISPN)
	  IF (i_DISPN_CODE IS NOT NULL) THEN
         Manu_Remote_Loader.append_data('DET000000000000000001'
                                       ||RPAD('Z_PPPI_STOCK_TYPE',30,' ')
                                       ||RPAD(i_DISPN_CODE,30,' ')
                                       ||'CHAR');
	  END IF;

	  --DET: ZPPPI BATCH CODE 
	  IF (i_ZPPPI_BATCH IS NOT NULL AND i_ZPPPI_BATCH <> ' ') THEN
          IF i_MESSAGE_TYPE  = 'Z_PI2' OR i_MESSAGE_TYPE  = 'Z_PI6'  THEN
              Manu_Remote_Loader.append_data('DET000000000000000001'
                                            ||RPAD('PPPI_BATCH',30,' ')
                                            ||RPAD(i_ZPPPI_BATCH,30,' ')
                                            ||'CHAR');
          ELSE 
              Manu_Remote_Loader.append_data('DET000000000000000001'
                                            ||RPAD('ZPPPI_BATCH',30,' ')
                                            ||RPAD(i_ZPPPI_BATCH,30,' ')
                                            ||'CHAR');
          END IF;
	  END IF;

	  --DET: DELIVER COMPLETE (LAST GR/RGR) 
	  IF (i_LAST_GR_FLAG = TRUE) THEN
         Manu_Remote_Loader.append_data('DET000000000000000001'
                                       ||RPAD('PPPI_DELIVERY_COMPLETE',30,' ')
                                       ||RPAD(TRIM('X'),30,' ')
                                       ||'CHAR');
	  END IF;
										   
	  --DET: BEST BEFORE DATE (SHELF LIFE EXPIRATION DATE = SLED) 
	  IF (i_BB_DATE IS NOT NULL) THEN
          IF i_MESSAGE_TYPE  = 'Z_PI1' THEN
              Manu_Remote_Loader.append_data('DET000000000000000001'
                                            ||RPAD('ZPPPI_SLED',30,' ')
                                            ||RPAD(TRIM(i_BB_DATE),30,' ')
                                            ||'DATE');
          END IF;
	  END IF;

	  
	  IF (i_plt_Type IS NOT NULL AND i_plt_Type <> ' ') THEN
	      IF (i_MESSAGE_TYPE  = 'Z_PI1' OR i_MESSAGE_TYPE = 'Z_PI6') THEN
			    Manu_Remote_Loader.append_data('DET000000000000000001'
                                           ||RPAD('ZPPPI_EXIDV',30,' ')
                                           ||RPAD(TRIM(i_plt_code),30,' ')
                                           ||'CHAR');
			END IF;
	  END IF;
	  
	  
	  
	  IF (i_plt_Type IS NOT NULL AND i_plt_Type <> ' ' ) THEN
	      IF i_MESSAGE_TYPE  = 'Z_PI1' THEN
			    Manu_Remote_Loader.append_data('DET000000000000000001'
                                           ||RPAD('ZPPPI_ZZPALETCHAR',30,' ')
                                           ||RPAD(TRIM(i_plt_type),30,' ')
                                           ||'CHAR');
			END IF;
	  END IF;
	  
	  IF (i_plt_Type IS NOT NULL AND i_plt_Type <> ' ' ) THEN
	      IF i_MESSAGE_TYPE  = 'Z_PI1' THEN
			    Manu_Remote_Loader.append_data('DET000000000000000001'
                                           ||RPAD('ZPPPI_ZZSRTPRDATE',30,' ')
                                           ||RPAD(TO_CHAR(i_start_prodn_date,'YYYYMMDD'),30,' ')
                                           ||'DATE');
			    Manu_Remote_Loader.append_data('DET000000000000000001'
                                           ||RPAD('ZPPPI_ZZSRTPRTIME',30,' ')
                                           ||RPAD(TRIM(LPAD(i_start_prodn_time,6,'0')),30,' ')
                                           ||'TIME');
				 Manu_Remote_Loader.append_data('DET000000000000000001'
                                           ||RPAD('ZPPPI_ZZENDPRDATE',30,' ')
                                           ||RPAD(TO_CHAR(i_end_prodn_date,'YYYYMMDD'),30,' ')
                                           ||'DATE');
			    Manu_Remote_Loader.append_data('DET000000000000000001'
                                           ||RPAD('ZPPPI_ZZENDPRTIME',30,' ')
                                           ||RPAD(TRIM(LPAD(i_end_prodn_time,6,'0')),30,' ')
                                           ||'TIME');
			END IF;
	  END IF;
	  
	  
     /*-*/
	  /*Close Remote Interface and send Unix script 
	  /*-*/
     Manu_Remote_Loader.finalise_interface(cst_prc_script ||  v_timestamp);
		
	 <<tempEnd>>
	 o_result := o_result;
		

   EXCEPTION
     WHEN OTHERS THEN
	     IF (Manu_Remote_Loader.is_created()) THEN
	   	  Manu_Remote_Loader.finalise_interface(cst_prc_script);
	     END IF;
		
        o_result := 1;
	     o_result_msg := 'Creation of Idoc failed ['||SQLERRM||']';
       --RAISE_APPLICATION_ERROR(-20001, o_result_msg);
END;
/


DROP PUBLIC SYNONYM GOODS_RECIPTE_SEND;

CREATE PUBLIC SYNONYM GOODS_RECIPTE_SEND FOR PT_APP.GOODS_RECIPTE_SEND;


GRANT EXECUTE ON PT_APP.GOODS_RECIPTE_SEND TO APPSUPPORT;

GRANT EXECUTE ON PT_APP.GOODS_RECIPTE_SEND TO BTHSUPPORT;

