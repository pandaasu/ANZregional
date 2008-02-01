/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_remote_loader
 Owner   : lics_app
 Author  : Steve Gregan - March 2005

 DESCRIPTION
 -----------
 Local Interface Control System - Remote Loader

 The package implements the remote loader functionality.

 1. The host application must supply the path and file name when creating the interface.
    **note** the path can be either an operating system path specified in the ORA.INIT file
             or an Oracle directory created in version 9i or later.

 2. The host application must supply the operating system file processing script when
    finalising the interface.
    **note** the processing script must be fully path qualified and LICS_APP must have
             access to that path. Oracle must have access to both the path and script.

 3. The host application is responsible for deciding the type of exception
    processing. The implementation can choose to abort the interface on the
    first exception (invoke the finalise interface method) or load all exceptions
    before aborting the interface.

 4. This package has been designed as a single instance class to facilitate
    reengineering in an object oriented language. That is, in an OO environment
    the host would create one or more instances of this class. However, in
    the PL/SQL environment only one instance is available at any one time.

 5. All methods have been implemented as autonomous transactions so as not
    to interfere with the commit boundaries of the host application.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/03   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lics_remote_loader as

   /**/
   /* Public declarations
   /**/
   procedure create_interface(par_fil_path in varchar2, par_fil_name in varchar2);
   procedure append_data(par_record in varchar2);
   procedure finalise_interface(par_prc_script in varchar2);
   function is_created return boolean;

end lics_remote_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_remote_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   var_opened boolean;
   var_fil_handle utl_file.file_type;

   /********************************************************/
   /* This procedure performs the create interface routine */
   /********************************************************/
   procedure create_interface(par_fil_path in varchar2, par_fil_name in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_fil_path varchar2(128);
      var_fil_name varchar2(64);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameters
      /*-*/
      if par_fil_path is null then
         raise_application_error(-20000, 'Create Interface - File path parameter must not be null');
      end if;
      if par_fil_name is null then
         raise_application_error(-20000, 'Create Interface - File name parameter must not be null');
      end if;

      /**/
      /* Set the remote path information
      /**/
      var_fil_path := par_fil_path;
      var_fil_name := par_fil_name;

      /*-*/
      /* Existing interface must not exist
      /*-*/
      if var_opened = true then
         raise_application_error(-20000, 'Create Interface - Interface has already been created');
      end if;

      /**/
      /* Open the remote interface file 
      /**/
      begin
         var_fil_handle := utl_file.fopen(var_fil_path, var_fil_name, 'w', 32767);
      exception
         when utl_file.access_denied then
            raise_application_error(-20000, 'Create Interface - Access denied to remote file (' || var_fil_path || '-' || var_fil_name || ') - ' || substr(SQLERRM, 1, 512));
         when utl_file.invalid_path then
            raise_application_error(-20000, 'Create Interface - Invalid path to remote file (' || var_fil_path || '-' || var_fil_name || ') - ' || substr(SQLERRM, 1, 512));
         when utl_file.invalid_filename then
            raise_application_error(-20000, 'Create Interface - Invalid file name for remote file (' || var_fil_path || '-' || var_fil_name || ') - ' || substr(SQLERRM, 1, 512));
         when others then
            raise_application_error(-20000, 'Create Interface - Could not open remote file (' || var_fil_path || '-' || var_fil_name || ') - ' || substr(SQLERRM, 1, 512));
      end;

      /*-*/
      /* Set the control indicator
      /*-*/
      var_opened := true;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Remote Loader - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_interface;

   /***************************************************/
   /* This procedure performs the append data routine */
   /***************************************************/
   procedure append_data(par_record in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Existing interface must exist
      /*-*/
      if var_opened = false then
         raise_application_error(-20000, 'Append Data - Interface has not been created');
      end if;

      /*-*/
      /* Write the outbound interface file line
      /*-*/
      utl_file.put_line(var_fil_handle, par_record);

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Remote Loader - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end append_data;

   /**********************************************************/
   /* This procedure performs the finalise interface routine */
   /**********************************************************/
   procedure finalise_interface(par_prc_script in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Existing interface must exist
      /*-*/
      if var_opened = false then
         raise_application_error(-20000, 'Finalise Interface - Interface has not been created');
      end if;

      /*-*/
      /* Close the outbound interface file
      /*-*/
      begin
         utl_file.fclose(var_fil_handle);
      exception
         when others then
            raise_application_error(-20000, 'Finalise Interface - Could not close remote file - ' || substr(SQLERRM, 1, 512));
      end;

      /**/
      /* Execute the remote processing script
      /**/
      begin
         java_utility.execute_external_procedure(par_prc_script);
      exception
         when others then
            raise_application_error(-20000, 'Finalise Interface - External process error - ' || substr(SQLERRM, 1, 3900));
      end;

      /*-*/
      /* Set the control indicator
      /*-*/
      var_opened := false;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Close the file handle whn required
         /*-*/
         if var_opened = true then
            begin
               utl_file.fclose(var_fil_handle);
            exception
               when others then
                  null;
            end;
            var_opened := false;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Remote Loader - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end finalise_interface;

   /*************************************************/
   /* This function performs the is created routine */
   /*************************************************/
   function is_created return boolean is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Existing interface exists
      /*-*/
      if var_opened = false then
         return false;
      end if;
      return true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end is_created;

/*----------------------*/
/* Initialisation block */
/*----------------------*/
begin

   /*-*/
   /* Initialise the package
   /*-*/
   var_opened := false;

end lics_remote_loader;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_remote_loader for lics_app.lics_remote_loader;
grant execute on lics_remote_loader to public;