/******************/
/* Package Header */
/******************/
create or replace package ladefx01_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ladefx01_loader
    Owner   : iface_app

    Description
    -----------
    Efex - LADEFX01 - China Item Loader

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/08   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ladefx01_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ladefx01_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure process_record_hdr(par_record in varchar2);

   /*-*/
   /* Private constants
   /*-*/
   con_market_id constant number := 4;

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_iface_item iface_item%rowtype;

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the transaction variables
      /*-*/
      var_trn_start := true;
      var_trn_ignore := false;
      var_trn_error := false;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('HDR','IFACE_HDR',3);
      lics_inbound_utility.set_definition('HDR','MARKET_ID',10);
      lics_inbound_utility.set_definition('HDR','ITEM_CODE',18);
      lics_inbound_utility.set_definition('HDR','ITEM_NAME',40);
      lics_inbound_utility.set_definition('HDR','ITEM_ZREP_CODE',18);
      lics_inbound_utility.set_definition('HDR','RSU_EAN_CODE',18);
      lics_inbound_utility.set_definition('HDR','CASES_LAYER',20);
      lics_inbound_utility.set_definition('HDR','LAYERS_PALLET',20);
      lics_inbound_utility.set_definition('HDR','UNITS_CASE',20);
      lics_inbound_utility.set_definition('HDR','UNIT_MEASURE',3);
      lics_inbound_utility.set_definition('HDR','PRICE1',20);
      lics_inbound_utility.set_definition('HDR','PRICE2',20);
      lics_inbound_utility.set_definition('HDR','PRICE3',20);
      lics_inbound_utility.set_definition('HDR','PRICE4',20);
      lics_inbound_utility.set_definition('HDR','MIN_ORD_QTY',20);
      lics_inbound_utility.set_definition('HDR','ORDER_MULTIPLES',20);
      lics_inbound_utility.set_definition('HDR','BRAND',30);
      lics_inbound_utility.set_definition('HDR','SUB_BRAND',30);
      lics_inbound_utility.set_definition('HDR','PACK_SIZE',30);
      lics_inbound_utility.set_definition('HDR','PACK_TYPE',30);
      lics_inbound_utility.set_definition('HDR','ITEM_CATEGORY',30);
      lics_inbound_utility.set_definition('HDR','ITEM_STATUS',1);

      /*-*/
      /* Clear the IFACE item table for the China market
      /*-*/
      delete iface_item
       where market_id = con_market_id;
      commit;

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
      var_record_identifier varchar2(3);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the data based on record identifier
      /*-*/
      var_record_identifier := substr(par_record,1,3);
      case var_record_identifier
         when 'HDR' then process_record_hdr(par_record);
         else raise_application_error(-20000, 'Record identifier (' || var_record_identifier || ') not recognised');
      end case;

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

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* No data processed
      /*-*/
      if var_trn_start = false then
         rollback;
         return;
      end if;

      /*-*/
      /* Commit/rollback the IDOC as required
      /* Execute the interface monitor when required
      /*-*/
      if var_trn_ignore = true then
         rollback;
      elsif var_trn_error = true then
         rollback;
      else
         commit;
         efex_refresh.refresh_item(con_market_id);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

   /**************************************************/
   /* This procedure performs the record HDR routine */
   /**************************************************/
   procedure process_record_hdr(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_record('HDR', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_iface_item.market_id := lics_inbound_utility.get_number('MARKET_ID',null);
      rcd_iface_item.item_code := lics_inbound_utility.get_variable('ITEM_CODE');
      rcd_iface_item.item_name := lics_inbound_utility.get_variable('ITEM_NAME');
      rcd_iface_item.rsu_ean_code := lics_inbound_utility.get_variable('RSU_EAN_CODE');
      rcd_iface_item.cases_layer := lics_inbound_utility.get_number('CASES_LAYER',null);
      rcd_iface_item.layers_pallet := lics_inbound_utility.get_number('LAYERS_PALLET',null);
      rcd_iface_item.units_case := lics_inbound_utility.get_number('UNITS_CASE',null);
      rcd_iface_item.unit_measure := lics_inbound_utility.get_variable('UNIT_MEASURE');
      rcd_iface_item.price1 := lics_inbound_utility.get_number('PRICE1',null);
      rcd_iface_item.price2 := lics_inbound_utility.get_number('PRICE2',null);
      rcd_iface_item.price3 := lics_inbound_utility.get_number('PRICE3',null);
      rcd_iface_item.price4 := lics_inbound_utility.get_number('PRICE4',null);
      rcd_iface_item.min_order_qty := lics_inbound_utility.get_number('MIN_ORD_QTY',null);
      rcd_iface_item.order_multiples := lics_inbound_utility.get_number('ORDER_MULTIPLES',null);
      rcd_iface_item.brand := lics_inbound_utility.get_variable('BRAND');
      rcd_iface_item.sub_brand := lics_inbound_utility.get_variable('SUB_BRAND');
      rcd_iface_item.item_category := lics_inbound_utility.get_variable('PACK_SIZE');
      rcd_iface_item.pack_size := lics_inbound_utility.get_variable('PACK_TYPE');
      rcd_iface_item.pack_type := lics_inbound_utility.get_variable('ITEM_CATEGORY');
      rcd_iface_item.item_status := lics_inbound_utility.get_variable('ITEM_STATUS');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_iface_item.market_id != con_market_id then
         lics_inbound_utility.add_exception('Item market id ('||rcd_iface_item.market_id||') is not valid for the China market');
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* ERROR- Bypass the update when required */
      /*----------------------------------------*/
      if var_trn_error = true then
         return;
      end if;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      insert into iface_item
         (market_id,
          item_code,
          item_name,
          rsu_ean_code,
          cases_layer,
          layers_pallet,
          units_case,
          unit_measure,
          price1,
          price2,
          price3,
          price4,
          min_order_qty,
          order_multiples,
          brand,
          sub_brand,
          item_category,
          pack_size,
          pack_type,
          item_status)
      values
         (rcd_iface_item.market_id;
          rcd_iface_item.item_code;
          rcd_iface_item.item_name;
          rcd_iface_item.rsu_ean_code;
          rcd_iface_item.cases_layer;
          rcd_iface_item.layers_pallet;
          rcd_iface_item.units_case;
          rcd_iface_item.unit_measure;
          rcd_iface_item.price1;
          rcd_iface_item.price2;
          rcd_iface_item.price3;
          rcd_iface_item.price4;
          rcd_iface_item.min_order_qty;
          rcd_iface_item.order_multiples;
          initcap(rcd_iface_item.brand);
          initcap(rcd_iface_item.sub_brand);
          rcd_iface_item.item_category;
          rcd_iface_item.pack_size;
          rcd_iface_item.pack_type;
          rcd_iface_item.item_status;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

end ladefx01_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladefx01_loader for iface_app.ladefx01_loader;
grant execute on ladefx01_loader to lics_app;
