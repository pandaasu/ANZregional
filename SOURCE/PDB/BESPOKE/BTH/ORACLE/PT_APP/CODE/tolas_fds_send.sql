DROP PROCEDURE PT_APP.TOLAS_FDS_SEND;

CREATE OR REPLACE PROCEDURE PT_APP.Tolas_Fds_Send(
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
	i_BB_DATE			IN VARCHAR2,	-- Best Before Date 
	i_plt_code			IN VARCHAR2,
	i_plt_type			IN VARCHAR2,
	i_pkg_matl 			IN VARCHAR2,
	i_START_PRODN_DATE IN DATE,
	i_START_PRODN_TIME IN NUMBER,
	i_END_PRODN_DATE	IN DATE,
	i_END_PRODN_TIME	IN NUMBER,
	i_seq				IN VARCHAR2)
	
AS
	
	/*-*/
	/* variables
	/*-*/
	var_intfc_rtn		NUMBER(15,0);
	var_seq_no			VARCHAR2(20);
	var_TEST_FLAG		VARCHAR2(1)  := '';
	var_dispn			VARCHAR2(2);
	
   exc_process_exception	EXCEPTION;
	
	
	/*-*/
	/* this value defines the interface sand server directory 
	/*-*/
	cst_fil_path	CONSTANT	VARCHAR2(60) := 'MANU_OUTBOUND';
	cst_fil_name	CONSTANT	VARCHAR2(20) := 'IPAL' || i_PLANT_CODE  ;
	cst_fil_ext     CONSTANT    VARCHAR2(4)  := '.int';
	/*-*/
	/* Unix command to send the file over MQIF 
	/*-*/
	cst_prc_script	 CONSTANT	VARCHAR2(100):= '/manu/prod/bin/send_file.sh -f ' ||  cst_fil_name;
	--cst_prc_script	 CONSTANT	VARCHAR2(100):= '/manu/test/bin/donothing.sh';
	
	
