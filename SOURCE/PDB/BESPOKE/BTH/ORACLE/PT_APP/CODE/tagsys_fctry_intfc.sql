CREATE OR REPLACE PACKAGE PT_APP.Tagsys_Fctry_Intfc AS

    /******************************************************?
	 /* this package contains 4 fprocedures 
	 /*\
	 /*  This package is used for PETCARE - Bathurst and Wodonga only 
	 /*
	 /* Creat_Pllt - will perform a Goods receipt of either a pallet or process 
	 /* Cancel_Pllt - will reverse a process qty 
	 /* Cancel_HU_Pllt - will reverse a pallet from atlas ie cancel 
	 /******************************************************/
 
 
    /******************************************************/
 	 /* NOTE: This Package is not the same as the one used in Wanganui or Food 
 	 /* it has been modified to handle the new HANDLING UNITS (pallet codes)
 	 /* and the package now uses the REMOTE_LOADER for transfer of data
 	 /* from Oracle to a file location on the Plant Database Server.
 	 /* this is then transferred via MQ Series Light to the LADS server 
 	 /* where is is sent again via MQ Series to Atlas via the HUB 
 
 	 /* Developer 	 Jeff Phillipson 
 	 /* Date			 13 Jan 2006 
 
 	 /******************************************************/
 
   /******************************************************/
	/* Create_Pllt will record data in PT schema and send on to Atlas
	/* o_result - 0 for successfull
	/*      		- 1 for a failure 
	/* o_result_msg - if o_result is 1 then this will contain the error message 
	/******************************************************/
   PROCEDURE Create_Pllt(
	   o_result          IN OUT NUMBER,
	   o_result_msg      IN OUT VARCHAR2,
	   i_XACTN_DATE		 IN DATE,
	   i_PLANT_CODE		 IN VARCHAR2,
	   i_SENDER_NAME	 IN VARCHAR2,
	   i_ZPPPI_BATCH	 IN VARCHAR2,
	   i_PROC_ORDER		 IN NUMBER,
	   i_DISPN_CODE		 IN VARCHAR2,
	   i_USE_BY_DATE	 IN DATE,
	   i_MATERIAL_CODE	 IN VARCHAR2,
	   i_PLT_CODE		 IN VARCHAR2,
	   i_QTY			 IN NUMBER,
	   i_FULL_PLT_FLAG	 IN VARCHAR2,
	   i_USER_ID		 IN VARCHAR2,
	   i_LAST_GR_FLAG	 IN VARCHAR2,
		i_PLT_TYPE			   IN VARCHAR2,
		i_START_PRODN_DATE 	   IN DATE,
		i_END_PRODN_DATE  	   IN DATE
   );
   
	/******************************************************/
	/* Cancel_Pllt will cancel process only data in PT schema and send on to Atlas
	/* o_result - 0 for successfull
	/*      		- 1 for a failure 
	/* o_result_msg - if o_result is 1 then this will contain the error message 
	/******************************************************/
   PROCEDURE Cancel_Pllt(
	   o_result          IN OUT NUMBER,
	   o_result_msg      IN OUT VARCHAR2,
	   i_XACTN_DATE		  IN DATE,
	   i_SENDER_NAME		IN VARCHAR2,
	   i_PLT_CODE			IN VARCHAR2,
	   i_USER_ID			IN VARCHAR2
   );  
   
	/******************************************************/
	/* Cancel_HU_Pllt will cancel pallets only data in PT schema and send on to Atlas
	/* o_result - 0 for successfull
	/*      		- 1 for a failure 
	/* o_result_msg - if o_result is 1 then this will contain the error message 
	/******************************************************/
   PROCEDURE Cancel_HU_Pllt(
	   o_result          IN OUT NUMBER,
	   o_result_msg      IN OUT VARCHAR2,
	   i_XACTN_DATE		IN DATE,
	   i_SENDER_NAME		IN VARCHAR2,
	   i_PLT_CODE			IN VARCHAR2,
	   i_USER_ID			IN VARCHAR2
   );  
	
	
	/******************************************************/
	/* Create_Consumption will record data in PT schema and send on to Atlas 
	/* this will record consumption of any material used within a 
	/* valid process order 
	/* o_result - 0 for successfull
	/*      		- 1 for a failure 
	/* o_result_msg - if o_result is 1 then this will contain the error message 
	/******************************************************/
   PROCEDURE Create_Consumption(
	   o_result          IN OUT NUMBER,
	   o_result_msg      IN OUT VARCHAR2,
		i_trans_id			IN NUMBER, --  uniquie id 
		i_XACTN_DATE				IN DATE,
	   i_PLANT_CODE		IN VARCHAR2,
	   i_PROC_ORDER		IN VARCHAR2,
	   i_MATERIAL_CODE	IN VARCHAR2,
	   i_QTY					IN NUMBER
   );
	
 
   /******************************************************/
	/* Cancel_Consumption will cancel process only data in PT schema and send on to Atlas
	/* o_result - 0 for successfull
	/*      		- 1 for a failure 
	/* o_result_msg - if o_result is 1 then this will contain the error message 
	/******************************************************/
   PROCEDURE Cancel_Consumption(
	   o_result          IN OUT NUMBER,
	   o_result_msg      IN OUT VARCHAR2,
	   i_trans_id		 IN NUMBER, --  uniquie id 
	   i_XACTN_DATE		 IN DATE,
	   i_PLANT_CODE		 IN VARCHAR2,
	   i_PROC_ORDER		 IN VARCHAR2,
	   i_MATERIAL_CODE	 IN VARCHAR2,
	   i_QTY			 IN NUMBER
    );  
	
 END;
/

