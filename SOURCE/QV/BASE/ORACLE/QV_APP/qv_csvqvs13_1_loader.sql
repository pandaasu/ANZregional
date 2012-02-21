create or replace package qv_app.qv_csvqvs13_1_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qv_csvqvs13_1_loader
    Owner   : qv_app

    Description
    -----------
    CSV File to Qlikview - CSVQVS13.1 - Petcare FPPS Values (Actuals and Forecast)

    YYYY/MM   Author         Description
    -------   ------         -----------
    2011/05   Trevor Keon    Created
    2011/11   Trevor Keon    Updated to support ICS v2

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end qv_csvqvs13_1_loader;

create or replace package body qv_app.qv_csvqvs13_1_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants 
   /*-*/
   con_delimiter constant varchar2(32)  := ',';
   con_unit_delimiter constant varchar2(1 char) := '/';
   con_curr_century constant varchar2(1 char) := '2';
   
   con_heading_count constant number := 3;
   con_fixed_columns constant number := 16;
   con_interface constant varchar2(10) := 'CSVQVS13.1';
   con_bus_segment constant fpps_values.fvl_bus_segment%type := '05'; --Petcare

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   var_trn_count number;  
   var_sequence number;
   
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
   
   type unit_table is table of unit_record index by pls_integer;
   
   header_data header_record;
   unit_list unit_table;
      
   rcd_fpps_values fpps_values%rowtype;  

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      lics_logging.start_log(con_interface, con_interface);
      lics_logging.write_log('Load started');

      /*-*/
      /* Initialise the transaction variables
      /*-*/
      var_trn_error := false;
      var_trn_count := 0;  
      
      /*-*/
      /* Set sequence number
      /*-*/
      select fpps_units_seq.nextval
      into var_sequence
      from dual;
      
      lics_logging.write_log('Sequence number = ' || var_sequence);       

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

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap 
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         var_trn_error := true;
         lics_logging.write_log('Error on_start - ' || substr(SQLERRM, 1, 512));
         lics_logging.end_log;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_start;

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   procedure on_data(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_field varchar2(10 char);
      var_unit_field varchar2(100 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
   
      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/

      if trim(par_record) is null then
         return;
      end if;
      
      /*-*/
      /* Ignore blank lines
      /*-*/      
      if qv_validation_utilities.check_blank_line(par_record, con_delimiter) = true then
         lics_logging.write_log('Found blank line - #' || var_trn_count);
         return;
      end if;
      
      var_trn_count := var_trn_count + 1;              
      
      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_csv_record(par_record, con_delimiter);           
      
      /*-*/
      /* Retrieve field values
      /*-*/      
      if var_trn_count <= con_heading_count then
        -- Load period value
        if var_trn_count = 1 then
--          var_unit_field := lics_inbound_utility.get_variable('LINE_ITEM');
          var_unit_field := par_record;
          header_data.period := substr(var_unit_field, length(var_unit_field) - 1, 2);         
          
          lics_logging.write_log('Period = ' || to_char(header_data.period));
                  
        -- Load year value
        elsif var_trn_count = 2 then
--          var_unit_field := lics_inbound_utility.get_variable('LINE_ITEM');
          var_unit_field := par_record;
          
          header_data.year := substr(var_unit_field, instr(var_unit_field, con_curr_century, 1, 1), 4);
          header_data.value_type := substr(var_unit_field, instr(var_unit_field, con_curr_century, 1, 1) + 5, instr(substr(var_unit_field, instr(var_unit_field, con_curr_century, 1, 1) + 5), ' ', 1, 1)-1);   
          
          lics_logging.write_log('Year = ' || to_char(header_data.year));
          lics_logging.write_log('Value Type = ' || header_data.value_type);
          
          -- Delete entries
          delete
          from fpps_values
          where fvl_mars_yyyypp = header_data.year || header_data.period
            and fvl_bus_segment = con_bus_segment
            and fvl_value_type = header_data.value_type;          

        -- Populate Unit / Destination Unit headers
        else
          for i in 1..con_fixed_columns loop
            var_field := 'CONS_' || to_char(i);
            var_unit_field := lics_inbound_utility.get_variable(var_field);
            
            unit_list(i).unit := substr(var_unit_field, 1, instr(var_unit_field, con_unit_delimiter, 1, 1) - 1);
            unit_list(i).destination := substr(var_unit_field, instr(var_unit_field, con_unit_delimiter, 1, 1) + 1);
            
            lics_logging.write_log('Unit = ' || to_char(unit_list(i).unit));
            lics_logging.write_log('Destination = ' || to_char(unit_list(i).destination));
            
          end loop;          
        end if;
              
      else
        rcd_fpps_values.fvl_mars_yyyypp := header_data.year || header_data.period;
        rcd_fpps_values.fvl_bus_segment := con_bus_segment;
        rcd_fpps_values.fvl_value_type := header_data.value_type;
        rcd_fpps_values.fvl_line_item := lics_inbound_utility.get_variable('LINE_ITEM');
        rcd_fpps_values.fvl_source := lics_inbound_utility.get_variable('SOURCE');
        rcd_fpps_values.fvl_customer := lics_inbound_utility.get_variable('CUSTOMER');
        rcd_fpps_values.fvl_material := lics_inbound_utility.get_variable('MATERIAL');
        
        for i in 1..con_fixed_columns loop
          var_field := 'CONS_' || to_char(i);
          var_unit_field := lics_inbound_utility.get_variable(var_field);

          -- only insert fields when we have a value
          if not(var_unit_field is null) then
            rcd_fpps_values.fvl_unit := unit_list(i).unit;
            rcd_fpps_values.fvl_destination := unit_list(i).destination;
            rcd_fpps_values.fvl_value := var_unit_field;
            
            /*-*/
            /* Insert the row when required
            /*-*/
            if not(rcd_fpps_values.fvl_mars_yyyypp is null) or
              not(rcd_fpps_values.fvl_bus_segment is null) or
              not(rcd_fpps_values.fvl_value_type is null) or
              not(rcd_fpps_values.fvl_line_item is null) or
              not(rcd_fpps_values.fvl_source is null) or
              not(rcd_fpps_values.fvl_customer is null) or
              not(rcd_fpps_values.fvl_material is null) or
              not(rcd_fpps_values.fvl_unit is null) or
              not(rcd_fpps_values.fvl_destination is null) then               
               insert into fpps_values values rcd_fpps_values;
            else
               lics_logging.write_log('Found blank line - #' || var_trn_count);
            end if;                 
          end if;
        end loop;
      end if; 

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         var_trn_error := true;
         lics_logging.write_log('Error on_data - ' || substr(SQLERRM, 1, 512));
         lics_logging.end_log;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;

   /**********************************************/
   /* This procedure performs the on end routine */
   /**********************************************/
   procedure on_end is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);      
      var_session number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
         
      /*-*/
      /* Ignore when required
      /*-*/
      if var_trn_error = true then
         rollback;
         return;
      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;
      
      lics_logging.write_log('Completed successfully');      
      lics_logging.end_log;        

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
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Add the exception to the interface
         /*-*/
         lics_inbound_utility.add_exception(var_exception);        
         lics_logging.end_log;
         
   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

end qv_csvqvs13_1_loader;

/**/
/* Authority 
/**/
grant execute on qv_csvqvs13_1_loader to lics_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_csvqvs13_1_loader for qv_app.qv_csvqvs13_1_loader;