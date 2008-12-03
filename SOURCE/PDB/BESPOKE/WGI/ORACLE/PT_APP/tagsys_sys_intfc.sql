DROP PACKAGE PT_APP.TAGSYS_SYS_INTFC;

CREATE OR REPLACE PACKAGE PT_APP.Tagsys_Sys_Intfc AS
/******************************************************************************
   NAME:       TAGSYS_SYS_INTFC
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/01/2005  Jeff Phillipson           1. Created this package.
******************************************************************************/

 
  PROCEDURE CheckSendsPlt;
  PROCEDURE CheckSendsSTO;
  PROCEDURE CheckSendsDisposition;
  
END Tagsys_Sys_Intfc;
/


DROP PACKAGE BODY PT_APP.TAGSYS_SYS_INTFC;

CREATE OR REPLACE PACKAGE BODY PT_APP.Tagsys_Sys_Intfc AS
/******************************************************************************
   NAME:       TAGSYS_SYS_INTFC
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/01/2005  Jeff Phillipson           1. Created this package body.
******************************************************************************/



         RESEND_MAX   CONSTANT NUMBER  := 5;


         /*********************************************
         RAISE email notification OF error
         **********************************************/
         PROCEDURE raiseNotification(message IN VARCHAR2)
             IS
     
                 vmessage VARCHAR2(4000);
         
             BEGIN
                 vmessage := message;
                 Mailout(vmessage);
             EXCEPTION
                 WHEN OTHERS THEN
                     vmessage := message;
             END;
     
             
   FUNCTION SendGR ( i_plt_code IN VARCHAR2) RETURN NUMBER IS
    
     
   /******************************************************************************
   NAME:       SendGR
   PURPOSE:    This function will send a GR Pallet data 
    
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/01/2005  Jeff Phillipson  1. Created this function.     
   ******************************************************************************/
     
                 iSuccess         NUMBER;
                 o_result         NUMBER;
                 o_result_msg     VARCHAR2(2000);
                 
                                                                             
                 CURSOR c_p
                 IS
                     SELECT h.*, REASON, xactn_date, xactn_time,
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
                     Create_Idoc(o_result, o_result_msg,
                         'Z_PI1', rcd.plant_code,
                         rcd.sender_name || ':' || SUBSTR(rcd.PLT_CODE,1,18), --rcd.sender_name, 
                         FALSE,
                         TO_NUMBER(rcd.proc_order),rcd.xactn_date,
                         rcd.xactn_time, rcd.matl_code,
                         rcd.qty, rcd.uom,
                         TO_NUMBER(rcd.stor_locn_code), rcd.dispn_code,
                         rcd.zpppi_batch, FALSE,
                         TO_CHAR(rcd.use_by_date,'YYYYMMDD'));
                                       
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
 
 
 
 
 
     FUNCTION SendRGR ( i_plt_code IN VARCHAR2) RETURN NUMBER IS
    
    
    /******************************************************************************
       NAME:       SendGR
       PURPOSE:    This function will send a GR Pallet data 
    
       REVISIONS:
       Ver        Date        Author           Description
       ---------  ----------  ---------------  ------------------------------------
       1.0        19/01/2005  Jeff Phillipson  1. Created this function.     
    
    ******************************************************************************/
        iSuccess         NUMBER;
                    o_result         NUMBER;
                    o_result_msg     VARCHAR2(2000);
                 
                                                                             
                    CURSOR c_p
                    IS
                    SELECT h.*, REASON, xactn_date, xactn_time,
                        sender_name, user_id
                    FROM PLT_HDR h, PLT_DET d
                    WHERE h.PLT_CODE = d.PLT_CODE
                    AND d.plt_code = i_plt_code
                    AND d.REASON = 'CANCEL';
                 
                    rcd c_p%ROWTYPE;
                 
                 BEGIN
                 
                   o_result  := 0;
                 
       OPEN c_p;
                       LOOP
                       
                           FETCH c_p INTO rcd;
                           EXIT WHEN c_p%NOTFOUND;
                           dbms_output.put_line ('Z44');
                           Create_Idoc(o_result, o_result_msg,
                                       'Z_PI2', rcd.plant_code,
                                       rcd.sender_name || ':' || SUBSTR(rcd.PLT_CODE,1,18), --rcd.sender_name, 
                                       FALSE,
                                       TO_NUMBER(rcd.proc_order),rcd.xactn_date,
                                       rcd.xactn_time, rcd.matl_code,
                                       rcd.qty, rcd.uom,
                                       TO_NUMBER(rcd.stor_locn_code), rcd.dispn_code,
                                       rcd.zpppi_batch, FALSE,
                                       TO_CHAR(rcd.use_by_date,'YYYYMMDD'));
                                       
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
    END SendRGR;
 
 
 
                





 
  PROCEDURE CheckSendsPlt IS
    
    
    CURSOR c_chk IS
    SELECT d.*, h.matl_code, h.qty qty , zpppi_batch batch 
    FROM PLT_DET d, PLT_HDR h
    WHERE sent_flag IS NULL
    AND h.PLT_CODE = d.PLT_CODE
    ORDER BY 1,2,3 DESC;
    
    r_chk c_chk%ROWTYPE;
    
    v_count    NUMBER;
    v_success  NUMBER;
    
  BEGIN
      /* check any Create and Cancel Pallets for a send error 
      || first CHECK IF the sending OF Idocs has been disabled
      */
      IF NOT Idoc_Hold THEN
      
          OPEN c_chk;
          LOOP
              FETCH c_chk INTO r_chk;
              EXIT WHEN c_chk%NOTFOUND;
             
            
              IF r_chk.reason = 'CREATE' THEN
                  v_success := sendgr(r_chk.plt_code);
              ELSE
                  v_success := sendrgr(r_chk.plt_code);
              END IF;
            
                 
              -- send email notification
              raiseNotification('Found A pallet not sent via the Idoc.' || r_chk.plt_code);
           
           
              IF v_success = 0 THEN
                 UPDATE PLT_DET SET sent_flag = 'Y'
                  WHERE plt_code = r_chk.plt_code
                    AND reason = r_chk.reason;
                 --dbms_output.put_line (r_chk.plt_code || 'OK');
              ELSE
                 SELECT COUNT(*) 
                   INTO v_count
                   FROM plt_idoc_log
                  WHERE plt_code = r_chk.plt_code
                    AND XACTN_TYPE = r_chk.reason;
                       
                 IF v_count = 1 THEN
                     SELECT RESEND_COUNT 
                       INTO v_count
                       FROM plt_idoc_log
                      WHERE plt_code = r_chk.plt_code
                        AND XACTN_TYPE = r_chk.reason;
                 ELSE
                     v_count := 0;
                 END IF;
                     
                 UPDATE PLT_IDOC_LOG 
                    SET resend_count = v_count + 1
                  WHERE plt_code = r_chk.plt_code 
                    AND XACTN_TYPE = r_chk.reason;
                 --dbms_output.put_line (r_chk.plt_code || 'Failed again' || r_chk.plt_code);
              END IF;
          END LOOP;
          CLOSE c_chk;
          COMMIT;
      END IF;  
        
  EXCEPTION
     WHEN OTHERS THEN
         ROLLBACK;
         raiseNotification('ERROR OCCURED - <Tagsys_Sys_Intfc.CheckSendsPlt> ' || CHR(13) ||SQLERRM);    
  END;

  
  
  
  
  PROCEDURE CheckSendsSTO  IS
 
  /******************************************************************************
   NAME:       CheckSendsSTO
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        17/02/2005   Jeff Phillipson 1. Created this procedure.

   NOTES:

  
******************************************************************************/

    CURSOR c_chk IS
    SELECT h.*
    FROM STO_DET d, STO_HDR h
    WHERE sent_flag IS NULL AND mesg_status = 'E'
    AND h.cnn = d.cnn
    ORDER BY 1,2,3 DESC;
    
    r_chk c_chk%ROWTYPE;
    
    
    CURSOR c_sto IS
    SELECT d.cnn,  matl_code, uom, SUM(qty) qty, stock_status, batch,
           DEST_PLANT, DELIV_DATE, DECODE(deliv_time, NULL, 0, deliv_time) DELIV_TIME,
           d.plt_code
    FROM STO_DET d, STO_HDR h
    WHERE h.cnn = d.cnn
    AND h.cnn = r_chk.cnn
    GROUP BY d.cnn, matl_code, uom, stock_status, batch, 
             DEST_PLANT, DELIV_DATE, DECODE(deliv_time, NULL, 0, deliv_time), d.plt_code
    ORDER BY batch;
          
    rcd c_sto%ROWTYPE;
       
       
    v_intfc_rtn      NUMBER(15,0);
 v_interface_type    VARCHAR2(10) := 'CISATL04.1'; 
    v_line              NUMBER;
    v_count             NUMBER;
    v_success           NUMBER;
    v_stock_status      VARCHAR2(1);
    
    o_result            NUMBER;
    o_result_msg        VARCHAR2(2000);
    
    e_process_exception EXCEPTION;
 e_IDOC_EXCEPTION EXCEPTION;
    
    
    
