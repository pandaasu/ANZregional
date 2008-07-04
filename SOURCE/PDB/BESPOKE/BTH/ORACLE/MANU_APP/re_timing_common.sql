DROP PACKAGE MANU_APP.RE_TIMING_COMMON;

CREATE OR REPLACE PACKAGE MANU_APP.Re_Timing_Common IS

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
		RETIMING_CODE CONSTANT VARCHAR2(3) := '013';
		RETIMING_LONG_CODE CONSTANT VARCHAR2(3) := '017';  -- used if the window is based on after 18:50 ie 3 days
                RETIMING_FRI_LONG_CODE CONSTANT VARCHAR2(3) := '020';  --  special case used on Fridays only, when the window is based after mrp period it becomes 4 days
		RETIMING_CODE_5DAYS CONSTANT VARCHAR2(3) := '021';  --  special case used when the window is +5 days
                
		-- Default Reference Return Cursor.
		TYPE RETURN_REF_CURSOR IS REF CURSOR;


END;
/


DROP PUBLIC SYNONYM RE_TIMING_COMMON;

CREATE PUBLIC SYNONYM RE_TIMING_COMMON FOR MANU_APP.RE_TIMING_COMMON;


GRANT EXECUTE ON MANU_APP.RE_TIMING_COMMON TO APPSUPPORT;

GRANT EXECUTE ON MANU_APP.RE_TIMING_COMMON TO BTHSUPPORT;

GRANT EXECUTE ON MANU_APP.RE_TIMING_COMMON TO PR_ADMIN;

GRANT EXECUTE ON MANU_APP.RE_TIMING_COMMON TO PR_APP WITH GRANT OPTION;

GRANT EXECUTE ON MANU_APP.RE_TIMING_COMMON TO PR_USER;

