/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_file_search
 Owner   : lics_app
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Interface Control System - File Serach

 The package implements the file search functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/09   Steve Gregan   Created
 2006/08   Steve Gregan   Added search time range

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lics_file_search as

   /**/
   /* Public declarations
   /**/
   function execute(par_file in varchar2,
                    par_search in varchar2,
                    par_str_time in varchar2,
                    par_end_time in varchar2) return varchar2;

end lics_file_search;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_file_search as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /**********************************************/
   /* This function performs the execute routine */
   /**********************************************/
   function execute(par_file in varchar2,
                    par_search in varchar2,
                    par_str_time in varchar2,
                    par_end_time in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_title varchar2(128);
      var_message varchar2(4000);
      var_return varchar2(4000);
      var_file varchar2(64);
      var_search varchar2(128);
      var_str_time varchar2(128);
      var_end_time varchar2(128);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_title := 'Interface Control System - File Search';
      var_message := null;

      /*-*/
      /* Initialise the parameters
      /*-*/
      var_file := par_file;
      var_search := par_search;
      var_str_time := trim(par_str_time);
      var_end_time := trim(par_end_time);

      /*-*/
      /* Validate the parameters
      /*-*/
      if var_file is null then
         var_message := var_message || chr(13) || 'File name must be specified';
      end if;
      if var_search is null then
         var_message := var_message || chr(13) || 'Search string must be specified';
      end if;
      if var_str_time is null then
         var_message := var_message || chr(13) || 'Search time range start must be specified';
      end if;
      if var_end_time is null then
         var_message := var_message || chr(13) || 'Search time range end must be specified';
      end if;
      if not(var_str_time is null) and not(var_end_time is null) then
         if var_str_time >= var_end_time then
            var_message := var_message || chr(13) || 'Search time range start must be less than end';
         end if;
      end if;
      if instr(var_file,' ') != 0 then
         var_message := var_message || chr(13) || 'File name must not contain blanks';
      end if;
      if instr(var_file,'"') != 0 then
         var_message := var_message || chr(13) || 'File name must not contain double quote';
      end if;
      if instr(var_file,'''') != 0 then
         var_message := var_message || chr(13) || 'File name must not contain single quote';
      end if;
      if instr(var_file,'.') != 0 then
         var_file := substr(var_file,1,instr(var_file,'.')-1);
         if var_file is null then
            var_message := var_message || chr(13) || 'Trimmed file name is null';
         end if;
      end if;
      if instr(var_search,'"') != 0 then
         var_message := var_message || chr(13) || 'Search string must not contain double quote';
      end if;
      if instr(var_search,'''') != 0 then
         var_message := var_message || chr(13) || 'Search string must not contain single quote';
      end if;

      /*-*/
      /* Return the message when required
      /*-*/
      if not(var_message is null) then
         return var_title || var_message;
      end if;

      /**/
      /* Execute the file search script
      /**/
      var_return := java_utility.execute_external_function(lics_parameter.script_directory
                                                           || 'ics_search.sh'
                                                           || ' ' || var_file
                                                           || ' "' || var_search || '"'
                                                           || ' ' || var_str_time
                                                           || ' ' || var_end_time);
      if instr(var_return,'<DATA>') != 0 then
         var_return := substr(var_return,instr(var_return,'<DATA>')+6,length(var_return));
      end if;
      if instr(var_return,'</DATA>') != 0 then
         var_return := substr(var_return,1,instr(var_return,'</DATA>')-1);
      end if;

      /*-*/
      /* Return
      /*-*/
      return var_return;

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
   end execute;

end lics_file_search;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_file_search for lics_app.lics_file_search;
grant execute on lics_file_search to public;