CREATE OR REPLACE PACKAGE BODY PT_APP.Tagsys_Fctry_Intfc AS
	
	 /******************************************************?
	 /* this package contains 4 procedures 
	 /*\
	 /*  This package is used for PETCARE - Bathurst and Wodonga only 
	 /*
	 /* Creat_Pllt - will perform a Goods receipt of either a pallet or process 
	 /* Cancel_Pllt - will reverse a process qty 
	 /* Cancel_HU_Pllt - will reverse a pallet from atlas ie cancel 
	 /******************************************************/
 
 
    /******************************************************/
 	 /* NOTE: This Package is not the same as the one used in Wanganui or Food 
 	 /* it has been modified to handle the new HANDLING UNITS (pallet codes)
 	 /* and the package now uses the REMOTE_LOADER for transfer of data
 	 /* from Oracle to a file location on the Plant Database Server.
 	 /* this is then transferred via MQ Series Light to the LADS server 
 	 /* where is is sent again via MQ Series to Atlas via the HUB 
 
 	 /* Developer 	 Jeff Phillipson 
 	 /* Date			 13 Jan 2006 
 
 	 /******************************************************/
   
   b_test_flag				BOOLEAN := FALSE; 
   
   /******************************************************/
	/* Create_Pllt will record data in PT schema and send on to Atlas
	/* o_result - 0 for successfull
	/*      		- 1 for a failure 
	/* o_result_msg - if o_result is 1 then this will contain the error message 
	/******************************************************/
   PROCEDURE Create_Pllt(
	   o_result                 IN OUT NUMBER,
	   o_result_msg             IN OUT VARCHAR2,
	   i_XACTN_DATE			    IN DATE,
	   i_PLANT_CODE			    IN VARCHAR2,
	   i_SENDER_NAME			IN VARCHAR2,
	   i_ZPPPI_BATCH			IN VARCHAR2,
	   i_PROC_ORDER			    IN NUMBER,
	   i_DISPN_CODE			    IN VARCHAR2,
	   i_USE_BY_DATE			IN DATE,
	   i_MATERIAL_CODE		    IN VARCHAR2,
	   i_PLT_CODE				IN VARCHAR2,
	   i_QTY					IN NUMBER,
	   i_FULL_PLT_FLAG		    IN VARCHAR2,
	   i_USER_ID				IN VARCHAR2,
	   i_LAST_GR_FLAG			IN VARCHAR2,
	   i_PLT_TYPE				IN VARCHAR2,
	   i_START_PRODN_DATE 		IN DATE,
	   i_END_PRODN_DATE  		IN DATE) AS
	   
		
		/*-*/
		/* variables 
		/*-*/
	    b_last_gr_flag			 BOOLEAN := FALSE;
	    v_count                  NUMBER := 0;
      	v_transaction_type       VARCHAR2(10);
      	v_result                 NUMBER DEFAULT 0;
      	v_result_msg             VARCHAR2(2000);
      	v_batch                  VARCHAR2(10);
		v_start_prodn_date		 VARCHAR2(20);
		v_end_prodn_date		 VARCHAR2(20);
		v_work					 NUMBER;
		v_work1					 VARCHAR2(10);
		
		
		v_seq					 NUMBER;
       
       	TRANS_TYPE               VARCHAR2(10) DEFAULT 'CREATE';
		
		e_process_exception      EXCEPTION;
	   	e_IDOC_EXCEPTION		 EXCEPTION;
		
		CURSOR csr_matl IS
		SELECT issue_strg_locn, 
		       DECODE(base_uom,'KGM','KG', base_uom) uom 
		  FROM matl
		 WHERE LTRIM(matl_code,'0') = i_material_code
		   AND plant = i_plant_code;
		
		
