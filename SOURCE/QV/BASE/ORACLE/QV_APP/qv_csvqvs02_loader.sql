create or replace package qv_app.qv_csvqvs02_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qv_csvqvs02_loader
    Owner   : qv_app

    Description
    -----------
    CSV File to Qlikview - CSVQVS02 - TP Budgets

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/09   Trevor Keon    Created
    2011/11   Trevor Keon    Updated to support ICS v2

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end qv_csvqvs02_loader;

create or replace package body qv_app.qv_csvqvs02_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants 
   /*-*/
   con_delimiter constant varchar2(32)  := ',';
   con_heading_count constant number := 1;
   con_interface constant varchar2(10) := 'CSVQVS02';

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   var_trn_count number;
   var_sequence number;
   
   rcd_tp_budget_data tp_budget_data%rowtype;

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

      /*-*/
      /* Set sequence number
      /*-*/
      select tp_budget_data_seq.nextval
      into var_sequence
      from dual;
      
      lics_logging.write_log('Sequence number = ' || var_sequence);      

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

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_start;

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   procedure on_data(par_record in varchar2) is

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
      if var_trn_count <= con_heading_count then
         return;
      end if;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_csv_record(par_record, con_delimiter);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_tp_budget_data.tbd_version := var_sequence;
      rcd_tp_budget_data.tbd_date := lics_inbound_utility.get_date('DATE','DD/MM/YYYY');
      rcd_tp_budget_data.tbd_demand_group := lics_inbound_utility.get_variable('DEMAND_GROUP');
      rcd_tp_budget_data.tbd_brand := lics_inbound_utility.get_variable('BRAND');
      rcd_tp_budget_data.tbd_mkt_sub_cat := lics_inbound_utility.get_variable('MARKET_SUB_CATEGORY');
      rcd_tp_budget_data.tbd_mars_year := lics_inbound_utility.get_variable('MARS_YEAR');
      rcd_tp_budget_data.tbd_mars_period := lics_inbound_utility.get_variable('MARS_PERIOD');
      rcd_tp_budget_data.tbd_mars_prd_wk := lics_inbound_utility.get_variable('MARS_PERIOD_WEEK');
      rcd_tp_budget_data.tbd_budget := lics_inbound_utility.get_variable('BUDGET');            

      /*-*/
      /* Insert the row when required
      /*-*/
      if not(rcd_tp_budget_data.tbd_date is null) or
         not(rcd_tp_budget_data.tbd_demand_group is null) or
         not(rcd_tp_budget_data.tbd_brand is null) or
         not(rcd_tp_budget_data.tbd_mkt_sub_cat is null) or
         not(rcd_tp_budget_data.tbd_mars_year is null) or
         not(rcd_tp_budget_data.tbd_mars_period is null) or
         not(rcd_tp_budget_data.tbd_mars_prd_wk is null) or
         not(rcd_tp_budget_data.tbd_budget is null) then           
         insert into tp_budget_data values rcd_tp_budget_data;
      else
         lics_logging.write_log('Found invalid line - #' || var_trn_count);
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

end qv_csvqvs02_loader;

/**/
/* Authority 
/**/
grant execute on qv_csvqvs02_loader to lics_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_csvqvs02_loader for qv_app.qv_csvqvs02_loader;