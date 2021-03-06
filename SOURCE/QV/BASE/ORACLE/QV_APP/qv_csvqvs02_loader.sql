create or replace package qv_app.qv_csvqvs02_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qv_csvqvs02_loader 
    Owner   : qv_app 

    Description 
    ----------- 
    CSV File to Qlikview - CSVQVS02 - NZ KAM Forecast 

    YYYY/MM   Author         Description 
    -------   ------         ----------- 
    2012/08   Trevor Keon    Created 

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
   
   rcd_nz_kam_forecast nz_kam_forecast%rowtype;

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
      /* Initialise the definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_csv_definition('MARS_PERIOD',1);
      lics_inbound_utility.set_csv_definition('MARS_WEEK',2);
      lics_inbound_utility.set_csv_definition('NZ_REGROUP',3);
      lics_inbound_utility.set_csv_definition('FORECAST',4);

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
      rcd_nz_kam_forecast.nkf_yyyypp := lics_inbound_utility.get_variable('MARS_PERIOD');
      rcd_nz_kam_forecast.nkf_yyyyppw := lics_inbound_utility.get_variable('MARS_WEEK');
      rcd_nz_kam_forecast.nkf_regroup_dpg := lics_inbound_utility.get_variable('NZ_REGROUP');
      rcd_nz_kam_forecast.nkf_value := lics_inbound_utility.get_variable('FORECAST');            

      /*-*/
      /* Update the row 
      /*-*/     
      update nz_kam_forecast
      set nkf_yyyypp = rcd_nz_kam_forecast.nkf_yyyypp,
         nkf_value = rcd_nz_kam_forecast.nkf_value
      where nkf_yyyyppw = rcd_nz_kam_forecast.nkf_yyyyppw
         and nkf_regroup_dpg = rcd_nz_kam_forecast.nkf_regroup_dpg;

      /*-*/
      /* Insert the row when required 
      /*-*/      
      if sql%notfound then      
         insert into nz_kam_forecast values rcd_nz_kam_forecast;      
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