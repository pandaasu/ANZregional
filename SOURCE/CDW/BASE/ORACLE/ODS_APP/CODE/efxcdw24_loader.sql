/******************/
/* Package Header */
/******************/
create or replace package ods_app.efxcdw24_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw24_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex Order Data - EFEX to CDW

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end efxcdw24_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.efxcdw24_loader as

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
   procedure process_record_nte(par_record in varchar2);
   procedure process_record_end(par_record in varchar2);
   procedure process_record_itm(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   var_trn_count number;
   var_trn_interface varchar2(32);
   var_trn_market number;
   var_trn_extract varchar2(14);
   rcd_efex_order efex_order%rowtype;
   rcd_efex_order_matl efex_order_matl%rowtype;

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
      lics_inbound_utility.set_definition('HDR','ORD_ID',10);
      lics_inbound_utility.set_definition('HDR','PUR_ORDER',50);
      lics_inbound_utility.set_definition('HDR','ORD_DATE',14);
      lics_inbound_utility.set_definition('HDR','ORD_CODE',50);
      lics_inbound_utility.set_definition('HDR','CUS_ID',10);
      lics_inbound_utility.set_definition('HDR','STE_ID',10);
      lics_inbound_utility.set_definition('HDR','SEG_ID',10);
      lics_inbound_utility.set_definition('HDR','BUS_ID',10);
      lics_inbound_utility.set_definition('HDR','CON_ID',10);
      lics_inbound_utility.set_definition('HDR','CON_NAME',101);
      lics_inbound_utility.set_definition('HDR','DIS_ID',10);
      lics_inbound_utility.set_definition('HDR','USR_ID',10);
      lics_inbound_utility.set_definition('HDR','DEL_DATE',14);
      lics_inbound_utility.set_definition('HDR','TOT_ITEMS',15);
      lics_inbound_utility.set_definition('HDR','TOT_PRICE',15);
      lics_inbound_utility.set_definition('HDR','COM_FLAG',1);
      lics_inbound_utility.set_definition('HDR','ORD_STATUS',50);
      lics_inbound_utility.set_definition('HDR','TPM_VALUE',15);
      lics_inbound_utility.set_definition('HDR','TPM_FLAG',1);
      lics_inbound_utility.set_definition('HDR','DEL_FLAG',1);
      lics_inbound_utility.set_definition('HDR','STATUS',1);
      /*-*/
      lics_inbound_utility.set_definition('NTE','RCD_ID',3);
      lics_inbound_utility.set_definition('NTE','NTE_TEXT',2000);
      /*-*/
      lics_inbound_utility.set_definition('END','RCD_ID',3);
      /*-*/
      lics_inbound_utility.set_definition('ITM','RCD_ID',3);
      lics_inbound_utility.set_definition('ITM','ORD_ID',10);
      lics_inbound_utility.set_definition('ITM','ITM_ID',10);
      lics_inbound_utility.set_definition('ITM','ORD_QTY',15);
      lics_inbound_utility.set_definition('ITM','ALC_QTY',15);
      lics_inbound_utility.set_definition('ITM','DIS_ID',10);
      lics_inbound_utility.set_definition('ITM','UOM_CODE',10);
      lics_inbound_utility.set_definition('ITM','STATUS',1);

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
         when 'NTE' then process_record_nte(par_record);
         when 'END' then process_record_end(par_record);
         when 'ITM' then process_record_itm(par_record);
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

      rcd_efex_order.efex_order_id := lics_inbound_utility.get_number('ORD_ID',null);
      rcd_efex_order.purch_order_num := lics_inbound_utility.get_variable('PUR_ORDER');
      rcd_efex_order.order_notes := null;
      rcd_efex_order.order_date := lics_inbound_utility.get_date('ORD_DATE','yyyymmddhh24miss');
      rcd_efex_order.order_code := lics_inbound_utility.get_variable('ORD_CODE');
      rcd_efex_order.efex_cust_id := lics_inbound_utility.get_number('CUS_ID',null);
      rcd_efex_order.sales_terr_id := lics_inbound_utility.get_number('STE_ID',null);
      rcd_efex_order.sgmnt_id := lics_inbound_utility.get_number('SEG_ID',null);
      rcd_efex_order.bus_unit_id := lics_inbound_utility.get_number('BUS_ID',null);
      rcd_efex_order.cust_contact_id := lics_inbound_utility.get_number('CON_ID',null);
      rcd_efex_order.cust_contact := substr(lics_inbound_utility.get_variable('CON_NAME'),1,100);
      rcd_efex_order.order_distbr_id := lics_inbound_utility.get_number('DIS_ID',null);
      rcd_efex_order.user_id := lics_inbound_utility.get_number('USR_ID',null);
      rcd_efex_order.dlvry_date := lics_inbound_utility.get_date('DEL_DATE','yyyymmddhh24miss');
      rcd_efex_order.tot_matls := lics_inbound_utility.get_number('TOT_ITEMS',null);
      rcd_efex_order.tot_price := lics_inbound_utility.get_number('TOT_PRICE',null);
      rcd_efex_order.confirm_flg := lics_inbound_utility.get_variable('COM_FLAG');
      rcd_efex_order.order_status := lics_inbound_utility.get_variable('ORD_STATUS');
      rcd_efex_order.tp_amt := lics_inbound_utility.get_number('TPM_VALUE',null);
      rcd_efex_order.tp_paid_flg := lics_inbound_utility.get_variable('TPM_FLAG');
      rcd_efex_order.dlvrd_flg := lics_inbound_utility.get_variable('DEL_FLAG');
      rcd_efex_order.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_order.valdtn_status := ods_constants.valdtn_unchecked;
      rcd_efex_order.efex_mkt_id := var_trn_market;
      var_trn_count := var_trn_count + 1;

      /*-------------------------------------*/
      /* DELETE - Delete any child materials */
      /*-------------------------------------*/

      delete from efex_order_matl where efex_order_id = rcd_efex_order.efex_order_id;

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

   /**************************************************/
   /* This procedure performs the record NTE routine */
   /**************************************************/
   procedure process_record_nte(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('NTE', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      rcd_efex_order.order_notes := rcd_efex_order.order_notes || lics_inbound_utility.get_variable('NTE_TEXT');

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
   end process_record_nte;

   /**************************************************/
   /* This procedure performs the record END routine */
   /**************************************************/
   procedure process_record_end(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('END', par_record);

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into efex_order values rcd_efex_order;
      exception
         when dup_val_on_index then
            update efex_order
               set purch_order_num = rcd_efex_order.purch_order_num,
                   order_notes = rcd_efex_order.order_notes,
                   order_date = rcd_efex_order.order_date,
                   order_code = rcd_efex_order.order_code,
                   efex_cust_id = rcd_efex_order.efex_cust_id,
                   sales_terr_id = rcd_efex_order.sales_terr_id,
                   sgmnt_id = rcd_efex_order.sgmnt_id,
                   bus_unit_id = rcd_efex_order.bus_unit_id,
                   cust_contact_id = rcd_efex_order.cust_contact_id,
                   cust_contact = rcd_efex_order.cust_contact,
                   order_distbr_id = rcd_efex_order.order_distbr_id,
                   user_id = rcd_efex_order.user_id,
                   dlvry_date = rcd_efex_order.dlvry_date,
                   tot_matls = rcd_efex_order.tot_matls,
                   tot_price = rcd_efex_order.tot_price,
                   confirm_flg = rcd_efex_order.confirm_flg,
                   order_status = rcd_efex_order.order_status,
                   tp_amt = rcd_efex_order.tp_amt,
                   tp_paid_flg = rcd_efex_order.tp_paid_flg,
                   dlvrd_flg = rcd_efex_order.dlvrd_flg,
                   status = rcd_efex_order.status,
                   valdtn_status = rcd_efex_order.valdtn_status,
                   efex_mkt_id = rcd_efex_order.efex_mkt_id
             where efex_order_id = rcd_efex_order.efex_order_id;
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
   end process_record_end;

   /**************************************************/
   /* This procedure performs the record ITM routine */
   /**************************************************/
   procedure process_record_itm(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('ITM', par_record);
      rcd_efex_order_matl.efex_order_id := lics_inbound_utility.get_number('ORD_ID',null);
      rcd_efex_order_matl.efex_matl_id := lics_inbound_utility.get_number('ITM_ID',null);
      rcd_efex_order_matl.order_qty := lics_inbound_utility.get_number('ORD_QTY',null);
      rcd_efex_order_matl.alloc_qty := lics_inbound_utility.get_number('ALC_QTY',null);
      rcd_efex_order_matl.uom := lics_inbound_utility.get_variable('UOM_CODE');
      rcd_efex_order_matl.matl_distbr_id := lics_inbound_utility.get_number('DIS_ID',null);
      rcd_efex_order_matl.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_order_matl.valdtn_status := ods_constants.valdtn_unchecked;
      rcd_efex_order_matl.efex_mkt_id := var_trn_market;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into efex_order_matl values rcd_efex_order_matl;
      exception
         when dup_val_on_index then
            update efex_order_matl
               set order_qty = rcd_efex_order_matl.order_qty,
                   alloc_qty = rcd_efex_order_matl.alloc_qty,
                   uom = rcd_efex_order_matl.uom,
                   matl_distbr_id = rcd_efex_order_matl.matl_distbr_id,
                   status = rcd_efex_order_matl.status,
                   valdtn_status = rcd_efex_order_matl.valdtn_status,
                   efex_mkt_id = rcd_efex_order_matl.efex_mkt_id
             where efex_order_id = rcd_efex_order_matl.efex_order_id
               and efex_matl_id = rcd_efex_order_matl.efex_matl_id;
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
   end process_record_itm;

end efxcdw24_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw24_loader for ods_app.efxcdw24_loader;
grant execute on ods_app.efxcdw24_loader to lics_app;
