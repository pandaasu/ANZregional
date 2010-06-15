/******************/
/* Package Header */
/******************/
create or replace package ods_app.efxcdw10_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw10_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex Item Data - EFEX to CDW

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

end efxcdw10_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.efxcdw10_loader as

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
   rcd_efex_matl efex_matl%rowtype;

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
      lics_inbound_utility.set_definition('CTL','INT_ID',10);
      lics_inbound_utility.set_definition('CTL','MKT_ID',10);
      lics_inbound_utility.set_definition('CTL','EXT_ID',14);
      /*-*/
      lics_inbound_utility.set_definition('HDR','RCD_ID',3);
      lics_inbound_utility.set_definition('HDR','ITM_ID',10);
      lics_inbound_utility.set_definition('HDR','ITM_CODE',50);
      lics_inbound_utility.set_definition('HDR','ITM_NAME',50);
      lics_inbound_utility.set_definition('HDR','RANK',10);
      lics_inbound_utility.set_definition('HDR','CAS_LAYER',15);
      lics_inbound_utility.set_definition('HDR','LAY_PALLET',15);
      lics_inbound_utility.set_definition('HDR','UNT_CASE',15);
      lics_inbound_utility.set_definition('HDR','UNT_MEASURE',50);
      lics_inbound_utility.set_definition('HDR','TDU_PRICE',15);
      lics_inbound_utility.set_definition('HDR','RRP_PRICE',15);
      lics_inbound_utility.set_definition('HDR','MCU_PRICE',15);
      lics_inbound_utility.set_definition('HDR','RSU_PRICE',15);
      lics_inbound_utility.set_definition('HDR','MIN_ORDQTY',15);
      lics_inbound_utility.set_definition('HDR','ORD_MULTIPLE',15);
      lics_inbound_utility.set_definition('HDR','TOP_FLAG',1);
      lics_inbound_utility.set_definition('HDR','IMP_FLAG',1);
      lics_inbound_utility.set_definition('HDR','ITS_ID',10);
      lics_inbound_utility.set_definition('HDR','POS_FLAG',1);
      lics_inbound_utility.set_definition('HDR','STATUS',1);

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

      rcd_efex_matl.efex_matl_id := lics_inbound_utility.get_number('ITM_ID',null);
      rcd_efex_matl.efex_matl_code := lics_inbound_utility.get_variable('ITM_CODE');
      rcd_efex_matl.matl_name := lics_inbound_utility.get_variable('ITM_NAME');
      rcd_efex_matl.rank := lics_inbound_utility.get_variable('RANK');
      rcd_efex_matl.cases_layer := lics_inbound_utility.get_number('CAS_LAYER',null);
      rcd_efex_matl.layers_pallet := lics_inbound_utility.get_number('LAY_PALLET',null);
      rcd_efex_matl.units_case := lics_inbound_utility.get_number('UNT_CASE',null);
      rcd_efex_matl.unit_measure := lics_inbound_utility.get_variable('UNT_MEASURE');
      rcd_efex_matl.tdu_price := lics_inbound_utility.get_number('TDU_PRICE',null);
      rcd_efex_matl.rrp_price := lics_inbound_utility.get_number('RRP_PRICE',null);
      rcd_efex_matl.mcu_price := lics_inbound_utility.get_number('MCU_PRIC',null);
      rcd_efex_matl.rsu_price := lics_inbound_utility.get_number('RSU_PRICE',null);
      rcd_efex_matl.min_order_qty := lics_inbound_utility.get_number('MIN_ORDQTY',null);
      rcd_efex_matl.order_multiples := lics_inbound_utility.get_number('ORD_MULTIPLE',null);
      rcd_efex_matl.topseller_flg := lics_inbound_utility.get_variable('TOP_FLAG');
      rcd_efex_matl.import_flg := lics_inbound_utility.get_variable('IMP_FLAG');
      rcd_efex_matl.matl_source_id := lics_inbound_utility.get_number('ITS_ID',null);
      rcd_efex_matl.pos_matl_flg := lics_inbound_utility.get_variable('POS_FLAG');
      rcd_efex_matl.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_matl.valdtn_status := ods_constants.valdtn_valid;
      var_trn_count := var_trn_count + 1;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into efex_matl values rcd_efex_matl;
      exception
         when dup_val_on_index then
            update efex_matl
               set matl_name = rcd_efex_matl.matl_name,
                   rank = rcd_efex_matl.rank,
                   cases_layer = rcd_efex_matl.cases_layer,
                   layers_pallet = rcd_efex_matl.layers_pallet,
                   units_case = rcd_efex_matl.units_case,
                   unit_measure = rcd_efex_matl.unit_measure,
                   tdu_price = rcd_efex_matl.tdu_price,
                   rrp_price = rcd_efex_matl.rrp_price,
                   mcu_price = rcd_efex_matl.mcu_price,
                   rsu_price = rcd_efex_matl.rsu_price,
                   min_order_qty = rcd_efex_matl.min_order_qty,
                   order_multiples = rcd_efex_matl.order_multiples,
                   topseller_flg = rcd_efex_matl.topseller_flg,
                   import_flg = rcd_efex_matl.import_flg,
                   matl_source_id = rcd_efex_matl.matl_source_id,
                   pos_matl_flg = rcd_efex_matl.pos_matl_flg,
                   status = rcd_efex_matl.status,
                   valdtn_status = rcd_efex_matl.valdtn_status
             where efex_matl_id = rcd_efex_matl.efex_matl_id;
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

end efxcdw10_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw10_loader for ods_app.efxcdw10_loader;
grant execute on ods_app.efxcdw10_loader to lics_app;
