DROP PROCEDURE MANU_APP.COPY_STOCK_BALANCE;

CREATE OR REPLACE PROCEDURE MANU_APP.Copy_Stock_Balance
AS
/****************************************************

Procedure to copy the stock balance table every Tuesday morning

This is used to hold the previous stoick leveles as of tha last Monday of each week

   
     
Author:  Jeff Phillipson  7/10/2004 

****************************************************/


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
     
     
       
       
   
BEGIN
   
   DELETE FROM pf.stock_blnc_monday;
   
   INSERT INTO pf.stock_blnc_monday
   (SELECT plant, strg_lctn, stock_blnc_date, 
      stock_blnc_time, LTRIM(matl_code,'0'),
      SPCL_STOCK_INDCTR, QTY_IN_STOCK, 
      STOCK_UOM, BEST_BFR_DATE, 
      CNSGNMNT_CUST_OR_VEND,
      RCVNG_OR_ISSNG_LCTN, STOCK_TYPE
    FROM manu.stock_blnc);
 
   COMMIT;
   
EXCEPTION

    WHEN OTHERS THEN
         ROLLBACK;
        --Raise an error 
        raiseNotification('MANU.Copy_Stock_balance Procedure - ' || SUBSTR(SQLERRM, 1, 512));
END;
/


