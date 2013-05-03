create or replace package qv_app.qv_csvqvs16_validation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qv_csvqvs16_validation 
    Owner   : qv_app 
    Author  : Trevor Keon 

    Description
    -----------
    CSV to QV- CSVQVS16 - PPV Future Price data validation 

    YYYY/MM   Author         Description 
    -------   ------         ----------- 
    2012/10   Trevor Keon    Created 

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function on_start return varchar2;
   function on_data(par_record in varchar2) return varchar2;

end qv_csvqvs16_validation;

create or replace package body qv_app.qv_csvqvs16_validation as

   /*-*/
   /* Private constants 
   /*-*/
   con_interface constant varchar2(10) := 'csvqvs16';
   con_header_row constant number := 2;
   con_mars_periods constant number := 13;
   con_delimiter constant varchar2(2 char)  := ',';
   con_text_qualifier constant varchar2(2 char) := '"';

   /*-*/
   /* Private definitions
   /*-*/
   var_check_user boolean;
   var_valid_user boolean;
   var_line_count number;
   var_user varchar2(32 char); 

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
      lics_inbound_utility.set_csv_definition('DO_NOT_USE',1);
      lics_inbound_utility.set_csv_definition('PLANT_CODE',2);
      lics_inbound_utility.set_csv_definition('MATERIAL_CODE',3);
      lics_inbound_utility.set_csv_definition('MATERIAL_DESC',4);
      lics_inbound_utility.set_csv_definition('CURRENCY',5);
      lics_inbound_utility.set_csv_definition('PERIOD_1',6);
      lics_inbound_utility.set_csv_definition('PERIOD_2',7);
      lics_inbound_utility.set_csv_definition('PERIOD_3',8);
      lics_inbound_utility.set_csv_definition('PERIOD_4',9);
      lics_inbound_utility.set_csv_definition('PERIOD_5',10);
      lics_inbound_utility.set_csv_definition('PERIOD_6',11);
      lics_inbound_utility.set_csv_definition('PERIOD_7',12);
      lics_inbound_utility.set_csv_definition('PERIOD_8',13);
      lics_inbound_utility.set_csv_definition('PERIOD_9',14);
      lics_inbound_utility.set_csv_definition('PERIOD_10',15);
      lics_inbound_utility.set_csv_definition('PERIOD_11',16);
      lics_inbound_utility.set_csv_definition('PERIOD_12',17);
      lics_inbound_utility.set_csv_definition('PERIOD_13',18);
      
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
      var_data varchar2(50);
      
      var_period ppv_future_price.pfp_yyyypp%type;

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
      if qv_validation_utilities.check_blank_line(par_record, con_delimiter) = true then
         return var_message;
      end if;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_csv_record(par_record, con_delimiter, con_text_qualifier);
       
      /*-*/
      /* Validate Period headings are correct on the header as it will be used
      /* in the final table
      /*-*/       
      if var_line_count < con_header_row then
         return var_message;
      elsif var_line_count = con_header_row then      
         for i in 1..con_mars_periods loop
            
            var_period_text := 'PERIOD_' || to_char(i);
            var_data := lics_inbound_utility.get_variable(var_period_text);
            var_period := substr(var_data, 5, 4) || substr(var_data, 2, 2);
            
            if qv_validation_utilities.check_mars_calendar(var_period, '*PERIOD') = false then
               if not(var_message is null) then
                  var_message := var_message || '; ';
               end if;
               var_message := var_message || 'Period [' || var_period || '] is not valid.  Expecting Pxx.YYYY format';
            end if;
         end loop;      
      
      else        
         if lics_inbound_utility.get_variable('PLANT_CODE') is null then
            if not(var_message is null) then
               var_message := var_message || '; ';
            end if;
            var_message := var_message || 'Plant code is not set.';
         end if;

         if lics_inbound_utility.get_variable('MATERIAL_CODE') is null then
            if not(var_message is null) then
               var_message := var_message || '; ';
            end if;
            var_message := var_message || 'Material code is not set.';
         end if;

         if lics_inbound_utility.get_variable('CURRENCY') is null then
            if not(var_message is null) then
               var_message := var_message || '; ';
            end if;
            var_message := var_message || 'Currency is not set.';
         end if;
                
         for i in 1..con_mars_periods loop
            
            var_period_text := 'PERIOD_' || to_char(i);
            var_data := lics_inbound_utility.get_variable(var_period_text);
            
            if qv_validation_utilities.check_number(var_data, '999,999') = false then
               if not(var_message is null) then
                  var_message := var_message || '; ';
               end if;
               var_message := var_message || 'Price [' || var_data || '] is not a number.';
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
   
end qv_csvqvs16_validation;

/**/
/* Authority 
/**/
grant execute on qv_csvqvs16_validation to lics_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_csvqvs16_validation for qv_app.qv_csvqvs16_validation;