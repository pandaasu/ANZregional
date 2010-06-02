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
    2009/05   Steve Gregan   Created

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

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
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
         commit;
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

      rcd_efex_pmt.pmt_id := lics_inbound_utility.get_number('PAY_ID');
      rcd_efex_pmt.efex_cust_id := lics_inbound_utility.get_number('CUS_ID');
      rcd_efex_pmt.sales_terr_id := lics_inbound_utility.get_number('STE_ID');
      rcd_efex_pmt.sgmnt_id := lics_inbound_utility.get_number('SEG_ID');
      rcd_efex_pmt.bus_unit_id := lics_inbound_utility.get_number('BUS_ID');
      rcd_efex_pmt.user_id := lics_inbound_utility.get_number('USR_ID');
      rcd_efex_pmt.pmt_date := lics_inbound_utility.get_date('PAY_DATE','yyyymmddhh24miss');
      rcd_efex_pmt.pmt_method := lics_inbound_utility.get_variable('PAY_METHOD');
      rcd_efex_pmt.rlse_date := lics_inbound_utility.get_date('RLS_DATE','yyyymmddhh24miss');
      rcd_efex_pmt.procd_flg := lics_inbound_utility.get_variable('PRC_FLAG');
      rcd_efex_pmt.contra_pmt_ref := lics_inbound_utility.get_variable('CTR_REFNR');
      rcd_efex_pmt.pmt_notes := null;
      rcd_efex_pmt.contra_pmt_status := lics_inbound_utility.get_variable('CTR_STATUS');
      rcd_efex_pmt.contra_procd_date := lics_inbound_utility.get_date('CTR_PRC_DATE','yyyymmddhh24miss');
      rcd_efex_pmt.contra_replicated_date := lics_inbound_utility.get_date('CTR_REP_DATE','yyyymmddhh24miss');
      rcd_efex_pmt.contra_deducted := lics_inbound_utility.get_number('CTR_DEDUCTED');
      rcd_efex_pmt.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_pmt.valdtn_status := ods_constants.valdtn_unchecked;
      var_ret_claim := lics_inbound_utility.get_variable('RET_CLAIM');

      /*--------------------------------*/
      /* DELETE - Delete any child rows */
      /*--------------------------------*/

      delete from efex_pmt_deal where efex_pmt_id = rcd_efex_pmt.efex_pmt_id;
      delete from efex_pmt_rtn where efex_pmt_id = rcd_efex_pmt.efex_pmt_id;

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

      rcd_efex_pmt.order_notes := rcd_efex_pmt.order_notes || lics_inbound_utility.get_variable('NTE_TEXT');

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
                   valdtn_status = rcd_efex_pmt.valdtn_status
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

      rcd_efex_pmt_deal.pmt_id := lics_inbound_utility.get_number('PAY_ID');
      rcd_efex_pmt_deal.seq_num := lics_inbound_utility.get_number('SEQ_NUM');
      rcd_efex_pmt_deal.efex_order_id := lics_inbound_utility.get_number('ORD_ID');
      rcd_efex_pmt_deal.details := null;
      rcd_efex_pmt_deal.deal_value := lics_inbound_utility.get_number('DEA_VALUE');
      rcd_efex_pmt_deal.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_pmt_deal.valdtn_status := ods_constants.valdtn_unchecked;

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
                   valdtn_status = rcd_efex_pmt_deal.valdtn_status
             where efex_pmt_id = rcd_efex_pmt_deal.efex_pmt_id
               and efex_seq_num = rcd_efex_pmt_deal.seq_num;
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

      rcd_efex_pmt_rtn.pmt_id := lics_inbound_utility.get_number('PAY_ID');
      rcd_efex_pmt_rtn.seq_num := lics_inbound_utility.get_number('SEQ_NUM');
      rcd_efex_pmt_rtn.efex_matl_id := lics_inbound_utility.get_number('ITM_ID');
      rcd_efex_pmt_rtn.rtn_claim_code := var_ret_claim;
      rcd_efex_pmt_rtn.rtn_reason := lics_inbound_utility.get_variable('RET_REASON');
      rcd_efex_pmt_rtn.rtn_qty := lics_inbound_utility.get_number('RET_QTY');
      rcd_efex_pmt_rtn.rtn_value := lics_inbound_utility.get_number('RET_VALUE');
      rcd_efex_pmt_rtn.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_pmt_rtn.valdtn_status := ods_constants.valdtn_unchecked;

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
                   valdtn_status = rcd_efex_pmt_rtn.valdtn_status
             where efex_pmt_id = rcd_efex_pmt_rtn.efex_pmt_id
               and efex_seq_num = rcd_efex_pmt_rtn.seq_num;
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
