DROP PACKAGE MANU_APP.RE_TIMING_COMMON;

CREATE OR REPLACE PACKAGE MANU_APP.Re_Timing_Common IS

  TYPE resource_array IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
  
  resources resource_array;
  
  
    -- System Constants
  SUBTYPE RESULT_TYPE IS INTEGER;
    SUCCESS  CONSTANT RESULT_TYPE := 0;  -- Worked Successfully.
    FAILURE  CONSTANT RESULT_TYPE := 1;  -- The request was failed to be carried out or the desired answer was false.  The reason for it being false will be containted in the error message.
    ERROR    CONSTANT RESULT_TYPE := 2;  -- Oracle Error Most likley or other serious problem.
    
  ISTRUE CONSTANT RESULT_TYPE := 1;
  ISFALSE CONSTANT RESULT_TYPE := 0;
  
  SUBTYPE ACCESS_TYPE IS INTEGER;
  NOACCESS CONSTANT ACCESS_TYPE := 0;
  READONLY CONSTANT ACCESS_TYPE := 1;
  EDIT     CONSTANT ACCESS_TYPE := 2;
  
  SCHEDULE_DAYS CONSTANT NUMBER := 56;  -- schedule period 
  
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
        SCHEDULE_CODE_AU40   CONSTANT VARCHAR2(3) := '061';
        PRODN_PLAN_CODE_AU40 CONSTANT VARCHAR2(3) := '040';
        SCHEDULE_CODE_AU45   CONSTANT VARCHAR2(3) := '061';
        PRODN_PLAN_CODE_AU45 CONSTANT VARCHAR2(3) := '045';
  SCHEDULE_CODE_AU20   CONSTANT VARCHAR2(3) := '011';
  SCHEDULE_CODE_AU21   CONSTANT VARCHAR2(3) := '014';
  SCHEDULE_CODE_AU22   CONSTANT VARCHAR2(3) := '015';
  SCHEDULE_CODE_AU25   CONSTANT VARCHAR2(3) := '016';
  RETIMING_CODE        CONSTANT VARCHAR2(3) := '010';
  RETIMING_LONG_CODE   CONSTANT VARCHAR2(3) := '010'; -- the same as above to keep in line with Bathurst
  /*-*/
  /* Bathurst values 
  /*-*/
  -- SHEDULE_CODE CONSTANT VARCHAR(3) := '012';
  -- RETIMING_CODE CONSTANT VARCHAR2(3) := '013';
  
  -- Default Reference Return Cursor.
  TYPE RETURN_REF_CURSOR IS REF CURSOR;


END;
/


DROP PUBLIC SYNONYM RE_TIMING_COMMON;

CREATE PUBLIC SYNONYM RE_TIMING_COMMON FOR MANU_APP.RE_TIMING_COMMON;


GRANT EXECUTE ON MANU_APP.RE_TIMING_COMMON TO APPSUPPORT;

GRANT EXECUTE ON MANU_APP.RE_TIMING_COMMON TO SITESUPPORT;