BEGIN

    o_result := 0;
    o_result_msg := 'OK';
	
	/*IF Plt_Common.DISABLE_ATLAS_TOLAS_SEND = TRUE THEN
	    GOTO tempEnd;
	END IF;*/
	
	 /*-*/
	 /* set seq_no for file and add the txt extension for use latter 
	 /*-*/
	 var_seq_no := LPAD(i_seq,8,'0') || cst_fil_ext ;
    
	 IF (i_TEST_FLAG = TRUE) THEN
	     var_TEST_FLAG := 'X';
	 ELSE
	     var_TEST_FLAG := ' ';
	 END IF;
	 
	 IF i_DISPN_CODE = ' ' THEN
	     -- unrestrited 
		  var_dispn := 'GD';
	 END IF;
	 IF i_DISPN_CODE = 'S' THEN
		 -- blocked 
		 var_dispn := 'HD';
	 END IF;
	 IF i_DISPN_CODE = 'X' THEN
	 	  -- QI - dont know the choice for this yet 
		  var_dispn := 'HD';
	 END IF;
			
			

      /*-*/  
      /* Create REMOTE interface on MANU for GR or RGR message to Atlas 
	  /*-*/
      Manu_Remote_Loader.create_interface(cst_fil_path, cst_fil_name || var_seq_no);

	  /*-*/
      /* HEADER: Header Record 
      /* Including 'X' at the end of the header record will cause Atlas
      /* to treat the message as a test, meaning no further processing
      /* will be completed once it reaches Atlas.
	  /*-*/
			
      Manu_Remote_Loader.append_data('HDR'
												||'000000000000000001'
                                    ||RPAD(TRIM(i_PLANT_CODE),4,' ')
                                    ||RPAD(i_MESSAGE_TYPE,8,' ')
                                    ||RPAD(TRIM(i_SENDER_NAME),32,' ')
										   	||RPAD(var_TEST_FLAG,1,' ')
												||RPAD('R',1,' ')  -- could be R and H 
												||RPAD(var_DISPN,4,' '));

														 
      --DET: PROCESS ORDER
      Manu_Remote_Loader.append_data('DET'
												||'000000000000000001'
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
      Manu_Remote_Loader.append_data('DET000000000000000001'
                                    ||RPAD('PPPI_MATERIAL_PRODUCED',30,' ')
                                    ||RPAD(LPAD(TRIM(TO_CHAR(i_QTY)),4,'0'),30,' ')
                                    ||'NUM');

      --DET: UNIT OF MEASURE (UOM)
      Manu_Remote_Loader.append_data('DET000000000000000001'
                                    ||RPAD('PPPI_UNIT_OF_MEASURE',30,' ')
                                    ||RPAD(TRIM(i_UOM),30,' ')
                                    ||'CHAR');

      --DET: STORAGE LOCATION
	  IF (i_STOR_LOC_CODE IS NOT NULL) THEN
         Manu_Remote_Loader.append_data('DET000000000000000001'
                                       ||RPAD('PPPI_STORAGE_LOCATION',30,' ')
                                       ||RPAD(LPAD(TRIM(TO_CHAR('H001')),4,0),30,' ')
                                       ||'CHAR');
	  END IF;

     --DET: STOCK TYPE (DISPN)
	  IF (i_DISPN_CODE IS NOT NULL) THEN
         Manu_Remote_Loader.append_data('DET000000000000000001'
                                       ||RPAD('PPPI_STOCK_TYPE',30,' ')
                                       ||RPAD(var_dispn,30,' ')
                                       ||'CHAR');
	  END IF;

	  -- Batch send 
	  IF (i_ZPPPI_BATCH IS NOT NULL) THEN
	      Manu_Remote_Loader.append_data('DET000000000000000001'
                                        ||RPAD('PPPI_BATCH',30,' ')
                                        ||RPAD(i_ZPPPI_BATCH,30,' ')
                                        ||'CHAR');
	  END IF;
	  
	  /*-*/
	  /* DET: BEST BEFORE DATE (SHELF LIFE EXPIRATION DATE = SLED) 
	  /*-*/
	  IF (i_BB_DATE IS NOT NULL) THEN
          IF i_MESSAGE_TYPE  = 'Z_PI1' THEN
              Manu_Remote_Loader.append_data('DET000000000000000001'
                                            ||RPAD('ZPPPI_SLED',30,' ')
                                            ||RPAD(TRIM(i_BB_DATE),30,' ')
                                            ||'DATE');
          END IF;
	  END IF;

	  
	  IF (i_plt_code IS NOT NULL) THEN
	      IF (i_MESSAGE_TYPE  = 'Z_PI1' OR i_MESSAGE_TYPE = 'Z_PI6') THEN
			    Manu_Remote_Loader.append_data('DET000000000000000001'
                                           ||RPAD('ZPPPI_EXIDV',30,' ')
                                           ||RPAD(TRIM(i_plt_code),30,' ')
                                           ||'CHAR');
			END IF;
	  END IF;
	  
	  IF (i_plt_Type IS NOT NULL) THEN
	      IF i_MESSAGE_TYPE  = 'Z_PI1' THEN
			    Manu_Remote_Loader.append_data('DET000000000000000001'
                                           ||RPAD('ZPPPI_VHILM',30,' ')
                                           ||RPAD(TRIM(i_pkg_matl),30,' ')
                                           ||'CHAR');
			END IF;
	  END IF;
	  
	  
	  IF (i_plt_Type IS NOT NULL AND i_plt_Type <> ' ' ) THEN
	      IF i_MESSAGE_TYPE  = 'Z_PI1' THEN
				 Manu_Remote_Loader.append_data('DET000000000000000001'
                                           ||RPAD('ZPPPI_ZZENDPRDATE',30,' ')
                                           ||RPAD(TRIM(i_start_prodn_date),30,' ')
                                           ||'CHAR');
			    Manu_Remote_Loader.append_data('DET000000000000000001'
                                           ||RPAD('ZPPPI_ZZENDPRTIME',30,' ')
                                           ||RPAD(TRIM(i_start_prodn_time),30,' ')
                                           ||'CHAR');
			END IF;
	  END IF;
	  
      /*-*/
	  /* Close Remote Interface and send Unix script 
	  /*-*/
	  Manu_Remote_Loader.finalise_interface(cst_prc_script || var_seq_no);
	  
	  <<tempEnd>>
	  o_result := o_result;
	 
	 
   EXCEPTION
     WHEN OTHERS THEN
	     IF (Manu_Remote_Loader.is_created()) THEN
	   	  Manu_Remote_Loader.finalise_interface(cst_prc_script);
	     END IF;
		
        o_result := 1;
	     o_result_msg := 'Tolas_Fds_Send failed ['||SUBSTR(SQLERRM,0.250) || SUBSTR(SQLERRM,251.350) ||']';
       RAISE_APPLICATION_ERROR(-20001, o_result_msg);
END;
/


DROP PUBLIC SYNONYM TOLAS_FDS_SEND;

CREATE PUBLIC SYNONYM TOLAS_FDS_SEND FOR PT_APP.TOLAS_FDS_SEND;


GRANT EXECUTE ON PT_APP.TOLAS_FDS_SEND TO APPSUPPORT;

GRANT EXECUTE ON PT_APP.TOLAS_FDS_SEND TO BTHSUPPORT;

