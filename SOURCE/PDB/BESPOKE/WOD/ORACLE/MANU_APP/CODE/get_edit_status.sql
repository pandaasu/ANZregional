DROP FUNCTION MANU_APP.GET_EDIT_STATUS;

CREATE OR REPLACE FUNCTION MANU_APP.Get_Edit_Status RETURN BOOLEAN IS

/******************************************************************************
   NAME:       Get_Edit Status 
   PURPOSE:    Used by Re_Timing Tool 
	            Determine if a session is open with a User who can update records
	   			ie PR_ADMIN 
					If already open with PR_ADMIN user then return false 
					If not Open set this user in the clien area as the session updater 
					and return true 

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        24-Nov-05          1. Created this function.

   NOTES:	  This function is used to allow only the first user with Update rights to 
				  Edit the screen data 
				  All other users accessing with update rights can only have EDIT only access 
				  
				  The query filters out any session with this user id that has a time stamp 
				  greater than 2 minutes.
				  
				  Any timestamp greater than 2 minutes signifies a broken connection 

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
	 var_status NUMBER;
	 var_work VARCHAR2(20) DEFAULT '';
	 
	 /*-*/
    /* Cursors 
    /*-*/
	 CURSOR cur_session IS
	 SELECT 'x' 
		FROM v$session t01 
	  WHERE t01.client_info LIKE Re_Timing_Common.EDIT_MODE || '%'
	    AND TO_DATE(SUBSTR(client_info, LENGTH('PR_EDIT') + 2,LENGTH(client_info)),'yyyymmddhh24miss') + 2/1440 > SYSDATE;
	  
BEGIN
	 
     /*-*/ 
 	  /* get the sesssion information 
 	  /*-*/ 
	  OPEN cur_session;
	  
     FETCH cur_session INTO var_work;
        
     CLOSE cur_session;
	  
	  IF var_work IS NULL  THEN
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
	  	  RETURN TRUE;
		  
	 ELSE
	     /*-*/
	  	  /*  return allowing this user to be in READONLY  data   
	  	  /*-*/
	     RETURN FALSE;
		  
	 END IF;
	 	
 
EXCEPTION

    WHEN OTHERS THEN
        -- Consider logging the error and then re-raise 
		  RAISE_APPLICATION_ERROR(-20000,'RE_TIMING - Get_Edit_Status function failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512));		
        RETURN FALSE;
		 
END Get_Edit_Status;
/


DROP PUBLIC SYNONYM GET_EDIT_STATUS;

CREATE PUBLIC SYNONYM GET_EDIT_STATUS FOR MANU_APP.GET_EDIT_STATUS;


GRANT EXECUTE ON MANU_APP.GET_EDIT_STATUS TO APPSUPPORT;