BEGIN
    
    IF NOT Idoc_Hold THEN

    -- check any Create and Cancel Pallets for a send error 
    o_result := 0;  
    OPEN c_chk;
      LOOP
         FETCH c_chk INTO r_chk;
         EXIT WHEN c_chk%NOTFOUND;
           --  SELECT RESEND_COUNT INTO v_count
           --  FROM plt_idoc_log
           --  WHERE plt_code = r_chk.plt_code;
           --  IF v_count >= RESEND_MAX THEN
           --      -- send email notification
           --      raiseNotification('Maximum resnds has been reached.');
           --  ELSE
             
             
         BEGIN
                
              --Create PASSTHROUGH interface on ICS for GR or RGR message to Atlas
              v_intfc_rtn := outbound_loader.create_interface(v_interface_type);

              --CREATE DATA LINES FOR MESSAGE

              -- HEADER: Header Record
              -- Including 'X' at the end of the header record will cause Atlas
              -- to treat the message as a test, meaning no further processing
              -- will be completed once it reaches Atlas.
              outbound_loader.append_data('HDRZUB '
                  ||LPAD(Plt_Common.CMPNY_CODE,4,' ')
                  ||RPAD(Plt_Common.PURCH_ORG,4,' ')
                  ||RPAD(Plt_Common.PURCH_GRP,3,' ')
                  ||RPAD(Plt_Common.VENDOR,8,' ')
                  ||RPAD(TRIM(Plt_Common.source_PLANT),4,' ')
                  ||RPAD(Plt_Common.CURRENCY,5,' ')
                  ||RPAD(' ',12,' '));
            
                        
              v_line := 10;
              
              OPEN c_sto;
              LOOP
                  FETCH c_sto INTO rcd;
                  EXIT WHEN c_sto%NOTFOUND;
                  
                  SELECT DISPN_CODE INTO v_stock_status
                  FROM PLT_HDR 
                  WHERE plt_code = rcd.plt_code;
                  
                  
                  -- DET: PROCESS ORDER 
                  outbound_loader.append_data('DET'
                       ||LPAD(TO_CHAR(v_line),5,'0')
                       ||RPAD(TRIM(rcd.MATL_code),8,' ')
                       ||RPAD(TRIM(rcd.dest_plant),4,' ')
                       ||RPAD(TRIM(Plt_Common.STOR_LOCN),4,' ')
                       ||RPAD(UPPER(rcd.uom),3,' ')
                       ||LTRIM(TO_CHAR(rcd.qty,'000000000.000'))
                       ||RPAD(v_stock_status,1,' ')
                       ||TO_CHAR(rcd.deliv_date,'YYYYMMDD')
                       ||LPAD(TO_CHAR(rcd.Deliv_Time),6,'0')
                       ||RPAD(rcd.Batch,10,' '));
                       
                  v_line := v_line + 10;
                                           
              END LOOP;
              CLOSE c_sto;
          
              --Close PASSTHROUGH INTERFACE
              outbound_loader.finalise_interface();
          
              v_success := 0;
              
         EXCEPTION              
              WHEN OTHERS THEN
              IF (outbound_loader.is_created()) THEN
                  outbound_loader.finalise_interface();
              END IF;
              
                 -- error has occured   
                 v_success := 1;
                 
                 
         END;      
         
         -- send email notification
         raiseNotification('Found A STO not sent via the Idoc.' || r_chk.cnn);       
                
         IF v_success = 0 THEN
             UPDATE STO_HDR SET sent_flag = 'Y'
             WHERE cnn = r_chk.cnn;
                     
             dbms_output.put_line (r_chk.cnn || 'OK');
         ELSE
             SELECT COUNT(*) INTO v_count
             FROM sto_idoc_log
             WHERE cnn = r_chk.cnn;
             IF v_count = 1 THEN
                SELECT resend_count INTO v_count
                FROM sto_idoc_log
                WHERE cnn = r_chk.cnn;
                
                UPDATE sto_idoc_log SET resend_count = v_count + 1
                WHERE cnn = r_chk.cnn;
             
             ELSE
                 v_count := 0;
             END IF;
             
         END IF;
         
      END LOOP;
      CLOSE c_chk;
    END IF;
    COMMIT;
        
   EXCEPTION
     WHEN OTHERS THEN
         ROLLBACK;
         raiseNotification('ERROR OCCURED - <Tagsys_Sys_Intfc.CheckSendsPlt> ' || CHR(13) ||SQLERRM);    
   END;






     PROCEDURE CheckSendsDisposition IS

     /******************************************************************************
         NAME:       CheckSendsDisposition
         PURPOSE:    

         REVISIONS:
         Ver        Date        Author           Description
         ---------  ----------  ---------------  ------------------------------------
         1.0        17/02/2005   Jeff Phillipson 1. Created this procedure.

         NOTES:

  
     ******************************************************************************/

     CURSOR c_dsp IS
         SELECT d.*, matl_code, qty, uom 
         FROM PLT_DSPSTN  d, PLT_HDR h
         WHERE sent_flag IS NULL
         AND h.PLT_CODE = d.PLT_CODE;
    
     rcd c_dsp%ROWTYPE;
    
   
    
     v_count                 NUMBER;
     v_intfc_rtn          NUMBER(15,0);
 v_interface_type     VARCHAR2(10) := 'CISATL05.1';
     v_sign                  VARCHAR2(1);
     v_rec_stock_status      VARCHAR2(1);
     v_plt_code              VARCHAR2(12);
     o_result_msg            VARCHAR2(2000);
     o_result                NUMBER;
    
     e_process_exception     EXCEPTION;
     e_escape_exception      EXCEPTION;
 e_IDOC_EXCEPTION     EXCEPTION;
    
                                                                              
