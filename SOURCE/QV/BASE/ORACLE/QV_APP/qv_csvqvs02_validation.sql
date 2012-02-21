create or replace package qv_app.qv_csvqvs02_validation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qv_csvqvs02_validation
    Owner   : qv_app
    Author  : Trevor Keon

    Description
    -----------
    CSV to QV- CSVQVS - TP Budgets Validation

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/09   Trevor Keon    Created
    2011/02   Trevor Keon    Added blank line check
    2011/11   Trevor Keon    Updated to support ICS v2

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function on_start return varchar2;
   function on_data(par_record in varchar2) return varchar2;

end qv_csvqvs02_validation;

create or replace package body qv_app.qv_csvqvs02_validation as

   /*-*/
   /* Private constants 
   /*-*/
   con_interface constant varchar2(10) := 'CSVQVS02';
   con_header_row constant number := 1;
   con_delimiter constant varchar2(32)  := ',';

   /*-*/
   /* Private definitions
   /*-*/
   var_line_count number;

   function on_start return varchar2 is
   
      /*-*/
      /* Local definitions
      /*-*/
      var_message varchar2(4000);  
   
   /*-------------*/
   /* Begin block */
   /*-------------*/   
   begin
   
      /*-*/
      /* Initialise the variables
      /*-*/   
      var_line_count := 0;
 
      /*-*/
      /* Initialise the definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_csv_definition('DATE',1);
      lics_inbound_utility.set_csv_definition('DEMAND_GROUP',2);
      lics_inbound_utility.set_csv_definition('BRAND',3);
      lics_inbound_utility.set_csv_definition('MARKET_SUB_CATEGORY',4);
      lics_inbound_utility.set_csv_definition('MARS_YEAR',5);
      lics_inbound_utility.set_csv_definition('MARS_PERIOD',6);
      lics_inbound_utility.set_csv_definition('MARS_PERIOD_WEEK',7);
      lics_inbound_utility.set_csv_definition('BUDGET',8); 
      
      return var_message;
   
   /*-------------*/
   /* End routine */
   /*-------------*/   
   end on_start;

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   function on_data(par_record in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_message varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the function
      /*-*/
      var_message := null;
      var_line_count := var_line_count + 1;
       
      /*-*/
      /* Dont need to validate the header row
      /*-*/       
      if var_line_count <= con_header_row then
         return var_message;
      end if;
      
      /*-*/
      /* Ignore blank lines
      /*-*/      
      if qv_validation_utilities.check_blank_line(par_record, con_delimiter) = true then
         return var_message;
      end if;      
      
      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_csv_record(par_record, con_delimiter);       

      /*-*/
      /* Validate the data
      /*-*/
      if qv_validation_utilities.check_date(lics_inbound_utility.get_variable('DATE'), 'DD/MM/YYYY') = false then
         if not(var_message is null) then
            var_message := var_message || '; ';
         end if;
         var_message := var_message || 'As At Date is not a valid date format - expecting DD/MM/YYYY format';         
      end if;
      if lics_inbound_utility.get_variable('DEMAND_GROUP') is null then
         if not(var_message is null) then
            var_message := var_message || '; ';
         end if;
         var_message := var_message || 'Demand group value not set';
      end if;
      if lics_inbound_utility.get_variable('BRAND') is null then
         if not(var_message is null) then
            var_message := var_message || '; ';
         end if;
         var_message := var_message || 'Brand value not set';
      end if;
      if lics_inbound_utility.get_variable('MARKET_SUB_CATEGORY') is null then
         if not(var_message is null) then
            var_message := var_message || '; ';
         end if;
         var_message := var_message || 'Market sub category not set';
      end if;
      if qv_validation_utilities.check_mars_calendar(lics_inbound_utility.get_variable('MARS_YEAR'), '*YEAR') = false then
         if not(var_message is null) then
            var_message := var_message || '; ';
         end if;
         var_message := var_message || 'Mars Year does not exist';
      end if;
      if qv_validation_utilities.check_mars_calendar(lics_inbound_utility.get_variable('MARS_PERIOD'), '*PERIOD') = false then
         if not(var_message is null) then
            var_message := var_message || '; ';
         end if;
         var_message := var_message || 'Mars Period does not exist';
      end if;
      if qv_validation_utilities.check_mars_calendar(lics_inbound_utility.get_variable('MARS_PERIOD_WEEK'), '*PERIOD_WEEK') = false then
         if not(var_message is null) then
            var_message := var_message || '; ';
         end if;
         var_message := var_message || 'Mars Period Week does not exist';
      end if;
      if qv_validation_utilities.check_number(lics_inbound_utility.get_variable('BUDGET')) = false then
         if not(var_message is null) then
            var_message := var_message || '; ';
         end if;
         var_message := var_message || 'Budget is not a valid number';
      end if;

      /*-*/
      /* Return the message
      /*-*/
      return var_message;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;
   
end qv_csvqvs02_validation;

/**/
/* Authority 
/**/
grant execute on qv_csvqvs02_validation to lics_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_csvqvs02_validation for qv_app.qv_csvqvs02_validation;