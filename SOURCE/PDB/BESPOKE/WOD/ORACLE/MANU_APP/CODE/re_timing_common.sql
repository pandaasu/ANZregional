CREATE OR REPLACE PACKAGE MANU_APP.Re_Timing_Common IS

    -- System Constants
    SUBTYPE RESULT_TYPE IS INTEGER;
      SUCCESS  CONSTANT RESULT_TYPE := 0;  -- Worked Successfully.
      FAILURE  CONSTANT RESULT_TYPE := 1;  -- The request was failed to be carried out or the desired answer was false.  The reason for it being false will be containted in the error message.
      ERROR    CONSTANT RESULT_TYPE := 2;  -- Oracle Error Most likley or other serious problem.
      
    ISTRUE  CONSTANT RESULT_TYPE := 1;
    ISFALSE  CONSTANT RESULT_TYPE := 0;
    
    SUBTYPE ACCESS_TYPE IS INTEGER;
    NOACCESS CONSTANT ACCESS_TYPE := 0;
    READONLY CONSTANT ACCESS_TYPE := 1;
    EDIT     CONSTANT ACCESS_TYPE := 2;
    
    SCHEDULE_DAYS CONSTANT NUMBER := 21;  -- schedule period 
    
    /*-*/
    /* used as a string to lock the database
    /*-*/
    SUBTYPE LOCK_TYPE IS VARCHAR2(10);
    EDIT_MODE   CONSTANT LOCK_TYPE := 'PR_EDIT';
    
    /*-*/
    /* wodonga settings - this is the code that defines to Atlas the type of file received
    /*-*/
    SCHEDULE_CODE_AU20 CONSTANT VARCHAR(3) := '011';
    SCHEDULE_CODE_AU21 CONSTANT VARCHAR(3) := '014';
    SCHEDULE_CODE_AU22 CONSTANT VARCHAR(3) := '015';
    SCHEDULE_CODE_AU25 CONSTANT VARCHAR(3) := '016';
    
    -- Resend Codes used at WOD
    SCHEDULE_RESEND_CODE_AU20 CONSTANT VARCHAR(3) := 'W11';
    SCHEDULE_RESEND_CODE_AU21 CONSTANT VARCHAR(3) := 'W14';
    SCHEDULE_RESEND_CODE_AU22 CONSTANT VARCHAR(3) := 'W15';
    SCHEDULE_RESEND_CODE_AU25 CONSTANT VARCHAR(3) := 'W16';
    
    RETIMING_CODE CONSTANT VARCHAR2(3) := '010';
    /*-*/
    /* Bathurst values 
    /*-*/
    -- SHEDULE_CODE CONSTANT VARCHAR(3) := '012';
    -- RETIMING_CODE CONSTANT VARCHAR2(3) := '013';
    
    -- Default Reference Return Cursor.
    TYPE RETURN_REF_CURSOR IS REF CURSOR;


END;
/

GRANT EXECUTE ON MANU_APP.RE_TIMING_COMMON TO APPSUPPORT;
GRANT EXECUTE ON MANU_APP.RE_TIMING_COMMON TO PR_ADMIN;
GRANT EXECUTE ON MANU_APP.RE_TIMING_COMMON TO PR_APP WITH GRANT OPTION;
GRANT EXECUTE ON MANU_APP.RE_TIMING_COMMON TO PR_USER;

CREATE OR REPLACE PUBLIC SYNONYM RE_TIMING_COMMON FOR MANU_APP.RE_TIMING_COMMON;