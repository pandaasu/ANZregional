DROP PROCEDURE MANU_APP.PROC_ORDER_MONITOR;

CREATE OR REPLACE PROCEDURE MANU_APP.Proc_Order_Monitor IS
       
/******************************************************************************
   NAME:       PROC_ORDER_MONITOR
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/04/2005   Jeff Phillipson 1. Created this procedure.

   NOTES: This job will check if the 5minute refresh for proc. orders has occured
   an email will be sent if this fails with a set time period 

  
******************************************************************************/

     v_count NUMBER;
     v_last   DATE;
     v_last_recorded DATE;
     
     
     /*********************************************
     RAISE email notification OF error
     **********************************************/
     PROCEDURE raiseNotification(message IN VARCHAR2, dbas IN NUMBER)
     IS
     
         vmessage VARCHAR2(4000);
         
     BEGIN
          vmessage := message;
          IF dbas <>  1 THEN
              Mailout(vmessage, Manu_Common.CONTACT, 'Plant_Database');
          ELSE
              Mailout(vmessage, Manu_Common.MANAGERS_LOCAL_SUPPORT, 'Plant_Database');
          END IF;
     EXCEPTION
         WHEN OTHERS THEN
         vmessage := message;
     END;
     
     
     
                                                                               
BEGIN     
     
     SELECT LAST_REFRESH, l.* INTO v_last, v_last_recorded
     FROM ALL_SNAPSHOT_REFRESH_TIMES r, LAST_REFRESH l
     WHERE owner = 'MANU' 
     AND name = 'CNTL_REC';
     
     
         IF v_last = v_last_recorded  THEN
             -- error has occurred 
             raiseNotification('The 5 minute Fast Refresh failed from LADS (AP0064P) to the Plant Database (MFA005)'
               || CHR(13) 
               || CHR(13) || '   It has been at least 15 minutes since the last refresh'
               || CHR(13) 
               || CHR(13) || 'Please contact the DBA''s'
               || CHR(13) 
               || CHR(13) || 'Note: This prevents proc Orders from being sent to Shiftlog',0);
               dbms_output.put_line('Failed' );
         ELSE
             -- ok so just save 
             UPDATE LAST_REFRESH SET last_refresh_datime = v_last;
             dbms_output.put_line('Good' );
         END IF;
     
     
     
   EXCEPTION
    
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       raiseNotification('PROC_ORDER_MONITOR job failed',0);
       
END Proc_Order_Monitor;
/


