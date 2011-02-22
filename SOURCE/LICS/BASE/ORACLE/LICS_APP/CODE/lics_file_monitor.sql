/******************/
/* Package Header */
/******************/
create or replace package lics_file_monitor as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_file_monitor
    Owner   : lics_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Local Interface Control System - File Monitor

    The package implements the file monitor functionality.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2011/02   Steve Gregan   End point architecture version

   *******************************************************************************/

   /**/
   /* Public declarations
   /**/
   function retry_file(par_file in number) return varchar2;
   function delete_file(par_file in number) return varchar2;

end lics_file_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_file_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_lics_file lics_file%rowtype;

   /*************************************************/
   /* This function performs the retry file routine */
   /*************************************************/
   function retry_file(par_file in number) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_file_01 is 
         select t01.*
           from lics_file t01
          where t01.fil_file = rcd_lics_file.file_file;
      rcd_lics_file_01 csr_lics_file_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - File Monitor - Retry File';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_file.fil_file := par_file;

      /*-*/
      /* File must exist with correct status
      /*-*/
      open csr_lics_file_01;
      fetch csr_lics_file_01 into rcd_lics_file_01;
      if csr_lics_file_01%notfound then
         var_message := var_message || chr(13) || 'File (' || to_char(rcd_lics_file.fil_file,'FM999999999999990') || ') does not exist';
      end if;
      close csr_lics_file_01;
      if rcd_lics_file_01.fil_status != lics_constant.file_error then
         var_message := var_message || chr(13) || 'File status must be error to retry';
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Update the existing file
      /*-*/
      update lics_file
         set fil_status = lics_constant.file_available
         where fil_file = rcd_lics_file.fil_file
           and fil_status = lics_constant.file_error;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Wake the file background processors
      /*-*/
      lics_pipe.spray(lics_constant.type_file, null, lics_constant.pipe_wake);

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retry_file;

   /**************************************************/
   /* This function performs the delete file routine */
   /**************************************************/
   function delete_file(par_file in number) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_file_01 is 
         select t01.*
           from lics_file t01
          where t01.fil_file = rcd_lics_file.file_file;
      rcd_lics_file_01 csr_lics_file_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - File Monitor - Delete File';
      var_message := null;

      /*-*/
      /* Set the private variables
      /**/
      rcd_lics_file.fil_file := par_file;

      /*-*/
      /* File must exist with correct status
      /*-*/
      open csr_lics_file_01;
      fetch csr_lics_file_01 into rcd_lics_file_01;
      if csr_lics_file_01%notfound then
         var_message := var_message || chr(13) || 'File (' || to_char(rcd_lics_file.fil_file,'FM999999999999990') || ') does not exist';
      end if;
      close csr_lics_file_01;
      if rcd_lics_file_01.fil_status != lics_constant.file_error then
         var_message := var_message || chr(13) || 'File status must be error to delete';
      end if;

      /*-*/
      /* Delete the file system file
      /*-*/
      begin
         lics_filesystem.delete_file(rcd_lics_file.fil_path, rcd_lics_file.fil_name);
      exception
         when others then
            var_message := var_message || chr(13) || substr(SQLERRM, 1, 1536);
      end;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /*-*/
      /* Delete the existing file
      /*-*/
      delete from lics_file
         where fil_file = rcd_lics_file.fil_file
           and fil_status = lics_constant.file_error;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Return
      /*-*/
      return '*OK';

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
         raise_application_error(-20000, var_title || chr(13) || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end delete_file;

end lics_file_monitor;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_file_monitor for lics_app.lics_file_monitor;
grant execute on lics_file_monitor to public;