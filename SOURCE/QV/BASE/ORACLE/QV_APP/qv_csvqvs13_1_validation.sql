create or replace package qv_app.qv_csvqvs13_1_validation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qv_csvqvs13_1_validation
    Owner   : qv_app
    Author  : Trevor Keon

    Description
    -----------
    CSV to QV- CSVQVS - Petcare FPPS Values (Actuals and Forecast) Validation

    YYYY/MM   Author         Description
    -------   ------         -----------
    2011/05   Trevor Keon    Created
    2011/11   Trevor Keon    Updated to support ICS v2

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function on_start return varchar2;
   function on_data(par_record in varchar2) return varchar2;

end qv_csvqvs13_1_validation;

create or replace package body qv_app.qv_csvqvs13_1_validation as

   /*-*/
   /* Private functions 
   /*-*/
   function check_master_data(par_value in varchar2, par_type in varchar2) return boolean;

   /*-*/
   /* Private constants 
   /*-*/
   con_delimiter constant varchar2(32)  := ',';
   con_unit_delimiter constant varchar2(1 char) := '/';
   con_curr_century constant varchar2(1 char) := '2';   

   con_interface constant varchar2(10) := 'CSVQVS13.1';
   con_header_row constant number := 3;
   con_fixed_columns constant number := 16;

   /*-*/
   /* Private definitions
   /*-*/
   var_line_count number;
   
   type unit_record is record
   (
      unit fpps_values.fvl_unit%type,
      destination fpps_values.fvl_destination%type
   );   
   
   type header_record is record
   (
      period varchar2(2 char),
      year varchar2(4 char),
      value_type fpps_values.fvl_value_type%type
   );
   
   header_data header_record;
   unit_data unit_record;    

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
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
      lics_inbound_utility.set_csv_definition('LINE_ITEM',1);
      lics_inbound_utility.set_csv_definition('SOURCE',2);
      lics_inbound_utility.set_csv_definition('CUSTOMER',3);
      lics_inbound_utility.set_csv_definition('MATERIAL',4);
      lics_inbound_utility.set_csv_definition('CONS_1',5);
      lics_inbound_utility.set_csv_definition('CONS_2',6);
      lics_inbound_utility.set_csv_definition('CONS_3',7);
      lics_inbound_utility.set_csv_definition('CONS_4',8);
      lics_inbound_utility.set_csv_definition('CONS_5',9);
      lics_inbound_utility.set_csv_definition('CONS_6',10);
      lics_inbound_utility.set_csv_definition('CONS_7',11);
      lics_inbound_utility.set_csv_definition('CONS_8',12);
      lics_inbound_utility.set_csv_definition('CONS_9',13);
      lics_inbound_utility.set_csv_definition('CONS_10',14);
      lics_inbound_utility.set_csv_definition('CONS_11',15);
      lics_inbound_utility.set_csv_definition('CONS_12',16);
      lics_inbound_utility.set_csv_definition('CONS_13',17);
      lics_inbound_utility.set_csv_definition('CONS_14',18);
      lics_inbound_utility.set_csv_definition('CONS_15',19);
      lics_inbound_utility.set_csv_definition('CONS_16',20);
      
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
      var_field varchar2(10 char);
      var_unit_field varchar2(100 char);
      
      var_line_item fpps_values.fvl_line_item%type;
      var_source fpps_values.fvl_source%type;
      var_customer fpps_values.fvl_customer%type;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the function
      /*-*/
      var_message := null;
      
      /*-*/
      /* Ignore blank lines
      /*-*/      
      if qv_validation_utilities.check_blank_line(par_record, con_delimiter) = true then
         return var_message;
      end if;
      
      var_line_count := var_line_count + 1;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_csv_record(par_record, con_delimiter);
       
      /*-*/
      /* Validate headings are correct
      /*-*/       
      if var_line_count <= con_header_row then
      
        -- Load period value
        if var_line_count = 1 then
          var_unit_field := lics_inbound_utility.get_variable('LINE_ITEM');
          header_data.period := substr(var_unit_field, length(var_unit_field) - 1, 2);
                  
        -- Load year value and validate YYYYPP and value type
        elsif var_line_count = 2 then
          var_unit_field := lics_inbound_utility.get_variable('LINE_ITEM');
          header_data.year := substr(var_unit_field, instr(var_unit_field, con_curr_century, 1, 1), 4);
          header_data.value_type := substr(var_unit_field, instr(var_unit_field, con_curr_century, 1, 1) + 5, instr(substr(var_unit_field, instr(var_unit_field, con_curr_century, 1, 1) + 5), ' ', 1, 1)-1);   

          if qv_validation_utilities.check_mars_calendar(header_data.year || header_data.period, '*PERIOD') = false then
            if not(var_message is null) then
               var_message := var_message || '; ';
            end if;
            var_message := var_message || 'Period [' || header_data.year || header_data.period || '] is not valid.';
          end if;
          
          if not(header_data.value_type = 'ACTUALS') and not(header_data.value_type = 'FORECAST') then
            if not(var_message is null) then
               var_message := var_message || '; ';
            end if;
            var_message := var_message || 'Value type [' || header_data.value_type || '] is not valid.  Expecting ACTUALS or FORECAST.';          
          end if;                  

        -- Validate Unit / Destination Unit headers
        else
          for i in 1..con_fixed_columns loop
            var_field := 'CONS_' || to_char(i);
            var_unit_field := lics_inbound_utility.get_variable(var_field);
            
            unit_data.unit := substr(var_unit_field, 1, instr(var_unit_field, con_unit_delimiter, 1, 1) - 1);
            unit_data.destination := substr(var_unit_field, instr(var_unit_field, con_unit_delimiter, 1, 1) + 1);
            
            if check_master_data(unit_data.unit, '*UNIT') = false then
              if not(var_message is null) then
                var_message := var_message || '; ';
              end if;
              var_message := var_message || 'Unit [' || unit_data.unit || '] is not valid.';
            end if;

            if check_master_data(unit_data.destination, '*DESTINATION') = false then
              if not(var_message is null) then
                var_message := var_message || '; ';
              end if;
              var_message := var_message || 'Destination [' || unit_data.destination || '] is not valid.';
            end if;
            
          end loop;          
        end if;
      
      else         
      
        var_line_item := lics_inbound_utility.get_variable('LINE_ITEM');
        var_source := lics_inbound_utility.get_variable('SOURCE');
        var_customer := lics_inbound_utility.get_variable('CUSTOMER');      
      
        if check_master_data(var_line_item, '*LINE_ITEM') = false then
          if not(var_message is null) then
            var_message := var_message || '; ';
          end if;
          var_message := var_message || 'Line Item [' || var_line_item || '] is not valid.';
        end if;
                     
        if check_master_data(var_source, '*SOURCE') = false then
          if not(var_message is null) then
            var_message := var_message || '; ';
          end if;
          var_message := var_message || 'Source [' || var_source || '] is not valid.';
        end if;
        
        if check_master_data(var_customer, '*CUSTOMER') = false then
          if not(var_message is null) then
            var_message := var_message || '; ';
          end if;
          var_message := var_message || 'Customer [' || var_customer || '] is not valid.';
        end if;                    
      end if;

      /*-*/
      /* Return the message
      /*-*/
      return var_message;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;
   
   function check_master_data(par_value in varchar2, par_type in varchar2) return boolean is
   
      /*-*/
      /* Local types
      /*-*/   
      type csr_master_data is ref cursor;
      type rcd_master_data is record (mars_val varchar2(1 char));   
   
      /*-*/
      /* Local definitions
      /*-*/
      var_result boolean := true;      
      
      /*-*/
      /* Dynamic cursor
      /*-*/      
      csr_check csr_master_data;
      rcd_values rcd_master_data;
   
   begin
   
      if par_type = '*CUSTOMER' then
         open csr_check for
            select 'x'
            from fpps_customer
            where fcs_int_acc = par_value
              and fcs_total = par_value;
      elsif par_type = '*DESTINATION' then
         open csr_check for
            select 'x'
            from fpps_destination
            where fde_mkt_group = par_value
              or fde_total = par_value;
      elsif par_type = '*LINE_ITEM' then
         open csr_check for
            select 'x'
            from fpps_line_item
            where fli_line_item = par_value; 
      elsif par_type = '*SOURCE' then
         open csr_check for
            select 'x'
            from fpps_source
            where fsr_from = par_value
              or fsr_total = par_value; 
      elsif par_type = '*UNIT' then
         open csr_check for
            select 'x'
            from fpps_units
            where fun_unit = par_value; 
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
   end check_master_data;       
   
end qv_csvqvs13_1_validation;

/**/
/* Authority 
/**/
grant execute on qv_csvqvs13_1_validation to lics_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_csvqvs13_1_validation for qv_app.qv_csvqvs13_1_validation;