BEGIN

   o_result := Plt_Common.SUCCESS;
   o_result_msg := 'Pallet ' || i_plt_code || ' created';
	
	/*-*/
	/* set prodn times to 6 char strings 
	/*-*/
	v_start_prodn_date := i_start_prodn_date;
   v_end_prodn_date := i_end_prodn_date;
	
   /**********************************************************************************/
   /* VALIDATE data BEFORE saving IN TABLE 
   /**********************************************************************************/
	
   /*-*/
   /*  Check if Pallet Code exists in the pallet tables
   /*-*/
   SELECT COUNT(*) INTO v_count
   FROM PLT_HDR
   WHERE plt_code = TO_CHAR(i_plt_code);
   IF v_count > 0 THEN
      o_result_msg := 'Transaction Failed: Pallet code already exists. Please select a unique value.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception; 
   END IF;
   
   /*-*/
   /*  check validity of date - transaction date cannot be null
   /*-*/
   IF i_XACTN_DATE IS NULL THEN
      o_result_msg := 'Transaction Date cannot be Null.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   END IF;
   
   /*-*/
   /* check plant code is valid and not null
   /*-*/
   IF i_plant_code IS NULL THEN
      o_result_msg := 'Plant Code cannot be Null.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   ELSE
       SELECT COUNT(*) INTO v_count FROM manu.REF_PLANT 
       WHERE plant = i_plant_code;
       IF v_count = 0 THEN
           o_result_msg := 'Plant Code is not correct.';
           o_result := Plt_Common.FAILURE;
           RAISE e_process_exception;
       END IF;
   END IF;
   
   /*-*/
   /* check for valid proc order
   /*-*/
   IF i_proc_order IS NULL THEN
      o_result_msg := 'Proc Order is not valid.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   ELSE
       IF SUBSTR(i_proc_order,1,2) <> '99' THEN
          SELECT COUNT(*) INTO v_count FROM manu.CNTL_REC 
          WHERE LTRIM(proc_order,'0') = LTRIM(TO_CHAR(i_proc_order),'0');
          IF v_count = 0 THEN
              o_result_msg := 'Proc Order is not valid.';
              o_result := Plt_Common.FAILURE;
           RAISE e_process_exception;
          END IF;
       END IF;
   END IF;
   
   /*-*/
   /* check for a valid material code 
   /*-*/
   IF i_material_code IS NULL THEN
      o_result_msg := 'Material Code cannot be Null.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   ELSE
       SELECT COUNT(*) INTO v_count FROM matl 
       WHERE matl_code = i_material_code;
       IF v_count = 0 THEN
           o_result_msg := 'Material Code is not correct.';
           o_result := 1;
           RAISE e_process_exception;
       END IF;
   END IF;
   
   /*-*/
   /* check validity of qty 
   /*-*/
   IF i_Qty = 0 THEN
      o_result_msg := 'Quantity cannot be Null.';
      o_result :=Plt_Common.FAILURE;
      RAISE e_process_exception;
   END IF;
   
  
   /*-*/
   /* check validity of best before date
   /*-*/
   IF LENGTH(i_plt_code) > 12 THEN
       IF i_USE_BY_DATE IS NULL THEN
           o_result_msg := 'Best before date cannot be Null.';
           o_result :=Plt_Common.FAILURE;
           RAISE e_process_exception;
       END IF;
   END IF;
   
   
   /*-*/
   /* check disposition code 
   /*-*/
   /***********************************************************************************
    DISPOSITION STATUS 
   ********************
   Blocked            = 'S'
   Un Restricted      = ' '
   Quality Inspect    = 'X'
   ************************************************************************************/
   
   IF i_DISPN_CODE IS NULL THEN
      o_result_msg := 'Disposition cannot be Null.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   ELSE
       IF i_DISPN_CODE <> ' ' AND i_DISPN_CODE <> 'S' AND i_DISPN_CODE <> 'X' THEN
           o_result_msg := 'Disposition is not a valid value - Blank, ''S'' or ''X''.';
           o_result := Plt_Common.FAILURE;
           RAISE e_process_exception;
       END IF;
   END IF;
   

   /*-*/																											 
   /* get storage location, uom  
   /*-*/
   BEGIN
       OPEN csr_matl;
   	       LOOP
               FETCH csr_matl INTO v_work, v_work1;
       	       EXIT WHEN csr_matl%NOTFOUND;
           END LOOP;
       CLOSE csr_matl;
   EXCEPTION
       WHEN OTHERS THEN
           o_result_msg := 'Failed to get the MATL data from the view RETURN ['
               || SQLCODE || '-' || SUBSTR(SQLERRM,1,255) ||']';
           o_result := Plt_Common.FAILURE;
		   RAISE e_process_exception;
   END;
   
   
      /**********************************************************************************/
      /* Save data in Pallet tables
      /**********************************************************************************/
      BEGIN
      
           IF i_ZPPPI_BATCH IS NULL THEN
               v_batch := ' ';
           ELSE
               -- FG 
               v_batch := SUBSTR(i_ZPPPI_BATCH,1,30);
           END IF;
            
           /**********************************************************************************/
           /* Insert record into header table
           /**********************************************************************************/
	  	     INSERT INTO PT.PLT_HDR (
				  	      PLT_CODE,
                  		  MATL_CODE,
                  		  QTY,
                  		  STATUS,
				  		  PLANT_CODE,
   				  		  ZPPPI_BATCH,
				  		  PROC_ORDER,
				  		  STOR_LOCN_CODE,
   				  		  DISPN_CODE,
				  		  USE_BY_DATE,
   				  		  FULL_PLT_FLAG,
                  		  LAST_GR_FLAG,
				  		  PLT_CREATE_DATIME,
                  		  UOM,
						  PLT_TYPE,
						  START_PRODN_DATIME,
						  END_PRODN_DATIME)
              VALUES (i_Plt_Code,
                  	 i_MATERIAL_CODE,
                  	 i_QTY,
                  	 TRANS_TYPE,
	 			  	 i_PLANT_CODE,
	 			  	 v_batch,
                  	 TO_CHAR(i_PROC_ORDER),
                  	 v_work,
   				  	 i_DISPN_CODE, 
	 			  	 i_USE_BY_DATE,
                  	 i_FULL_PLT_FLAG,
                  	 i_LAST_GR_FLAG,
   				  	 SYSDATE,
	 			  	 v_work1,
					 i_PLT_TYPE,
					 i_start_prodn_date,
					 i_end_prodn_date
				  	 );
                 
          /**********************************************************************************/                 
          /* Insert detail record 
          /**********************************************************************************/
          INSERT INTO  PLT_DET (
                  PLT_CODE,
                  XACTN_TYPE,
                  USER_ID,
                  REASON,
                  XACTN_DATE,
                  XACTN_TIME,
                  SENDER_NAME
                  )
              VALUES (
                  i_PLT_CODE,
                  TRANS_TYPE,
                  UPPER(i_USER_ID),
                  TRANS_TYPE,
                  TRUNC(i_Xactn_Date),
                  TO_NUMBER(TO_CHAR(i_Xactn_date,'HH24MISS')),
                  UPPER(i_Sender_Name)
                  );         
             COMMIT;
			   
        EXCEPTION
          WHEN OTHERS THEN
              o_result_msg := 'INSERT (CREATE) INTO pt.plt_hdr and plt_det FAILED, RETURN ['
               || SQLCODE || '-' || SUBSTR(SQLERRM,1,255) ||']';
			   ROLLBACK;
              o_result := Plt_Common.FAILURE;
			  RAISE e_process_exception;
        END;

        
	
		  
		/*-*/
		/* only send if the pallet code is areal Atlas code
		/* anything begining with 99 is a dummy - local code
		/* This will still allow FG Pallet Codes and Process to be sent
		/* Process will use an auto generated id for plt codes this will be less than 
		/* 10 digits long
		/*-*/
	    IF SUBSTR(i_proc_order,1,2) <> '99' THEN
			 	
			v_transaction_type := 'Z_PI1';
				
			IF (i_LAST_GR_FLAG = 'Y') THEN
			   b_last_gr_flag := TRUE;
			END IF;

				
			/*-*/
			/* if the hold flag is not set then send the files to Atlas and Tolas
			/*-*/
            IF NOT Idoc_Hold THEN
				
				/**********************************************************************************/
        		/* Create Idoc package for Create
        		/**********************************************************************************/  
	
				BEGIN
				
				    /*-*/
					/* Make call to create iDOC 
				    /*-*/
					 Goods_Recipte_Send(v_result,
                            v_result_msg,
                            v_transaction_type,
	   				        i_PLANT_CODE,
	   						i_SENDER_NAME || ':' || SUBSTR(i_PLT_CODE,1,18), --i_SENDER_NAME,
	   						b_TEST_FLAG,
	   						i_PROC_ORDER,
	   						TRUNC(i_XACTN_DATE),
	   						TO_NUMBER(TO_CHAR(i_Xactn_date,'HH24MISS')),
	   						i_MATERIAL_CODE,
	   						i_QTY,
	   						v_work1,
	   						v_work,
	   						i_DISPN_CODE,
	   						v_batch,
	   						b_LAST_GR_FLAG,
							TO_CHAR(i_USE_BY_DATE,'YYYYMMDD'),
							i_PLT_CODE,
							i_PLT_TYPE,
							'CHEP',
							TRUNC(i_start_prodn_date),
							TO_NUMBER(TO_CHAR(i_start_prodn_date,'HH24MISS')),
							TRUNC(i_end_prodn_date),
							TO_NUMBER(TO_CHAR(i_end_prodn_date,'HH24MISS'))
							);
						
						COMMIT;
						
				EXCEPTION
				    WHEN OTHERS THEN
		                o_result_msg := 'Call to Goods_Recipte_Send (create) Failed ['|| SQLCODE || ' ' || SUBSTR(SQLERRM,1,255) ||']';
                        o_result := Plt_Common.FAILURE;
                        ROLLBACK;
			            RAISE   e_process_exception;
				END;
				
			
				BEGIN
				
			        IF v_result = 0 THEN
			            UPDATE PT.PLT_DET
				           SET SENT_FLAG = 'Y'
				         WHERE PLT_CODE = UPPER(i_PLT_CODE);  
			        ELSE
                        /*-*/
				        /*  error has occured 
                        /*  INSERT RECORD IN LOG FILE 
				        /* and a retry will be made latter
				        /*-*/
                        o_result_msg := v_result_msg;
                        o_result := v_result;
                 
				        INSERT INTO PLT_IDOC_LOG
                        VALUES (i_PLT_CODE, TRANS_TYPE, 0, 'FAIL', o_result_msg, SYSDATE, 1);
         
			        END IF;
					
			    EXCEPTION
				    WHEN OTHERS THEN
		                o_result_msg := 'Insert SEND flag (create) Failed ['|| SQLCODE || ' ' || SUBSTR(SQLERRM,1,255) ||']';
                        o_result := Plt_Common.FAILURE;
			            RAISE   e_process_exception;
				END;
				    
            END IF; -- on not on Hold section complete 
			 
			  
			
			/*-*/
			/* only send Tolas files if the Pallet Code is for a Finished Good
			/*-*/
			IF LENGTH(i_PLT_CODE) > 10 AND LENGTH(LTRIM(i_material_code,'0')) = 8 THEN
				
				/*-*
				/* get a sequence number for the Tolas interface
				/*-*/
				BEGIN
				    SELECT PLT_TOLAS_SEQ.NEXTVAL INTO v_seq FROM dual;
					INSERT INTO plt_tolas
					VALUES (i_plt_code, v_seq);
				END;
					 
				BEGIN
				    /*-*/
					/* only for Plant codes Cannery and Bathurst 
					/*-*/
					IF i_PLANT_CODE = 'AU20'  OR  i_PLANT_CODE = 'AU30' THEN
				        /*-*/
						/* send the FDS file to Tolas
						/* this file is based on plant and will be assigned to a different queue for the 2 Plant Codes
						/* defined in the If statement
						/*-*/
						Tolas_Fds_Send(v_result,
                         					 v_result_msg,
											 v_transaction_type,
	   				     					 i_PLANT_CODE,
	   										 i_SENDER_NAME || ':' || SUBSTR(i_PLT_CODE,1,18), 
	   										 b_TEST_FLAG,
	   										 i_PROC_ORDER,
	   										 TRUNC(i_XACTN_DATE),
	   										 TO_NUMBER(TO_CHAR(i_Xactn_date,'HH24MISS')),
	   										 i_MATERIAL_CODE,
	   										 i_QTY,
	   										 v_work1,
	   										 v_work,
	   										 i_DISPN_CODE,
	   										 v_batch,
											 TO_CHAR(i_USE_BY_DATE,'YYYYMMDD'),
											 i_PLT_CODE,
											 i_PLT_TYPE,
											 'CHEP',
											 TRUNC(i_start_prodn_date),
											 TO_NUMBER(TO_CHAR(i_start_prodn_date,'HH24MISS')),
											 TRUNC(i_end_prodn_date),
											 TO_NUMBER(TO_CHAR(i_end_prodn_date,'HH24MISS')),
											 TO_CHAR(LPAD(v_seq,8,'0')));
				    END IF;
											 
					
					/*-*/
					/* the LDTS file is sent to the same queue for all plants
					/* for Petcare
					/*-*/
					Tolas_Ltds_Send(v_result,
                        			 v_result_msg,
									 v_transaction_type,
	   				      			 i_PLANT_CODE,
	   								 i_MATERIAL_CODE,
	   								 i_QTY,
	   								 i_DISPN_CODE,
	   								 v_batch,
									 TO_CHAR(i_USE_BY_DATE,'YYYYMMDD'),
									 i_PLT_CODE,
									 TO_CHAR(LPAD(v_seq,8,'0')));
					COMMIT;
					
			    EXCEPTION
				    WHEN OTHERS THEN
		                o_result_msg := 'Call to Tolas_Send (create) Failed ['|| SQLCODE || ' ' || SUBSTR(SQLERRM,1,255) ||']';
                        o_result := Plt_Common.FAILURE;
                        ROLLBACK;
			            RAISE   e_process_exception;
				END;
			END IF;  -- end of send if pallet code is a real code 
								
        ELSE
		    UPDATE PT.PLT_DET
			   SET SENT_FLAG = 'X'
		    WHERE PLT_CODE = UPPER(i_PLT_CODE);        
                          
		END IF; -- end of Temp pallet or FG/Process pallet
      		
   EXCEPTION
       WHEN e_process_exception THEN
           o_result := Plt_Common.FAILURE;
           -- RAISE_APPLICATION_ERROR(-20001, o_result_msg);
		   ROLLBACK;
	    WHEN e_IDOC_EXCEPTION THEN
           COMMIT;
           o_result := Plt_Common.SUCCESS;
		     -- RAISE_APPLICATION_ERROR(-20000, o_result_msg);
       WHEN OTHERS THEN
           o_result := Plt_Common.FAILURE;
           ROLLBACK;
           o_result_msg := 'ERROR OCCURED'||SQLCODE || '-' || SUBSTR(SQLERRM,1,255);
          --  RAISE_APPLICATION_ERROR(-20000, o_result_msg);
  END;




