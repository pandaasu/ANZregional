CREATE OR REPLACE PACKAGE PT_APP.PT_PDBTOL02_LTDS AS
/******************************************************************************
   NAME:       PT_PDBTOL02_LTDS
   PURPOSE:    Send the LTDS data to Tolas
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        20/09/2007      Jeff Phillipson       1. Created this package.
******************************************************************************/

  PROCEDURE EXECUTE(o_result         OUT NUMBER,
					o_result_msg      OUT VARCHAR2,
					i_message_type	  IN VARCHAR2,	-- Z_PI1 Create or Z_PI2 Reverse , Z_PI6 HU Reversal 
					i_plant_code	  IN VARCHAR2,
					i_material_code	  IN VARCHAR2,
					i_qty			  IN NUMBER,	   	-- Material Produced
					i_dispn_code	  IN VARCHAR2,	-- Stock Type
					i_zpppi_batch	  IN VARCHAR2,	-- ATLAS BATCH CODE
					i_bb_date		  IN VARCHAR2,	-- Best Before Date 
					i_plt_code		  IN VARCHAR2,
					i_seq			  IN VARCHAR2);

END PT_PDBTOL02_LTDS; 
/

CREATE OR REPLACE PACKAGE BODY PT_APP.Pt_Pdbtol02_Ltds AS
/******************************************************************************
   NAME:       PT_PDBTOL02_LTDS
   PURPOSE:    Send the LTDS data to Tolas
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        20/09/2007      Jeff Phillipson       1. Created this package.
******************************************************************************/

  PROCEDURE EXECUTE(o_result         OUT NUMBER,
					o_result_msg      OUT VARCHAR2,
					i_message_type	  IN VARCHAR2,	-- Z_PI1 Create or Z_PI2 Reverse , Z_PI6 HU Reversal 
					i_plant_code	  IN VARCHAR2,
					i_material_code	  IN VARCHAR2,
					i_qty			  IN NUMBER,	   	-- Material Produced
					i_dispn_code	  IN VARCHAR2,	-- Stock Type
					i_zpppi_batch	  IN VARCHAR2,	-- ATLAS BATCH CODE
					i_bb_date		  IN VARCHAR2,	-- Best Before Date 
					i_plt_code		  IN VARCHAR2,
					i_seq			  IN VARCHAR2)
	
AS
	
	/*-*/
	/* variables
	/*-*/
	var_work 			VARCHAR2(20); 
	var_seq_no          VARCHAR2(20);
	var_dispn			VARCHAR2(2);
	var_bb_date			VARCHAR2(12);
	var_success         NUMBER;
    var_db_value        VARCHAR2(4);
    exc_process_exception	EXCEPTION;
	
	
	/*-*/
	/* this value defines the interface sand server directory 
	/*-*/
	cst_file_name	   CONSTANT	VARCHAR2(20) := 'LTDS' || i_plant_code;
	cst_extension      CONSTANT VARCHAR2(4)  := '.int';
    cst_file_interface CONSTANT VARCHAR2(20) := 'PDBTOL02';
	
	/*-*/
	/* cursor definitions 
	/*-*/
	CURSOR csr_gtin IS
	SELECT EAN_CODE 
	  FROM material_vw
	 WHERE material_code = trim(i_material_code);
	  -- AND plant = i_plant_code;
       
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
              
BEGIN
    o_result := 0;
    o_result_msg := 'OK';
	
    OPEN csr_db;
          FETCH csr_db INTO var_db_value;
          IF csr_db%NOTFOUND THEN
              var_db_value := '.1';
          END IF;
      CLOSE csr_db;
      
	 /*-*/
	 /* set unique sequence number for file and add int file extension for use latter as the standard timestamp for all files
	 /*-*/
	 var_seq_no := LPAD(i_seq,8,'0') || cst_extension ;

	 /*-*/
	 /* get EAN Code which is the same as GTIN Code 
	 /*-*/
	 OPEN csr_gtin;
        FETCH csr_gtin INTO var_work;
        IF  csr_gtin%NOTFOUND THEN
		      var_work := ' ';
	     END IF;	 
     CLOSE csr_gtin;
    
	 IF i_dispn_code = ' ' THEN
	     -- unrestrited 
		  var_dispn := 'GD';
	 END IF;
	 IF i_dispn_code = 'S' THEN
		 -- blocked 
		 var_dispn := 'HD';
	 END IF;
	 IF i_dispn_code = 'X' THEN
	 	  -- QI - dont know the choice for this yet 
		  var_dispn := 'HD';
	 END IF; 
         
	IF i_bb_date IS NULL THEN
	    var_bb_date := ' ';
	ELSE
	    var_bb_date := i_bb_date;
	END IF;
    /*-*/
	/* reate REMOTE interface on MANU for GR or RGR message to Atlas
	/*-*/
    var_success := lics_outbound_loader.create_interface(cst_file_interface || var_db_value, cst_file_name || var_seq_no);

	/*-*/
    /* HEADER: Header Record 
	/*-*/			
    lics_outbound_loader.append_data('HDR'
								||RPAD(TRIM(i_plt_code),20,' ')
                                ||RPAD(' ',5,' ')
                                ||RPAD(TRIM(i_material_code),8,' ')
                                ||RPAD(var_work,14,' ')
								||RPAD(TRIM(i_ZPPPI_BATCH),10,' ')
								||RPAD(trim(var_bb_date),8,' ')
								||LPAD(i_QTY,4,' ')
								||RPAD(i_plant_code,4,' ')
								||'R'
								||RPAD(var_dispn,4, ' ')
								||RPAD(' ',12, ' ')
								);										
	  
    /*-*/
	/* Close Remote Interface and send Unix script 
    /*-*/
	lics_outbound_loader.finalise_interface();
	
    lics_logging.start_log('Tolas LTDS', 'Message type' || i_message_type);
    lics_logging.write_log('Pallet: ' || i_plt_code || ' Material code: ' || i_material_code || ' Quantity: ' || i_qty);
 	lics_logging.end_log;
		
   EXCEPTION
     WHEN OTHERS THEN
	     IF lics_outbound_loader.is_created() THEN
	   	     lics_outbound_loader.finalise_interface();
	     END IF;
		 IF NOT lics_logging.is_created THEN
             lics_logging.start_log('PT_PDBTOL02_LTDS failed', 'Message type' || i_message_type);
         END IF;
         lics_logging.write_log('PT_PDBTOL02_LTDS [' || SUBSTR(SQLERRM,0,1900) || ']');
 	     lics_logging.end_log;
         o_result := 1;
	     o_result_msg := 'PT_PDBTOL02_LTDS failed with error is - ['|| SUBSTR(SQLERRM,1,1000)||']';

   END EXECUTE;

END; 
/

