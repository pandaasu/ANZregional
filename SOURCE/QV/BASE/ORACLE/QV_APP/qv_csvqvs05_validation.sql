create or replace package bi_app.qv_csvqvs05_validation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qv_csvqvs05_validation
    Owner   : bi_app
    Author  : Trevor Keon

    Description
    -----------
    CSV to QV- CSVQVS - Qlikview Sales Tonnes OP validation

    YYYY/MM   Author         Description
    -------   ------         -----------
    2011/02   Trevor Keon    Created 
    2011/02   Trevor Keon    Added blank line check 
    2011/11   Trevor Keon    Updated to support ICS v2 

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function on_start return varchar2;
   function on_data(par_record in varchar2) return varchar2;

end qv_csvqvs05_validation;

create or replace package body bi_app.qv_csvqvs05_validation as

   /*-*/
   /* Private constants 
   /*-*/
   con_interface constant varchar2(10) := 'CSVQVS05';
   con_header_row constant number := 1;
   con_mars_periods constant number := 13;
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
      lics_inbound_utility.set_csv_definition('ACCNT_ASSIGNMNT_CODE',1);
      lics_inbound_utility.set_csv_definition('ACCNT_ASSIGNMNT_DESC',2);
      lics_inbound_utility.set_csv_definition('PLNG_SRC_CODE',3);
      lics_inbound_utility.set_csv_definition('PLNG_SRC_DESC',4);
      lics_inbound_utility.set_csv_definition('PERIOD_1',5);
      lics_inbound_utility.set_csv_definition('PERIOD_2',6);
      lics_inbound_utility.set_csv_definition('PERIOD_3',7);
      lics_inbound_utility.set_csv_definition('PERIOD_4',8);
      lics_inbound_utility.set_csv_definition('PERIOD_5',9);
      lics_inbound_utility.set_csv_definition('PERIOD_6',10);
      lics_inbound_utility.set_csv_definition('PERIOD_7',11);
      lics_inbound_utility.set_csv_definition('PERIOD_8',12);
      lics_inbound_utility.set_csv_definition('PERIOD_9',13);
      lics_inbound_utility.set_csv_definition('PERIOD_10',14);
      lics_inbound_utility.set_csv_definition('PERIOD_11',15);
      lics_inbound_utility.set_csv_definition('PERIOD_12',16);
      lics_inbound_utility.set_csv_definition('PERIOD_13',17);
      
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
      var_period_text varchar2(25);
      
      var_period shp_sls_tons_op.sst_period%type;
      var_forecast shp_sls_tons_op.sst_forecast%type;

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
      /* Ignore blank lines
      /*-*/      
      if qv_app.qv_validation_utilities.check_blank_line(par_record, con_delimiter) = true then
         return var_message;
      end if;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_csv_record(par_record, con_delimiter);
       
      /*-*/
      /* Validate Period headings are correct on the header as it will be used
      /* in the final table
      /*-*/       
      if var_line_count <= con_header_row then      
         for i in 1..con_mars_periods loop
            
            var_period_text := 'PERIOD_' || to_char(i);
            var_period := lics_inbound_utility.get_variable(var_period_text);
            
            if qv_app.qv_validation_utilities.check_mars_calendar(var_period, '*PERIOD') = false then
               if not(var_message is null) then
                  var_message := var_message || '; ';
               end if;
               var_message := var_message || 'Period [' || var_period || '] is not valid.  Expecting YYYYPP format';
            end if;
         end loop;      
      
      else        
         if lics_inbound_utility.get_variable('ACCNT_ASSIGNMNT_CODE') is null then
            if not(var_message is null) then
               var_message := var_message || '; ';
            end if;
            var_message := var_message || 'Account assignment code is not set.';
         end if;
         if lics_inbound_utility.get_variable('PLNG_SRC_CODE') is null then
            if not(var_message is null) then
               var_message := var_message || '; ';
            end if;
            var_message := var_message || 'Planning source code is not set.';
         end if;
                
         for i in 1..con_mars_periods loop
            
            var_period_text := 'PERIOD_' || to_char(i);
            var_forecast := lics_inbound_utility.get_variable(var_period_text);
            
            if qv_app.qv_validation_utilities.check_number(var_forecast) = false then
               if not(var_message is null) then
                  var_message := var_message || '; ';
               end if;
               var_message := var_message || 'Forecast value is not a number.';
            end if;
         end loop;                     
      end if;

      /*-*/
      /* Return the message
      /*-*/
      return var_message;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;
   
end qv_csvqvs05_validation;

/**/
/* Authority 
/**/
grant execute on qv_csvqvs05_validation to lics_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_csvqvs05_validation for bi_app.qv_csvqvs05_validation;