/******************/
/* Package Header */
/******************/
create or replace package ods_app.efxcdw25_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw25_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex Payment Data - EFEX to CDW

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

end efxcdw25_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.efxcdw25_loader as

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
   procedure process_record_deh(par_record in varchar2);
   procedure process_record_ded(par_record in varchar2);
   procedure process_record_det(par_record in varchar2);
   procedure process_record_reh(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   var_trn_count number;
   var_trn_interface varchar2(32);
   var_trn_market number;
   var_trn_extract varchar2(14);
   rcd_efex_pmt efex_pmt%rowtype;
   rcd_efex_pmt_deal efex_pmt_deal%rowtype;
   rcd_efex_pmt_rtn efex_pmt_rtn%rowtype;
   var_ret_claim varchar2(50);

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
      lics_inbound_utility.set_definition('HDR','PAY_ID',10);
      lics_inbound_utility.set_definition('HDR','CUS_ID',10);
      lics_inbound_utility.set_definition('HDR','STE_ID',10);
      lics_inbound_utility.set_definition('HDR','SEG_ID',10);
      lics_inbound_utility.set_definition('HDR','BUS_ID',10);
      lics_inbound_utility.set_definition('HDR','USR_ID',10);
      lics_inbound_utility.set_definition('HDR','PAY_DATE',14);
      lics_inbound_utility.set_definition('HDR','PAY_METHOD',50);
      lics_inbound_utility.set_definition('HDR','RLS_DATE',14);
      lics_inbound_utility.set_definition('HDR','PRC_FLAG',1);
      lics_inbound_utility.set_definition('HDR','CTR_REFNR',50);
      lics_inbound_utility.set_definition('HDR','CTR_STATUS',50);
      lics_inbound_utility.set_definition('HDR','CTR_PRC_DATE',14);
      lics_inbound_utility.set_definition('HDR','CTR_REP_DATE',14);
      lics_inbound_utility.set_definition('HDR','CTR_DEDUCTED',15);
      lics_inbound_utility.set_definition('HDR','RET_CLAIM',50);
      lics_inbound_utility.set_definition('HDR','STATUS',1);
      /*-*/
      lics_inbound_utility.set_definition('NTE','RCD_ID',3);
      lics_inbound_utility.set_definition('NTE','NTE_TEXT',2000);
      /*-*/
      lics_inbound_utility.set_definition('END','RCD_ID',3);
      /*-*/
      lics_inbound_utility.set_definition('DEH','RCD_ID',3);
      lics_inbound_utility.set_definition('DEH','PAY_ID',10);
      lics_inbound_utility.set_definition('DEH','SEQ_NUM',10);
      lics_inbound_utility.set_definition('DEH','ORD_ID',10);
      lics_inbound_utility.set_definition('DEH','DEA_VALUE',15);
      lics_inbound_utility.set_definition('DEH','STATUS',1);
      /*-*/
      lics_inbound_utility.set_definition('DED','RCD_ID',3);
      lics_inbound_utility.set_definition('DED','DET_TEXT',2000);
      /*-*/
      lics_inbound_utility.set_definition('DET','RCD_ID',3);
      /*-*/
      lics_inbound_utility.set_definition('REH','RCD_ID',3);
      lics_inbound_utility.set_definition('REH','PAY_ID',10);
      lics_inbound_utility.set_definition('REH','SEQ_NUM',10);
      lics_inbound_utility.set_definition('REH','ITM_ID',10);
      lics_inbound_utility.set_definition('REH','RET_REASON',50);
      lics_inbound_utility.set_definition('REH','RET_QTY',15);
      lics_inbound_utility.set_definition('REH','RET_VALUE',15);
      lics_inbound_utility.set_definition('REH','STATUS',1);

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
         when 'DEH' then process_record_deh(par_record);
         when 'DED' then process_record_ded(par_record);
         when 'DET' then process_record_det(par_record);
         when 'REH' then process_record_reh(par_record);
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

      rcd_efex_pmt.pmt_id := lics_inbound_utility.get_number('PAY_ID',null);
      rcd_efex_pmt.efex_cust_id := lics_inbound_utility.get_number('CUS_ID',null);
      rcd_efex_pmt.sales_terr_id := lics_inbound_utility.get_number('STE_ID',null);
      rcd_efex_pmt.sgmnt_id := lics_inbound_utility.get_number('SEG_ID',null);
      rcd_efex_pmt.bus_unit_id := lics_inbound_utility.get_number('BUS_ID',null);
      rcd_efex_pmt.user_id := lics_inbound_utility.get_number('USR_ID',null);
      rcd_efex_pmt.pmt_date := lics_inbound_utility.get_date('PAY_DATE','yyyymmddhh24miss');
      rcd_efex_pmt.pmt_method := lics_inbound_utility.get_variable('PAY_METHOD');
      rcd_efex_pmt.rlse_date := lics_inbound_utility.get_date('RLS_DATE','yyyymmddhh24miss');
      rcd_efex_pmt.procd_flg := lics_inbound_utility.get_variable('PRC_FLAG');
      rcd_efex_pmt.contra_pmt_ref := lics_inbound_utility.get_variable('CTR_REFNR');
      rcd_efex_pmt.pmt_notes := null;
      rcd_efex_pmt.contra_pmt_status := lics_inbound_utility.get_variable('CTR_STATUS');
      rcd_efex_pmt.contra_procd_date := lics_inbound_utility.get_date('CTR_PRC_DATE','yyyymmddhh24miss');
      rcd_efex_pmt.contra_replicated_date := lics_inbound_utility.get_date('CTR_REP_DATE','yyyymmddhh24miss');
      rcd_efex_pmt.contra_deducted := lics_inbound_utility.get_number('CTR_DEDUCTED',null);
      rcd_efex_pmt.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_pmt.valdtn_status := ods_constants.valdtn_unchecked;
      rcd_efex_pmt.efex_mkt_id := var_trn_market;
      var_ret_claim := lics_inbound_utility.get_variable('RET_CLAIM');
      var_trn_count := var_trn_count + 1;

      /*-*/
      /* Exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
         return;
      end if;

      /*--------------------------------*/
      /* DELETE - Delete any child rows */
      /*--------------------------------*/

      delete from efex_pmt_deal where pmt_id = rcd_efex_pmt.pmt_id;
      delete from efex_pmt_rtn where pmt_id = rcd_efex_pmt.pmt_id;

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

      rcd_efex_pmt.pmt_notes := rcd_efex_pmt.pmt_notes || lics_inbound_utility.get_variable('NTE_TEXT');

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
         insert into efex_pmt values rcd_efex_pmt;
      exception
         when dup_val_on_index then
            update efex_pmt
               set efex_cust_id = rcd_efex_pmt.efex_cust_id,
                   sales_terr_id = rcd_efex_pmt.sales_terr_id,
                   sgmnt_id = rcd_efex_pmt.sgmnt_id,
                   bus_unit_id = rcd_efex_pmt.bus_unit_id,
                   user_id = rcd_efex_pmt.user_id,
                   pmt_date = rcd_efex_pmt.pmt_date,
                   pmt_method = rcd_efex_pmt.pmt_method,
                   rlse_date = rcd_efex_pmt.rlse_date,
                   procd_flg = rcd_efex_pmt.procd_flg,
                   contra_pmt_ref = rcd_efex_pmt.contra_pmt_ref,
                   pmt_notes = rcd_efex_pmt.pmt_notes,
                   contra_pmt_status = rcd_efex_pmt.contra_pmt_status,
                   contra_procd_date = rcd_efex_pmt.contra_procd_date,
                   contra_replicated_date = rcd_efex_pmt.contra_replicated_date,
                   contra_deducted = rcd_efex_pmt.contra_deducted,
                   status = rcd_efex_pmt.status,
                   valdtn_status = rcd_efex_pmt.valdtn_status,
                   efex_mkt_id = rcd_efex_pmt.efex_mkt_id
             where pmt_id = rcd_efex_pmt.pmt_id;
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
   /* This procedure performs the record DEH routine */
   /**************************************************/
   procedure process_record_deh(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('DEH', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      rcd_efex_pmt_deal.pmt_id := lics_inbound_utility.get_number('PAY_ID',null);
      rcd_efex_pmt_deal.seq_num := lics_inbound_utility.get_number('SEQ_NUM',null);
      rcd_efex_pmt_deal.efex_order_id := lics_inbound_utility.get_number('ORD_ID',null);
      rcd_efex_pmt_deal.details := null;
      rcd_efex_pmt_deal.deal_value := lics_inbound_utility.get_number('DEA_VALUE',null);
      rcd_efex_pmt_deal.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_pmt_deal.valdtn_status := ods_constants.valdtn_unchecked;
      rcd_efex_pmt_deal.efex_mkt_id := var_trn_market;

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
   end process_record_deh;

   /**************************************************/
   /* This procedure performs the record DED routine */
   /**************************************************/
   procedure process_record_ded(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('DED', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      rcd_efex_pmt_deal.details := rcd_efex_pmt_deal.details || lics_inbound_utility.get_variable('DET_TEXT');

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
   end process_record_ded;

   /**************************************************/
   /* This procedure performs the record DET routine */
   /**************************************************/
   procedure process_record_det(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('DET', par_record);

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
         insert into efex_pmt_deal values rcd_efex_pmt_deal;
      exception
         when dup_val_on_index then
            update efex_pmt_deal
               set efex_order_id = rcd_efex_pmt_deal.efex_order_id,
                   details = rcd_efex_pmt_deal.details,
                   deal_value = rcd_efex_pmt_deal.deal_value,
                   status = rcd_efex_pmt_deal.status,
                   valdtn_status = rcd_efex_pmt_deal.valdtn_status,
                   efex_mkt_id = rcd_efex_pmt_deal.efex_mkt_id
             where pmt_id = rcd_efex_pmt_deal.pmt_id
               and seq_num = rcd_efex_pmt_deal.seq_num;
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
   end process_record_det;

   /**************************************************/
   /* This procedure performs the record REH routine */
   /**************************************************/
   procedure process_record_reh(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('REH', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      rcd_efex_pmt_rtn.pmt_id := lics_inbound_utility.get_number('PAY_ID',null);
      rcd_efex_pmt_rtn.seq_num := lics_inbound_utility.get_number('SEQ_NUM',null);
      rcd_efex_pmt_rtn.efex_matl_id := lics_inbound_utility.get_number('ITM_ID',null);
      rcd_efex_pmt_rtn.rtn_claim_code := var_ret_claim;
      rcd_efex_pmt_rtn.rtn_reason := lics_inbound_utility.get_variable('RET_REASON');
      rcd_efex_pmt_rtn.rtn_qty := lics_inbound_utility.get_number('RET_QTY',null);
      rcd_efex_pmt_rtn.rtn_value := lics_inbound_utility.get_number('RET_VALUE',null);
      rcd_efex_pmt_rtn.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_pmt_rtn.valdtn_status := ods_constants.valdtn_unchecked;
      rcd_efex_pmt_rtn.efex_mkt_id := var_trn_market;

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
         insert into efex_pmt_rtn values rcd_efex_pmt_rtn;
      exception
         when dup_val_on_index then
            update efex_pmt_rtn
               set efex_matl_id = rcd_efex_pmt_rtn.efex_matl_id,
                   rtn_claim_code = rcd_efex_pmt_rtn.rtn_claim_code,
                   rtn_reason = rcd_efex_pmt_rtn.rtn_reason,
                   rtn_qty = rcd_efex_pmt_rtn.rtn_qty,
                   rtn_value = rcd_efex_pmt_rtn.rtn_value,
                   status = rcd_efex_pmt_rtn.status,
                   valdtn_status = rcd_efex_pmt_rtn.valdtn_status,
                   efex_mkt_id = rcd_efex_pmt_rtn.efex_mkt_id
             where pmt_id = rcd_efex_pmt_rtn.pmt_id
               and seq_num = rcd_efex_pmt_rtn.seq_num;
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
   end process_record_reh;

end efxcdw25_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw25_loader for ods_app.efxcdw25_loader;
grant execute on ods_app.efxcdw25_loader to lics_app;