/**********************************************************************************/
/* Cancel Pallet record - special for Handling Units 
/* - the pallet record has to exist and it should be CREATE status
/**********************************************************************************/
      
      
PROCEDURE Cancel_Pllt(o_result      IN OUT NUMBER,
	   	 			 o_result_msg   IN OUT VARCHAR2,
	   				 i_XACTN_DATE	IN DATE,
	   				 i_SENDER_NAME	IN VARCHAR2,
	   				 i_PLT_CODE		IN VARCHAR2,
	   				 i_USER_ID		IN VARCHAR2
       				 )
       				AS
   	   
	   
	  
	   b_last_gr_flag		BOOLEAN := FALSE;
       v_count              NUMBER;
	   v_transaction_type   VARCHAR2(10);
       v_result             NUMBER;
       v_result_msg         VARCHAR2(2000);
       v_proc_order         VARCHAR2(12);
	   e_process_exception  EXCEPTION;
	   e_IDOC_EXCEPTION		EXCEPTION;
       
      TRANS_TYPE           VARCHAR2(10) DEFAULT 'CANCEL';
       
      CURSOR c_get_plt IS
         SELECT h.*, sent_flag
           FROM PLT_HDR h, PLT_DET d
          WHERE h.plt_code = i_plt_code
            AND h.PLT_CODE = d.PLT_CODE
            AND d.xactn_type = 'CREATE';
       
      r_plt  c_get_plt%ROWTYPE;
       
       
