DROP FUNCTION MANU_APP.GET_EDIT_USER;

CREATE OR REPLACE FUNCTION MANU_APP.Get_Edit_User RETURN VARCHAR2 IS

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

******************************************************************************/
    
	 /*-*/
    /* Private exceptions
    /*-*/
    application_exception EXCEPTION;
    PRAGMA EXCEPTION_INIT(application_exception, -20000);
	
    /*-*/
    /* Private variables 
    /*-*/
	 var_work VARCHAR2(20) DEFAULT '-1';
	 
	 /*-*/
    /* Cursors 
    /*-*/	  
	 CURSOR cur_user IS
	 SELECT username 
		FROM v$session t01 
	  WHERE t01.client_info LIKE Re_Timing_Common.EDIT_MODE || '%'
	    AND TO_DATE(SUBSTR(client_info, LENGTH(Re_Timing_Common.EDIT_MODE) + 2,LENGTH(client_info)),'yyyymmddhh24miss') + 2/1440 > SYSDATE
	  ORDER BY client_info DESC;
	  
	  
BEGIN
	 
     /*-*/ 
 	  /* get the sesssion information 
 	  /*-*/ 
     OPEN cur_user;

     FETCH cur_user INTO var_work;
          
     CLOSE cur_user;		
	  
	  RETURN UPPER(var_work);

EXCEPTION

     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RETURN '';
		 
END Get_Edit_User;
/


DROP PUBLIC SYNONYM GET_EDIT_USER;

CREATE PUBLIC SYNONYM GET_EDIT_USER FOR MANU_APP.GET_EDIT_USER;


GRANT EXECUTE ON MANU_APP.GET_EDIT_USER TO APPSUPPORT;

