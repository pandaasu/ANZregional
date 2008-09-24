DROP PACKAGE PT_APP.TAGSYS_RESEND;

CREATE OR REPLACE PACKAGE PT_APP.TAGSYS_RESEND AS
/******************************************************************************
   NAME:       TAGSYS_RESEND
   PURPOSE:    This set of procedures is used to re-create and resend 
               interface-files for HU's.  There is a separate procedure for
               each specific type of HU interface file. (ATLAS, TOLAS_FDS or
               TOLAS_LTDS).  
               
               The list of HU's to send must be entered into the respective
               table shown below:
               
               ResendAtlas sends HU's in RESEND_HU_ATLAS to Altas only
               ResendTolasFDS sends HU's in RESEND_HU_TOLAS_FDS to Tolas FDS only
               ResendTolasLTDS sends HU's in RESEND_HU_TOLAS_LTDS to Tolas LTDS only
               
               The HU's listed in the tables above to resend must exist already
               in plt_hdr and plt_det (ie, they have already been created but
               the sending has failed for some reason)
               
               The two Tolas procedures will use the seq number already recorded
               in plt_tolas if the HU is found in there - otherwise they will use
               the next seq value.

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        30/05/2007  Daniel Owen      1. Created this package.
				  				  									 this affecets creat and cancel plts
******************************************************************************/
 
  PROCEDURE ResendAtlas;
  PROCEDURE ResendTolasLTDS;
  PROCEDURE ResendTolasFDS;
  
END TAGSYS_RESEND;
/


DROP PACKAGE BODY PT_APP.TAGSYS_RESEND;

