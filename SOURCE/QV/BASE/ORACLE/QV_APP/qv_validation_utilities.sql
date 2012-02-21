create or replace package qv_app.qv_validation_utilities as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qv_validation_utilities
    Owner   : qv_app
    Author  : Trevor Keon

    Description
    -----------
    Qlikview Loader - Validation Utilities
    
    MARS Calendar Types:
    --------------------
    *YEAR - Validate the Mars Year (YYYY)
    *PERIOD - Validate the Mars Period value (YYYYPP)
    *PERIOD_WEEK - Validate the Mars Period Week value (YYYYPPW)
    *PERIOD_DAY - Validate the Mars Period Day (YYYYPPDD)
    *PERIOD_WEEK_DAY - Validate the Mars Period Week Day (YYYYPPWDD)

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/09   Trevor Keon    Created
    2011/02   Trevor Keon    Added blank line check
    2011/11   Trevor Keon    Updated to support ICS v2

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function check_date(par_date in varchar2, par_format in varchar2) return boolean;
   function check_number(par_number in varchar2) return boolean;
   function check_length(par_value in varchar2, par_length in number) return boolean;
   function check_mars_calendar(par_value in varchar2, par_type in varchar2) return boolean;
   function check_blank_line(par_value in varchar2, par_delimiter in varchar2) return boolean;
   
end qv_validation_utilities;

create or replace package body qv_app.qv_validation_utilities as

   function check_date(par_date in varchar2, par_format in varchar2) return boolean is

      /*-*/
      /* Local definitions
      /*-*/
      var_result boolean := true;
      var_date date;
   
   begin
      
      if not(par_date is null) or
        not(par_format is null) then      
         begin
            var_date := to_date(par_date, par_format);
            var_result := not(var_date is null);
         exception
            when others then
               var_result := false;
         end;      
      else
         var_result := false;
      end if;
      
      return var_result;
   
   /*-------------*/
   /* End routine */
   /*-------------*/   
   end check_date;
   
   function check_number(par_number in varchar2) return boolean is

      /*-*/
      /* Local definitions
      /*-*/
      var_result boolean := true;
      var_number number;
   
   begin
   
      if not(par_number is null) then      
         begin
            var_number := to_number(par_number);
            var_result := not(var_number is null);
         exception
            when others then
               var_result := false;
         end;      
      else
         var_result := false;
      end if;
      
      return var_result;   
   
   /*-------------*/
   /* End routine */
   /*-------------*/   
   end check_number;
   
   function check_length(par_value in varchar2, par_length in number) return boolean is
   
      /*-*/
      /* Local definitions
      /*-*/
      var_result boolean := true;
   
   begin
   
      if not(par_value is null) or
        not(par_length is null) then      
         var_result := (length(par_value) = par_length);
      else
         var_result := false;
      end if;
      
      return var_result;
      
   /*-------------*/
   /* End routine */
   /*-------------*/   
   end check_length;
   
   function check_mars_calendar(par_value in varchar2, par_type in varchar2) return boolean is
   
      /*-*/
      /* Local types
      /*-*/   
      type csr_mars is ref cursor;
      type rcd_mars is record (mars_val number);   
   
      /*-*/
      /* Local definitions
      /*-*/
      var_result boolean := true;      
      
      /*-*/
      /* Dynamic cursor
      /*-*/      
      csr_check csr_mars;
      rcd_values rcd_mars;
   
   begin
   
      if par_type = '*YEAR' then
         open csr_check for
            select distinct mars_year
            from mars_date
            where mars_year = par_value;   
      elsif par_type = '*PERIOD' then
         open csr_check for
            select distinct mars_period
            from mars_date
            where mars_period = par_value;   
      elsif par_type = '*PERIOD_WEEK' then
         open csr_check for
            select distinct mars_week
            from mars_date
            where mars_week = par_value;  
      elsif par_type = '*PERIOD_DAY' then
         open csr_check for
            select distinct mars_yyyyppdd
            from mars_date
            where mars_yyyyppdd = par_value; 
      elsif par_type = '*PERIOD_WEEK_DAY' then
         open csr_check for
            select distinct to_number(mars_week || substr(mars_yyyyppdd,7,2)) as mars_yyyyppwdd
            from mars_date
            where mars_week || substr(mars_yyyyppdd,7,2) = par_value;   
      else
         var_result := false;
      end if;
      
      if var_result = true then
      
         fetch csr_check into rcd_values;
         var_result := csr_check%found;
         
         close csr_check;
      
      end if;
      
      return var_result;
   
   /*-------------*/
   /* End routine */
   /*-------------*/      
   end check_mars_calendar;
      
   function check_blank_line(par_value in varchar2, par_delimiter in varchar2) return boolean is
   
      /*-*/
      /* Local definitions
      /*-*/
      var_result boolean := false;
   
   begin
      
      if not(par_value is null) or
        not(par_delimiter is null) then
         var_result := (trim(replace(par_value, par_delimiter, ' ')) is null);
      else
         var_result := true;
      end if;
      
      return var_result;
      
   /*-------------*/
   /* End routine */
   /*-------------*/   
   end check_blank_line;       

end qv_validation_utilities;

/**/
/* Synonym 
/**/
create or replace public synonym qv_validation_utilities for qv_app.qv_validation_utilities;