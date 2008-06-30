DROP PACKAGE PT_APP.RE_PROCESS_GOODS_RECEIPTS;

CREATE OR REPLACE PACKAGE PT_APP.Re_Process_Goods_Receipts
AS
/******************************************************************************
   NAME:       PT_SEND_GOODS_RECEIPTS
   PURPOSE:    This set of procedures will check for any unsent records
               and will re process the messages to Atlas

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/01/2005  Jeff Phillipson           1. Created this package.
   2.0        07/03/2006  JP                        Update for HaU (handling units) adedd
                                                    this affecets creat and cancel plts
******************************************************************************/
   PROCEDURE EXECUTE;
   
END Re_Process_Goods_Receipts;
/


DROP PACKAGE BODY PT_APP.RE_PROCESS_GOODS_RECEIPTS;

CREATE OR REPLACE PACKAGE BODY PT_APP.Re_Process_Goods_Receipts AS
/******************************************************************************
	NAME:        PT_Reprocess_Goods_Receipts
	PURPOSE:		This set of procedures will check for any unsent records 
					and will re process the messages to Atlas 

	REVISIONS:
	Ver        Date        Author           Description
	---------  ----------  ---------------  ------------------------------------
	1.0        19/01/2005  Jeff Phillipson           1. Created this package body.
	2.0		  07/03/2006  JP	 					   Update for HU (handling units) adedd 
				  				  					   this affecets creat and cancel plts
******************************************************************************/
		
        
    
        
        /* This function is used to return the next element in a list of element stored in a string or
		/*  the leftmost portion of a string up to a particular delimiter.
		/*
		/* When called, the first element, up to and including sDelimiter is removed from sList and the
		/*  element returned by this function.
		/*
		/* If the list consists of only one element, or doesn't contain the delimiter at all, the whole
		/*  of sList is returned and sList set to the empty string. Calling this function with the
		/*	empty string, returns the empty string.
		/*
		/* The parameter sDelimiter is usually a "," but it can be any character or string of characters.
		/*-*/
	 	FUNCTION getElement (sList IN OUT VARCHAR2, sDelimiter IN VARCHAR2) RETURN VARCHAR2 IS
		
		    iCharPos INTEGER;
		    sTemp VARCHAR2(4000);
		
        BEGIN
		    -- find the end of the element by finding the sDelimiter or end of string
			iCharPos := INSTR(sList, sDelimiter);
			sTemp := sList;
			IF iCharPos = 0 THEN
			    sList := '';
				RETURN sTemp;
			ELSE
				sList := SUBSTR(sList, iCharPos + LENGTH(sDelimiter));
				RETURN SUBSTR(sTemp, 1, iCharPos - 1);
			END IF;
		END getElement;
		
		/******************************************************************************
		NAME:       SendGR
		PURPOSE:    This function will send a GR Pallet data 
			
		REVISIONS:
		Ver        Date        Author           Description
		---------  ----------  ---------------  ------------------------------------
		1.0        19/01/2005  Jeff Phillipson  1. Created this function.     
		******************************************************************************/     
		FUNCTION Send_GR (i_plt_code IN VARCHAR2) RETURN NUMBER IS 
        
            v_success      NUMBER;
            o_result         NUMBER;
            o_result_msg     VARCHAR2(2000);
                                                                                  
			/*-*/
            /* cursors
            /*-*/
            CURSOR c_p
			IS
            SELECT h.*, 
			       REASON, 
				   xactn_date, xactn_time,
                   sender_name, user_id
              FROM PLT_HDR h, PLT_DET d
             WHERE h.PLT_CODE = d.PLT_CODE
               AND d.plt_code = i_plt_code
               AND d.REASON = 'CREATE';      
           rcd c_p%ROWTYPE;
                 
                 
            BEGIN
			    OPEN c_p;
                FETCH c_p INTO rcd;
                IF NOT c_p%NOTFOUND THEN
                    Pt_Cisatl17_Gr.EXECUTE(o_result, 
										o_result_msg,
										'Z_PI1', 
										rcd.plant_code,
										rcd.sender_name || ':' || SUBSTR(rcd.PLT_CODE,1,18), --rcd.sender_name, 
										FALSE,
										TO_NUMBER(rcd.proc_order),
										rcd.xactn_date,
										rcd.xactn_time, 
										rcd.matl_code,
										rcd.qty, 
										NVL(rcd.uom,'KG'),
										TO_NUMBER(NVL(rcd.stor_locn_code,'0020')), 
										rcd.dispn_code,
										rcd.zpppi_batch, 
										FALSE,
										TO_CHAR(rcd.use_by_date,'YYYYMMDD'),
										rcd.plt_code,
										rcd.plt_type,
										'CHEP',
										TRUNC(rcd.start_prodn_datime),
										TO_NUMBER(TO_CHAR(rcd.start_prodn_datime, 'hh24miss')),
										TRUNC(rcd.end_prodn_datime),
										TO_NUMBER(TO_CHAR(rcd.end_prodn_datime, 'hh24miss')));
                END IF;   
                CLOSE c_p;
                   
				RETURN o_result;
                   
				EXCEPTION
				    WHEN NO_DATA_FOUND THEN
				        NULL;
				    WHEN OTHERS THEN
				        -- Consider logging the error and then re-raise
				        RAISE;
				END Send_GR;
 
 
				/******************************************************************************
				   NAME:       SendGR
				   PURPOSE:    This function will send a GR Pallet data 
				
				   REVISIONS:
				   Ver        Date        Author           Description
				   ---------  ----------  ---------------  ------------------------------------
				   1.0        19/01/2005  Jeff Phillipson  1. Created this function.     
				
				******************************************************************************/
				FUNCTION Send_RGR (i_plt_code IN VARCHAR2) RETURN NUMBER IS
				
				
					v_success      NUMBER;
					v_type			VARCHAR2(10);
					o_result         NUMBER;
					o_result_msg     VARCHAR2(2000);
                 
                    /*-*/
                    /* cursors
                    /*-*/                                                            
                    CURSOR c_p
                    IS
                    SELECT h.*, 
					       REASON, 
					       xactn_date, 
					       xactn_time,
                           sender_name, 
					       user_id
                      FROM PLT_HDR h, PLT_DET d
                     WHERE h.PLT_CODE = d.PLT_CODE
                       AND d.plt_code = i_plt_code
                       AND d.REASON = 'CANCEL';
                    rcd c_p%ROWTYPE;
                 
                BEGIN
                 
                    o_result  := 0;   
        			IF LENGTH(rcd.plt_code) = 18 THEN
        			    /*-*/
        				/* set type as pallet if the pallet code is a full 18 chars long 
        				/*-*/
        			    v_type := 'Z_PI6';
        			ELSE
        			 	/*-*/
        				/* otherwise this is a process record 
        				/*-*/
        			    v_type := 'Z_PI2';
        			END IF;
        					 
		            OPEN c_p;
                    FETCH c_p INTO rcd;
                    IF NOT c_p%NOTFOUND THEN
                        Pt_Cisatl17_Gr.EXECUTE(o_result, 
						                    o_result_msg,
                                            v_type, 
						                    rcd.plant_code,
                                            rcd.sender_name || ':' || SUBSTR(rcd.PLT_CODE,1,18), --rcd.sender_name, 
                                            FALSE,
                                            TO_NUMBER(rcd.proc_order),rcd.xactn_date,
                                            rcd.xactn_time, rcd.matl_code,
                                            rcd.qty, NVL(rcd.uom,'KG'),
                                            TO_NUMBER(nvl(rcd.stor_locn_code,'0020')), rcd.dispn_code,
                                            rcd.zpppi_batch, FALSE,
                                            TO_CHAR(rcd.use_by_date,'YYYYMMDD'),
						                    rcd.plt_code,
						                    rcd.plt_type,
						                    'CHEP',
						                    TRUNC(rcd.start_prodn_datime),
						                    TO_NUMBER(TO_CHAR(rcd.start_prodn_datime, 'hh24miss')),
						                    TRUNC(rcd.end_prodn_datime),
						                    TO_NUMBER(TO_CHAR(rcd.end_prodn_datime, 'hh24miss')));
                                        
                    END IF;
                    CLOSE c_p;
		            RETURN o_result;
		        EXCEPTION
		            WHEN NO_DATA_FOUND THEN
			            o_result := 1;
		            WHEN OTHERS THEN
		                -- Consider logging the error and then re-raise 
				        o_result := 1;
		                RAISE;
		        END Send_RGR;
 
 


    /*-*/
	/* this procedure will check for any palet records not sent  to Atlas and will forward them 
	/*-*/ 
	PROCEDURE EXECUTE IS
	 
    v_count    NUMBER;
    v_success  NUMBER;
    v_client_info VARCHAR2(2000);
    
    CURSOR csr_chk IS
    SELECT d.*, 
	       h.matl_code, 
		   h.qty qty , 
		   zpppi_batch batch 
      FROM PLT_DET d, PLT_HDR h
     WHERE sent_flag IS NULL
       AND h.PLT_CODE = d.PLT_CODE
     ORDER BY 1,2,3 DESC; 
    rcd_chk csr_chk%ROWTYPE;
   
	BEGIN
  
        /*-*/ 
   	    /* get the client info sesssion information
        /* if in use wait for the create pallet procedure to finish 
   	    /*-*/ 
  	    dbms_application_info.read_client_info(v_client_info);
  	    IF v_client_info IS NOT NULL  THEN
  	  	    DBMS_LOCK.sleep(1);
        END IF;  
       
          
	    /*-*/
		/* only resend data if there is more than 1 plt waiting
		/* temp fix for the issue of one being sent -by the normal process but not finished
		/*-*/
	    SELECT COUNT(*) INTO v_count
	      FROM plt_det 
         WHERE sent_flag IS NULL;
	  
		/*-*/
		/* check any Create and Cancel Pallets for a send error 
		/* FIRST CHECK IF THE sending OF Idocs has been disabled
		/*-*/
		IF v_count >= 1 THEN
      
			OPEN csr_chk;
			LOOP
				FETCH csr_chk INTO rcd_chk;
				EXIT WHEN csr_chk%NOTFOUND;
             
            
				IF rcd_chk.reason = 'CREATE' THEN
					v_success := send_gr(rcd_chk.plt_code);
				ELSE
					/*-*/
					/* otherwise cancel pallet 
					/*-*/
					v_success := send_rgr(rcd_chk.plt_code);
				END IF;
            
                
				IF v_success = 0 THEN
				  
					UPDATE PLT_DET SET sent_flag = 'Y'
					 WHERE plt_code = rcd_chk.plt_code
                       AND reason = rcd_chk.reason;
						  
				
				
				
                     	  
					
				END IF;
				  
			END LOOP;
			 
			CLOSE csr_chk;
			 
			COMMIT;
		END IF;  
        
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
	END;

       
		 
	PROCEDURE Check_Sends_Consumption IS
    /*-*/
    /* this procedure will check for any consumption records not sent to Atlas 
	/* and will forward them grouped by proc order, material and trans type
	/*-*/  
	
	/*-*/
	/* Constants
	/*-*/
	MAX_ROWS_PER_FILE		CONSTANT NUMBER  := 101;
	
	/*-*/
	/* retrieve the cursor of grouped material, proc orders and trans type
	/* this will minimise the sending of descrete materials to Atlas
	/* This will reduce the number of transmissions to Atlas
	/* and will be run on a scheduled job every 30mis.
	/*-*/
	CURSOR csr_chk IS
       SELECT t02.*, ROWNUM ID
	     FROM (SELECT  t01.*
	  		    FROM PLT_CNSMPTN t01
     		   WHERE sent_flag IS  NULL 
       		     AND SUBSTR(proc_order,1,2) <> '99'
     		   ORDER BY 2,3, trans_type) t02
		WHERE ROWNUM < MAX_ROWS_PER_FILE;
	  	 
	rcd_chk csr_chk%ROWTYPE;       -- used to store current record
    rcd_chk_last csr_chk%ROWTYPE;  -- used to store last record
	 
	 
    v_count    				 NUMBER DEFAULT 1;
    v_success  				 NUMBER DEFAULT 0;
	v_result_msg  			 VARCHAR2(2000);
    v_transaction_type 		 VARCHAR2(100);
	v_ids					 VARCHAR2(4000) DEFAULT '''';
	v_id					 VARCHAR2(20);
	v_qty					 NUMBER DEFAULT 0;
	v_counter				 NUMBER DEFAULT 0;
	v_string_count			 NUMBER DEFAULT 0;
	/*-*/
	/* added by Jeff Phillipson 31 Oct 2006
	/* to allow for grouping of files of consumption
	/*-*/
	v_start					 BOOLEAN DEFAULT TRUE;
	v_end					 BOOLEAN DEFAULT TRUE;
	v_first_send			 BOOLEAN DEFAULT TRUE;
	v_seq					 NUMBER;
	v_filename				 VARCHAR2(200);
	
	
	BEGIN
		WHILE  v_count > 0 
		LOOP
			v_counter := 0;
			v_first_send := TRUE;
			v_start := TRUE;
			/*-*/
			/* get the next sequence number
			/*-*/
			SELECT PLT_CNSMPTN_SEND_ID_SEQ.NEXTVAL INTO v_seq FROM dual;
			
			/*-*/
			/* check any Create and Cancel Pallets for a send error 
			/*-*/ 
			OPEN csr_chk;
			LOOP
				FETCH csr_chk INTO rcd_chk;
				EXIT WHEN csr_chk%NOTFOUND;
		   
				v_counter := v_counter + 1;
				IF v_counter = 1 THEN
				    -- on first record only make the 2 record sets equal
					rcd_chk_last := rcd_chk;
				END IF;
                
		    	BEGIN
		           IF rcd_chk_last.proc_order <> rcd_chk.proc_order
						OR  rcd_chk_last.matl_code <> rcd_chk.matl_code
						OR rcd_chk_last.trans_type <> rcd_chk.trans_type  THEN
				  
						/*-*/
						/* First time in this procedure
						/*-*/
						IF v_first_send = TRUE THEN
							v_start := TRUE;
							v_end := FALSE;
							v_first_send := FALSE;
						END IF;
					
						/*-*/
						/* get trans type 
						/*-*/
						IF rcd_chk_last.trans_type = 'CREATE' THEN
							v_transaction_type := 'ZPI_CONS';
						ELSE
							v_transaction_type := 'Z_PI4';
						END IF;
						
						v_success := 1;
						
						/*-*/
						/* Make call to create iDOC 
						/*-*/
						IF v_qty > 0 THEN
							Pt_Cisatl17_Gr.EXECUTE(v_success,
												v_result_msg,
												v_transaction_type,
												rcd_chk_last.plant_code,
												'',
												FALSE,
												rcd_chk_last.PROC_ORDER,
												TRUNC(SYSDATE),
												TO_NUMBER(TO_CHAR(SYSDATE,'HH24') || TO_CHAR(SYSDATE,'MI') || '00') ,
												rcd_chk_last.MATL_CODE,
												v_QTY,
												UPPER(rcd_chk_last.UOM),
												rcd_chk_last.store_locn,
												'',
												'',
												FALSE,
												0,
												'',
												'',
												'',
												TRUNC(SYSDATE), -- dummy entry 
												0, -- dummy entry 
												TRUNC(SYSDATE), -- dummy entry 
												0); -- dummy entry 
																			
							/*-*/
							/* add file name to variable to save in table latter
							/*-*/
							IF v_start = TRUE THEN
							    v_filename := v_result_msg;
							END IF;
							
						END IF;
						v_start := FALSE;  -- set to false after the first send
						
						IF v_success = 0 THEN
					    
							v_ids := SUBSTR(v_ids, 0, LENGTH(v_ids)-2); -- remove the trailing comma
			            
							/*-*/
							/* Insert the sent flag into the table entries for the selected group of records
							/*-*/
							EXECUTE IMMEDIATE 'UPDATE PLT_CNSMPTN ' 
											|| ' SET sent_flag = ''Y'' ' 
											|| ' WHERE TO_CHAR(trim(PLT_CNSMPTN_id)) IN (' || v_ids || ')';
				      	
							WHILE LENGTH(v_ids) > 0
							LOOP
								v_id := getElement(v_ids,',');
								v_id := SUBSTR(v_id,2,LENGTH(v_id));
								v_id := SUBSTR(v_id,0, LENGTH(v_id)-1);
								--DBMS_OUTPUT.PUT_LINE(v_id);
								INSERT INTO plt_cnsmptn_send
								VALUES(v_seq,
									TO_NUMBER(LTRIM(RTRIM(v_id))),
									SYSDATE,
									v_filename);
							END LOOP;		 
						END IF;
						/*-*/
						/* reset the values to blank
						/*-*/
						v_ids := '''';
						v_qty := 0;
						v_string_count := 0;
					END IF;
					/*-*/
					/* commit the 1 record
					/*-*/
					COMMIT;
				
				EXCEPTION
					WHEN OTHERS THEN
						--DBMS_OUTPUT.PUT_LINE( 'Oracle error ' || SUBSTR(SQLERRM, 1, 512));
						ROLLBACK;
				END;
			
				IF LENGTH(v_ids) < 3900 AND v_string_count < 300 THEN
					v_string_count := v_string_count + 1;	
					v_ids := v_ids || TO_CHAR(rcd_chk.plt_cnsmptn_id) || ''',''';  
					v_qty := v_qty + rcd_chk.qty;  
					--DBMS_OUTPUT.PUT_LINE('here' || v_qty || '-' || v_ids);
				END IF;
			
				/*-*/
				/* make the last record = the ciurrent record
				/*-*/
				rcd_chk_last := rcd_chk;
			
			END LOOP;
			
			/*-*/
			/* send the last record here
			/*-*/
			IF v_counter > 0 THEN
				/*-*/
				/* get trans type 
				/*-*/
				IF rcd_chk_last.trans_type = 'CREATE' THEN
					v_transaction_type := 'ZPI_CONS';
				ELSE
					v_transaction_type := 'Z_PI4';
				END IF;
				
				v_success := 1;
				
				/*-*/
				/* Make call to create iDOC 
				/*-*/
				IF v_qty > 0 THEN
					Pt_Cisatl17_Gr.EXECUTE(v_success,
										v_result_msg,
										v_transaction_type,
										rcd_chk_last.plant_code,
										'',
										FALSE,
										rcd_chk_last.PROC_ORDER,
										TRUNC(SYSDATE),
										TO_NUMBER(TO_CHAR(SYSDATE,'HH24') || TO_CHAR(SYSDATE,'MI') || '00') ,
										rcd_chk_last.MATL_CODE,
										v_QTY,
										UPPER(rcd_chk_last.UOM),
										rcd_chk_last.store_locn,
				   						'',
										'',
										FALSE,
										0,
										'',
										'',
										'',
										TRUNC(SYSDATE), -- dummy entry 
										0, -- dummy entry 
										TRUNC(SYSDATE), -- dummy entry 
										0); -- dummy entry 
										
					/*-*/
					/* add file name to variable to save in table latter
					/*-*/
					IF v_start = TRUE THEN
					    v_filename := v_result_msg;
					END IF;
								
				END IF;
							
				IF v_success = 0 THEN
					v_ids := SUBSTR(v_ids, 0, LENGTH(v_ids)-2); -- remove the trailing comma
		           
					/*-*/
					/* Insert the sent flag into the table entries for the selected group of records
					/*-*/
					EXECUTE IMMEDIATE 'UPDATE PLT_CNSMPTN ' 
								|| ' SET sent_flag = ''Y'' ' 
								|| ' WHERE TO_CHAR(trim(PLT_CNSMPTN_id)) IN (' || v_ids || ')';
				    
					WHILE LENGTH(v_ids) > 0
						LOOP
							v_id := getElement(v_ids,',');
							v_id := SUBSTR(v_id,2,LENGTH(v_id));
							v_id := SUBSTR(v_id,0, LENGTH(v_id)-1);
							INSERT INTO plt_cnsmptn_send
							VALUES(v_seq,
								TO_NUMBER(LTRIM(RTRIM(v_id))),
								SYSDATE,
								v_filename);
					END LOOP;
				END IF;
				/*-*/
				/* reset the values to blank
				/*-*/
				v_ids := '''';
				v_qty := 0;
				v_string_count := 0;
				
			END IF;
			CLOSE csr_chk;
			 
			COMMIT;		  
		
		    /*-*/
			/* see if there are morer records to process
			/*-*/
			SELECT  COUNT(*) INTO v_count
	  		  FROM PLT_CNSMPTN t01
     		 WHERE sent_flag IS  NULL 
       		   AND SUBSTR(proc_order,1,2) <> '99';
		END LOOP;		  
      
   EXCEPTION
       WHEN OTHERS THEN
	      --DBMS_OUTPUT.PUT_LINE( 'Oracle error end ' || SUBSTR(SQLERRM, 1, 512));
		  ROLLBACK;
   END;
  
		 
END Re_Process_Goods_Receipts;
/


DROP PUBLIC SYNONYM RE_PROCESS_GOODS_RECEIPTS;

CREATE PUBLIC SYNONYM RE_PROCESS_GOODS_RECEIPTS FOR PT_APP.RE_PROCESS_GOODS_RECEIPTS;


GRANT EXECUTE ON PT_APP.RE_PROCESS_GOODS_RECEIPTS TO APPSUPPORT;

