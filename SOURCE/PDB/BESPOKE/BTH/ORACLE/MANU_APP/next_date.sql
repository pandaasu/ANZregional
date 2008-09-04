DROP FUNCTION MANU_APP.NEXT_DATE;

CREATE OR REPLACE FUNCTION MANU_APP.Next_Date RETURN DATE IS

/******************************************************************************
   NAME:       Next_Date
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        25-Aug-06  Jeff Phillipson        1. Created this function.

   NOTES:
   	  Purpose:		   Due to planned Atlas outages it is necessary to automate the
	  				   Master Schedule send times plus make the Firm window change follow any
					   changes.
	  				   The table RTT_WNDW_TIME is used to manually load 
	  				   effective dates for schedule changes due to Atlas outages.
					   This table is then used to determine the next time the schedule
					   is sent to Atlas and also control the RTT Firm window settings.
	  Returns:		   Date and time of the next days schedule run
  
      Object Name:     Next_Date
      Date and Time:   25-Aug-06 1:25:48 PM
      Username:        PHILLJEF
      Table Name:      Gets data from RTT_WNDW_TIME

******************************************************************************/
    
	CURSOR csr_wndw
	IS
	SELECT TO_DATE(TO_CHAR(TRUNC(SYSDATE)+decode(to_char(sysdate,'DY'),'FRI', 2,1),'dd-mon-yyyy') || ' ' || decode(to_char(sysdate,'DY'),'THU', fri_wndw_time,wndw_time),'dd-Mon-yyyy HH24:MI')  Next_Date FROM RTT_Wndw_time WHERE Wndw_Date IN
	(SELECT MAX(wndw_date) FROM RTT_Wndw_time WHERE Wndw_date <= SYSDATE+decode(to_char(sysdate,'DY'),'FRI', 2,1));
	
	var_next_date		   DATE DEFAULT TRUNC(SYSDATE);
	
BEGIN
  
    OPEN csr_wndw;
    LOOP
       FETCH csr_wndw INTO var_next_date;
       EXIT WHEN csr_wndw%NOTFOUND;
    END LOOP;
    CLOSE csr_wndw;
    
   RETURN var_next_date;
   
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
	   RETURN var_next_date;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
	   RETURN var_next_date;
	   
END Next_Date;
/


DROP PUBLIC SYNONYM NEXT_DATE;

CREATE PUBLIC SYNONYM NEXT_DATE FOR MANU_APP.NEXT_DATE;


GRANT EXECUTE ON MANU_APP.NEXT_DATE TO APPSUPPORT;

GRANT EXECUTE ON MANU_APP.NEXT_DATE TO BTHSUPPORT;

