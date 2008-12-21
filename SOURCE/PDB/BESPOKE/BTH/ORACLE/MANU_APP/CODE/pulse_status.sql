DROP FUNCTION MANU_APP.PULSE_STATUS;

CREATE OR REPLACE FUNCTION MANU_APP.Pulse_Status(i_userid IN VARCHAR2) RETURN NUMBER IS

/******************************************************************************
   NAME:       Pulse_Status 
   PURPOSE:    Used by Re_Timing Tool 
	            This function is ddesigned to update the CLIENT_INFO field of the SESSION table 
					with the current time stamp .
					If a READ ONLY User accesses the procedure a number is returned.
					The numbers do not represent anything to the calling app 

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        24-Nov-05          1. Created this function.

   NOTES:	  This function is used to allow only the first user with Update rights to 
				  Edit the screen data and so update the CLIENT_INFO field
				  
				  RETURN 0 Fault 
				  RETURN 9 Editor in normal operation 
				  RETURN 8 Non editor in normal operation 

******************************************************************************/

    /*-*/
    /* Private exceptions
    /*-*/
    application_exception EXCEPTION;
    PRAGMA EXCEPTION_INIT(application_exception, -20000);
	
    /*-*/
    /* Private variables 
    /*-*/
	 var_lock_handle VARCHAR2(128);
	 var_status      NUMBER;
	 var_client_info VARCHAR2(200);
	  
BEGIN
	 
     /*-*/ 
 	  /* get the client info sesssion information 
 	  /*-*/ 
	  dbms_application_info.read_client_info(var_client_info);
	  
	  
	  IF var_client_info IS NOT NULL  THEN
	  	  /*-*/
		  /* if result is null no assoc has the application in Edit Mode 
		  /* so setup Lock for this user 
	  	  /* set up a lock so that v$ession can be written to exclusivly 
	  	  /*-*/
	  	  dbms_lock.allocate_unique('RE_TIMING', var_lock_handle);
	
     	  var_status := dbms_lock.request(var_lock_handle, dbms_lock.x_mode, dbms_lock.maxwait); -- hope x_mode = 6  
	  	  IF var_status > 1 THEN
		      RAISE_APPLICATION_ERROR(-20000, 'Get_Edit_Status  - Unable to aquire lock ');
        END IF;
	  
	  	  /*-*/
	  	  /* update the v$session client field 
	  	  /*-*/
     	  dbms_application_info.set_client_info(Re_Timing_Common.EDIT_MODE || '_' || TO_CHAR(SYSDATE,'yyyymmddhh24miss')); 
	  
	  	  /*-*/
	  	  /* release lock  
	  	  /*-*/
	  	  var_status := dbms_lock.release(var_lock_handle);
	  
	  	  /*-*/
	  	  /*  return allowing this user to edit the application data   
	  	  /*-*/
	  	  RETURN 9;
		  
	 ELSE
	     /*-*/
	  	  /*  return allowing this user to be in READONLY  data and still connected   
	  	  /*-*/
	     RETURN 8; -- READ ONLY Access 
		  
	 END IF;
	 	
 
EXCEPTION

    WHEN OTHERS THEN
        -- Consider logging the error and then re-raise 
		  RAISE_APPLICATION_ERROR(-20000,'RE_TIMING - Pulse_Status function failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512));		
        RETURN 1;
		 
END Pulse_Status;
/


DROP PUBLIC SYNONYM PULSE_STATUS;

CREATE PUBLIC SYNONYM PULSE_STATUS FOR MANU_APP.PULSE_STATUS;


GRANT EXECUTE ON MANU_APP.PULSE_STATUS TO APPSUPPORT;

GRANT EXECUTE ON MANU_APP.PULSE_STATUS TO BTHSUPPORT;

