CREATE OR REPLACE PACKAGE Re_Timing_Common IS
/******************************************************************************************************
   NAME:       Re_timing_Common
   PURPOSE:    Constants used by Re Timing.

   REVISIONS:
   Ver        Date          Author              Description
   ---------  ----------    ---------------     ------------------------------------
   1.0        21/11/2005    Jeff Phillipson     1. Created this package.
   2.0        10/06/2008    Daniel Owen         Added 6 day RTT msg code and renamed all RTT msg codes
   3.0		  05/11/2008	Chris Munn			Added message codes for window withs 6 up to days wide.
*******************************************************************************************************/

    -- System Constants
		SUBTYPE RESULT_TYPE IS INTEGER;
  		SUCCESS  CONSTANT RESULT_TYPE := 0;  -- Worked Successfully.
  		FAILURE  CONSTANT RESULT_TYPE := 1;  -- The request was failed to be carried out or the desired answer was false.  The reason for it being false will be containted in the error message.
  		ERROR    CONSTANT RESULT_TYPE := 2;  -- Oracle Error Most likley or other serious problem.
  		
		ISTRUE	CONSTANT RESULT_TYPE := 1;
		ISFALSE	CONSTANT RESULT_TYPE := 0;
		
		SUBTYPE ACCESS_TYPE IS INTEGER;
		NOACCESS CONSTANT ACCESS_TYPE := 0;
		READONLY CONSTANT ACCESS_TYPE := 1;
		EDIT     CONSTANT ACCESS_TYPE := 2;
		
		/*-*/
		/* Note: The Firm Start and End times are defined in the RE_TIMING package
		/*-*/
		SCHEDULE_DAYS CONSTANT NUMBER := 21;  -- schedule period 
		
		/*-*/
		/* This is the start time for the production Schedule to be sent to Atlas
		/* ie 6 pm = 6:00pm
		/*-*/
		SCHEDULE_TIME CONSTANT NUMBER := 18/24;
		/*-*/
		/* The SCHEDULE_TIME_DELAY is the estimated time to get into Atlas and allow MRP to run 
		/*-*/
		SCHEDULE_TIME_DELAY CONSTANT NUMBER := 50/1440;  -- corresponds to 50 minutes 
		/*-*/
		/* this constant is used for the RTT schedule send
		/* if the time is before SCHEDULE_CHANGE then now + 1 is added as the Firm date
		/* after SCHEDULE_CHANGE the firm date is now + 2 days
		/*-*/
		SCHEDULE_CHANGE CONSTANT NUMBER := SCHEDULE_TIME + SCHEDULE_TIME_DELAY;
		
		/*-*/
		/* used as a string to lock the database
		/*-*/
		SUBTYPE LOCK_TYPE IS VARCHAR2(10);
		EDIT_MODE   CONSTANT LOCK_TYPE := 'PR_EDIT';
		
		/*-*/
		/* wodonga settings 
		/*-*/
		--SCHEDULE_CODE CONSTANT VARCHAR(3) := '011';
		--RETIMING_CODE CONSTANT VARCHAR2(3) := '010';
		/*-*/
		/* Bathurst values 
		/*-*/
		SCHEDULE_CODE CONSTANT VARCHAR(3) := '012';
		RETIMING_CODE_2DAYS CONSTANT VARCHAR2(3) := '013'; -- indicates a window width of 2 days
		RETIMING_CODE_3DAYS CONSTANT VARCHAR2(3) := '017'; -- indicates a window width of 3 days
        RETIMING_CODE_4DAYS CONSTANT VARCHAR2(3) := '020'; --  indicates a window width of 4 days
		RETIMING_CODE_5DAYS CONSTANT VARCHAR2(3) := '021'; --  indicates a window width of 5 days
        RETIMING_CODE_6DAYS CONSTANT VARCHAR2(3) := '022'; --  indicates a window width of 6 days
                
		-- Default Reference Return Cursor.
		TYPE RETURN_REF_CURSOR IS REF CURSOR;
END;



grant execute on manu_app.re_timing_common to appsupport;
grant execute on manu_app.re_timing_common to bthsupport;
grant execute on manu_app.re_timing_common to pr_admin;
grant execute on manu_app.re_timing_common to pr_app with grant option;
grant execute on manu_app.re_timing_common to pr_user;

create or replace public synonym re_timing_common for manu_app.re_timing_common;