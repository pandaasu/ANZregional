DROP PACKAGE PT_APP.RE_PROCESS_TOLAS;

CREATE OR REPLACE PACKAGE PT_APP.Re_Process_Tolas AS
/******************************************************************************
   NAME:       TAGSYS_SYS_INTFC
   PURPOSE:		This set of procedures will check for any unsent records 
					and will re process the messages to Atlas 

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/01/2005  Jeff Phillipson           1. Created this package.
	2.0		  07/03/2006  JP	 							 Update for HaU (handling units) adedd 
				  				  									 this affecets creat and cancel plts
******************************************************************************/

 
  PROCEDURE CheckSendsPlt;

 
  
END Re_Process_Tolas;
/


DROP PACKAGE BODY PT_APP.RE_PROCESS_TOLAS;

CREATE OR REPLACE PACKAGE BODY PT_APP.Re_Process_Tolas AS
/******************************************************************************
   NAME:       TAGSYS_SYS_INTFC
   PURPOSE:		This set of procedures will check for any unsent records 
					and will re process the messages to Atlas 

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/01/2005  Jeff Phillipson           1. Created this package body.
   2.0		  07/03/2006  JP	 						Update for HaU (handling units) adedd 
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
                 v_seq          NUMBER;
				 
                                                                             
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
							IF LENGTH(i_PLT_CODE) > 10 AND LENGTH(LTRIM(rcd.matl_code,'0')) = 8 THEN
							     /*-*
								 /* get a sequence number for the Tolas interface
								 /*-*/
				    			 SELECT PLT_TOLAS_SEQ.NEXTVAL INTO v_seq FROM dual;
							     
									
								/*-*/
								/* only for Plant codes Cannery and Bathurst 
								/*-*/
								IF rcd.PLANT_CODE = 'AU20'  OR  rcd.PLANT_CODE = 'AU30' THEN
					 
					 		       
					 
					                Tolas_Fds_Send(o_result,
                                       o_result_msg,
								  	   'Z_PI1',
	   				      	      	   rcd.PLANT_CODE,
	   							  	   rcd.SENDER_NAME || ':' || SUBSTR(i_PLT_CODE,1,18), --i_SENDER_NAME,
	   							  	   FALSE,
	   							  	   rcd.PROC_ORDER,
	   							  	   TRUNC(rcd.XACTN_DATE),
	   							  	   TO_NUMBER(TO_CHAR(rcd.Xactn_date,'HH24MISS')),
	   							  	   rcd.MATL_CODE,
	   							  	   rcd.QTY,
	   							  	   UPPER(rcd.UOM),
	   							  	   TO_NUMBER(rcd.stor_locn_code),
	   							  	   rcd.dispn_code,
	   							  	   rcd.zpppi_batch, 
                         	      	   TO_CHAR(rcd.use_by_date,'YYYYMMDD'),
								  	   rcd.plt_code,
								  	   rcd.plt_type,
								  	   'CHEP',
								  	   TRUNC(rcd.start_prodn_datime),
								  	   TO_NUMBER(TO_CHAR(rcd.start_prodn_datime, 'hh24miss')),
								  	   TRUNC(rcd.end_prodn_datime),
								  	   TO_NUMBER(TO_CHAR(rcd.end_prodn_datime, 'hh24miss')),
									   v_seq);
								END IF;
								
					          Tolas_Ltds_Send(o_result,
                                  o_result_msg,
								  'Z_PI1',
	   				      	  	  rcd.PLANT_CODE,
	   							  rcd.MATL_CODE,
	   							  rcd.QTY,
	   							  rcd.DISPN_CODE,
	   							  rcd.zpppi_batch,
								  TO_CHAR(rcd.USE_BY_DATE,'YYYYMMDD'),
								  rcd.PLT_CODE,
								  v_seq);
								  
							  INSERT INTO plt_tolas
							  VALUES (i_plt_code, v_seq);
								   
						      DBMS_OUTPUT.PUT_LINE('Seq code =' || v_seq);
								
					      END IF;
					       
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
					v_type		   VARCHAR2(10);
					v_seq		   NUMBER;
                    o_result       NUMBER;
                    o_result_msg   VARCHAR2(2000);
                 
                                                                             
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
					    IF LENGTH(i_PLT_CODE) > 10 AND LENGTH(LTRIM(rcd.matl_code,'0')) = 8 THEN
						   
								
						    /*-*/
						    /* only for Plant codes Cannery and Bathurst 
						    /*-*/
							IF rcd.PLANT_CODE = 'AU20'  OR  rcd.PLANT_CODE = 'AU30' THEN
					            	/*-*
					            /* get a sequence number for the Tolas interface
					       		/*-*/
				           		SELECT PLT_TOLAS_SEQ.NEXTVAL INTO v_seq FROM dual;
					   	   		
												
                           		/*-*/
					   	   		/* send the FDS file to Tolas
					   	   		/* this file is based on plant and will be assigned to a different queue for the 2 Plant Codes
					   	   		/* defined in the If statement
					   	   		/*-*/
					   	   		Tolas_Fds_Send(o_result,
                    		             o_result_msg,
							   			 v_type,
	   				     	   			 rcd.PLANT_CODE,
	   						   			 rcd.SENDER_NAME || ':' || SUBSTR(i_PLT_CODE,1,18), 
	   						   			 FALSE,
	   						   			 rcd.PROC_ORDER,
	   						   			 TRUNC(rcd.XACTN_DATE),
	   						   			 TO_NUMBER(TO_CHAR(rcd.Xactn_date,'HH24MISS')),
	   						   			 rcd.MATL_CODE,
	   						   			 rcd.QTY,
	   						   			 rcd.uom,
	   						   			 rcd.stor_locn_code,
	   						   			 rcd.DISPN_CODE,
	   						   			 rcd.zpppi_batch,
							   			 TO_CHAR(rcd.USE_BY_DATE,'YYYYMMDD'),
							   			 i_PLT_CODE,
							   			 rcd.PLT_TYPE,
							   			 'CHEP',
							   			 TRUNC(SYSDATE), -- dummy entry 
							   			 0, 			    -- dummy entry 
							   			 TRUNC(SYSDATE), -- dummy entry 
							   			 0, 			    -- dummy entry 
							   			 TO_CHAR(LPAD(v_seq,8,'0')));
                            
							    INSERT INTO plt_tolas
					   	   		VALUES (i_plt_code, v_seq);
								
							END IF;
						END IF;                
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
  /* this procedure will check for any palet records not sent  to Tolas and will forward them 
  /*-*/  
    
    CURSOR csr_chk IS
    SELECT
	       h.*, dt.reason
      FROM PLT_TOLAS d, PLT_HDR h, plt_det dt
     WHERE LENGTH(matl_code) = 8
	   AND dt.plt_code = h.plt_code
       AND LENGTH(h.plt_code) > 12
       AND h.PLT_CODE = d.PLT_CODE(+)
	   AND SUBSTR(proc_order,1,2) <> '99'
       AND d.plt_code IS NULL 
     ORDER BY 1,2,3 DESC;
    
    rcd_chk csr_chk%ROWTYPE;
    
    v_count    NUMBER;
    v_success  NUMBER;
    
  BEGIN
  
      /*-*/
	  /* check any Create and Cancel Pallets for a send error 
      /*-*/
      
          OPEN csr_chk;
          LOOP
              FETCH csr_chk INTO rcd_chk;
              EXIT WHEN csr_chk%NOTFOUND;
              DBMS_OUTPUT.PUT_LINE ('plt code=' || rcd_chk.plt_code);
            
              IF UPPER(rcd_chk.reason) = 'CREATE' THEN
                  v_success := sendgr(rcd_chk.plt_code);
              ELSE
				  /*-*/
				  /* otherwise cancel pallet 
				  /*-*/
                  v_success := sendrgr(rcd_chk.plt_code);
              END IF;
            
             
				  
          END LOOP;
			 
          CLOSE csr_chk;
			 
          COMMIT;
      
        
  EXCEPTION
     WHEN OTHERS THEN
         ROLLBACK;
         raiseNotification('ERROR OCCURED - <Re_Process_Tolas.CheckSendsPlt> ' || CHR(13) ||SUBSTR(SQLERRM,0,255));    
  END;

       
		 
	
  
		 
END Re_Process_Tolas;
/


DROP PUBLIC SYNONYM RE_PROCESS_TOLAS;

CREATE PUBLIC SYNONYM RE_PROCESS_TOLAS FOR PT_APP.RE_PROCESS_TOLAS;


