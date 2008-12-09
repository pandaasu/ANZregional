CREATE OR REPLACE FUNCTION "NEXT_DATE" RETURN DATE IS

/******************************************************************************
   NAME:       Next_Date
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        25-Aug-06  Jeff Phillipson        1. Created this function.
   1.2        05-Nov-08  Chris Munn				1. Updated the function to handle the dynamic frozen window changes

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
    
  sqlstmt     varchar2(1000);
  var_next_date		   DATE DEFAULT TRUNC(SYSDATE);
	
BEGIN

  -- Build the SQL statement used to retrieve the date and time at which the Master Schedule Send should occur.
  sqlstmt := 'SELECT TO_DATE(TO_CHAR(TRUNC(SYSDATE) + 1,''dd-mon-yyyy'') || ';
        
  -- If tomorrow is a day on and a block of days off falls the next day.
  IF (RE_TIMING.IS_DAY_OFF(SYSDATE + 1) = false) AND (RE_TIMING.GET_OFF_BLOCK_LENGTH(SYSDATE + 1) >= 2) THEN
      -- Send the schedule at the earlier extended time.
      sqlstmt := sqlstmt || 'ext_wndw_time';
  ELSE
      -- otherwise send the schedule at the regular time.
      sqlstmt := sqlstmt || 'wndw_time';
  END IF;
  
  sqlstmt := sqlstmt || ',''dd-Mon-yyyy HH24:MI'')  Next_Date FROM RTT_Wndw_time WHERE Wndw_Date IN 
    (SELECT MAX(wndw_date) FROM RTT_Wndw_time WHERE Wndw_date <= SYSDATE+1)';
    
  -- Execute the query.
  EXECUTE IMMEDIATE sqlstmt INTO var_next_date;
  
  -- Return the date the master schedule send will next occur.
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

grant execute on manu_app.next_date to appsupport;
grant execute on manu_app.next_date to bthsupport;

create or replace public synonym next_date for manu_app.next_date;