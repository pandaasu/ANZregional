/******************/
/* Package Header */
/******************/
create or replace package qv_app.qvi_util as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qvi_util
    Owner   : qv_app

    Description
    -----------
    Package to hold generic utility functions

    YYYY/MM   Author         Description
    -------   ------         -----------
    2012/03   Mal Chambeyron Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function get_validated_string(par_column_name in varchar2, par_validation_descr in varchar2, par_validation_regexp in varchar2, par_validation_regexp_switch in varchar2, par_trim_flag in boolean, par_src_error in out boolean) return varchar2;
   function get_validated_string(par_column_name in varchar2, par_column_value in varchar2, par_validation_descr in varchar2, par_validation_regexp in varchar2, par_validation_regexp_switch in varchar2, par_trim_flag in boolean, par_src_error in out boolean) return varchar2;
   function get_csv_at_position(par_csv_string in varchar2, par_csv_position number) return varchar2;
   
end qvi_util;
/

/****************/
/* Package Body */
/****************/
create or replace package body qv_app.qvi_util as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*******************************************************************************************************************/
   /* This procedure validates value against regexp, on success return value, otherwise add_exception and return null */
   /*******************************************************************************************************************/
   function get_validated_string(par_column_name in varchar2, par_validation_descr in varchar2, par_validation_regexp in varchar2, par_validation_regexp_switch in varchar2, par_trim_flag in boolean, par_src_error in out boolean) return varchar2 as
      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
      /*-*/
      /* Validate column value against regexp, on success return value, otherwise add_exception and return null
      /*-*/
      var_return := lics_inbound_utility.get_variable(par_column_name);
      var_return := get_validated_string(par_column_name,var_return,par_validation_descr,par_validation_regexp,par_validation_regexp_switch,par_trim_flag,par_src_error);
      return var_return;
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - [QV_UTIL.GET_VALIDATED_STRING-1] - '
            ||'Column Name "'||par_column_name
            ||'", Column Value "'||var_return
            ||'", Validation Desc "'||par_validation_descr
            ||'", Validation Regular Expression "'||par_validation_regexp
            ||'", Validation Regular Switch "'||par_validation_regexp_switch
            ||'", Trim Flag "'||(CASE par_trim_flag when true then 'TRUE' ELSE 'FALSE' END)
            ||'", Source Error "'||(CASE par_src_error when true then 'TRUE' ELSE 'FALSE' END)
            ||'" - '||substr(sqlerrm, 1, 1536));
   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_validated_string;
   
   /*******************************************************************************************************************/
   /* This procedure validates value against regexp, on success return value, otherwise add_exception and return null */
   /*******************************************************************************************************************/
   function get_validated_string(par_column_name in varchar2, par_column_value in varchar2, par_validation_descr in varchar2, par_validation_regexp in varchar2, par_validation_regexp_switch in varchar2, par_trim_flag in boolean, par_src_error in out boolean) return varchar2 as
      /* 
      /* par_validation_regexp_switch is a text literal that lets you change the default matching 
      /* behavior of the function. You can specify one or more of the following values 
      /* for match_parameter:
      /* 
      /* 'i' specifies case-insensitive matching.
      /* 'c' specifies case-sensitive matching.
      /* 'n' allows the period (.), which is the match-any-character wildcard character, 
      /*     to match the newline character. If you omit this parameter, the period 
      /*     does not match the newline character.
      /* 'm' treats the source string as multiple lines. Oracle interprets [caret symbol] and [dollar symbol] 
      /*     as the start and end, respectively, of any line anywhere in the source 
      /*     string, rather than only at the start or end of the entire source string. 
      /*     If you omit this parameter, Oracle treats the source string as a single line.      
      */

      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
      /*-*/
      /* Validate column value against regexp, on success return value, otherwise add_exception and return null
      /*-*/
      var_return := par_column_value;
         
      if var_return is not null and par_trim_flag = true then
      	var_return := regexp_replace(var_return,'[[:space:]]*$',null); -- remove extraneous trailing whitespace (cr/lf/tab/etc..) 
      	var_return := trim(var_return);
      end if;
      
      if not regexp_like(var_return, par_validation_regexp, par_validation_regexp_switch) then
         lics_inbound_utility.add_exception('Field "'||par_column_name||'" value "'||var_return||'" must be - '||par_validation_descr);
         var_return := null;
         par_src_error := true;
      end if;

      return var_return;

   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - [QV_UTIL.GET_VALIDATED_STRING-2] - '
            ||'Column Name "'||par_column_name
            ||'", Column Value "'||var_return
            ||'", Validation Desc "'||par_validation_descr
            ||'", Validation Regular Expression "'||par_validation_regexp
            ||'", Validation Regular Switch "'||par_validation_regexp_switch
            ||'", Trim Flag "'||(CASE par_trim_flag when true then 'TRUE' ELSE 'FALSE' END)
            ||'", Source Error "'||(CASE par_src_error when true then 'TRUE' ELSE 'FALSE' END)
            ||'" - '||substr(sqlerrm, 1, 1536));
   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_validated_string;

   function get_csv_at_position(par_csv_string in varchar2, par_csv_position number) return varchar2 as
      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
      /*-*/
      /* Get CSV position .. parsing CSV string with embedded commas, double quotes and line breaks
      /*
      /* *** Regular Expression taken from Kim Anthony Gentes 
      /*     "Regex Pattern for Parsing CSV files with Embedded commas, double quotes and line breaks" .. 
      /*-*/
      var_return := regexp_substr(par_csv_string, '("(?:[^"]|"")*"|[^,]*),("(?:[^"]|"")*"|[^,]*)', 1, par_csv_position);
      
      /*-*/
      /* Trim leading [comma quote] and [comma] combinations
      /*-*/
      if substr(var_return,1,2) = ',"' then
         var_return := substr(var_return,3);
      elsif substr(var_return,1,1) = ',' then
         var_return := substr(var_return,2);
      end if;

      /*-*/
      /* Trim trailing [quote]
      /*-*/
      if substr(var_return,length(var_return),1) = '"' then
         var_return := substr(var_return,1,length(var_return)-1);
      end if;
      
      return var_return;
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - [QV_UTIL.GET_CSV_AT_POSITION] - '
            ||'"CSV String "'||par_csv_string
            ||'", CSV Position "'||par_csv_position
            ||'" - '||substr(sqlerrm, 1, 1536));
   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_csv_at_position;
   
end qvi_util;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
grant execute on qvi_util to lics_app;
