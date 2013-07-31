create or replace 
package body          pmxpxi02_loader as

/*******************************************************************************
  Interface Field Definitions
*******************************************************************************/  
  pc_ic_record_type fflu_common.st_name := 'IC Record Type';
  pc_px_company_code fflu_common.st_name := 'PX Company Code';
  pc_px_division_code fflu_common.st_name := 'PX Division Code';
  pc_type fflu_common.st_name := 'Type';
  pc_document_date fflu_common.st_name := 'Document Date';
  pc_posting_date fflu_common.st_name := 'Posting Date';
  pc_claim_date fflu_common.st_name := 'Claim Date';
  pc_reference fflu_common.st_name := 'Reference';
  pc_document_header_text fflu_common.st_name := 'Document Header Text';
  pc_expenditure_type fflu_common.st_name := 'Expenditure Type';
  pc_posting_key fflu_common.st_name := 'Posting Key';
  pc_account_code fflu_common.st_name := 'Account Code';
  pc_amount fflu_common.st_name := 'Amount';
  pc_spend_amount fflu_common.st_name := 'Spend Amount';
  pc_tax_amount fflu_common.st_name := 'Tax Amount';
  pc_payment_method fflu_common.st_name := 'Payment Method';
  pc_allocation fflu_common.st_name := 'Allocation';
  pc_pc_reference fflu_common.st_name := 'PC Reference';
  pc_px_reference fflu_common.st_name := 'PX Reference';
  pc_ext_reference fflu_common.st_name := 'Ext Reference';
  pc_product_number fflu_common.st_name := 'Product Number';
  pc_transaction_code fflu_common.st_name := 'Transaction Code';
  pc_deduction_ac_code fflu_common.st_name := 'Deduction AC Code';
  pc_payee_code fflu_common.st_name := 'Payee Code';
  pc_customer_is_a_vendor fflu_common.st_name := 'Customer Is A Vendor';
  pc_currency fflu_common.st_name := 'Currency';
  pc_promo_claim_detail_row_id fflu_common.st_name := 'Promo Claim Detail Row ID';
  pc_promo_claim_group_row_id fflu_common.st_name := 'Promo Claim Group Row ID';
  pc_promo_claim_group_pub_id fflu_common.st_name := 'Promo Claim Group Pub Id';
  pc_reason_code fflu_common.st_name := 'Reason Code';
  pc_pc_message fflu_common.st_name := 'PC Message';
  pc_pc_comment fflu_common.st_name := 'PC Comment';
  pc_text_1 fflu_common.st_name := 'Text 1';
  pc_text_2 fflu_common.st_name := 'Text 2';
  pc_buy_start_date fflu_common.st_name := 'Buy Start Date';
  pc_buy_stop_date fflu_common.st_name := 'Buy Stop Date';
  pc_bom_header_sku_stock_code fflu_common.st_name := 'BOM Header Sku Stock Code';

/*******************************************************************************
  Package Variables
*******************************************************************************/  

/*******************************************************************************
  NAME:      ON_START                                                     PUBLIC
*******************************************************************************/  
  procedure on_start is 
  begin
    -- Now initialise the data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,true,true);
    -- Now define the column structure
    fflu_data.add_char_field_txt(pc_ic_record_type,0,6,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_px_company_code,6,3,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_px_division_code,9,3,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_type,12,1,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_date_field_txt(pc_document_date,13,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_txt(pc_posting_date,21,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_txt(pc_claim_date,29,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_txt(pc_reference,37,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_document_header_text,47,25,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_expenditure_type,72,5,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_posting_key,77,7,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_account_code,84,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_number_field_txt(pc_amount,94,14,'99999999999.99',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_txt(pc_spend_amount,108,14,'99999999999.99',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_txt(pc_tax_amount,122,14,'99999999999.99',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_txt(pc_payment_method,136,1,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_allocation,137,12,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_pc_reference,149,18,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_px_reference,167,60,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_ext_reference,227,65,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_product_number,292,18,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_transaction_code,310,40,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_deduction_ac_code,350,20,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_payee_code,370,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_customer_is_a_vendor,380,1,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_currency,381,3,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_promo_claim_detail_row_id,384,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_promo_claim_group_row_id,394,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_promo_claim_group_pub_id,404,30,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_reason_code,434,5,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_pc_message,439,65,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_pc_comment,504,200,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_text_1,704,40,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_text_2,744,40,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_date_field_txt(pc_buy_start_date,784,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_txt(pc_buy_stop_date,792,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_txt(pc_bom_header_sku_stock_code,800,40,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
  exception 
    when others then 
      fflu_utils.log_interface_exception('On Start');
end on_start;

/*******************************************************************************
  NAME:      ON_START                                                     PUBLIC
*******************************************************************************/  
  procedure on_data(p_row in varchar2) is 
    v_ok boolean;
  begin
    if fflu_data.parse_data(p_row) = true then
        null;
    end if;
  exception 
    when others then 
      fflu_utils.log_interface_exception('On Data');
  end on_data;
  
/*******************************************************************************
  NAME:      ON_END                                                       PUBLIC
*******************************************************************************/  
  procedure on_end is 
  begin 
    -- Only perform a commit if there were no errors at all. 
    if fflu_data.was_errors = true then 
      rollback;
    else 
      commit;
    end if;
    -- Perform a final cleanup and a last progress logging.
    fflu_data.cleanup;
  exception 
    when others then 
      fflu_utils.log_interface_exception('On End');
  end on_end;

/*******************************************************************************
  NAME:      ON_GET_FILE_TYPE                                             PUBLIC
*******************************************************************************/  
  function on_get_file_type return varchar2 is 
  begin 
    return fflu_common.gc_file_type_fixed_width;
  end on_get_file_type;
  
/*******************************************************************************
  NAME:      ON_GET_CSV_QUALIFER                                          PUBLIC
*******************************************************************************/  
  function on_get_csv_qualifier return varchar2 is
  begin 
    return fflu_common.gc_csv_qualifier_null;
  end on_get_csv_qualifier;

-- Initialise this package.  
begin
  null;
end pmxpxi02_loader;


/** OLD CODE USE FOR REFERENCE ONLY

   var_trn_error boolean;
   var_trn_count number;

   rcd_pmx_payments pmx_payments%rowtype;
   
   var_trn_interface number;
   var_trn_user varchar2(20);
   
   procedure on_start is

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

   cursor csr_logon_usr is
      select sys_context('USERENV', 'OS_USER') as username 
      from dual;
   rcd_logon_usr csr_logon_usr%rowtype;

   
   begin

      var_trn_error := false;
      var_trn_count := 0;

	  var_trn_interface := 0;
	  var_trn_user := null;

	  
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
	  
      -- Obtain the logon name for bill_raw_hdr
      open csr_logon_usr;
      fetch csr_logon_usr into rcd_logon_usr;
        if csr_logon_usr%notfound then
           lics_inbound_utility.add_exception('Unable to retrieve user name - LAST_UPDTD_USER');
           var_trn_error := true;
        else
           var_trn_user := rcd_logon_usr.username;
        end if;
      close csr_logon_usr;
   end on_start;

   procedure on_data(par_record in varchar2) is

      var_record_identifier varchar2(3);
      
      var_result number;
      var_matl_tdu_code nvarchar2(20);
      var_division_code nvarchar2(20);
      var_plant_code nvarchar2(20);
      var_distbn_chnl_code nvarchar2(20);

   begin


      lics_inbound_utility.parse_record('DTL', par_record);

	  
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
	  
      -- Lookup Functions 
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

	  insert into pmx_payments values rcd_pmx_payments;
*/