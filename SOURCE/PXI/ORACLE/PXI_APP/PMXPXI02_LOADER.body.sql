create or replace 
package body          pmxpxi02_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   --procedure process_record_ctl(par_record in varchar2);
   --procedure process_record_hdr(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   var_trn_count number;

   rcd_pmx_payments pmx_payments%rowtype;
   
   var_trn_interface number;
   var_trn_user varchar2(20);
   

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-*/
   /* Lookup Interface Number - pmx_payments
   /*-*/ --TODO - Cleanup with actual interface number lookup.
   cursor csr_interface_num is
	select max(int_num) as int_num
	from
	( 
		select max(int_id) as int_num
		from pmx_payments
		union
		select 0 as int_num from dual
	);
   rcd_interface_num csr_interface_num%rowtype;

   /*-*/
   /* Lookup Current User
   /*-*/   
   cursor csr_logon_usr is
      select sys_context('USERENV', 'OS_USER') as username 
      from dual;
   rcd_logon_usr csr_logon_usr%rowtype;

   
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the transaction variables
      /*-*/
      var_trn_error := false;
      var_trn_count := 0;

	  var_trn_interface := 0;
	  var_trn_user := null;

	  
	  /*-*/
      /* Obtain the interface number
      /*-*/ -- TODO
	  open csr_interface_num;
      fetch csr_interface_num into rcd_interface_num;
        if csr_interface_num%notfound then
           -- TODO
		   --lics_inbound_utility.add_exception('Unable to retrieve user name - LAST_UPDTD_USER');
           --var_trn_error := true;
		   var_trn_interface := 1;
        else
           var_trn_interface := rcd_interface_num.int_num+1;
        end if;
      close csr_interface_num;
	  
	  /*-*/
      /* Obtain the logon name for bill_raw_hdr
      /*-*/
      open csr_logon_usr;
      fetch csr_logon_usr into rcd_logon_usr;
        if csr_logon_usr%notfound then
           lics_inbound_utility.add_exception('Unable to retrieve user name - LAST_UPDTD_USER');
           var_trn_error := true;
        else
           var_trn_user := rcd_logon_usr.username;
        end if;
      close csr_logon_usr;
	  
	  
	  
      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
	  
      /*-*/
      lics_inbound_utility.set_definition('DTL','ICMESSAGE',6);
      lics_inbound_utility.set_definition('DTL','REC_TYPE',1);
      lics_inbound_utility.set_definition('DTL','DOC_DATE',8);
      lics_inbound_utility.set_definition('DTL','POSTING_DATE',8);
      lics_inbound_utility.set_definition('DTL','CLAIM_DATE',8);
      lics_inbound_utility.set_definition('DTL','REFERENCE',10);
      lics_inbound_utility.set_definition('DTL','DOC_HDR_TXT',25);
      lics_inbound_utility.set_definition('DTL','EXPENDITURE_TYPE',5);
      lics_inbound_utility.set_definition('DTL','POSTING_KEY',7);
      lics_inbound_utility.set_definition('DTL','ACCOUNT_CODE',10);
      lics_inbound_utility.set_definition('DTL','AMOUNT',14);
      lics_inbound_utility.set_definition('DTL','SPEND_AMOUNT',14);
      lics_inbound_utility.set_definition('DTL','TAX_AMOUNT',14);
      lics_inbound_utility.set_definition('DTL','PAYMENT_METHOD',1);
      lics_inbound_utility.set_definition('DTL','ALLOCATION',12);       
      lics_inbound_utility.set_definition('DTL','PC_REFERENCE',18);
      lics_inbound_utility.set_definition('DTL','PX_REFERENCE',60);
      lics_inbound_utility.set_definition('DTL','EXT_REFERENCE',65);
      lics_inbound_utility.set_definition('DTL','PRODUCT_NUM',18);
      lics_inbound_utility.set_definition('DTL','TRANSACTION_CODE',40);
      lics_inbound_utility.set_definition('DTL','DEDUCTION_AC_CODE',20); -- NOT IN TABLE -- IGNORE FIELD.
      lics_inbound_utility.set_definition('DTL','PAYEE_CODE',10);
      lics_inbound_utility.set_definition('DTL','CUSTOMER_IS_A_VENDOR',1);
      lics_inbound_utility.set_definition('DTL','CURRENCY',3);
      lics_inbound_utility.set_definition('DTL','PX_DIVISION_CODE',10);
      lics_inbound_utility.set_definition('DTL','PX_COMPANY_CODE',10);
      lics_inbound_utility.set_definition('DTL','PROMO_CLAIM_DETAIL_ROW_ID',10);
      lics_inbound_utility.set_definition('DTL','PROMO_CLAIM_GRP_ROW_ID',10);
      lics_inbound_utility.set_definition('DTL','PROMO_CLAIM_GRP_PUB_ID',30);
      lics_inbound_utility.set_definition('DTL','REASON_CODE',5);
      lics_inbound_utility.set_definition('DTL','PC_MESSAGE',65);
      lics_inbound_utility.set_definition('DTL','PC_COMMENT',200);
      lics_inbound_utility.set_definition('DTL','TEXT_1',40);
      lics_inbound_utility.set_definition('DTL','TEXT_2',40);
      lics_inbound_utility.set_definition('DTL','BUY_START_DATE',8);
      lics_inbound_utility.set_definition('DTL','BUY_STOP_DATE',8);
      lics_inbound_utility.set_definition('DTL','BOM_HEADER_SKU_DATE',40);


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
      
      var_result number;
      var_matl_tdu_code nvarchar2(20);
      var_division_code nvarchar2(20);
      var_plant_code nvarchar2(20);
      var_distbn_chnl_code nvarchar2(20);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('DTL', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/
	  
	  var_trn_count := var_trn_count + 1;
	  
	  rcd_pmx_payments.int_id := var_trn_interface; 
	  rcd_pmx_payments.line_num := var_trn_count;
	  
      -- IGNORE FIRST FIELD --lics_inbound_utility.get_variable('ICMESSAGE');
      rcd_pmx_payments.rec_type := lics_inbound_utility.get_variable('REC_TYPE');
      rcd_pmx_payments.doc_date := lics_inbound_utility.get_date('DOC_DATE', 'ddmmyyyy');
      rcd_pmx_payments.posting_date := lics_inbound_utility.get_date('POSTING_DATE', 'ddmmyyyy');
      rcd_pmx_payments.claim_date := lics_inbound_utility.get_date('CLAIM_DATE', 'ddmmyyyy');
      rcd_pmx_payments.reference := lics_inbound_utility.get_variable('REFERENCE');
      rcd_pmx_payments.doc_hdr_txt := lics_inbound_utility.get_variable('DOC_HDR_TXT');
      rcd_pmx_payments.expenditure_type := lics_inbound_utility.get_variable('EXPENDITURE_TYPE');
      rcd_pmx_payments.posting_key := lics_inbound_utility.get_variable('POSTING_KEY');
      rcd_pmx_payments.account_code := lics_inbound_utility.get_variable('ACCOUNT_CODE');
      rcd_pmx_payments.amount := lics_inbound_utility.get_variable('AMOUNT');
      rcd_pmx_payments.spend_amount := lics_inbound_utility.get_variable('SPEND_AMOUNT');
      rcd_pmx_payments.tax_amount := lics_inbound_utility.get_variable('TAX_AMOUNT');
      rcd_pmx_payments.payment_method := lics_inbound_utility.get_variable('PAYMENT_METHOD');
      rcd_pmx_payments.allocation := lics_inbound_utility.get_variable('ALLOCATION');
      rcd_pmx_payments.pc_reference := lics_inbound_utility.get_variable('PC_REFERENCE');
      rcd_pmx_payments.px_reference := lics_inbound_utility.get_variable('PX_REFERENCE');
      rcd_pmx_payments.ext_reference := lics_inbound_utility.get_variable('EXT_REFERENCE');
      rcd_pmx_payments.product_num := lics_inbound_utility.get_variable('PRODUCT_NUM');
      rcd_pmx_payments.transaction_code := lics_inbound_utility.get_variable('TRANSACTION_CODE');
      -- IGNORE FIELD --rcd_pmx_payments.deduction_ac_code := lics_inbound_utility.get_variable('DEDUCTION_AC_CODE');
      rcd_pmx_payments.deduction_ac_code := lics_inbound_utility.get_variable('PAYEE_CODE');
      rcd_pmx_payments.customer_is_a_vendor := lics_inbound_utility.get_variable('CUSTOMER_IS_A_VENDOR');
      rcd_pmx_payments.currency := lics_inbound_utility.get_variable('CURRENCY');
      rcd_pmx_payments.px_division_code := lics_inbound_utility.get_variable('PX_DIVISION_CODE');
      rcd_pmx_payments.px_company_code := lics_inbound_utility.get_variable('PX_COMPANY_CODE');
      rcd_pmx_payments.promo_claim_detail_row_id := lics_inbound_utility.get_variable('PROMO_CLAIM_DETAIL_ROW_ID');
      rcd_pmx_payments.promo_claim_grp_row_id := lics_inbound_utility.get_variable('PROMO_CLAIM_GRP_ROW_ID');
      rcd_pmx_payments.promo_claim_grp_pub_id := lics_inbound_utility.get_variable('PROMO_CLAIM_GRP_PUB_ID');
      rcd_pmx_payments.reason_code := lics_inbound_utility.get_variable('REASON_CODE');
      rcd_pmx_payments.pc_message := lics_inbound_utility.get_variable('PC_MESSAGE');
      rcd_pmx_payments.pc_comment := lics_inbound_utility.get_variable('PC_COMMENT');
      rcd_pmx_payments.text_1 := lics_inbound_utility.get_variable('TEXT_1');
      rcd_pmx_payments.text_2 := lics_inbound_utility.get_variable('TEXT_2');
      rcd_pmx_payments.buy_start_date := lics_inbound_utility.get_date('BUY_START_DATE', 'ddmmyyyy');
      rcd_pmx_payments.buy_stop_date := lics_inbound_utility.get_date('BUY_STOP_DATE', 'ddmmyyyy');
      rcd_pmx_payments.bom_header_sku_date := lics_inbound_utility.get_date('BOM_HEADER_SKU_DATE', 'ddmmyyyy');
	  
        
      /* these require lookup functions */
      
      var_result := pmx_interface_lookup.lookup_matl_tdu_num(rcd_pmx_payments.product_num, var_matl_tdu_code, rcd_pmx_payments.buy_start_date, rcd_pmx_payments.buy_stop_date);
      var_result := pmx_interface_lookup.lookup_division_code(rcd_pmx_payments.product_num, var_division_code);
      var_result := pmx_interface_lookup.lookup_plant_code(rcd_pmx_payments.product_num, var_plant_code);
      var_result := pmx_interface_lookup.lookup_distbn_chnl_code(rcd_pmx_payments.product_num, var_distbn_chnl_code);
      
      var_result := pmx_common.format_matl_code(var_matl_tdu_code, var_matl_tdu_code);
      
      rcd_pmx_payments.matl_tdu_code := var_matl_tdu_code;
      rcd_pmx_payments.bus_sgmnt := var_division_code;
      rcd_pmx_payments.plant_code := var_plant_code;
      rcd_pmx_payments.distbn_chnl_code := var_distbn_chnl_code;
      
      if (var_division_code = '01') then
        rcd_pmx_payments.profit_ctr_code := '0000110001';
      elsif (var_division_code = '02') then
        rcd_pmx_payments.profit_ctr_code := '0000110006';
      else  
        rcd_pmx_payments.profit_ctr_code := '0000110005';
      end if;
      
      
	  rcd_pmx_payments.last_updtd_user := var_trn_user;
	  rcd_pmx_payments.last_updtd_time := sysdate;


      /*-*/
      /* Exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
         return;
      end if;

      /*------------------------------*/
      /* INSERT - Update the database */
      /*------------------------------*/

	  insert into pmx_payments values rcd_pmx_payments;

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

end pmxpxi02_loader;