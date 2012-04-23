set define off;
/******************************************************************************/
/* Package Header                                                             */
/******************************************************************************/
create or replace package qv_app.qvi_util as

   /***************************************************************************/
   /* Package Definition                                                      */
   /***************************************************************************/
   /**
    Package : qvi_util
    Owner   : qv_app

    Description
    -----------
    Package to hold generic utility functions

    YYYY/MM   Author         Description
    -------   ------         -----------
    2012/03   Mal Chambeyron Created

   ****************************************************************************/

--          123456789012345678901234567890 .. Maximum identifier length ..
   /*-*/
   /* Public declarations
   /*-*/
   function get_validated_string(par_column_name in varchar2, par_validation_descr in varchar2, par_validation_regexp in varchar2, par_validation_regexp_switch in varchar2, par_trim_flag in boolean, par_src_error in out boolean) return varchar2;
   function get_validated_string(par_column_name in varchar2, par_column_value in varchar2, par_validation_descr in varchar2, par_validation_regexp in varchar2, par_validation_regexp_switch in varchar2, par_trim_flag in boolean, par_src_error in out boolean) return varchar2;

   function get_validated_column(par_column_name in varchar2, par_validation_descr in varchar2, par_validation_regexp in varchar2, par_src_error in out boolean) return varchar2;
   function get_validated_value(par_column_name in varchar2, par_value in varchar2, par_validation_descr in varchar2, par_validation_regexp in varchar2, par_src_error in out boolean) return varchar2;
   
end qvi_util;
/

/******************************************************************************/
/* Package Body                                                               */
/******************************************************************************/
create or replace package body qv_app.qvi_util as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_schema_name constant varchar2(30) := 'QV_APP';
   con_package_name constant varchar2(30) := 'QVI_UTIL';

   con_delimiter constant varchar2(32)  := ',';
   con_regexp_switch constant varchar2(4) := null; -- oracle regexp_like match_parameter
   con_trim_flag constant boolean := true;

   /*-*/
   /* Private definitions
   /*-*/
   var_module_name varchar2(128) := trim(con_schema_name)||'.'||trim(con_package_name)||'.*PACKAGE'; -- Fully qualified schema.package.module used for error reporting
   var_statement_tag varchar2(128) := null;

   /***************************************************************************/
   /* Wrapper function validates column against regexp, on success return value, 
   /* otherwise add exception, set source error and return null
   /***************************************************************************/
   function get_validated_column(par_column_name in varchar2, par_validation_descr in varchar2, par_validation_regexp in varchar2, par_src_error in out boolean) return varchar2 as
      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
      /*-*/
      /* Fully qualified schema.package.module used for error reporting 
      /*-*/
      var_module_name := trim(con_schema_name)||'.'||trim(con_package_name)||'.GET_STRING_FROM_COLUMN';
      var_statement_tag := null;
   
      /*-*/
      /* Validate column value against regexp, on success return value, otherwise add_exception and return null
      /*-*/
      var_return := lics_inbound_utility.get_variable(par_column_name);
      var_return := get_validated_string(par_column_name,var_return,par_validation_descr,par_validation_regexp,con_regexp_switch,con_trim_flag,par_src_error);
      return var_return;
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, substr(
            'FATAL ERROR - ['||var_module_name||']['||var_statement_tag||'] - '
            ||'Column Name "'||par_column_name
            ||'", Column Value "'||var_return
            ||'", Validation Desc "'||par_validation_descr
            ||'", Validation Regular Expression "'||par_validation_regexp
            ||'", Validation Regular Switch "'||con_regexp_switch
            ||'", Trim Flag "'||(CASE con_trim_flag when true then 'TRUE' ELSE 'FALSE' END)
            ||'", Source Error "'||(CASE par_src_error when true then 'TRUE' ELSE 'FALSE' END)
            ||'" - '||sqlerrm, 1, 4000));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_validated_column;
   
   /***************************************************************************/
   /* Wrapper function validates value against regexp, on success return value, 
   /* otherwise add exception, set source error and return null
   /***************************************************************************/
   function get_validated_value(par_column_name in varchar2, par_value in varchar2, par_validation_descr in varchar2, par_validation_regexp in varchar2, par_src_error in out boolean) return varchar2 as
      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
      /*-*/
      /* Fully qualified schema.package.module used for error reporting 
      /*-*/
      var_module_name := trim(con_schema_name)||'.'||trim(con_package_name)||'.GET_STRING_FROM_VALUE';
      var_statement_tag := null;
   
      /*-*/
      /* Validate column value against regexp, on success return value, otherwise add_exception and return null
      /*-*/
      var_return := get_validated_string(par_column_name,par_value,par_validation_descr,par_validation_regexp,con_regexp_switch,con_trim_flag,par_src_error);
      return var_return;
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, substr(
            'FATAL ERROR - ['||var_module_name||']['||var_statement_tag||'] - '
            ||'Column Name "'||par_column_name
            ||'", Column Value "'||par_value
            ||'", Validation Desc "'||par_validation_descr
            ||'", Validation Regular Expression "'||par_validation_regexp
            ||'", Validation Regular Switch "'||con_regexp_switch
            ||'", Trim Flag "'||(CASE con_trim_flag when true then 'TRUE' ELSE 'FALSE' END)
            ||'", Source Error "'||(CASE par_src_error when true then 'TRUE' ELSE 'FALSE' END)
            ||'" - '||sqlerrm, 1, 4000));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_validated_value;
   
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
      /* Fully qualified schema.package.module used for error reporting 
      /*-*/
      var_module_name := trim(con_schema_name)||'.'||trim(con_package_name)||'.get_validated_string';
      var_statement_tag := null;
   
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
         raise_application_error(-20000, substr(
            'FATAL ERROR - ['||var_module_name||']['||var_statement_tag||'] - '
            ||'Column Name "'||par_column_name
            ||'", Column Value "'||var_return
            ||'", Validation Desc "'||par_validation_descr
            ||'", Validation Regular Expression "'||par_validation_regexp
            ||'", Validation Regular Switch "'||par_validation_regexp_switch
            ||'", Trim Flag "'||(CASE par_trim_flag when true then 'TRUE' ELSE 'FALSE' END)
            ||'", Source Error "'||(CASE par_src_error when true then 'TRUE' ELSE 'FALSE' END)
            ||'" - '||sqlerrm, 1, 4000));

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
      /* Fully qualified schema.package.module used for error reporting 
      /*-*/
      var_module_name := trim(con_schema_name)||'.'||trim(con_package_name)||'.get_validated_string';
      var_statement_tag := null;

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
         raise_application_error(-20000, substr(
            'FATAL ERROR - ['||var_module_name||']['||var_statement_tag||'] - '
            ||'Column Name "'||par_column_name
            ||'", Column Value "'||var_return
            ||'", Validation Desc "'||par_validation_descr
            ||'", Validation Regular Expression "'||par_validation_regexp
            ||'", Validation Regular Switch "'||par_validation_regexp_switch
            ||'", Trim Flag "'||(CASE par_trim_flag when true then 'TRUE' ELSE 'FALSE' END)
            ||'", Source Error "'||(CASE par_src_error when true then 'TRUE' ELSE 'FALSE' END)
            ||'" - '||sqlerrm, 1, 4000));
   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_validated_string;

end qvi_util;
/

/******************************************************************************/
/* Package Synonym/Grants                                                     */
/******************************************************************************/
create or replace public synonym qvi_util for qv_app.qvi_util;
grant execute on qvi_util to lics_app;

/******************************************************************************/
set define on;
set define ^;

