/******************/
/* Package Header */
/******************/
create or replace package ics_app.ics_steics03_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ics_steics03_loader
    Owner   : ics_app

    Description
    -----------
    Site to ICS - STEICS03 - Pet - Shipment Summary Interface Loader (Korea)

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ics_steics03_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ics_app.ics_steics03_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants 
   /*-*/
   con_segment constant varchar2(128) := 'PET';
   con_delimiter constant varchar2(32) := ',';
   con_qualifier constant varchar2(10) := '"';
   con_heading_count constant number := 1;

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   var_trn_count number;
   rcd_kor_shp_summary kor_shp_summary%rowtype;

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the transaction variables
      /*-*/
      var_trn_error := false;
      var_trn_count := 0;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_csv_definition('WAREHOUSE',1);
      lics_inbound_utility.set_csv_definition('SUPPLIER',2);
      lics_inbound_utility.set_csv_definition('SHIP_PERIOD',3);
      lics_inbound_utility.set_csv_definition('MATERIAL',4);
      lics_inbound_utility.set_csv_definition('FORECAST_QTY',5);
      lics_inbound_utility.set_csv_definition('OUTSTAND_QTY',6);
      lics_inbound_utility.set_csv_definition('EXPT_AVAIL_DATE',7);

      /*-*/
      /* Delete the existing Korea shipment summary data
      /*-*/
      delete from kor_shp_summary where segment = con_segment;

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

      lics_inbound_utility.parse_csv_record(par_record, con_delimiter, con_qualifier);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_kor_shp_summary.segment := con_segment;
      rcd_kor_shp_summary.warehouse := lics_inbound_utility.get_variable('WAREHOUSE');
      rcd_kor_shp_summary.supplier := lics_inbound_utility.get_variable('SUPPLIER');
      rcd_kor_shp_summary.ship_period := lics_inbound_utility.get_variable('SHIP_PERIOD');
      rcd_kor_shp_summary.material := lics_inbound_utility.get_variable('MATERIAL');
      rcd_kor_shp_summary.forecast_qty := lics_inbound_utility.get_variable('FORECAST_QTY');
      rcd_kor_shp_summary.outstand_qty := lics_inbound_utility.get_variable('OUTSTAND_QTY');
      rcd_kor_shp_summary.expt_avail_date := lics_inbound_utility.get_variable('EXPT_AVAIL_DATE');

      /*-*/
      /* Insert the shipment summary row when required
      /*-*/
      if not(rcd_kor_shp_summary.warehouse is null) or
         not(rcd_kor_shp_summary.supplier is null) or
         not(rcd_kor_shp_summary.ship_period is null) or
         not(rcd_kor_shp_summary.material is null) or
         not(rcd_kor_shp_summary.forecast_qty is null) or
         not(rcd_kor_shp_summary.outstand_qty is null) or
         not(rcd_kor_shp_summary.expt_avail_date is null) then
         insert into kor_shp_summary values rcd_kor_shp_summary;
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

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

end ics_steics03_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ics_steics03_loader for ics_app.ics_steics03_loader;
grant execute on ics_app.ics_steics03_loader to lics_app;
