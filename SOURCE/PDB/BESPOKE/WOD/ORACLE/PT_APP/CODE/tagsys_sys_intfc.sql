DROP PACKAGE PT_APP.TAGSYS_SYS_INTFC;

CREATE OR REPLACE PACKAGE PT_APP.Tagsys_Sys_Intfc AS
/******************************************************************************
   NAME:       TAGSYS_SYS_INTFC
   PURPOSE:		This set of procedures will check for any unsent records 
					and will re process the messages to Atlas 

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/01/2005  Jeff Phillipson           1. Created this package.
	2.0		  07/03/2006  JP	 					   Update for HU (handling units) adedd 
				  				  					   this affecets creat and cancel plts
******************************************************************************/

 
  PROCEDURE CheckSendsPlt;
  
  PROCEDURE CheckSendsConsumption;
 
  
END Tagsys_Sys_Intfc;
/


DROP PACKAGE BODY PT_APP.TAGSYS_SYS_INTFC;

CREATE OR REPLACE PACKAGE BODY PT_APP.Tagsys_Sys_Intfc AS
/******************************************************************************
   NAME:       TAGSYS_SYS_INTFC
   PURPOSE:		This set of procedures will check for any unsent records 
					and will re process the messages to Atlas 

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/01/2005  Jeff Phillipson           1. Created this package body.
	2.0		  07/03/2006  JP	 					   Update for HU (handling units) adedd 
				  				  					   this affecets creat and cancel plts
******************************************************************************/



         RESEND_MAX   CONSTANT NUMBER  := 5;
			
		/*-*/
		/* this value defines the interface sand server directory 
		/*-*/
		cst_fil_path	CONSTANT	VARCHAR2(60) := 'MANU_OUTBOUND';
			

        /*********************************************
        RAISE email notification OF error
        **********************************************/
        PROCEDURE raiseNotification(message IN VARCHAR2)
             IS
     
                 var_message VARCHAR2(4000);
         
             BEGIN
                 var_message := message;
                 Mailout(var_message);
             EXCEPTION
                 WHEN OTHERS THEN
                     var_message := message;
             END;
     
             
		FUNCTION SendGR (i_plt_code IN VARCHAR2) RETURN NUMBER IS
				
				 
		/******************************************************************************
		NAME:       SendGR
		PURPOSE:    This function will send a GR Pallet data 
			
		REVISIONS:
		Ver        Date        Author           Description
		---------  ----------  ---------------  ------------------------------------
		1.0        19/01/2005  Jeff Phillipson  1. Created this function.     
		******************************************************************************/
				 
                v_success      NUMBER;
                o_result         NUMBER;
                o_result_msg     VARCHAR2(2000);
                 
                                                                             
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
                 LOOP
                     FETCH c_p INTO rcd;
                     EXIT WHEN c_p%NOTFOUND;
                     Goods_Recipte_Send(o_result, 
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
									rcd.uom,
                         			TO_NUMBER(rcd.stor_locn_code), 
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
									TO_NUMBER(TO_CHAR(rcd.end_prodn_datime, 'hh24miss'))
									);
                            
								
					  
                     EXIT;   
                 END LOOP;
                 CLOSE c_p;
                   
				RETURN o_result;
                   
				EXCEPTION
				    WHEN NO_DATA_FOUND THEN
				        NULL;
				    WHEN OTHERS THEN
				        -- Consider logging the error and then re-raise
				        RAISE;
				END SendGR;
 
 
 
 
 
				FUNCTION SendRGR (i_plt_code IN VARCHAR2) RETURN NUMBER IS
				
				
				/******************************************************************************
				   NAME:       SendGR
				   PURPOSE:    This function will send a GR Pallet data 
				
				   REVISIONS:
				   Ver        Date        Author           Description
				   ---------  ----------  ---------------  ------------------------------------
				   1.0        19/01/2005  Jeff Phillipson  1. Created this function.     
				
				******************************************************************************/
				 v_success      NUMBER;
				 v_type			VARCHAR2(10);
                 o_result         NUMBER;
                 o_result_msg     VARCHAR2(2000);
                 
                                                                             
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
                
					 IF LENGTH(rcd.plt_code) > 12 THEN
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
                    LOOP
                       FETCH c_p INTO rcd;
                       EXIT WHEN c_p%NOTFOUND;
                           Goods_Recipte_Send(o_result, 
								o_result_msg,
                                v_type, 
								rcd.plant_code,
                                rcd.sender_name || ':' || SUBSTR(rcd.PLT_CODE,1,18), --rcd.sender_name, 
                                FALSE,
                                TO_NUMBER(rcd.proc_order),rcd.xactn_date,
                                rcd.xactn_time, rcd.matl_code,
                                rcd.qty, rcd.uom,
                                TO_NUMBER(rcd.stor_locn_code), rcd.dispn_code,
                                rcd.zpppi_batch, FALSE,
                                TO_CHAR(rcd.use_by_date,'YYYYMMDD'),
								rcd.plt_code,
								rcd.plt_type,
								'CHEP',
								TRUNC(rcd.start_prodn_datime),
								TO_NUMBER(TO_CHAR(rcd.start_prodn_datime, 'hh24miss')),
								TRUNC(rcd.end_prodn_datime),
								TO_NUMBER(TO_CHAR(rcd.end_prodn_datime, 'hh24miss')));
                                       
                    EXIT;   
                END LOOP;
                CLOSE c_p;
                   
       
				   RETURN o_result;
				EXCEPTION
				     WHEN NO_DATA_FOUND THEN
					    o_result := 1;
				      
				     WHEN OTHERS THEN
				       -- Consider logging the error and then re-raise 
						 o_result := 1;
				       RAISE;
				END SendRGR;
 
 


 
  PROCEDURE CheckSendsPlt IS
  /*-*/
  /* this procedure will check for any palet records not sent  to Atlas and will forward them 
  /*-*/  
    
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
    
    v_count    NUMBER;
    v_success  NUMBER;
    
  BEGIN
  
      /*-*/
	  /* only resend data if there is more than 1 plt waiting
	  /* temp fix for the issue of one being sent -by the normal process but not finished
	  /*-*/
	  SELECT COUNT(*) INTO v_count
	  FROM plt_det WHERE sent_flag IS NULL;
	  
      /*-*/
	  /* check any Create and Cancel Pallets for a send error 
      /*FIRST CHECK IF THE sending OF Idocs has been disabled
      /*-*/
      IF NOT Idoc_Hold AND v_count > 1 THEN
      
          OPEN csr_chk;
          LOOP
              FETCH csr_chk INTO rcd_chk;
              EXIT WHEN csr_chk%NOTFOUND;
             
            
              IF rcd_chk.reason = 'CREATE' THEN
                  v_success := sendgr(rcd_chk.plt_code);
              ELSE
				  /*-*/
				  /* otherwise cancel pallet 
				  /*-*/
                  v_success := sendrgr(rcd_chk.plt_code);
              END IF;
            
                
              IF v_success = 0 THEN
				  
                 UPDATE PLT_DET SET sent_flag = 'Y'
                  WHERE plt_code = rcd_chk.plt_code
                    AND reason = rcd_chk.reason;
						  
			     UPDATE PLT_IDOC_LOG SET status = 'Sent'
				  WHERE plt_code = rcd_chk.plt_code
                    AND XACTN_TYPE = rcd_chk.reason;
						  
                 DBMS_OUTPUT.PUT_LINE (rcd_chk.plt_code || 'OK');
					  
              ELSE
				  
                 SELECT COUNT(*) 
                   INTO v_count
                   FROM PLT_IDOC_LOG
                  WHERE plt_code = rcd_chk.plt_code
                    AND XACTN_TYPE = rcd_chk.reason;
                       
                 IF v_count = 1 THEN
                     SELECT RESEND_COUNT 
                       INTO v_count
                       FROM PLT_IDOC_LOG
                      WHERE plt_code = rcd_chk.plt_code
                        AND XACTN_TYPE = rcd_chk.reason;
								
							UPDATE PLT_IDOC_LOG 
                        SET resend_count = v_count + 1
                      WHERE plt_code = rcd_chk.plt_code 
                        AND XACTN_TYPE = rcd_chk.reason;
                 ELSE
                     v_count := 0;
                 END IF;
                     
                 
						  
				 IF v_count >= 5 THEN
					-- send email notification
                    raiseNotification(v_count + 1 || ' attempts to send a pallet via the interface Idoc have failed. Plt code = ' || rcd_chk.plt_code);
                 END IF;
              END IF;
				  
          END LOOP;
			 
          CLOSE csr_chk;
			 
          COMMIT;
      END IF;  
        
  EXCEPTION
     WHEN OTHERS THEN
         ROLLBACK;
         raiseNotification('ERROR OCCURED - <Tagsys_Sys_Intfc.CheckSendsPlt> ' || CHR(13) ||SQLERRM);    
  END;

       
		 
	PROCEDURE CheckSendsConsumption IS
        /*-*/
    /* this procedure will check for any consumption records not sent to Atlas 
    /* and will forward them grouped by proc order, material and trans type
    /*-*/  
	
	/*-*/
	/* retrieve the cursor of grouped material, proc orders and trans type
	/* this will minimise the sending of descrete materials to Atlas
	/* This will reduce the number of transmissions to Atlas
	/* and will be run on a scheduled job every 30mis.
	/*-*/
	CURSOR csr_chk IS
     SELECT  t01.*, ROWNUM ID
	  FROM PLT_CNSMPTN t01
     WHERE sent_flag IS  NULL 
       AND SUBSTR(proc_order,1,2) <> '99'
     ORDER BY 2,3, trans_type;
	  	 
	 rcd_chk csr_chk%ROWTYPE;       -- used to store current record
     rcd_chk_last csr_chk%ROWTYPE;  -- used to store last record
	 
	 
    v_count    				 NUMBER;
    v_success  				 NUMBER DEFAULT 0;
	v_result_msg  			 VARCHAR2(2000);
    v_transaction_type 		 VARCHAR2(100);
	v_ids					 VARCHAR2(4000) DEFAULT '''';
	v_qty					 NUMBER DEFAULT 0;
	v_counter				 NUMBER DEFAULT 0;
	v_string_count			 NUMBER DEFAULT 0;
	 
   BEGIN
	   
   	   /*-*/
	   /* check any Create and Cancel Pallets for a send error 
       /*-*/ 
       OPEN csr_chk;
       LOOP
           FETCH csr_chk INTO rcd_chk;
           EXIT WHEN csr_chk%NOTFOUND;
		   v_counter := v_counter + 1;
		   IF v_counter = 1 THEN
		       rcd_chk_last := rcd_chk;
		   END IF;
		   
		   BEGIN
					
		        IF rcd_chk_last.proc_order <> rcd_chk.proc_order
				   OR  rcd_chk_last.matl_code <> rcd_chk.matl_code
				   OR rcd_chk_last.trans_type <> rcd_chk.trans_type  THEN
				   
				    /*-*/
					/* get trans type 
					/*-*/
					IF rcd_chk_last.trans_type = 'CREATE' THEN
				        v_transaction_type := 'ZPI_CONS';
				    ELSE
				 	    v_transaction_type := 'Z_PI4';
				    END IF;
					 
					/*-*/
					/* Make call to create iDOC 
					/*-*/
					IF v_QTY > 0 THEN
					Goods_Recipte_Send(v_success,
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
							0 -- dummy entry 
							);
								
					END IF;
					
			    	IF v_success = 0 THEN
					    
					    v_ids := SUBSTR(v_ids, 0, LENGTH(v_ids)-2); -- remove the trailing comma
			            
						/*-*/
				 	    /* Insert the sent flag into the table entries for the selected group of records
				 	    /*-*/
                 	    EXECUTE IMMEDIATE 'UPDATE PLT_CNSMPTN ' 
				                          || ' SET sent_flag = ''Y'' ' 
                        				  || ' WHERE TO_CHAR(trim(PLT_CNSMPTN_id)) IN (' || v_ids || ')';
				      	
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
		    /*-*/
			/* Make call to create iDOC 
			/*-*/
			IF v_QTY > 0 THEN
		        Goods_Recipte_Send(v_success,
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
							0 -- dummy entry 
							);
								
		    END IF;
								
		    IF v_success = 0 THEN
			    
		        v_ids := SUBSTR(v_ids, 0, LENGTH(v_ids)-2); -- remove the trailing comma
		           
				/*-*/
		    	/* Insert the sent flag into the table entries for the selected group of records
		    	/*-*/
            	EXECUTE IMMEDIATE 'UPDATE PLT_CNSMPTN ' 
		                      || ' SET sent_flag = ''Y'' ' 
               				  || ' WHERE TO_CHAR(trim(PLT_CNSMPTN_id)) IN (' || v_ids || ')';
				      	
		    END IF;
		END IF;
        CLOSE csr_chk;
			 
        COMMIT;		  
				  
      
		 
   EXCEPTION
       WHEN OTHERS THEN
	      --DBMS_OUTPUT.PUT_LINE( 'Oracle error end ' || SUBSTR(SQLERRM, 1, 512));
		  raiseNotification('CreateSendsConsumption failed. Proc order = ' || rcd_chk_last.proc_order
		                    || CHR(13) || ' Matl Code = ' || rcd_chk_last.matl_code
							|| CHR(13) || 'Oracle error end ' || SUBSTR(SQLERRM, 1, 512));
  		  ROLLBACK;
   END;
  
		 
END Tagsys_Sys_Intfc;
/


DROP PUBLIC SYNONYM TAGSYS_SYS_INTFC;

CREATE PUBLIC SYNONYM TAGSYS_SYS_INTFC FOR PT_APP.TAGSYS_SYS_INTFC;


GRANT EXECUTE ON PT_APP.TAGSYS_SYS_INTFC TO APPSUPPORT;

GRANT EXECUTE ON PT_APP.TAGSYS_SYS_INTFC TO SHIFTLOG;

