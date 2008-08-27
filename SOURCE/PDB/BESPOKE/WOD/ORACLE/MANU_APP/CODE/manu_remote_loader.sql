DROP PACKAGE MANU_APP.MANU_REMOTE_LOADER;

CREATE OR REPLACE PACKAGE MANU_APP.Manu_Remote_Loader AS

	/**/
   /* Note - to get this package to function correctly 
	/* you need to get the DBA's to execute the following line
	/* this will allow the jave line in the finalise_interface to function cofrrectly 
	/*  use the '-' symbol in the directory path to specify all sub directories. e.g. /home/dwtrnsfr/-

	/*  execute dbms_java.grant_permission('IU_APP','java.io.FilePermission','/dir/dir/-','read,write,execute,delete');
   
	/**/

   /**/
   /* Public declarations
   /**/
   PROCEDURE create_interface(par_fil_path IN VARCHAR2, par_fil_name IN VARCHAR2);
   PROCEDURE append_data(par_record IN VARCHAR2);
   PROCEDURE finalise_interface(par_prc_script IN VARCHAR2);
   FUNCTION is_created RETURN BOOLEAN;

END Manu_Remote_Loader;
/


DROP PACKAGE BODY MANU_APP.MANU_REMOTE_LOADER;

CREATE OR REPLACE PACKAGE BODY MANU_APP.Manu_Remote_Loader AS

   /**/
   /* Note - to get this package to function correctly 
	/* you need to get the DBA's to execute the following line
	/* this will allow the jave line in the finalise_interface to function cofrrectly 
	/*  use the '-' symbol in the directory path to specify all sub directories. e.g. /home/dwtrnsfr/-

	/*  execute dbms_java.grant_permission('IU_APP','java.io.FilePermission','/dir/dir/-','read,write,execute,delete');
   
	/**/
	
	
   /*-*/
   /* Private exceptions
   /*-*/
   application_exception EXCEPTION;
   PRAGMA EXCEPTION_INIT(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   var_opened BOOLEAN;
   var_fil_handle UTL_FILE.FILE_TYPE;

   /********************************************************/
   /* This procedure performs the create interface routine */
   /********************************************************/
   PROCEDURE create_interface(par_fil_path IN VARCHAR2, par_fil_name IN VARCHAR2) IS

      /*-*/
      /* Autonomous transaction
      /*-*/
      PRAGMA autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_fil_path VARCHAR2(128);
      var_fil_name VARCHAR2(64);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Validate the parameters
      /*-*/
      IF par_fil_path IS NULL THEN
         RAISE_APPLICATION_ERROR(-20000, 'Create Interface - File path parameter must not be null');
      END IF;
      IF par_fil_name IS NULL THEN
         RAISE_APPLICATION_ERROR(-20000, 'Create Interface - File name parameter must not be null');
      END IF;

      /**/
      /* Set the remote path information
      /**/
      var_fil_path := par_fil_path;
      var_fil_name := par_fil_name;

      /*-*/
      /* Existing interface must not exist
      /*-*/
      IF var_opened = TRUE THEN
         RAISE_APPLICATION_ERROR(-20000, 'Create Interface - Interface has already been created');
      END IF;

      /**/
      /* Open the remote interface file 
      /**/
      BEGIN
		
         var_fil_handle := UTL_FILE.FOPEN(var_fil_path, var_fil_name, 'w'); --, 32767);
			
      EXCEPTION
		
         WHEN UTL_FILE.access_denied THEN
            RAISE_APPLICATION_ERROR(-20000, 'Create Interface - Access denied to remote file (' || var_fil_path || '-' || var_fil_name || ') - ' || SUBSTR(SQLERRM, 1, 512));
         WHEN UTL_FILE.INVALID_PATH THEN
            RAISE_APPLICATION_ERROR(-20000, 'Create Interface - Invalid path to remote file (' || var_fil_path || '-' || var_fil_name || ') - ' || SUBSTR(SQLERRM, 1, 512));
         WHEN UTL_FILE.invalid_filename THEN
            RAISE_APPLICATION_ERROR(-20000, 'Create Interface - Invalid file name for remote file (' || var_fil_path || '-' || var_fil_name || ') - ' || SUBSTR(SQLERRM, 1, 512));
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Create Interface - Could not open remote file (' || var_fil_path || '-' || var_fil_name || ') - ' || SUBSTR(SQLERRM, 1, 512));
      END;

      /*-*/
      /* Set the control indicator
      /*-*/
      var_opened := TRUE;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   EXCEPTION

      /**/
      /* Exception trap
      /**/
      WHEN OTHERS THEN

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         RAISE_APPLICATION_ERROR(-20000, 'FATAL ERROR - Create Interface - Remote Loader - ' || CHR(13) || SUBSTR(SQLERRM, 1, 2024) || CHR(13));

   /*-------------*/
   /* End routine */
   /*-------------*/
   END create_interface;

   /***************************************************/
   /* This procedure performs the append data routine */
   /***************************************************/
   PROCEDURE append_data(par_record IN VARCHAR2) IS

      /*-*/
      /* Autonomous transaction
      /*-*/
      PRAGMA autonomous_transaction;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Existing interface must exist
      /*-*/
      IF var_opened = FALSE THEN
         RAISE_APPLICATION_ERROR(-20000, 'Append Data - Interface has not been created' || CHR(13));
      END IF;

      /*-*/
      /* Write the outbound interface file line
      /*-*/
      UTL_FILE.PUT_LINE(var_fil_handle, par_record);

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   EXCEPTION

      /**/
      /* Exception trap
      /**/
      WHEN OTHERS THEN

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         RAISE_APPLICATION_ERROR(-20000, 'FATAL ERROR - Finalise Interface - Remote Loader - ' || CHR(13) || SUBSTR(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   END append_data;

   /**********************************************************/
   /* This procedure performs the finalise interface routine */
   /**********************************************************/
   PROCEDURE finalise_interface(par_prc_script IN VARCHAR2) IS

      /*-*/
      /* Autonomous transaction
      /*-*/
      PRAGMA autonomous_transaction;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Existing interface must exist
      /*-*/
      IF var_opened = FALSE THEN
         RAISE_APPLICATION_ERROR(-20000, 'Finalise Interface - Interface has not been created');
      END IF;

      /*-*/
      /* Close the outbound interface file
      /*-*/
      BEGIN
         UTL_FILE.FCLOSE(var_fil_handle);
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Finalise Interface - Could not close remote file - ' || SUBSTR(SQLERRM, 1, 512));
      END;
		
      /**/
      /* Execute the remote processing script
      /**/
	  /*-*/
	  /* taken out on 14 Aug 2006 so that the procedure just saves the file to the server directory
	  /*-*/
	  /*
      BEGIN
		  
         java_utility.execute_external_procedure(par_prc_script);
			
      EXCEPTION
         WHEN OTHERS THEN
			    
             RAISE_APPLICATION_ERROR(-20000, 'Finalise Interface - External process error - ' || par_prc_script || ' - ' || SUBSTR(SQLERRM, 1, 3900));
      END;
	  */

      /*-*/
      /* Set the control indicator
      /*-*/
      var_opened := FALSE;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   EXCEPTION

      /**/
      /* Exception trap
      /**/
      WHEN OTHERS THEN

         /*-*/
         /* Close the file handle whn required
         /*-*/
         IF var_opened = TRUE THEN
            BEGIN
               UTL_FILE.FCLOSE(var_fil_handle);
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
            var_opened := FALSE;
         END IF;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
			
         RAISE_APPLICATION_ERROR(-20000, 'FATAL ERROR - Interface Control System - Remote Loader - ' || CHR(13) || SUBSTR(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   END finalise_interface;

   /*************************************************/
   /* This function performs the is created routine */
   /*************************************************/
   FUNCTION is_created RETURN BOOLEAN IS

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Existing interface exists
      /*-*/
      IF var_opened = FALSE THEN
         RETURN FALSE;
      END IF;
      RETURN TRUE;

   /*-------------*/
   /* End routine */
   /*-------------*/
   END is_created;

/*----------------------*/
/* Initialisation block */
/*----------------------*/
BEGIN

   /*-*/
   /* Initialise the package
   /*-*/
   var_opened := FALSE;

END Manu_Remote_Loader;
/


DROP PUBLIC SYNONYM MANU_REMOTE_LOADER;

CREATE PUBLIC SYNONYM MANU_REMOTE_LOADER FOR MANU_APP.MANU_REMOTE_LOADER;


GRANT EXECUTE ON MANU_APP.MANU_REMOTE_LOADER TO APPSUPPORT;

GRANT EXECUTE ON MANU_APP.MANU_REMOTE_LOADER TO PT_APP;

GRANT EXECUTE ON MANU_APP.MANU_REMOTE_LOADER TO SITESUPPORT WITH GRANT OPTION;

