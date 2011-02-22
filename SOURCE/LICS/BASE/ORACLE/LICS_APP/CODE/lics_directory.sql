/******************/
/* Package Header */
/******************/
create or replace package lics_directory as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_directory
    Owner   : sys
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Local Interface Control System - Directory

    The package implements the directory functionality.

    1. This package must be compiled using the SYS schema.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2011/02   Steve Gregan   End point architecture version

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure create_directory(par_dir_name in varchar2);
   procedure delete_directory(par_dir_name in varchar2);

end lics_directory;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_directory as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /********************************************************/
   /* This procedure performs the create directory routine */
   /********************************************************/
   procedure create_directory(par_ics_name in varchar2, par_sys_name in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_ics_name varchar2(256);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create the new directory
      /*-*/
      var_dir_name := par_dir_name;
      var_dir_name := replace(var_dir_name,'.','_');
      var_dir_name := replace(var_dir_name,' ','_');
      lics_filesystem.create_directory(lics_parameter.ics_outbound_path||lics_parameter.ics_path_delimiter||par_sys_name);
      execute immediate 'create directory ics_'||var_ics_name||' as '''||lics_parameter.ics_outbound_path||lics_parameter.ics_path_delimiter||var_sys_name||'''';
      execute immediate 'grant all on directory ics_'||var_ics_name||' to lics_app';
      
   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Directory - Create Directory - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_directory;

   /********************************************************/
   /* This procedure performs the delete directory routine */
   /********************************************************/
   procedure delete_directory(par_dir_name in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_dir_name varchar2(256);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Delete the existing directory
      /*-*/
      var_dir_name := par_dir_name;
      var_dir_name := replace(var_dir_name,'.','_');
      var_dir_name := replace(var_dir_name,' ','_');
      execute immediate 'drop_directory ics_'||var_dir_name;
      lics_filesystem.delete_directory(lics_parameter.ics_outbound_path||lics_parameter.ics_path_delimiter||var_dir_name);
      
   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Directory - Delete Directory - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_directory;

end lics_directory;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_directory for lics_app.lics_directory;
grant execute on lics_directory to lics_app;