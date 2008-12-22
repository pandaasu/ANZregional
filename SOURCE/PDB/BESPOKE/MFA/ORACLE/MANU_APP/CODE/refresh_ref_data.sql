DROP PROCEDURE MANU_APP.REFRESH_REF_DATA;

CREATE OR REPLACE PROCEDURE MANU_APP.Refresh_Ref_Data IS

/******************************************************************************
   NAME:       REFRESH_REF_DATA
   PURPOSE:    This procedure is used as a wrapper around 
   			   Refresh_Ref_Grp procedure which will run the refresh group for
			   all the reference data feeding down from LADS to each plant 
			   database.
			   This will only refresh the data for the particular plant.
			   
			   The DBAs need to be aware each time this refresh is run so
			   an email message is sent to the DBA notes group upon completion 
			   of the procedure.
			   
   			   

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        21-Sep-06   Jeff Phillipson Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     REFRESH_REF_DATA
      Sysdate:         21-Sep-06
      Date and Time:   21-Sep-06, 8:11:08 AM, and 21-Sep-06 8:11:08 AM
      

******************************************************************************/
   /*-*/
   /* Private exceptions
   /*-*/
   application_exception EXCEPTION;
   PRAGMA EXCEPTION_INIT(application_exception, -20000);
   
	 
    /*-*/
	/* variables
	/*-*/
	var_name	               VARCHAR2(20);  -- mail from - database name
	var_oracle_login		   VARCHAR2(20);  -- oracle login running procedure
	var_start   			   VARCHAR2(20);  -- start date
	var_username 	   		   VARCHAR2(10);  -- SDS username
	var_table				   VARCHAR2(200); -- snapshot table names
	var_count				   NUMBER;
	var_text				   VARCHAR2(4000);
	
	/*-*/
	/* mail to address
	/*-*/
	var_mail_addr CONSTANT VARCHAR2(200) := '"isa.applications.dw.team.dbas"@esosn1';
	
	
BEGIN
   
    var_start := TO_CHAR(SYSDATE,'dd-mon-yyyy hh24:mi:ss');
   
    /*-*/
    /* get the database, oracle login and username name
    /*-*/
    SELECT SUBSTR(GLOBAL_NAME,0,6) INTO var_name FROM GLOBAL_NAME;
    SELECT username INTO var_oracle_login FROM USER_USERS;
    SELECT sys_context('USERENV', 'OS_USER') INTO var_username FROM dual;
   
    /*-*/
    /* call the site refresh group to update materialised views
    /*-*/
    manu.Refresh_Ref_Grp;
   
    /*-*/
    /* check that records exist for all snapshots
    /*-*/
    var_text := GET_MATERIALISED_VIEW_INFO;
    
	/*-*/
	/* check for any errors
	/*-*/
	IF LENGTH(var_text) > 0 THEN
		var_text := '# ERROR #' ||  CHR(10) || 'Materialised VIEW with zero records:' || CHR(10) || SUBSTR(var_text,0,LENGTH(var_text)-1) || CHR(10);
		DBMS_OUTPUT.PUT_LINE(var_text);
	END IF;
	
    /*-*/
    /* send an email to the DBAs to make them aware that the refresh has been run
    /*-*/
    Mailout('The MANU reference data Refresh Group has been MANUALY run' 
   				|| CHR(13) || 'Using the procedure - manu.Refresh_Ref_Grp'
				|| CHR(13) || 'Refresh started at: ' || var_start || ' completed at: ' || TO_CHAR(SYSDATE,'dd-mon-yyyy hh24:mi:ss')
				|| CHR(13) || 'On database: ' || var_name || ' as ' || var_oracle_login
				|| CHR(13) || 'SDS Username: ' || var_username
				|| CHR(13) 
				|| CHR(13) || var_text,
				var_mail_addr,
				var_name,
				'MANU REFRESH GROUP has been run');
   
   EXCEPTION
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE application_exception;
	   /*-*/
   	   /* send an email to the DBAs to make them aware that the refresh has been run
   	   /*-*/
   	   Mailout('The MANU reference data Refresh Group has been MANUALY run' 
   				|| CHR(13) || 'Using the procedure - manu.Refresh_Ref_Grp'
				|| CHR(13) || 'Refresh started at: ' || var_start || ' completed at: ' || TO_CHAR(SYSDATE,'dd-mon-yyyy hh24:mi:ss')
				|| CHR(13) || 'On database: ' || var_name || ' as ' || var_oracle_login
				|| CHR(13) || 'SDS Username: ' || var_username
				|| CHR(13) || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512),
				var_mail_addr,
				var_name,
				'Error occurred in MANU REFRESH GROUP when run manually');
				
END Refresh_Ref_Data;
/


DROP PUBLIC SYNONYM REFRESH_REF_DATA;

CREATE PUBLIC SYNONYM REFRESH_REF_DATA FOR MANU_APP.REFRESH_REF_DATA;


GRANT EXECUTE ON MANU_APP.REFRESH_REF_DATA TO APPSUPPORT;

