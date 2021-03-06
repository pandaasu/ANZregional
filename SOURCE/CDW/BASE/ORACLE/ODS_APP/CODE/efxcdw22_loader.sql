create or replace package ods_app.efxcdw22_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw22_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex Distribution Data - EFEX to CDW 

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created 
    2012/07   Trevor Keon    Added Promo Price field
    2012/08   Mal Chambeyron Modify Promo Price to VARCHAR2, equal to source

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end efxcdw22_loader;
/

create or replace package body ods_app.efxcdw22_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure process_record_ctl(par_record in varchar2);
   procedure process_record_hdr(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   var_trn_count number;
   var_trn_interface varchar2(32);
   var_trn_market number;
   var_trn_extract varchar2(14);
   rcd_efex_distbn efex_distbn%rowtype;

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
      var_trn_interface := null;
      var_trn_market := 0;
      var_trn_extract := null;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('CTL','RCD_ID',3);
      lics_inbound_utility.set_definition('CTL','INT_ID',32);
      lics_inbound_utility.set_definition('CTL','MKT_ID',10);
      lics_inbound_utility.set_definition('CTL','EXT_ID',14);
      /*-*/
      lics_inbound_utility.set_definition('HDR','RCD_ID',3);
      lics_inbound_utility.set_definition('HDR','CUS_ID',10);
      lics_inbound_utility.set_definition('HDR','ITM_ID',10);
      lics_inbound_utility.set_definition('HDR','STE_ID',10);
      lics_inbound_utility.set_definition('HDR','SEG_ID',10);
      lics_inbound_utility.set_definition('HDR','BUS_ID',10);
      lics_inbound_utility.set_definition('HDR','USR_ID',10);
      lics_inbound_utility.set_definition('HDR','RAN_ID',10);
      lics_inbound_utility.set_definition('HDR','DSP_QTY',15);
      lics_inbound_utility.set_definition('HDR','FAC_QTY',15);
      lics_inbound_utility.set_definition('HDR','OST_FLAG',1);
      lics_inbound_utility.set_definition('HDR','ODT_FLAG',1);
      lics_inbound_utility.set_definition('HDR','REQ_FLAG',1);
      lics_inbound_utility.set_definition('HDR','INV_QTY',15);
      lics_inbound_utility.set_definition('HDR','SEL_PRICE',15);
      lics_inbound_utility.set_definition('HDR','PRO_PRICE',15);
      lics_inbound_utility.set_definition('HDR','IST_DATE',14);
      lics_inbound_utility.set_definition('HDR','STATUS',1);
      lics_inbound_utility.set_definition('HDR','EFX_DATE',14);

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
         var_trn_error := true;
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 1024));

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
      /* Commit/rollback as required
      /*-*/
      if var_trn_error = true then
         rollback;
      else
         efxcdw00_loader.update_interface(var_trn_interface, var_trn_market, var_trn_extract, var_trn_count);
         commit;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

   /**************************************************/
   /* This procedure performs the record CTL routine */
   /**************************************************/
   procedure process_record_ctl(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('CTL', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      var_trn_interface := lics_inbound_utility.get_variable('INT_ID');
      var_trn_market := lics_inbound_utility.get_number('MKT_ID',null);
      var_trn_extract := lics_inbound_utility.get_variable('EXT_ID');

      /*-*/
      /* Exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
         return;
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 1024));
         var_trn_error := true;

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

      rcd_efex_distbn.efex_cust_id := lics_inbound_utility.get_number('CUS_ID',null);
      rcd_efex_distbn.efex_matl_id := lics_inbound_utility.get_number('ITM_ID',null);
      rcd_efex_distbn.sales_terr_id := lics_inbound_utility.get_number('STE_ID',null);
      rcd_efex_distbn.sgmnt_id := lics_inbound_utility.get_number('SEG_ID',null);
      rcd_efex_distbn.bus_unit_id := lics_inbound_utility.get_number('BUS_ID',null);
      rcd_efex_distbn.user_id := lics_inbound_utility.get_number('USR_ID',null);
      rcd_efex_distbn.range_id := lics_inbound_utility.get_number('RAN_ID',null);
      rcd_efex_distbn.display_qty := lics_inbound_utility.get_number('DSP_QTY',null);
      rcd_efex_distbn.facing_qty := lics_inbound_utility.get_number('FAC_QTY',null);
      rcd_efex_distbn.out_of_stock_flg := lics_inbound_utility.get_variable('OST_FLAG');
      rcd_efex_distbn.out_of_date_flg := lics_inbound_utility.get_variable('ODT_FLAG');
      rcd_efex_distbn.rqd_flg := lics_inbound_utility.get_variable('REQ_FLAG');
      rcd_efex_distbn.inv_qty := lics_inbound_utility.get_number('INV_QTY',null);
      rcd_efex_distbn.sell_price := lics_inbound_utility.get_number('SEL_PRICE',null);
      -- rcd_efex_distbn.promo_price := lics_inbound_utility.get_number('PRO_PRICE',null);
      rcd_efex_distbn.promo_price := lics_inbound_utility.get_variable('PRO_PRICE');
      rcd_efex_distbn.in_store_date := lics_inbound_utility.get_date('IST_DATE','yyyymmddhh24miss');
      rcd_efex_distbn.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_distbn.efex_lupdt := lics_inbound_utility.get_date('EFX_DATE','yyyymmddhh24miss');
      rcd_efex_distbn.valdtn_status := ods_constants.valdtn_unchecked;
      rcd_efex_distbn.efex_mkt_id := var_trn_market;
      var_trn_count := var_trn_count + 1;

      /*-*/
      /* Exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
         return;
      end if;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into efex_distbn values rcd_efex_distbn;
      exception
         when dup_val_on_index then
            update efex_distbn
               set sales_terr_id = rcd_efex_distbn.sales_terr_id,
                   sgmnt_id = rcd_efex_distbn.sgmnt_id,
                   bus_unit_id = rcd_efex_distbn.bus_unit_id,
                   user_id = rcd_efex_distbn.user_id,
                   range_id = rcd_efex_distbn.range_id,
                   display_qty = rcd_efex_distbn.display_qty,
                   facing_qty = rcd_efex_distbn.facing_qty,
                   out_of_stock_flg = rcd_efex_distbn.out_of_stock_flg,
                   out_of_date_flg = rcd_efex_distbn.out_of_date_flg,
                   rqd_flg = rcd_efex_distbn.rqd_flg,
                   inv_qty = rcd_efex_distbn.inv_qty,
                   sell_price = rcd_efex_distbn.sell_price,
                   promo_price = rcd_efex_distbn.promo_price,
                   in_store_date = rcd_efex_distbn.in_store_date,
                   status = rcd_efex_distbn.status,
                   efex_lupdt = rcd_efex_distbn.efex_lupdt,
                   valdtn_status = rcd_efex_distbn.valdtn_status,
                   efex_mkt_id = rcd_efex_distbn.efex_mkt_id
             where efex_cust_id = rcd_efex_distbn.efex_cust_id
               and efex_matl_id = rcd_efex_distbn.efex_matl_id;
      end;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 1024));
         var_trn_error := true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

end efxcdw22_loader;
/

