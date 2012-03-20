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
      var_return := get_validated_string(par_column_name, lics_inbound_utility.get_variable(par_column_name), par_validation_descr, par_validation_regexp, par_validation_regexp, par_trim_flag, par_src_error);
      return var_return;

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
         
      if par_trim_flag = true then
      	var_return := trim(var_return);
      	var_return := regexp_replace(var_return,'[[:space:]]*$',''); -- remove extraneous trailing whitespace (cr/lf/tab/etc..) 
      end if;
      
      if not regexp_like(var_return, par_validation_regexp, par_validation_regexp_switch) then
         lics_inbound_utility.add_exception('Field "'||par_column_name||'" value "'||var_return||'" must be - '||par_validation_descr);
         var_return := null;
         par_src_error := true;
      end if;

      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_validated_string;

end qvi_util;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
grant execute on qvi_util to lics_app;
