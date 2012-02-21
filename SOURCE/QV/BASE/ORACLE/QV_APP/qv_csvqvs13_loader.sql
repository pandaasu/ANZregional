create or replace package qv_app.qv_csvqvs13_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qv_csvqvs13_loader
    Owner   : qv_app

    Description
    -----------
    CSV File to Qlikview - CSVQVS13 - FPPS Values (Actuals and Forecast)

    YYYY/MM   Author         Description
    -------   ------         -----------
    2011/05   Trevor Keon    Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end qv_csvqvs13_loader;

create or replace package body qv_app.qv_csvqvs13_loader as

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
   con_interface constant varchar2(10) := 'CSVQVS13';

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   var_trn_count number;  
   
   type header_record is record
   (
      unit fpps_values.fvl_unit%type,
      destination fpps_values.fvl_destination%type
   );
   
   type year_period_record is record
   (
      period varchar2(2 char),
      year varchar2(4 char) 
   );
   
   type header_table is table of header_record index by pls_integer;
   
   year_period year_period_record;
   header_list header_table;
      
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
      var_period_text varchar2(25);
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
      
      lics_logging.write_log('Line count = ' || to_char(var_trn_count));
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
          var_unit_field := lics_inbound_utility.get_variable('LINE_ITEM');
          year_period.period := substr(var_unit_field, length(var_unit_field) - 1, 2);
          
          lics_logging.write_log('Period = ' || to_char(year_period.period));
                  
        -- Load year value
        elsif var_trn_count = 2 then
          var_unit_field := lics_inbound_utility.get_variable('LINE_ITEM');
          year_period.year := substr(var_unit_field, instr(var_unit_field, con_curr_century, 1, 1), 4);
          
          lics_logging.write_log('Year = ' || to_char(year_period.year));

        -- Populate Unit / Destination Unit headers
        else
          for i in 1..con_fixed_columns loop
            var_field := 'CONS_' || to_char(i);
            var_unit_field := lics_inbound_utility.get_variable(var_field);
            
            header_list(i).unit := substr(var_unit_field, 1, instr(var_unit_field, con_unit_delimiter, 1, 1) - 1);
            header_list(i).destination := substr(var_unit_field, instr(var_unit_field, con_unit_delimiter, 1, 1) + 1);
            
            lics_logging.write_log('Unit = ' || to_char(header_list(i).unit));
            lics_logging.write_log('Destination = ' || to_char(header_list(i).destination));
            
          end loop;
        end if;
              
      else
        rcd_fpps_values.fvl_mars_yyyypp := year_period.year || year_period.period;
        rcd_fpps_values.fvl_line_item := lics_inbound_utility.get_variable('LINE_ITEM');
        rcd_fpps_values.fvl_source := lics_inbound_utility.get_variable('SOURCE');
        rcd_fpps_values.fvl_customer := lics_inbound_utility.get_variable('CUSTOMER');
        rcd_fpps_values.fvl_material := lics_inbound_utility.get_variable('MATERIAL');
        
        for i in 1..con_fixed_columns loop
          var_field := 'CONS_' || to_char(i);
          var_unit_field := lics_inbound_utility.get_variable(var_field);

          -- only insert fields when we have a value
          if not(var_unit_field is null) then
            rcd_fpps_values.fvl_unit := header_list(i).unit;
            rcd_fpps_values.fvl_destination := header_list(i).destination;
            rcd_fpps_values.fvl_value := var_unit_field;   
            
            -- update the existing entry
            update fpps_values set
              fvl_mars_yyyypp = rcd_fpps_values.fvl_mars_yyyypp,
              fvl_line_item = rcd_fpps_values.fvl_line_item,
              fvl_source = rcd_fpps_values.fvl_source,
              fvl_customer = rcd_fpps_values.fvl_customer,
              fvl_material = rcd_fpps_values.fvl_material,
              fvl_unit = rcd_fpps_values.fvl_unit,
              fvl_destination = rcd_fpps_values.fvl_destination,
              fvl_value = rcd_fpps_values.fvl_value
            where fvl_mars_yyyypp = rcd_fpps_values.fvl_mars_yyyypp
              and fvl_line_item = rcd_fpps_values.fvl_line_item
              and fvl_source = rcd_fpps_values.fvl_source
              and fvl_customer = rcd_fpps_values.fvl_customer
              and fvl_material = rcd_fpps_values.fvl_material
              and fvl_unit = rcd_fpps_values.fvl_unit
              and fvl_destination = rcd_fpps_values.fvl_destination;
            
            -- if new entry, insert it
            if sql%notfound then
              insert into fpps_values
              values
              (
                rcd_fpps_values.fvl_mars_yyyypp,
                rcd_fpps_values.fvl_line_item,
                rcd_fpps_values.fvl_source,
                rcd_fpps_values.fvl_customer,
                rcd_fpps_values.fvl_material,
                rcd_fpps_values.fvl_unit,
                rcd_fpps_values.fvl_destination,
                rcd_fpps_values.fvl_value
              );
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
      var_audit_user varchar2(10 char);
      var_file_path varchar2(200 char);
      
      var_session number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      var_audit_user := lics_interface_loader.get_user(con_interface);
      var_file_path := lics_interface_loader.get_file_path(con_interface);
      
      lics_interface_loader.remove_user(con_interface);     
            
      lics_logging.write_log('Audit user = ' || var_audit_user);
      lics_logging.write_log('File = ' || var_file_path);
      
      lics_logging.end_log;
      
      if var_audit_user is null then
        raise_application_error(-20000, 'CSVQVS13 Loader - Audit user is null.');
      end if;

      if var_file_path is null then
        raise_application_error(-20000, 'CSVQVS13 Loader - File path is null.');
      end if;
      
      qv_audit_control.add_audit_line(con_interface, 0, var_audit_user);

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
      
      /**/
      /* Execute the file archive script
      /**/
      java_utility.execute_external_procedure(lics_parameter.archive_script || ' ' || var_file_path);      

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
         /* Add the exception to the interface and remove locking user
         /*-*/
         lics_inbound_utility.add_exception(var_exception);
         lics_interface_loader.remove_user(con_interface);
         
         lics_logging.write_log('Error on_end - ' || substr(SQLERRM, 1, 512));
         lics_logging.end_log;
         
   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

end qv_csvqvs13_loader;

/**/
/* Authority 
/**/
grant execute on qv_csvqvs13_loader to lics_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_csvqvs13_loader for qv_app.qv_csvqvs13_loader;