/******************/
/* Package Header */
/******************/
create or replace package sys.lics_directory as

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
   procedure create_directory(par_ics_name in varchar2, par_sys_name in varchar2);
   procedure delete_directory(par_ics_name in varchar2);

end lics_directory;
/

/****************/
/* Package Body */
/****************/
create or replace package body sys.lics_directory as

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
      var_sys_name varchar2(128);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create the new directory
      /*-*/
      var_sys_name := '/ics/'||par_sys_name;
      lics_filesystem.create_directory(par_sys_name);
      execute immediate 'create directory '||par_ics_name||' as '''||var_sys_name||'''';
      execute immediate 'grant all on directory '||par_ics_name||' to lics_app';
      
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
   procedure delete_directory(par_ics_name in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_all_directories is 
         select t01.directory_path
           from all_directories t01
          where t01.directory_name = upper(par_ics_name);
      rcd_all_directories csr_all_directories%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Delete the existing directory
      /*-*/
      execute immediate 'drop_directory '||par_ics_name;
      
      /*-*/
      /* Retrieve and delete the related operating system directory name from the oracle directory
      /*-*/
      open csr_all_directories;
      fetch csr_all_directories into rcd_all_directories;
      if csr_all_directories%found then
         lics_filesystem.delete_directory(rcd_all_directories.directory_path);
      end if;
      close csr_all_directories;
      
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
create or replace public synonym lics_directory for sys.lics_directory;
grant execute on lics_directory to lics_app;