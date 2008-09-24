DROP PROCEDURE PT_APP.TOLAS_LTDS_SEND;

CREATE OR REPLACE PROCEDURE PT_APP.Tolas_Ltds_Send(
    o_result          IN OUT NUMBER,
	o_result_msg      IN OUT VARCHAR2,
	i_MESSAGE_TYPE	  IN VARCHAR2,	-- Z_PI1 Create or Z_PI2 Reverse , Z_PI6 HU Reversal 
	i_PLANT_CODE	  IN VARCHAR2,
	i_MATERIAL_CODE	  IN VARCHAR2,
	i_QTY			  IN NUMBER,	   	-- Material Produced
	i_DISPN_CODE	  IN VARCHAR2,	-- Stock Type
	i_ZPPPI_BATCH	  IN VARCHAR2,	-- ATLAS BATCH CODE
	i_BB_DATE		  IN VARCHAR2,	-- Best Before Date 
	i_plt_code		  IN VARCHAR2,
	i_seq			  IN VARCHAR2)
	
AS
	
	/*-*/
	/* variables
	/*-*/
	var_work 			VARCHAR2(20); 
	var_seq_no          VARCHAR2(20);
	var_dispn			VARCHAR2(2);
	var_BB_DATE			VARCHAR2(12);
	
   exc_process_exception	EXCEPTION;
	
	
	/*-*/
	/* this value defines the interface sand server directory 
	/*-*/
	cst_fil_path	CONSTANT	VARCHAR2(60) := 'MANU_OUTBOUND';
	cst_fil_name	CONSTANT	VARCHAR2(20) := 'LTDS' || i_plant_code;
	cst_fil_ext    	CONSTANT 	VARCHAR2(4)  := '.int';
	/*-*/
	/* Unix command to send the file over MQIF 
	/*-*/
	cst_prc_script	 CONSTANT	VARCHAR2(100):= '/manu/prod/bin/send_file.sh -f ' ||  cst_fil_name;


	
	/*-*/
	/* cursor definitions 
	/*-*/
	CURSOR csr_gtin IS
	SELECT EAN_CODE 
	  FROM manu.matl
	 WHERE matl_code = trim(i_MATERIAL_CODE)
	   AND plant = i_PLANT_CODE;
	
BEGIN

    o_result := 0;
    o_result_msg := 'OK';
	
	
	/*IF Plt_Common.DISABLE_ATLAS_TOLAS_SEND THEN
	    GOTO tempEnd;
	END IF;*/
	
	 /*-*/
	 /* set unique sequence number for file and add int file extension for use latter as the standard timestamp for all files
	 /* 
	 /*-*/
	 var_seq_no := LPAD(i_seq,8,'0') || cst_fil_ext ;

	 /*-*/
	 /* get EAN Code which is the same as GTIN Code 
	 /*-*/
	 OPEN csr_gtin;
        FETCH csr_gtin INTO var_work;
        IF  csr_gtin%NOTFOUND THEN
		      var_work := ' ';
	     END IF;	 
     CLOSE csr_gtin;
    
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
         
	IF i_BB_DATE IS NULL THEN
	    var_BB_DATE := ' ';
	ELSE
	    var_BB_DATE := i_BB_DATE;
	END IF;
    /*-*/
	/* reate REMOTE interface on MANU for GR or RGR message to Atlas
	/*-*/
    Manu_Remote_Loader.create_interface(cst_fil_path, cst_fil_name ||  var_seq_no);

	/*-*/
    /* HEADER: Header Record 
	/*-*/			
    Manu_Remote_Loader.append_data('HDR'
								||RPAD(TRIM(i_plt_code),20,' ')
                                ||RPAD(' ',5,' ')
                                ||RPAD(TRIM(i_MATERIAL_CODE),8,' ')
                                ||RPAD(var_work,14,' ')
								||RPAD(TRIM(i_ZPPPI_BATCH),10,' ')
								||RPAD(trim(var_BB_DATE),8,' ')
								||LPAD(i_QTY,4,' ')
								||RPAD(i_PLANT_CODE,4,' ')
								||'R'
								||RPAD(var_dispn,4, ' ')
								||RPAD(' ',12, ' ')
								);										
	  
    /*-*/
	/* Close Remote Interface and send Unix script 
    /*-*/
	Manu_Remote_Loader.finalise_interface(cst_prc_script ||  var_seq_no);
	
	 <<tempEnd>>
	 o_result := o_result;
	 
		
   EXCEPTION
     WHEN OTHERS THEN
	     IF (Manu_Remote_Loader.is_created()) THEN
	   	  Manu_Remote_Loader.finalise_interface(cst_prc_script ||  var_seq_no);
	     END IF;
		
        o_result := 1;
	     o_result_msg := 'Tolas_Ltds_Send failed error is - ['||SQLERRM||']';
       RAISE_APPLICATION_ERROR(-20001, o_result_msg);
END;
/


DROP PUBLIC SYNONYM TOLAS_LTDS_SEND;

CREATE PUBLIC SYNONYM TOLAS_LTDS_SEND FOR PT_APP.TOLAS_LTDS_SEND;


GRANT EXECUTE ON PT_APP.TOLAS_LTDS_SEND TO APPSUPPORT;