BEGIN

   o_result := Plt_Common.SUCCESS;
   o_result_msg := 'Pallet ' || i_plt_code || ' cancelled';
   
   
   /**********************************************************************************/
   /* VALIDATE data BEFORE saving IN TABLE
   /**********************************************************************************/

   
   SELECT COUNT(*) INTO v_count
    FROM PLT_HDR
   WHERE plt_code = i_plt_code
     AND STATUS = 'CREATE';
	  
   IF v_count <> 1 THEN
      o_result_msg := 'Transaction Failed: A Pallet record with status ''CREATE'' has to exist.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   END IF;
  
   SELECT COUNT(*) INTO v_count
     FROM PLT_HDR
    WHERE plt_code = i_plt_code
      AND STATUS = 'CANCEL';
		
   IF v_count > 0 THEN
      o_result_msg := 'Transaction Failed: A Pallet record with status ''CANCEL'' already exists.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   END IF;
   
   -- check validity of dates
   IF i_XACTN_DATE IS NULL THEN
      o_result_msg := 'Transaction Date cannot be Null.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   END IF;
   
   -- check SEnder name
   IF i_Sender_name IS NULL THEN
      o_result_msg := 'Sender Name cannot be Null for a Cancel Pallet.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   END IF;
   
   
   v_transaction_type := 'Z_PI2'; -- set atlas type code 
   
   -- get rest of pallet data 
   OPEN c_get_plt;
   FETCH c_get_plt INTO r_plt;
   LOOP
       EXIT WHEN c_get_plt%NOTFOUND;
   
       -- check Sif Sent Flag is set - if not warn shiftlog to get it fixed before Cancelling Pallet
       /*
       IF r_plt.Sent_flag IS NULL THEN
           o_result_msg := 'Warning the Pallet ingformation has not been sent to Atlas.' || CHR(13) 
                            || ' Please consult your Support team.';
           o_result := Plt_Common.FAILURE;
           RAISE e_process_exception;
       END IF;
       */
   
   
   
       /**********************************************************************************/
       /* Save data in Pallet tables
       /**********************************************************************************/

       BEGIN
	  	   UPDATE PT.PLT_HDR 
               SET STATUS = TRANS_TYPE
               WHERE plt_code = r_plt.Plt_Code;
	  	   
   
         /**********************************************************************************/                 
         /* Insert detail record 
         /**********************************************************************************/
         INSERT INTO  PLT_DET (
                  PLT_CODE,
                  XACTN_TYPE,
                  USER_ID,
                  REASON,
                  XACTN_DATE,
                  XACTN_TIME,
                  SENDER_NAME,
						ATLAS_TYPE
                  )
              VALUES (
                  i_PLT_CODE,
                  TRANS_TYPE,
                  UPPER(i_USER_ID),
                  TRANS_TYPE,
                  TRUNC(i_Xactn_Date),
                  TO_NUMBER(TO_CHAR(i_Xactn_date,'HH24MISS')),
                  UPPER(i_Sender_Name),
						v_transaction_type
                  ); 
                  
                      
            
      EXCEPTION
         WHEN OTHERS THEN
            o_result := Plt_Common.FAILURE;
            o_result_msg := 'UPDATE (CANCEL) INTO pt.plt_hdr and plt_det FAILED, RETURN ['
               ||SUBSTR(SQLERRM,1,255) ||']';
      END;

      /**********************************************************************************/
      /* Create Idoc package for Cancel 
      /**********************************************************************************/

      IF NOT Idoc_Hold THEN
		BEGIN
        
             SELECT proc_order INTO v_proc_order
             FROM PLT_HDR
             WHERE plt_code = i_plt_code;
             
			 IF SUBSTR(v_proc_order,1,2) <> '99'  THEN
			 	
				
				IF r_plt.LAST_GR_FLAG = 'Y' THEN
                b_last_gr_flag := TRUE;
            ELSE
                b_last_gr_flag := FALSE;
            END IF;

                
                
				    -- Make call to create iDOC
				    Goods_Recipte_Send(v_result,
	                         v_result_msg,
                            v_transaction_type,
	   						  	 trim(r_plt.PLANT_CODE),
	   							 i_SENDER_NAME || ':' || SUBSTR(i_PLT_CODE,1,18), --i_SENDER_NAME,
	   							 b_TEST_FLAG,
	   							 TO_NUMBER(r_plt.PROC_ORDER),
	   							 TRUNC(i_XACTN_DATE),
	   							 TO_NUMBER(TO_CHAR(i_Xactn_date,'HH24MISS')),
	   							 r_plt.MATL_CODE,
	   							 r_plt.QTY,
	   							 r_plt.UOM,
	   							 TO_NUMBER(r_plt.STOR_LOCN_CODE),
	   							 r_plt.DISPN_CODE,
	   							 r_plt.ZPPPI_BATCH,
	   							 b_last_gr_flag,
									 TO_CHAR(r_plt.USE_BY_DATE,'YYYYMMDD'),
									 i_plt_Code,
									 r_plt.plt_type,
									 '1095',
									 TRUNC(SYSDATE), -- dummy entry 
									 0, 				  -- dummy entry 
									 TRUNC(SYSDATE), -- dummy entry 
									 0 				  -- dummy entry 
									 );
                
                 
                IF v_result <> 0 THEN
                    -- error has occured 
                    -- insert record in log file
                    o_result_msg := v_result_msg;
                    o_result := v_result;
                    INSERT INTO PLT_IDOC_LOG
                        VALUES (i_PLT_CODE, TRANS_TYPE, 0, 'FAIL',o_result_msg, SYSDATE, o_result);
                    o_result_msg := '';
                    o_result := Plt_Common.SUCCESS;
                    RAISE e_IDOC_EXCEPTION;
                END IF;
                 
			 END IF;
 
		EXCEPTION
		    WHEN OTHERS THEN
		        o_result_msg := 'Call to Goods_Recipte_Send Failed ['||SQLERRM||']';
                o_result := Plt_Common.FAILURE;
			    RAISE e_process_exception;
		END;
      END IF;
        
		BEGIN
		    IF SUBSTR(v_proc_order,1,2) = '99' THEN
			    UPDATE PT.PLT_DET
				SET SENT_FLAG = 'X'
				WHERE PLT_CODE = UPPER(i_PLT_CODE);
			ELSE
                IF NOT Idoc_Hold THEN
			          UPDATE PT.PLT_DET
				          SET SENT_FLAG = 'Y'
				        WHERE PLT_CODE = UPPER(i_PLT_CODE);
                END IF;
			END IF;

		EXCEPTION
		   WHEN OTHERS THEN
		       o_result_msg :=  '<TAGSYS_FCTRY_INTFC.Cancel_Pllt> Error updating sent flag on pts_intfc: ['||SQLERRM||']';
               o_result := Plt_Common.FAILURE;
		       RAISE e_process_exception;
		END;
        
        EXIT;
        
   END LOOP;
   CLOSE c_get_plt;
       
   
   COMMIT;

EXCEPTION
     WHEN e_process_exception THEN
         o_result := Plt_Common.FAILURE;
         -- RAISE_APPLICATION_ERROR(-20001, o_result_msg);
	 WHEN e_IDOC_EXCEPTION THEN
         COMMIT;
         o_result := Plt_Common.SUCCESS;
		 -- RAISE_APPLICATION_ERROR(-20000, o_result_msg);
     WHEN OTHERS THEN
         o_result := Plt_Common.FAILURE;
         ROLLBACK;
         o_result_msg := 'ERROR OCCURED'||SQLERRM(SQLCODE);
         -- RAISE_APPLICATION_ERROR(-20000, o_result_msg);
END;



