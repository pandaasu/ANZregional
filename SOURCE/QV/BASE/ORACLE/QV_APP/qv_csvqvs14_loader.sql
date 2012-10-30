create or replace package qv_app.qv_csvqvs14_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qv_csvqvs14_loader 
    Owner   : qv_app 

    Description
    -----------
    CSV File to Qlikview - CSVQVS14 - AU Coles Forecast (Food)  

    YYYY/MM   Author         Description
    -------   ------         -----------
    2012/07   Trevor Keon    Created 
    2012/07   Trevor Keon    Added Rep Item and removed 0 forecasts 
    2012/07   Trevor Keon    Fixed issue with variable columns 
    2012/08   Trevor Keon    Updated to support all AU sites 

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end qv_csvqvs14_loader;

create or replace package body qv_app.qv_csvqvs14_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);
   
   /*-*/
   /* Private declarations
   /*-*/
   function get_mars_week(par_date in date) return number;
   function get_rep_item(par_coles_product in varchar2) return varchar2;

   /*-*/
   /* Private constants 
   /*-*/
   con_delimiter constant varchar2(32)  := ',';  
   con_heading_count constant number := 2;
   con_date_heading constant number := 3;
   
   con_max_columns constant number := 50;
   con_interface constant varchar2(10) := 'CSVQVS14';
   con_unit_moe_code constant varchar2(8) := '0021';

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   var_trn_count number;
   var_last_mars_week number;
   var_column_count number;
   
   var_load_week au_coles_forecast.acf_load_yyyyppw%type;
   var_load_period au_coles_forecast.acf_load_yyyypp%type;
   
   type data_record is record
   (
      mars_week mars_date.mars_week%type,
      calendar_date mars_date.calendar_date%type
   );
   
   type forecast_record is record
   (
      mars_week mars_date.mars_week%type,
      mars_period mars_date.mars_period%type,
      forecast au_coles_forecast.acf_forecast%type      
   );
   
   type data_table is table of data_record index by pls_integer;   
   data_list data_table;
   current_forecast forecast_record;
      
   rcd_au_coles_fcst au_coles_forecast%rowtype;  

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
      var_last_mars_week := 0;
      var_column_count := 0;
      
      /*-*/
      /* Set the load week and period based on the current date 
      /*-*/      
      var_load_week := get_mars_week(trunc(sysdate));
      var_load_period := substr(var_load_week, 0, 6);

      /*-*/
      /* Initialise the definitions 
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_csv_definition('COLES_WAREHOUSE',1);
      lics_inbound_utility.set_csv_definition('COLES_PRODUCT',2);
      lics_inbound_utility.set_csv_definition('DAY_1',3);
      lics_inbound_utility.set_csv_definition('DAY_2',4);
      lics_inbound_utility.set_csv_definition('DAY_3',5);
      lics_inbound_utility.set_csv_definition('DAY_4',6);
      lics_inbound_utility.set_csv_definition('DAY_5',7);
      lics_inbound_utility.set_csv_definition('DAY_6',8);
      lics_inbound_utility.set_csv_definition('DAY_7',9);
      lics_inbound_utility.set_csv_definition('DAY_8',10);
      lics_inbound_utility.set_csv_definition('DAY_9',11);
      lics_inbound_utility.set_csv_definition('DAY_10',12);
      lics_inbound_utility.set_csv_definition('DAY_11',13);
      lics_inbound_utility.set_csv_definition('DAY_12',14);
      lics_inbound_utility.set_csv_definition('DAY_13',15);
      lics_inbound_utility.set_csv_definition('DAY_14',16);
      lics_inbound_utility.set_csv_definition('DAY_15',17);
      lics_inbound_utility.set_csv_definition('DAY_16',18);
      lics_inbound_utility.set_csv_definition('DAY_17',19);
      lics_inbound_utility.set_csv_definition('DAY_18',20);
      lics_inbound_utility.set_csv_definition('DAY_19',21);
      lics_inbound_utility.set_csv_definition('DAY_20',22);
      lics_inbound_utility.set_csv_definition('DAY_21',23);
      lics_inbound_utility.set_csv_definition('DAY_22',24);
      lics_inbound_utility.set_csv_definition('DAY_23',25);
      lics_inbound_utility.set_csv_definition('DAY_24',26);
      lics_inbound_utility.set_csv_definition('DAY_25',27);
      lics_inbound_utility.set_csv_definition('DAY_26',28);
      lics_inbound_utility.set_csv_definition('DAY_27',29);
      lics_inbound_utility.set_csv_definition('DAY_28',30);
      lics_inbound_utility.set_csv_definition('DAY_29',31);
      lics_inbound_utility.set_csv_definition('DAY_30',32);
      lics_inbound_utility.set_csv_definition('DAY_31',33);
      lics_inbound_utility.set_csv_definition('DAY_32',34);
      lics_inbound_utility.set_csv_definition('DAY_33',35);
      lics_inbound_utility.set_csv_definition('DAY_34',36);
      lics_inbound_utility.set_csv_definition('DAY_35',37);
      lics_inbound_utility.set_csv_definition('DAY_36',38);
      lics_inbound_utility.set_csv_definition('DAY_37',39);
      lics_inbound_utility.set_csv_definition('DAY_38',40);
      lics_inbound_utility.set_csv_definition('DAY_39',41);
      lics_inbound_utility.set_csv_definition('DAY_40',42);
      lics_inbound_utility.set_csv_definition('DAY_41',43);
      lics_inbound_utility.set_csv_definition('DAY_42',44);
      lics_inbound_utility.set_csv_definition('DAY_43',45);
      lics_inbound_utility.set_csv_definition('DAY_44',46);
      lics_inbound_utility.set_csv_definition('DAY_45',47);
      lics_inbound_utility.set_csv_definition('DAY_46',48);
      lics_inbound_utility.set_csv_definition('DAY_47',49);
      lics_inbound_utility.set_csv_definition('DAY_48',50);
      lics_inbound_utility.set_csv_definition('DAY_49',51);
      lics_inbound_utility.set_csv_definition('DAY_50',52);
      
      /*-*/
      /* Remove any records loaded in the same week  
      /*-*/       
      delete from au_coles_forecast where acf_load_yyyyppw = var_load_week;

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
      var_day_count number;
      
      var_unit_field mars_date.calendar_date%type;
      var_mars_week mars_date.mars_week%type;

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
      
      var_trn_count := var_trn_count + 1;
      var_day_count := 0;       
      
      /*-*/
      /* Ignore blank lines
      /*-*/      
      if qv_validation_utilities.check_blank_line(par_record, con_delimiter) = true then
         lics_logging.write_log('Found blank line - #' || var_trn_count);
         return;
      end if;      
     
      /*-*/
      /* Ignore the header record 
      /*-*/         
      if var_trn_count <= con_heading_count then
         return;
      end if;                   
      
      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_csv_record(par_record, con_delimiter);           
      
      /*-*/
      /* Retrieve field values
      /*-*/      
      if var_trn_count = con_date_heading then
        for i in 1..con_max_columns loop
          var_field := 'DAY_' || to_char(i);
          var_unit_field := lics_inbound_utility.get_date(var_field, 'DD/MM/YYYY');
                    
          exit when var_unit_field is null;
          
          var_column_count := var_column_count + 1;          
          var_mars_week := get_mars_week(var_unit_field);
          
          if var_mars_week = -1 then
            lics_logging.write_log('Invalid Date - ' || to_char(var_unit_field, 'DD/MM/YYYY'));
          else
            data_list(i).mars_week := var_mars_week;
            data_list(i).calendar_date := var_unit_field;
          end if;
        
        end loop;
      else      
        rcd_au_coles_fcst.acf_load_yyyyppw := var_load_week;
        rcd_au_coles_fcst.acf_load_yyyypp := var_load_period;
        rcd_au_coles_fcst.acf_warehouse := lics_inbound_utility.get_variable('COLES_WAREHOUSE');
        rcd_au_coles_fcst.acf_rep_item := get_rep_item(lics_inbound_utility.get_variable('COLES_PRODUCT'));
        rcd_au_coles_fcst.acf_moe_code := con_unit_moe_code;
        
       /*-*/
       /* Ignore records with no Coles product matching a rep item 
       /*-*/         
        if rcd_au_coles_fcst.acf_rep_item is null then
          lics_logging.write_log('Missing mapping for Coles product - ' || lics_inbound_utility.get_variable('COLES_PRODUCT'));
          return;
        end if;
        
        for i in 1..var_column_count loop
          var_field := 'DAY_' || to_char(i);
          
          if var_last_mars_week = 0 then
            current_forecast.mars_week := data_list(i).mars_week;
            current_forecast.mars_period := substr(data_list(i).mars_week, 0, 6);
            current_forecast.forecast := lics_inbound_utility.get_number(var_field, '999999');
            
            var_last_mars_week := data_list(i).mars_week;
            var_day_count := 1;
          elsif var_last_mars_week <> data_list(i).mars_week then
            rcd_au_coles_fcst.acf_yyyypp := current_forecast.mars_period;
            rcd_au_coles_fcst.acf_yyyyppw := current_forecast.mars_week;
            rcd_au_coles_fcst.acf_forecast := current_forecast.forecast;
          
            /*-*/
            /* Add the record if the forecast is not 0 
            /*-*/             
            if current_forecast.forecast <> 0 then
              insert into au_coles_forecast
              values rcd_au_coles_fcst;
            end if;
            
            /*-*/
            /* Log when an incomplete week is recorded 
            /*-*/
            if var_day_count <> 7 then
               lics_logging.write_log('Incomplete week recorded - ' || to_char(current_forecast.mars_week));
            end if;
            
            current_forecast.mars_week := data_list(i).mars_week;
            current_forecast.mars_period := substr(data_list(i).mars_week, 0, 6);
            current_forecast.forecast := lics_inbound_utility.get_number(var_field, '999999');
            
            var_last_mars_week := data_list(i).mars_week;
          else
            current_forecast.forecast := lics_inbound_utility.get_number(var_field, '999999') + current_forecast.forecast;
            var_day_count := var_day_count + 1;
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
   
   /****************************************************/
   /* This function performs the get mars week routine */
   /****************************************************/
   function get_mars_week(par_date in date) return number is
         
      /*-*/
      /* Local definitions
      /*-*/
      var_result number;
         
      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_mars_week is
         select mars_week
         from mars_date
         where calendar_date = par_date;
      rcd_mars_week csr_mars_week%rowtype;   
   
   begin
   
     open csr_mars_week;
       fetch csr_mars_week into rcd_mars_week;
       if csr_mars_week%notfound then
         var_result := '-1';
       else
         var_result := rcd_mars_week.mars_week;
       end if;
     close csr_mars_week;
     
     return var_result;
   
   end get_mars_week;
     
   /***************************************************/
   /* This function performs the get rep item routine */
   /***************************************************/   
   function get_rep_item(par_coles_product in varchar2) return varchar2 is
   
      /*-*/
      /* Local definitions
      /*-*/
      var_result varchar2(18 char);
      var_coles_code varchar2(18 char);
      
      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_rep_item is
        select acmm_rep_item
        from au_coles_matl_map
        where acmm_coles_code = var_coles_code;
      rcd_rep_item csr_rep_item%rowtype;         
   
   begin
   
     var_coles_code := substr(par_coles_product, 0, instr(par_coles_product, ' ') - 1);
   
     open csr_rep_item;
       fetch csr_rep_item into rcd_rep_item;
       if csr_rep_item%notfound then
         var_result := null;
       else
         var_result := rcd_rep_item.acmm_rep_item;
       end if;
     close csr_rep_item;
     
     return var_result;      
   
   end get_rep_item;   

end qv_csvqvs14_loader;

/**/
/* Authority 
/**/
grant execute on qv_csvqvs14_loader to lics_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_csvqvs14_loader for qv_app.qv_csvqvs14_loader;