CREATE OR REPLACE PACKAGE BODY PT_APP.TAGSYS_RESEND AS

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

  FUNCTION SendLTDSGR(i_plt_code IN VARCHAR2) RETURN NUMBER IS
				
				 
			/******************************************************************************
			NAME:       SendGR
			PURPOSE:    This function will send an LTDS-GR Pallet data 
				
			REVISIONS:
			Ver        Date        Author           Description
			---------  ----------  ---------------  ------------------------------------
			1.0        19/01/2005  Jeff Phillipson  1. Created this function.
                        2.0        31/01/2007  Daniel Owen      2. Modified for sending LTDS only for existing HU's
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
                                                         begin        
                                                          SELECT tolas_seq INTO v_seq from plt_tolas where plt_code = i_PLT_CODE;
                                                         exception
                                                         when others then
                                    			  SELECT PLT_TOLAS_SEQ.NEXTVAL INTO v_seq FROM dual;
                                                          INSERT INTO plt_tolas
							  VALUES (i_plt_code, v_seq);
                                                         end;
							     
											
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
  END SendLTDSGR;

  FUNCTION SendLTDSRGR(i_plt_code IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    /* AT time of writing, this type of file not sent */
    RETURN 1;
  END SendLTDSRGR;

  FUNCTION SendFDSGR(i_plt_code IN VARCHAR2) RETURN NUMBER IS
  				
				 
			/******************************************************************************
			NAME:       SendGR
			PURPOSE:    This function will send a FDS GR Pallet data 
				
			REVISIONS:
			Ver        Date        Author           Description
			---------  ----------  ---------------  ------------------------------------
			1.0        19/01/2005  Jeff Phillipson  1. Created this function.     
                        2.0        31/01/2007  Daniel Owen      2. Modified for sending FDS only for existing HU's
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
                                                         begin        
                                                          SELECT tolas_seq INTO v_seq from plt_tolas where plt_code = i_PLT_CODE;
                                                         exception
                                                         when others then
                                    			  SELECT PLT_TOLAS_SEQ.NEXTVAL INTO v_seq FROM dual;
                                                          INSERT INTO plt_tolas
							  VALUES (i_plt_code, v_seq);
                                                         end;
							     
									
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
  END SendFDSGR;
  
  FUNCTION SendFDSRGR(i_plt_code IN VARCHAR2) RETURN NUMBER IS
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
                                                         begin        
                                                          SELECT tolas_seq INTO v_seq from plt_tolas where plt_code = i_PLT_CODE;
                                                         exception
                                                         when others then
                                    			  SELECT PLT_TOLAS_SEQ.NEXTVAL INTO v_seq FROM dual;
                                                          INSERT INTO plt_tolas
							  VALUES (i_plt_code, v_seq);
                                                         end;
					   	   		
												
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
  END SendFDSRGR;

  PROCEDURE ResendAtlas AS
      CURSOR csr_resend IS
      SELECT d.*, 
             h.matl_code, 
             h.qty qty , 
             zpppi_batch batch 
      FROM PLT_DET d, PLT_HDR h
      WHERE h.plt_code in (select plt_code from resend_hu_atlas) 
      AND h.PLT_CODE = d.PLT_CODE
      ORDER BY 1,2,3 DESC;
      
      rcd_resend csr_resend%ROWTYPE;
      v_success  NUMBER;
      v_create   NUMBER;
      v_cancel   NUMBER;
    
  BEGIN
      v_create := 0;
      v_cancel := 0;
      
      /*FIRST CHECK IF THE sending OF Idocs has been disabled
      /*-*/
      IF NOT Idoc_Hold THEN
        OPEN csr_resend;
        LOOP
          FETCH csr_resend INTO rcd_resend;
          EXIT WHEN csr_resend%NOTFOUND;
          
          IF rcd_resend.reason = 'CREATE' THEN
            v_success := sendgr(rcd_resend.plt_code);
            DBMS_OUTPUT.PUT('ATLAS_GR: ');
            v_create := v_create + 1;
          ELSE
  	    /* otherwise cancel pallet */
            v_success := sendrgr(rcd_resend.plt_code);
            DBMS_OUTPUT.PUT('ATLAS_RGR: ');
            v_cancel := v_cancel + 1;
          END IF;
          
          IF v_success = 0 THEN
            DBMS_OUTPUT.PUT_LINE (rcd_resend.plt_code || ' OK');
          ELSE
            DBMS_OUTPUT.PUT_LINE (rcd_resend.plt_code || ' FAILED');
          END IF;
          
        END LOOP;
        CLOSE csr_resend;
      END IF; --NOT Idoc_Hold
      
      DBMS_OUTPUT.PUT_LINE('CREATES: ' || v_create);
      DBMS_OUTPUT.PUT_LINE('CANCELS: ' || v_cancel);
  END ResendAtlas;

  PROCEDURE ResendTolasLTDS AS
      CURSOR csr_resend IS
      SELECT d.*, 
             h.matl_code, 
             h.qty qty , 
             zpppi_batch batch 
      FROM PLT_DET d, PLT_HDR h
      WHERE h.plt_code in (select plt_code from resend_hu_tolas_ltds) 
      AND h.PLT_CODE = d.PLT_CODE
      ORDER BY 1,2,3 DESC;
      
      rcd_resend csr_resend%ROWTYPE;
      v_success  NUMBER;
      v_create   NUMBER;
      v_cancel   NUMBER;
    
  BEGIN
      v_create := 0;
      v_cancel := 0;
      
      /*FIRST CHECK IF THE sending OF Idocs has been disabled
      /*-*/
      IF NOT Idoc_Hold THEN
        OPEN csr_resend;
        LOOP
          FETCH csr_resend INTO rcd_resend;
          EXIT WHEN csr_resend%NOTFOUND;
          
          IF rcd_resend.reason = 'CREATE' THEN
            v_success := sendltdsgr(rcd_resend.plt_code);
            DBMS_OUTPUT.PUT('LTDS_GR: ');
            v_create := v_create + 1;
          ELSE
  	    /* otherwise cancel pallet */
            v_success := sendltdsrgr(rcd_resend.plt_code);
            DBMS_OUTPUT.PUT('LTDS_RGR: ');
            v_cancel := v_cancel + 1;
          END IF;
          
          IF v_success = 0 THEN
            DBMS_OUTPUT.PUT_LINE (rcd_resend.plt_code || ' OK');
          ELSE
            DBMS_OUTPUT.PUT_LINE (rcd_resend.plt_code || ' FAILED');
          END IF;
          
        END LOOP;
        CLOSE csr_resend;
      END IF;
      DBMS_OUTPUT.PUT_LINE('CREATES: ' || v_create);
      DBMS_OUTPUT.PUT_LINE('CANCELS: ' || v_cancel);
  END ResendTolasLTDS;

  PROCEDURE ResendTolasFDS AS
        CURSOR csr_resend IS
      SELECT d.*, 
             h.matl_code, 
             h.qty qty , 
             zpppi_batch batch 
      FROM PLT_DET d, PLT_HDR h
      WHERE h.plt_code in (select plt_code from resend_hu_tolas_fds) 
      AND h.PLT_CODE = d.PLT_CODE
      ORDER BY 1,2,3 DESC;
      
      rcd_resend csr_resend%ROWTYPE;
      v_success  NUMBER;
      v_create   NUMBER;
      v_cancel   NUMBER;
    
  BEGIN
      v_create := 0;
      v_cancel := 0;
      
      /*FIRST CHECK IF THE sending OF Idocs has been disabled
      /*-*/
      IF NOT Idoc_Hold THEN
        OPEN csr_resend;
        LOOP
          FETCH csr_resend INTO rcd_resend;
          EXIT WHEN csr_resend%NOTFOUND;
          
          IF rcd_resend.reason = 'CREATE' THEN
            v_success := sendfdsgr(rcd_resend.plt_code);
            DBMS_OUTPUT.PUT('FDS_GR: ');
            v_create := v_create + 1;
          ELSE
  	    /* otherwise cancel pallet */
            v_success := sendfdsrgr(rcd_resend.plt_code);
            DBMS_OUTPUT.PUT('FDS_RGR: ');
            v_cancel := v_cancel + 1;
          END IF;
          
          IF v_success = 0 THEN
            DBMS_OUTPUT.PUT_LINE (rcd_resend.plt_code || ' OK');
          ELSE
            DBMS_OUTPUT.PUT_LINE (rcd_resend.plt_code || ' FAILED');
          END IF;
          
        END LOOP;
        CLOSE csr_resend;
      END IF;
      
      DBMS_OUTPUT.PUT_LINE('CREATES: ' || v_create);
      DBMS_OUTPUT.PUT_LINE('CANCELS: ' || v_cancel);
  END ResendTolasFDS;
  
END TAGSYS_RESEND;
/