/**********************************************************************************/
/* Cancel Pallet record - special for Handling Units 
/* - the pallet record has to exist and it should be CREATE status
/**********************************************************************************/  
PROCEDURE Cancel_HU_Pllt(o_result      IN OUT NUMBER,
	   	 				 o_result_msg  IN OUT VARCHAR2,
	   					 i_XACTN_DATE	IN DATE,
	   					 i_SENDER_NAME	IN VARCHAR2,
	   					 i_PLT_CODE		IN VARCHAR2,
	   					 i_USER_ID		IN VARCHAR2
       					 )
       					 AS
   	   
	   
	  
	   b_last_gr_flag		BOOLEAN := FALSE;
       v_count              NUMBER;
	   v_transaction_type   VARCHAR2(10);
       v_result             NUMBER;
       v_result_msg         VARCHAR2(2000);
       v_proc_order         VARCHAR2(12);
	   v_seq				NUMBER;
	   
	   e_process_exception  EXCEPTION;
	   e_IDOC_EXCEPTION		EXCEPTION;
       
      TRANS_TYPE           VARCHAR2(10) DEFAULT 'CANCEL';
       
      CURSOR c_get_plt IS
         SELECT h.*, sent_flag
           FROM PLT_HDR h, PLT_DET d
          WHERE h.plt_code = i_plt_code
            AND h.PLT_CODE = d.PLT_CODE
            AND d.xactn_type = 'CREATE';
       
      r_plt  c_get_plt%ROWTYPE;
       
       
BEGIN

   o_result := Plt_Common.SUCCESS;
   o_result_msg := 'Pallet ' || i_plt_code || ' cancelled';
   
   
   /**********************************************************************************/
   /* VALIDATE data BEFORE saving IN TABLE
   /**********************************************************************************/

   
   SELECT COUNT(*) INTO v_count
    FROM PLT_HDR
   WHERE plt_code = i_plt_code
     AND STATUS = 'CREATE';
	  
   IF v_count <> 1 THEN
      o_result_msg := 'Transaction Failed: A Pallet record with status ''CREATE'' has to exist.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   END IF;
  
   SELECT COUNT(*) INTO v_count
     FROM PLT_HDR
    WHERE plt_code = i_plt_code
      AND STATUS = 'CANCEL';
		
   IF v_count > 0 THEN
      o_result_msg := 'Transaction Failed: A Pallet record with status ''CANCEL'' already exists.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   END IF;
   
   -- check validity of dates
   IF i_XACTN_DATE IS NULL THEN
      o_result_msg := 'Transaction Date cannot be Null.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   END IF;
   
   -- check SEnder name
   IF i_Sender_name IS NULL THEN
      o_result_msg := 'Sender Name cannot be Null for a Cancel Pallet.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   END IF;
   
   v_transaction_type := 'Z_PI6'; -- set atlas type code 
   
   
   -- get rest of pallet data 
   OPEN c_get_plt;
   FETCH c_get_plt INTO r_plt;
   LOOP
       EXIT WHEN c_get_plt%NOTFOUND;
   
      
   
   
   
       /**********************************************************************************/
       /* Save data in Pallet tables
       /**********************************************************************************/

       BEGIN
	  	   UPDATE PT.PLT_HDR 
               SET STATUS = TRANS_TYPE
               WHERE plt_code = r_plt.Plt_Code;
	  	   
   
           /**********************************************************************************/                 
           /* Insert detail record 
           /**********************************************************************************/
           INSERT INTO  PLT_DET (
                  PLT_CODE,
                  XACTN_TYPE,
                  USER_ID,
                  REASON,
                  XACTN_DATE,
                  XACTN_TIME,
                  SENDER_NAME,
				  ATLAS_TYPE
                  )
              VALUES (
                  i_PLT_CODE,
                  TRANS_TYPE,
                  UPPER(i_USER_ID),
                  TRANS_TYPE,
                  TRUNC(i_Xactn_Date),
                  TO_NUMBER(TO_CHAR(i_Xactn_date,'HH24MISS')),
                  UPPER(i_Sender_Name),
				  v_transaction_type 
                  ); 
                  
                      
            
      EXCEPTION
         WHEN OTHERS THEN
            o_result := Plt_Common.FAILURE;
            o_result_msg := '<TAGSYS_FCTRY_INTFC.Cancel_HU_Pllt> UPDATE INTO pt.plt_hdr and plt_det FAILED, RETURN ['
               ||SUBSTR(SQLERRM,1,255) ||']';
      END;

      /**********************************************************************************/
      /* Create Idoc package for Cancel 
      /**********************************************************************************/
	  /*-*/
	  /* first get the process order number
	  /*-*/
	  SELECT proc_order INTO v_proc_order
        FROM PLT_HDR
       WHERE plt_code = i_plt_code;
		   
      
		BEGIN
      		 /*-*/
			 /* only send cancel to Atlas and Tolas if the pallet code is a valid value
			 /*-*/
			 IF SUBSTR(v_proc_order,1,2) <> '99'  THEN
			 	
				
				IF r_plt.LAST_GR_FLAG = 'Y' THEN
                    b_last_gr_flag := TRUE;
                ELSE
                    b_last_gr_flag := FALSE;
                END IF;

                IF NOT Idoc_Hold THEN
				    /*-*/
					/* Make call to create iDOC
					/*-*/
					Goods_Recipte_Send(v_result,
	                              v_result_msg,
                            	  v_transaction_type,
	   						  	  trim(r_plt.PLANT_CODE),
	   							  i_SENDER_NAME || ':' || SUBSTR(i_PLT_CODE,1,18), --i_SENDER_NAME,
	   							  b_TEST_FLAG,
	   							  TO_NUMBER(r_plt.PROC_ORDER),
	   							  TRUNC(i_XACTN_DATE),
	   							  TO_NUMBER(TO_CHAR(i_Xactn_date,'HH24MISS')),
	   							  r_plt.MATL_CODE,
	   							  r_plt.QTY,
	   							  r_plt.UOM,
	   							  TO_NUMBER(r_plt.STOR_LOCN_CODE),
	   							  r_plt.DISPN_CODE,
	   							  r_plt.ZPPPI_BATCH,
	   							  b_last_gr_flag,
								  TO_CHAR(r_plt.USE_BY_DATE,'YYYYMMDD'),
								  i_plt_Code,
								  r_plt.plt_type,
								  '',
								  TRUNC(SYSDATE), -- dummy entry 
								  0, 			  -- dummy entry 
								  TRUNC(SYSDATE), -- dummy entry 
								  0 			  -- dummy entry 
								  );
                
                    /*-*/
					/* set sent flag if no errors found
					/*-*/
                    IF v_result <> 0 THEN
                        -- error has occured 
                        -- insert record in log file
                        o_result_msg := v_result_msg;
                        o_result := v_result;
                        INSERT INTO PLT_IDOC_LOG
                        VALUES (i_PLT_CODE, TRANS_TYPE, 0, 'FAIL', SUBSTR(o_result_msg,0,500), SYSDATE, o_result);
                        o_result_msg := '';
                        o_result := Plt_Common.SUCCESS;
                        RAISE e_IDOC_EXCEPTION;
                    END IF;
            
			    END IF; 
				
			
			END IF;
 
		EXCEPTION
		    WHEN OTHERS THEN
		        o_result_msg := '<TAGSYS_FCTRY_INTFC.Cancel_HU_Pllt> Error: Call to Goods_Recipte_Send Failed ['||SUBSTR(SQLERRM,0,255)||']';
                o_result := Plt_Common.FAILURE;
			    RAISE e_process_exception;
		END;
     
      
	   /*-*/
	   /* insert the sent flag if everything ok
	   /*-*/  
	   BEGIN
		    IF SUBSTR(v_proc_order,1,2) = '99' THEN
			    UPDATE PT.PLT_DET
				SET SENT_FLAG = 'X'
				WHERE PLT_CODE = UPPER(i_PLT_CODE);
			ELSE
                IF NOT Idoc_Hold THEN
			          UPDATE PT.PLT_DET
				          SET SENT_FLAG = 'Y'
				        WHERE PLT_CODE = UPPER(i_PLT_CODE);
                END IF;
			END IF;

		EXCEPTION
		   WHEN OTHERS THEN
		       o_result_msg :=  '<TAGSYS_FCTRY_INTFC.Cancel_HU_Pllt> Error updating sent flag on pts_intfc: ['||SQLERRM||']';
               o_result := Plt_Common.FAILURE;
		       RAISE e_process_exception;
		END;
		/*-*/
		/* Cancel sent to atlas
		/*-*/
		
		
		/*-*/
		/* now send Tolas Files if required
		/*-*/
		BEGIN
		    /*-*/
			/* only for Plant codes Cannery and Bathurst 
			/*-*/
			IF r_plt.plant_code = 'AU20'  OR  r_plt.PLANT_CODE = 'AU30' THEN
			
			    /*-*/
				/* get a sequence number for the Tolas interface
				/*-*/
				BEGIN
					 SELECT PLT_TOLAS_SEQ.NEXTVAL INTO v_seq FROM dual;
					 INSERT INTO plt_tolas
					 VALUES (i_plt_code, v_seq);
				END;
					
					
				/*-*/
				/* send the FDS file to Tolas
				/* this file is based on plant and will be assigned to a different queue for the 2 Plant Codes
				/* defined in the If statement
				/*-*/
				Tolas_Fds_Send(v_result,
                    		v_result_msg,
							v_transaction_type,
	   				     	r_plt.PLANT_CODE,
	   						i_SENDER_NAME || ':' || SUBSTR(i_PLT_CODE,1,18), 
	   						b_TEST_FLAG,
	   						v_PROC_ORDER,
	   						TRUNC(i_XACTN_DATE),
	   						TO_NUMBER(TO_CHAR(i_Xactn_date,'HH24MISS')),
	   						r_plt.MATL_CODE,
	   						r_plt.QTY,
	   						r_plt.uom,
	   						r_plt.stor_locn_code,
	   						r_plt.DISPN_CODE,
	   						r_plt.zpppi_batch,
							TO_CHAR(r_plt.USE_BY_DATE,'YYYYMMDD'),
							i_PLT_CODE,
							r_plt.PLT_TYPE,
							'CHEP',
							TRUNC(SYSDATE), -- dummy entry 
							0, 			    -- dummy entry 
							TRUNC(SYSDATE), -- dummy entry 
							0, 			    -- dummy entry 
							TO_CHAR(LPAD(v_seq,8,'0')));
			END IF;
											 
					
			
		
		EXCEPTION
		    WHEN OTHERS THEN
		       o_result_msg :=  '<TAGSYS_FCTRY_INTFC.Cancel_HU_Pllt> Error sending Tolas files: ['||SUBSTR(SQLERRM,0,255)||']';
               o_result := Plt_Common.FAILURE;
		       RAISE e_process_exception;
		END;
		/*-*/
		/* Tolas files sent
		/*-*/
        
        EXIT;
        
   END LOOP;
   CLOSE c_get_plt;
       
   
   COMMIT;

