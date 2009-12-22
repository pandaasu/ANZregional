/******************/
/* Package Header */
/******************/
create or replace package iface_app.ladefx91_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ladefx91_loader
    Owner   : iface_app

    Description
    -----------
    Efex - LADEFX91 - New Zealand Item Loader

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/11   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ladefx91_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.ladefx91_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure complete_transaction;
   procedure process_record_ctl(par_record in varchar2);
   procedure process_record_hdr(par_record in varchar2);

   /*-*/
   /* Private constants
   /*-*/
   con_market_id constant number := 5;

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
      lics_inbound_utility.set_definition('CTL','IFACE_CTL',3);
      /*-*/
      lics_inbound_utility.set_definition('HDR','IFACE_HDR',3);
      lics_inbound_utility.set_definition('HDR','MARKET_ID',10);
      lics_inbound_utility.set_definition('HDR','ITEM_CODE',50);
      lics_inbound_utility.set_definition('HDR','ITEM_NAME',50);
      lics_inbound_utility.set_definition('HDR','RSU_EAN_CODE',50);
      lics_inbound_utility.set_definition('HDR','MCU_EAN_CODE',50);
      lics_inbound_utility.set_definition('HDR','TDU_EAN_CODE',50);
      lics_inbound_utility.set_definition('HDR','CASES_LAYER',20);
      lics_inbound_utility.set_definition('HDR','LAYERS_PALLET',20);
      lics_inbound_utility.set_definition('HDR','UNITS_CASE',20);
      lics_inbound_utility.set_definition('HDR','MCU_PER_TDU',20);
      lics_inbound_utility.set_definition('HDR','UNIT_MEASURE',3);
      lics_inbound_utility.set_definition('HDR','TDU_PRICE',20);
      lics_inbound_utility.set_definition('HDR','RRP_PRICE',20);
      lics_inbound_utility.set_definition('HDR','MCU_PRICE',20);
      lics_inbound_utility.set_definition('HDR','RSU_PRICE',20);
      lics_inbound_utility.set_definition('HDR','ORDER_BY',1);
      lics_inbound_utility.set_definition('HDR','MIN_ORDER_QTY',20);
      lics_inbound_utility.set_definition('HDR','ORDER_MULTIPLES',20);
      lics_inbound_utility.set_definition('HDR','BRAND',50);
      lics_inbound_utility.set_definition('HDR','SUB_BRAND',50);
      lics_inbound_utility.set_definition('HDR','PRODUCT_CATEGORY',50);
      lics_inbound_utility.set_definition('HDR','MARKET_CATEGORY',30);
      lics_inbound_utility.set_definition('HDR','MARKET_SUBCATEGORY',30);
      lics_inbound_utility.set_definition('HDR','MARKET_SUBCATEGORY_GROUP',30);
      lics_inbound_utility.set_definition('HDR','ITEM_STATUS',1); 
      lics_inbound_utility.set_definition('HDR','TDU_NAME',200);
      lics_inbound_utility.set_definition('HDR','MCU_NAME',200);
      lics_inbound_utility.set_definition('HDR','RSU_NAME',200);

      /*-*/
      /* Clear the IFACE item table for the New Zealand market
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
         when 'CTL' then process_record_ctl(par_record);
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
      /* Complete the transaction
      /*-*/
      complete_transaction;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

   /************************************************************/
   /* This procedure performs the complete transaction routine */
   /************************************************************/
   procedure complete_transaction is

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
         efex_refresh.refresh_nz_item(con_market_id);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end complete_transaction;

   /**************************************************/
   /* This procedure performs the record CTL routine */
   /**************************************************/
   procedure process_record_ctl(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Complete the previous transaction
      /*-*/
      complete_transaction;

      /*-*/
      /* Reset the transaction variables
      /*-*/
      var_trn_start := true;
      var_trn_ignore := false;
      var_trn_error := false;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ctl;

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
      rcd_iface_item.item_name := substrb(lics_inbound_utility.get_variable('ITEM_NAME'),1,50);
      rcd_iface_item.rsu_ean_code := lics_inbound_utility.get_variable('RSU_EAN_CODE');
      rcd_iface_item.mcu_ean_code := lics_inbound_utility.get_variable('MCU_EAN_CODE');
      rcd_iface_item.tdu_ean_code := lics_inbound_utility.get_variable('TDU_EAN_CODE');
      if lics_inbound_utility.get_number('CASES_LAYER',null) > 9999 then
         rcd_iface_item.cases_layer := 9999;
      else
         rcd_iface_item.cases_layer := lics_inbound_utility.get_number('CASES_LAYER',null);
      end if;
      if lics_inbound_utility.get_number('LAYERS_PALLET',null) > 9999 then
         rcd_iface_item.layers_pallet := 9999;
      else
         rcd_iface_item.layers_pallet := lics_inbound_utility.get_number('LAYERS_PALLET',null);
      end if;
      if lics_inbound_utility.get_number('UNITS_CASE',null) > 9999 then
         rcd_iface_item.units_case := 9999;
      else
         rcd_iface_item.units_case := lics_inbound_utility.get_number('UNITS_CASE',null);
      end if;
      if lics_inbound_utility.get_number('MCU_PER_TDU',null) > 9999 then
         rcd_iface_item.mcu_per_tdu := 9999;
      else
         rcd_iface_item.mcu_per_tdu := lics_inbound_utility.get_number('MCU_PER_TDU',null);
      end if;
      rcd_iface_item.unit_measure := lics_inbound_utility.get_variable('UNIT_MEASURE');
      rcd_iface_item.price1 := lics_inbound_utility.get_number('TDU_PRICE',null);
      rcd_iface_item.price2 := lics_inbound_utility.get_number('RRP_PRICE',null);
      rcd_iface_item.price3 := lics_inbound_utility.get_number('MCU_PRICE',null);
      rcd_iface_item.price4 := lics_inbound_utility.get_number('RSU_PRICE',null);
      rcd_iface_item.order_by := lics_inbound_utility.get_variable('ORDER_BY');
      if lics_inbound_utility.get_number('MIN_ORD_QTY',null) > 9999 then
         rcd_iface_item.min_order_qty := 9999;
      else
         rcd_iface_item.min_order_qty := lics_inbound_utility.get_number('MIN_ORD_QTY',null);
      end if;
      if lics_inbound_utility.get_number('ORDER_MULTIPLES',null) > 9999 then
         rcd_iface_item.order_multiples := 9999;
      else
         rcd_iface_item.order_multiples := lics_inbound_utility.get_number('ORDER_MULTIPLES',null);
      end if;
      rcd_iface_item.brand := lics_inbound_utility.get_variable('BRAND');
      rcd_iface_item.sub_brand := lics_inbound_utility.get_variable('SUB_BRAND');
      rcd_iface_item.product_category := lics_inbound_utility.get_variable('PRODUCT_CATEGORY');
      rcd_iface_item.market_category := lics_inbound_utility.get_variable('MARKET_CATEGORY');
      rcd_iface_item.market_subcategory := lics_inbound_utility.get_variable('MARKET_SUBCATEGORY');
      rcd_iface_item.market_subcategory_group := lics_inbound_utility.get_variable('MARKET_SUBCATEGORY_GROUP');
      rcd_iface_item.item_status := lics_inbound_utility.get_variable('ITEM_STATUS');
      rcd_iface_item.item_tdu_name := lics_inbound_utility.get_variable('TDU_NAME');
      rcd_iface_item.item_mcu_name := lics_inbound_utility.get_variable('MCU_NAME');
      rcd_iface_item.item_rsu_name := lics_inbound_utility.get_variable('RSU_NAME');

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
         lics_inbound_utility.add_exception('Item market id ('||rcd_iface_item.market_id||') is not valid for the New Zealand market');
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
          mcu_ean_code,
          tdu_ean_code,
          cases_layer,
          layers_pallet,
          units_case,
          mcu_per_tdu,
          unit_measure,
          price1,
          price2,
          price3,
          price4,
          order_by,
          min_order_qty,
          order_multiples,
          brand,
          sub_brand,
          product_category,
          market_category,
          market_subcategory,
          market_subcategory_group,
          item_status,
          item_tdu_name,
          item_mcu_name,
          item_rsu_name)
      values
         (rcd_iface_item.market_id,
          rcd_iface_item.item_code,
          rcd_iface_item.item_name,
          rcd_iface_item.rsu_ean_code,
          rcd_iface_item.mcu_ean_code,
          rcd_iface_item.tdu_ean_code,
          rcd_iface_item.cases_layer,
          rcd_iface_item.layers_pallet,
          rcd_iface_item.units_case,
          rcd_iface_item.mcu_per_tdu,
          rcd_iface_item.unit_measure,
          rcd_iface_item.price1,
          rcd_iface_item.price2,
          rcd_iface_item.price3,
          rcd_iface_item.price4,
          rcd_iface_item.order_by,
          rcd_iface_item.min_order_qty,
          rcd_iface_item.order_multiples,
          rcd_iface_item.brand,
          rcd_iface_item.sub_brand,
          rcd_iface_item.product_category,
          rcd_iface_item.market_category,
          rcd_iface_item.market_subcategory,
          rcd_iface_item.market_subcategory_group,
          rcd_iface_item.item_status,
          rcd_iface_item.item_tdu_name,
          rcd_iface_item.item_mcu_name,
          rcd_iface_item.item_rsu_name);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

end ladefx91_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladefx91_loader for iface_app.ladefx91_loader;
grant execute on ladefx91_loader to lics_app;