BEGIN
     /* check any Create and Cancel Pallets for a send error 
     || first CHECK IF the sending OF Idocs has been disabled
     */
     IF NOT Idoc_Hold THEN
     o_result := 0;
     OPEN c_dsp;
     LOOP
         FETCH c_dsp INTO rcd ;
         EXIT WHEN c_dsp%NOTFOUND;
             BEGIN
                       
                 --Create PASSTHROUGH interface on ICS for GR or RGR message to Atlas
                 v_intfc_rtn := outbound_loader.create_interface(v_interface_type);

                 

                 -- HEADER: Header Record
                 -- Including 'X' at the end of the header record will cause Atlas
                 -- to treat the message as a test, meaning no further processing
                 -- will be completed once it reaches Atlas.
                 outbound_loader.append_data('HDR'
                     ||TO_CHAR(SYSDATE,'yyyymmdd')
                     ||TO_CHAR(SYSDATE,'hh24miss')
                     ||RPAD(' ',16,' ')
                     ||RPAD(' ',25,' ')
                     ||RPAD(LTRIM(rcd.Whse_Ref),16,' '));
                             
                     -- DBMS_OUTPUT.PUT_LINE(TO_CHAR(rcd.qty,'000000000.000'));
                     --DET: PROCESS ORDER
                     IF rcd.SIGN IS NULL THEN
                         v_sign := ' ';
                     ELSE
                         v_sign := rcd.SIGN;
                     END IF;  
                     IF rcd.rec_stock_status IS NULL THEN
                         v_rec_stock_status := ' ';
                     ELSE
                         V_rec_stock_status := rcd.rec_stock_status;
                     END IF;
                     IF rcd.dspstn_type <> 'STCH' THEN  
                         v_rec_stock_status := ' ';
                     END IF;                   
                                        
                     outbound_loader.append_data('DET'
                         ||RPAD(Plt_Common.SOURCE_PLANT,4)
                         ||LPAD(rcd.sloc_1,4,'0')
                         ||RPAD(' ', 4,' ')
                         ||RPAD(' ', 4,' ')
                         ||RPAD(rcd.matl_code,8,' ')
                         ||RPAD(rcd.dspstn_type,4,' ')
                         ||v_sign
                         ||LTRIM(TO_CHAR(rcd.qty,'000000000.000'))
                         ||RPAD(TRIM(rcd.uom),3,' ')
                         ||RPAD(rcd.iss_stock_status,1,' ')
                         ||RPAD(rcd.rec_stock_status,1,' ')
                         ||RPAD(rcd.Batch,10,' ')
                         ||RPAD(' ',8,' ')
                         ||RPAD(' ',1,' ')
                         ||RPAD(' ',8,' ')
                         ||RPAD(' ',8,' '));
                                           
                                           
                     --Close PASSTHROUGH INTERFACE
                     outbound_loader.finalise_interface();                         
                     dbms_output.put ('Sent Idoc');
                   
                     o_result := Plt_Common.SUCCESS;
               
             EXCEPTION
                 WHEN OTHERS THEN
                 IF (outbound_loader.is_created()) THEN
                     outbound_loader.finalise_interface();
                 END IF;
                           
                     -- error has occured 
                     -- insert record in log file
                     --o_result_msg := 'ERROR OCCURED'|| '-' || SUBSTR(SQLERRM,1,256);
                     --o_result := SQLCODE;
                     --INSERT INTO DSPSTN_IDOC_LOG
                       --  VALUES (rcd.PLT_CODE, 0,o_result_msg, SYSDATE, o_result);
                     -- raise error 
                     o_result_msg := 'Disposition Idoc create Failed ['|| o_result_msg ||']';
                     o_result := Plt_Common.FAILURE;
                    -- RAISE e_IDOC_EXCEPTION;
             END;
                 
                 
             
            
             IF o_result = Plt_Common.SUCCESS THEN
                 UPDATE PT.PLT_DSPSTN SET SENT_FLAG = 'Y'
           WHERE PLT_CODE = UPPER(rcd.PLT_CODE);
                     
                 dbms_output.put_line (rcd.PLT_CODE || 'OK');
             ELSE
                 SELECT COUNT(*) INTO v_count
                 FROM dspstn_idoc_log
                 WHERE plt_code = rcd.plt_code;
                 IF v_count = 1 THEN
                    SELECT resend_count INTO v_count
                    FROM dspstn_idoc_log
                    WHERE  plt_code = rcd.plt_code;
                 
                    UPDATE dspstn_idoc_log SET resend_count = v_count + 1
                    WHERE plt_code = rcd.plt_code;
                ELSE
                    v_count := 0;
                END IF;
                 
                
             END IF;
             
            -- send email notification
            raiseNotification('Found A Disposition not sent via the Idoc.' || rcd.plt_code); 
                                                  
          
         END LOOP;
         CLOSE c_dsp;    
    END IF;
END CheckSendsDisposition;




   
END Tagsys_Sys_Intfc;
/


GRANT EXECUTE ON PT_APP.TAGSYS_SYS_INTFC TO SHIFTLOG;

GRANT EXECUTE ON PT_APP.TAGSYS_SYS_INTFC TO SHIFTLOG_APP;

