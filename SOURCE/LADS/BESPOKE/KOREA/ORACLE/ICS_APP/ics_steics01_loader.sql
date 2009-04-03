/******************/
/* Package Header */
/******************/
create or replace package ics_app.ics_steics01_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ics_steics01_loader
    Owner   : ics_app

    Description
    -----------
    Site to ICS - STEICS01 - Inbound Summary Interface Loader (Korea)

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/02   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ics_steics01_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ics_app.ics_steics01_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants 
   /*-*/
   con_delimiter constant varchar2(32)  := ',';
   con_qualifier constant varchar2(10) := '"';
   con_heading_count constant number := 1;

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   var_trn_count number;
   rcd_kor_inb_summary kor_inb_summary%rowtype;

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
      lics_inbound_utility.set_csv_definition('PLANT',1);
      lics_inbound_utility.set_csv_definition('DELIVERY',2);
      lics_inbound_utility.set_csv_definition('SOURCE_PLANT',3);
      lics_inbound_utility.set_csv_definition('SHIP_DATE',4);
      lics_inbound_utility.set_csv_definition('DELIVERY_DATE',5);
      lics_inbound_utility.set_csv_definition('EXPIRY_DATE',6);
      lics_inbound_utility.set_csv_definition('MATERIAL',7);
      lics_inbound_utility.set_csv_definition('QTY',8);
      lics_inbound_utility.set_csv_definition('ORDERTYPE',9);
      lics_inbound_utility.set_csv_definition('SHIP_PERIOD',10);
      lics_inbound_utility.set_csv_definition('RSMN_DATE',11);

      /*-*/
      /* Delete the existing Korea inbound summary data
      /*-*/
      delete from kor_inb_summary;

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
      rcd_kor_inb_summary.plant := lics_inbound_utility.get_variable('PLANT');
      rcd_kor_inb_summary.delivery := lics_inbound_utility.get_variable('DELIVERY');
      rcd_kor_inb_summary.source_plant := lics_inbound_utility.get_variable('SOURCE_PLANT');
      rcd_kor_inb_summary.ship_date := lics_inbound_utility.get_variable('SHIP_DATE');
      rcd_kor_inb_summary.delivery_date := lics_inbound_utility.get_variable('DELIVERY__DATE');
      rcd_kor_inb_summary.expiry_date := lics_inbound_utility.get_variable('EXPIRY_DATE');
      rcd_kor_inb_summary.material := lics_inbound_utility.get_variable('MATERIAL');
      rcd_kor_inb_summary.qty := lics_inbound_utility.get_variable('QTY');
      rcd_kor_inb_summary.ordertype := lics_inbound_utility.get_variable('ORDERTYPE');
      rcd_kor_inb_summary.ship_period := lics_inbound_utility.get_variable('SHIP_PERIOD');
      rcd_kor_inb_summary.rsmn_date := lics_inbound_utility.get_variable('RSMN_DATE');

      /*-*/
      /* Insert the inbound summary row
      /*-*/
      insert into kor_inb_summary values rcd_kor_inb_summary;

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

end ics_steics01_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ics_steics01_loader for ics_app.ics_steics01_loader;
grant execute on ics_app.ics_steics01_loader to lics_app;
