create or replace package qv_app.qv_csvqvs16_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qv_csvqvs16_loader 
    Owner   : qv_app 

    Description 
    ----------- 
    CSV File to Qlikview - CSVQVS16 - PPV Future Price 

    YYYY/MM   Author         Description 
    -------   ------         ----------- 
    2012/10   Trevor Keon    Created 

   *******************************************************************************/

   /*-*/
   /* Public declarations 
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end qv_csvqvs16_loader;

create or replace package body qv_app.qv_csvqvs16_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants 
   /*-*/
   con_delimiter constant varchar2(2 char) := ',';
   con_text_qualifier constant varchar2(2 char) := '"';
   con_heading_count constant number := 2;
   con_mars_periods constant number := 13;
   con_interface constant varchar2(10) := 'csvqvs16';

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   var_trn_count number;
   var_sequence number;
   
   type period_table is table of number index by pls_integer;
      
   tbl_period period_table;
   rcd_ppv_future_price ppv_future_price%rowtype;
   
   var_last_plant ppv_future_price.pfp_plant%type;  

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      lics_logging.start_log(con_interface, con_interface);

      /*-*/
      /* Initialise the transaction variables 
      /*-*/
      var_trn_error := false;
      var_trn_count := 0;
      var_last_plant := null; 

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
      var_period_text varchar2(25 char);
      var_temp varchar2(25 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
   
      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/
     
      var_trn_count := var_trn_count + 1;
      
      /*-*/
      /* Ignore blank lines 
      /*-*/      
      if qv_validation_utilities.check_blank_line(par_record, con_delimiter) = true then
         lics_logging.write_log('Found blank line - #' || var_trn_count);
         return;
      end if;
      
      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_csv_record(par_record, con_delimiter, con_text_qualifier);       
      
      /*-*/
      /* Retrieve field values 
      /*-*/      
      if var_trn_count = con_heading_count then
         for i in 1..con_mars_periods loop            
            var_period_text := 'PERIOD_' || to_char(i);          
            var_temp := lics_inbound_utility.get_variable(var_period_text);
            
            tbl_period(i) := to_number(substr(var_temp, 5, 4) || substr(var_temp, 2, 2));
            
         end loop;              
      elsif var_trn_count > con_heading_count then 
         rcd_ppv_future_price.pfp_plant := lics_inbound_utility.get_variable('PLANT_CODE');
         rcd_ppv_future_price.pfp_material := lics_inbound_utility.get_variable('MATERIAL_CODE');
         rcd_ppv_future_price.pfp_currency := lics_inbound_utility.get_variable('CURRENCY');
         
         if var_last_plant is null or var_last_plant <>  rcd_ppv_future_price.pfp_plant then
         
            var_last_plant := rcd_ppv_future_price.pfp_plant;            
            for i in 1..con_mars_periods loop
            
               delete
               from ppv_future_price
               where pfp_plant = var_last_plant
                  and pfp_yyyypp = tbl_period(i);
            
            end loop;
         
         end if;          
             
         for i in 1..con_mars_periods loop          
            var_period_text := 'PERIOD_' || to_char(i);           
            
            rcd_ppv_future_price.pfp_yyyypp := tbl_period(i);
            rcd_ppv_future_price.pfp_price := lics_inbound_utility.get_number(var_period_text, '999,999'); 
                     
            /*-*/
            /* Insert the row when required 
            /*-*/            
            insert into ppv_future_price values rcd_ppv_future_price;
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

end qv_csvqvs16_loader;

/**/
/* Authority 
/**/
grant execute on qv_csvqvs16_loader to lics_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_csvqvs16_loader for qv_app.qv_csvqvs16_loader;