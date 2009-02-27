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
    Site to ICS - STEICS01 - Intransit Interface Loader (Korea)

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
   type typ_outbound is table of varchar2(2000 char) index by binary_integer;
   tbl_outbound typ_outbound;

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
      tbl_outbound.delete;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_csv_definition('TARGET_DEST',1);
      lics_inbound_utility.set_csv_definition('LOAD_ID',2);
      lics_inbound_utility.set_csv_definition('SOURCE_PLANT',3);
      lics_inbound_utility.set_csv_definition('SHIP_DATE',4);
      lics_inbound_utility.set_csv_definition('ARRIV_DATE',5);
      lics_inbound_utility.set_csv_definition('BEST_BEFORE',6);
      lics_inbound_utility.set_csv_definition('TRANSMODE',7);
      lics_inbound_utility.set_csv_definition('IN_ITEM',8);
      lics_inbound_utility.set_csv_definition('QTY',9);
      lics_inbound_utility.set_csv_definition('ATLASSTOCKTYPE',10);
      lics_inbound_utility.set_csv_definition('ORDERTYPE',11);
      lics_inbound_utility.set_csv_definition('U_VEHCLLD_UDC1',12);
      lics_inbound_utility.set_csv_definition('SOURCE_STATUS',13);

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

      /*-*/
      /* Local definitions
      /*-*/
      var_output varchar2(2000 char);

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
      /* Build the inbound data array
      /*-*/
      var_output := lics_inbound_utility.get_variable('TARGET_DEST')||',';
      var_output := var_output||lics_inbound_utility.get_variable('LOAD_ID')||',';
      var_output := var_output||lics_inbound_utility.get_variable('SOURCE_PLANT')||',';
      var_output := var_output||lics_inbound_utility.get_variable('SHIP_DATE')||',';
      var_output := var_output||lics_inbound_utility.get_variable('ARRIV_DATE')||',';
      var_output := var_output||lics_inbound_utility.get_variable('BEST_BEFORE')||',';
      var_output := var_output||lics_inbound_utility.get_variable('TRANSMODE')||',';
      var_output := var_output||lics_inbound_utility.get_variable('IN_ITEM')||',';
      var_output := var_output||lics_inbound_utility.get_variable('QTY')||',';
      var_output := var_output||lics_inbound_utility.get_variable('ATLASSTOCKTYPE')||',';
      var_output := var_output||lics_inbound_utility.get_variable('ORDERTYPE')||',';
      var_output := var_output||lics_inbound_utility.get_variable('U_VEHCLLD_UDC1')||',';
      var_output := var_output||lics_inbound_utility.get_variable('SOURCE_STATUS')||',';
      var_output := var_output||to_char(tbl_outbound.count + 1)||',';
      tbl_outbound(tbl_outbound.count + 1) := var_output;

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
      var_instance number(15,0);
      var_timestamp varchar2(256 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Ignore when required
      /*-*/
      if var_trn_error = true then
         return;
      end if;
      if tbl_outbound.count = 0 then
         return;
      end if;

      /*-*/
      /* Create the outbound interface
      /*-*/
      var_timestamp := to_char(sysdate,'yyyymmddhh24miss');
      var_instance := lics_outbound_loader.create_interface('ICSAPL02', null, 'IN_INTRANSIT_SUP_STG_LADASU03.3.dat');
      for idx in 1..tbl_outbound.count loop
         lics_outbound_loader.append_data(tbl_outbound(idx)||to_char(tbl_outbound.count)||','||var_timestamp);
      end loop;
      ics_outbound_loader.finalise_interface;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

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