EXCEPTION
     WHEN e_process_exception THEN
         o_result := Plt_Common.FAILURE;
         -- RAISE_APPLICATION_ERROR(-20001, o_result_msg);
	 WHEN e_IDOC_EXCEPTION THEN
         COMMIT;
         o_result := Plt_Common.SUCCESS;
		 -- RAISE_APPLICATION_ERROR(-20000, o_result_msg);
     WHEN OTHERS THEN
         o_result := Plt_Common.FAILURE;
         ROLLBACK;
         o_result_msg := 'ERROR OCCURED'||SQLERRM(SQLCODE);
         -- RAISE_APPLICATION_ERROR(-20000, o_result_msg);
END;


   /******************************************************/
	/* Create_Consumption will send on to Atlas
	/* this will record consumption of any material used within a 
	/* valid process order 
	/* o_result - 0 for successfull
	/*      		- 1 for a failure 
	/* o_result_msg - if o_result is 1 then this will contain the error message 
	/******************************************************/
   PROCEDURE Create_Consumption(
	   o_result          IN OUT NUMBER,
	   o_result_msg      IN OUT VARCHAR2,
	   i_trans_id		 IN NUMBER, --  uniquie id 
	   i_XACTN_DATE		 IN DATE,
	   i_PLANT_CODE		 IN VARCHAR2,
	   i_PROC_ORDER		 IN VARCHAR2,
	   i_MATERIAL_CODE	 IN VARCHAR2,
	   i_QTY			 IN NUMBER) AS
		
	   e_process_exception      EXCEPTION;
	   e_IDOC_EXCEPTION			EXCEPTION;
       v_result                 NUMBER DEFAULT 0;
       v_result_msg             VARCHAR2(2000);
	   v_count 					NUMBER;
	   v_transaction_type       VARCHAR2(10);
	   v_work   				NUMBER;
	   v_work1					VARCHAR2(10);
	   v_seq					NUMBER;
		
		
		CURSOR csr_matl IS
		SELECT issue_strg_locn, DECODE(base_uom,'KGM','KG', base_uom) uom FROM matl
		WHERE LTRIM(matl_code,'0') = i_material_code
		AND plant = i_plant_code;
		
	BEGIN
	
		 o_result := Plt_Common.SUCCESS;
   	 o_result_msg := '';
   
   /**********************************************************************************/
   /* VALIDATE data BEFORE saving IN TABLE 
   /**********************************************************************************/

	-- check plant code 
   IF i_plant_code IS NULL THEN
      o_result_msg := 'Plant Code cannot be Null.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   ELSE
       SELECT COUNT(*) INTO v_count FROM manu.REF_PLANT 
       WHERE plant = i_plant_code;
       IF v_count = 0 THEN
           o_result_msg := 'Plant Code is not correct.';
           o_result := Plt_Common.FAILURE;
           RAISE e_process_exception;
       END IF;
   END IF;
   
   -- check for valid proc order
	IF i_proc_order IS NULL THEN
      o_result_msg := 'Proc Order is not valid.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   ELSE
       IF SUBSTR(i_proc_order,1,2) <> '99' THEN
          SELECT COUNT(*) INTO v_count FROM manu.CNTL_REC 
          WHERE LTRIM(proc_order,'0') = LTRIM(i_proc_order,'0');
          IF v_count = 0 THEN
              o_result_msg := 'Proc Order is not valid.';
              o_result := Plt_Common.FAILURE;
           RAISE e_process_exception;
          END IF;
       END IF;
   END IF;
   
   -- check material code 
   -- material may be a substitution so may not be in the process order bom
   IF i_material_code IS NULL THEN
      o_result_msg := 'Material Code cannot be Null.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   END IF;
   
   -- check validity of qty 
   IF i_Qty = 0 THEN
      o_result_msg := 'Quantity cannot be Null.';
      o_result :=Plt_Common.FAILURE;
      RAISE e_process_exception;
   END IF;
   

	
	 /**********************************************************************************/
    /* Create Idoc package for Create
    /**********************************************************************************/
          /*-*/																											 
		  /* get storage location   
		  /*-*/
	 	  OPEN csr_matl;
     	  LOOP
              FETCH csr_matl INTO v_work, v_work1;
        	  EXIT WHEN csr_matl%NOTFOUND;
          END LOOP;
     	  CLOSE csr_matl;
	
     
    /*-*/
	 /* save data to table 
	 /*-*/
	 BEGIN
	 
	     SELECT PLT_CNSMPTN_ID_SEQ.NEXTVAL INTO v_seq FROM dual;
	     INSERT INTO PLT_CNSMPTN
		  VALUES (v_seq,
					i_proc_order,
					i_material_code,
					i_qty,
					v_work1,
					i_plant_code,
					'',
					v_work,
					i_XACTN_DATE,
					i_trans_id,
					'CREATE'); 
	 
	 EXCEPTION
	     WHEN OTHERS THEN
            o_result := Plt_Common.FAILURE;
            ROLLBACK;
            o_result_msg := 'ERROR OCCURED'||SUBSTR(SQLERRM(SQLCODE),0,256);
	 END ;
	 
		
				       
   EXCEPTION
      WHEN e_process_exception THEN
         o_result := Plt_Common.FAILURE;
         -- RAISE_APPLICATION_ERROR(-20001, o_result_msg);
	   WHEN e_IDOC_EXCEPTION THEN
         COMMIT;
         o_result := Plt_Common.SUCCESS;
		 -- RAISE_APPLICATION_ERROR(-20000, o_result_msg);
      WHEN OTHERS THEN
         o_result := Plt_Common.FAILURE;
         ROLLBACK;
         o_result_msg := 'ERROR OCCURED'||SQLERRM(SQLCODE);
         -- RAISE_APPLICATION_ERROR(-20000, o_result_msg);
								
	END Create_Consumption;
   

	
	/******************************************************/
	/* Cancel_Consumption will cancel process only data in PT schema and send on to Atlas
	/* o_result - 0 for successfull
	/*      		- 1 for a failure 
	/* o_result_msg - if o_result is 1 then this will contain the error message 
	/******************************************************/
   PROCEDURE Cancel_Consumption(
	   o_result          IN OUT NUMBER,
	   o_result_msg      IN OUT VARCHAR2,
	   i_trans_id		 IN NUMBER, --  uniquie id 
	   i_XACTN_DATE		 IN DATE,
	   i_PLANT_CODE		 IN VARCHAR2,
	   i_PROC_ORDER		 IN VARCHAR2,
	   i_MATERIAL_CODE	 IN VARCHAR2,
	   i_QTY			 IN NUMBER
    ) AS
	 
	 e_process_exception         EXCEPTION;
	 e_IDOC_EXCEPTION			 EXCEPTION;
	 
	 v_work						 NUMBER;
	 v_work1					 VARCHAR2(10);
	 v_result                	 NUMBER DEFAULT 0;
     v_result_msg            	 VARCHAR2(2000);
	 v_transaction_type    	 	 VARCHAR2(10);
	 v_seq					     VARCHAR2(10);
	 
	 
	   /*-*/
	   /* get storage location and uom from matl table
	   /*-*/
	  CURSOR csr_matl IS
		SELECT issue_strg_locn, DECODE(base_uom,'KGM','KG', base_uom) uom FROM matl
		WHERE LTRIM(matl_code,'0') = i_material_code
		AND plant = i_plant_code;
		
	
	 BEGIN
	 
	     /*-*/
		 /* get storage location and uom
		 /*-*/
	 	  OPEN csr_matl;
     	  LOOP
              FETCH csr_matl INTO v_work, v_work1;
        	  EXIT WHEN csr_matl%NOTFOUND;
          END LOOP;
     	  CLOSE csr_matl;
		  
		  
	     /*-*/
	     /* save data to table 
	 	  /*-*/
	 	  BEGIN
	 
	         SELECT PLT_CNSMPTN_ID_SEQ.NEXTVAL INTO v_seq FROM dual;
	     		INSERT INTO PLT_CNSMPTN
		  		VALUES (v_seq,
					    i_proc_order,
						 i_material_code,
						 i_qty,
						 v_work1,
						 i_plant_code,
						 '',
						 v_work,
						 i_XACTN_DATE,
						 i_trans_id,
						 'CANCEL'); 
	 
	     EXCEPTION
	         WHEN OTHERS THEN
                o_result := Plt_Common.FAILURE;
                ROLLBACK;
                o_result_msg := 'ERROR OCCURED'||SUBSTR(SQLERRM(SQLCODE),0,255);
	     END ;
		 
		  
	 EXCEPTION
      WHEN e_process_exception THEN
         o_result := Plt_Common.FAILURE;
         -- RAISE_APPLICATION_ERROR(-20001, o_result_msg);
	   WHEN e_IDOC_EXCEPTION THEN
         COMMIT;
         o_result := Plt_Common.SUCCESS;
		 -- RAISE_APPLICATION_ERROR(-20000, o_result_msg);
      WHEN OTHERS THEN
         o_result := Plt_Common.FAILURE;
         ROLLBACK;
         o_result_msg := 'ERROR OCCURED'||SQLERRM(SQLCODE);
         -- RAISE_APPLICATION_ERROR(-20000, o_result_msg);
	 
	 END;

END Tagsys_Fctry_Intfc;
/

GRANT EXECUTE ON PT_APP.TAGSYS_FCTRY_INTFC TO APPSUPPORT;
GRANT EXECUTE ON PT_APP.TAGSYS_FCTRY_INTFC TO BTHSUPPORT;
GRANT EXECUTE ON PT_APP.TAGSYS_FCTRY_INTFC TO CITECT_USER;
GRANT EXECUTE ON PT_APP.TAGSYS_FCTRY_INTFC TO PT_MAINT;
GRANT EXECUTE ON PT_APP.TAGSYS_FCTRY_INTFC TO PT_USER;

CREATE OR REPLACE PUBLIC SYNONYM TAGSYS_FCTRY_INTFC FOR PT_APP.TAGSYS_FCTRY_INTFC;