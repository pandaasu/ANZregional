create or replace 
package body          pmxlad01_loader as

/*******************************************************************************
  Interface Field Definitions
*******************************************************************************/  
  pc_ic_record_type fflu_common.st_name := 'IC Record Type';
pc_px_company_code fflu_common.st_name := 'PX Company Code';
pc_px_division_code fflu_common.st_name := 'PX Division Code';
pc_rec_type fflu_common.st_name := 'Rec Type';
pc_document_date fflu_common.st_name := 'Document Date';
pc_posting_date fflu_common.st_name := 'Posting Date';
pc_document_type fflu_common.st_name := 'Document Type';
pc_currency fflu_common.st_name := 'Currency';
pc_reference fflu_common.st_name := 'Reference';
pc_document_header_text fflu_common.st_name := 'Document Header Text';
pc_posting_key fflu_common.st_name := 'Posting Key';
pc_account fflu_common.st_name := 'Account';
pc_pa_assignment_flag fflu_common.st_name := 'PA Assignment Flag';
pc_amount fflu_common.st_name := 'Amount';
pc_payment_method fflu_common.st_name := 'Payment Method';
pc_allocation fflu_common.st_name := 'Allocation';
pc_text fflu_common.st_name := 'Text';
pc_profit_centre fflu_common.st_name := 'Profit Centre';
pc_cost_centre fflu_common.st_name := 'cost Centre';
pc_sales_organisation fflu_common.st_name := 'Sales Organisation';
pc_sales_office fflu_common.st_name := 'Sales Office';
pc_product_number fflu_common.st_name := 'Product Number';
pc_pa_code fflu_common.st_name := 'PA Code';
pc_glt_row_id fflu_common.st_name := 'GLT Row Id';
pc_user_1 fflu_common.st_name := 'User 1';
pc_user_2 fflu_common.st_name := 'User 2';
pc_buy_start_date fflu_common.st_name := 'Buy Start Date';
pc_buy_stop_date fflu_common.st_name := 'Buy Stop Date';
pc_start_date fflu_common.st_name := 'Start Date';
pc_stop_date fflu_common.st_name := 'Stop Date';
pc_quantity fflu_common.st_name := 'Quantity';
pc_additional_info fflu_common.st_name := 'Additional Info';
pc_promotio_is_closed fflu_common.st_name := 'Promotio Is Closed';


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
    fflu_data.add_char_field_txt(pc_ic_record_type,0,6,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_not_trim);
fflu_data.add_char_field_txt(pc_px_company_code,6,3,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_not_trim);
fflu_data.add_char_field_txt(pc_px_division_code,9,3,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_not_trim);
fflu_data.add_char_field_txt(pc_rec_type,12,1,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_not_trim);
fflu_data.add_date_field_txt(pc_document_date,13,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
fflu_data.add_date_field_txt(pc_posting_date,21,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
fflu_data.add_char_field_txt(pc_document_type,29,2,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_not_trim);
fflu_data.add_char_field_txt(pc_currency,31,3,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
fflu_data.add_char_field_txt(pc_reference,34,16,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
fflu_data.add_char_field_txt(pc_document_header_text,50,25,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
fflu_data.add_char_field_txt(pc_posting_key,75,4,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
fflu_data.add_char_field_txt(pc_account,79,17,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
fflu_data.add_char_field_txt(pc_pa_assignment_flag,96,1,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
fflu_data.add_number_field_txt(pc_amount,97,13,'9999999999.99',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
fflu_data.add_char_field_txt(pc_payment_method,110,1,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
fflu_data.add_char_field_txt(pc_allocation,111,18,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
fflu_data.add_char_field_txt(pc_text,129,30,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
fflu_data.add_char_field_txt(pc_profit_centre,159,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
fflu_data.add_char_field_txt(pc_cost_centre,169,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
fflu_data.add_char_field_txt(pc_sales_organisation,179,4,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
fflu_data.add_char_field_txt(pc_sales_office,183,5,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
fflu_data.add_char_field_txt(pc_product_number,188,18,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
fflu_data.add_char_field_txt(pc_pa_code,206,5,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
fflu_data.add_char_field_txt(pc_glt_row_id,211,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
fflu_data.add_char_field_txt(pc_user_1,221,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
fflu_data.add_char_field_txt(pc_user_2,231,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
fflu_data.add_date_field_txt(pc_buy_start_date,241,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
fflu_data.add_date_field_txt(pc_buy_stop_date,249,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
fflu_data.add_date_field_txt(pc_start_date,257,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
fflu_data.add_date_field_txt(pc_stop_date,265,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
fflu_data.add_char_field_txt(pc_quantity,273,15,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
fflu_data.add_char_field_txt(pc_additional_info,288,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
fflu_data.add_char_field_txt(pc_promotio_is_closed,298,1,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
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
end pmxlad01_loader;

/*
   -- Private definitions
   var_trn_error boolean;
   var_trn_count number;
   --var_trn_interface varchar2(32);
   --var_trn_market number;
   --var_trn_extract varchar2(14);
   rcd_pmx_accrls pmx_accrls%rowtype;
   
   var_trn_interface number;
   var_trn_user varchar2(20);
   

   procedure on_start is

   -- Lookup Interface Number - pmx_accrls
   cursor csr_interface_num is
    select max(int_num) as int_num
    from
    ( 
        select max(int_id) as int_num
        from pmx_accrls
        union
        select 0 as int_num from dual
    );
   rcd_interface_num csr_interface_num%rowtype;

   -- Lookup Current User
   cursor csr_logon_usr is
      select sys_context('USERENV', 'OS_USER') as username 
      from dual;
   rcd_logon_usr csr_logon_usr%rowtype;

   
   -- Begin block.
   begin

      -- Initialise the transaction variables
      var_trn_error := false;
      var_trn_count := 0;
      --var_trn_interface := null;
      --var_trn_market := 0;
      --var_trn_extract := null;
      var_trn_interface := 0;
      var_trn_user := null;

      
      -- Obtain the interface number
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
      
      -- Initialise the inbound definitions
      lics_inbound_utility.clear_definition;

      lics_inbound_utility.set_definition('DTL','IC_REC_TYPE',6);
      lics_inbound_utility.set_definition('DTL','REC_TYPE',1);
      lics_inbound_utility.set_definition('DTL','DOC_DATE',8);
      lics_inbound_utility.set_definition('DTL','POSTING_DATE',8);
      lics_inbound_utility.set_definition('DTL','DOC_TYPE',2);
      lics_inbound_utility.set_definition('DTL','PX_CMPNY_CODE',10);
      lics_inbound_utility.set_definition('DTL','CURRENCY',5);
      lics_inbound_utility.set_definition('DTL','REFERENCE',16);
      lics_inbound_utility.set_definition('DTL','DOC_HDR_TXT',25);
      lics_inbound_utility.set_definition('DTL','POSTING_KEY',4);
      lics_inbound_utility.set_definition('DTL','ACCOUNT',17);
      lics_inbound_utility.set_definition('DTL','PA_ASSIGNMENT_FLAG',1);
      lics_inbound_utility.set_definition('DTL','AMOUNT',13);
      lics_inbound_utility.set_definition('DTL','PAYMENT_METHOD',1);
      lics_inbound_utility.set_definition('DTL','ALLOCATION',18);
      lics_inbound_utility.set_definition('DTL','TEXT',30);
      lics_inbound_utility.set_definition('DTL','PROFIT_CENTRE',10);
      lics_inbound_utility.set_definition('DTL','COST_CENTRE',10);
      lics_inbound_utility.set_definition('DTL','SALES_ORG',4);
      lics_inbound_utility.set_definition('DTL','SALES_OFFICE',5);
      lics_inbound_utility.set_definition('DTL','PRODUCT_NUMBER',18);
      lics_inbound_utility.set_definition('DTL','PA_CODE',5);
      lics_inbound_utility.set_definition('DTL','GLT_ROW_ID',10);
      lics_inbound_utility.set_definition('DTL','USER_1',10);
      lics_inbound_utility.set_definition('DTL','USER_2',10);
      lics_inbound_utility.set_definition('DTL','BUY_START_DATE',8);
      lics_inbound_utility.set_definition('DTL','BUY_STOP_DATE',8);
      lics_inbound_utility.set_definition('DTL','START_DATE',8);
      lics_inbound_utility.set_definition('DTL','STOP_DATE',8);
      lics_inbound_utility.set_definition('DTL','QTY',15);
      lics_inbound_utility.set_definition('DTL','ADDITIONAL_INFO',10);
      lics_inbound_utility.set_definition('DTL','PROM_IS_CLOSED',1);
      lics_inbound_utility.set_definition('DTL','PX_DIVISION_CODE',10);
      --lics_inbound_utility.set_definition('DTL','PX_COMPANY_CODE',10);        -- CONFIRM IF FIELD WILL BE ADDED. Commented out below
   end on_start;

   procedure on_data(par_record in varchar2) is
      -- Local definitions
      var_record_identifier varchar2(3);
      
      var_result number;
      var_matl_tdu_code nvarchar2(20);
      var_division_code nvarchar2(20);
      var_plant_code nvarchar2(20);
      var_distbn_chnl_code nvarchar2(20);

   begin

      lics_inbound_utility.parse_record('DTL', par_record);

      var_trn_count := var_trn_count + 1;
      
      rcd_pmx_accrls.int_id := var_trn_interface; 
      rcd_pmx_accrls.line_num := var_trn_count;
      
      -- IGNORE FIRST FIELD --lics_inbound_utility.get_variable('IC_REC_TYPE');
      rcd_pmx_accrls.rec_type :=lics_inbound_utility.get_variable('REC_TYPE');
      rcd_pmx_accrls.doc_date := lics_inbound_utility.get_date('DOC_DATE', 'ddmmyyyy');
      rcd_pmx_accrls.posting_date := lics_inbound_utility.get_date('POSTING_DATE', 'ddmmyyyy');
      rcd_pmx_accrls.doc_type := lics_inbound_utility.get_variable('DOC_TYPE');
      rcd_pmx_accrls.px_cmpny_code := lics_inbound_utility.get_variable('PX_CMPNY_CODE');
      rcd_pmx_accrls.currency := lics_inbound_utility.get_variable('CURRENCY');
      rcd_pmx_accrls.reference := lics_inbound_utility.get_variable('REFERENCE');
      rcd_pmx_accrls.doc_hdr_txt := lics_inbound_utility.get_variable('DOC_HDR_TXT');
      rcd_pmx_accrls.posting_key := lics_inbound_utility.get_variable('POSTING_KEY');
      rcd_pmx_accrls.account := lics_inbound_utility.get_variable('ACCOUNT');
      rcd_pmx_accrls.pa_assignment_flag := lics_inbound_utility.get_variable('PA_ASSIGNMENT_FLAG');
      rcd_pmx_accrls.amount := lics_inbound_utility.get_number('AMOUNT', '999999999999.99');
      rcd_pmx_accrls.payment_method := lics_inbound_utility.get_variable('PAYMENT_METHOD');
      rcd_pmx_accrls.allocation := lics_inbound_utility.get_variable('ALLOCATION');
      rcd_pmx_accrls.text := lics_inbound_utility.get_variable('TEXT');
      rcd_pmx_accrls.profit_centre := lics_inbound_utility.get_variable('PROFIT_CENTRE');
      rcd_pmx_accrls.cost_centre := lics_inbound_utility.get_variable('COST_CENTRE');
      rcd_pmx_accrls.sales_org := lics_inbound_utility.get_variable('SALES_ORG');
      rcd_pmx_accrls.sales_office := lics_inbound_utility.get_variable('SALES_OFFICE');
      rcd_pmx_accrls.product_number := lics_inbound_utility.get_variable('PRODUCT_NUMBER');
      rcd_pmx_accrls.pa_code := lics_inbound_utility.get_variable('PA_CODE');
      rcd_pmx_accrls.glt_row_id := lics_inbound_utility.get_variable('GLT_ROW_ID');
      rcd_pmx_accrls.user_1 := lics_inbound_utility.get_variable('USER_1');
      rcd_pmx_accrls.user_2 := lics_inbound_utility.get_variable('USER_2');
      rcd_pmx_accrls.buy_start_date := lics_inbound_utility.get_date('BUY_START_DATE', 'ddmmyyyy');
      rcd_pmx_accrls.buy_stop_date := lics_inbound_utility.get_date('BUY_STOP_DATE', 'ddmmyyyy');
      rcd_pmx_accrls.start_date := lics_inbound_utility.get_date('START_DATE', 'ddmmyyyy');
      rcd_pmx_accrls.stop_date := lics_inbound_utility.get_date('STOP_DATE', 'ddmmyyyy');
      rcd_pmx_accrls.qty := lics_inbound_utility.get_variable('QTY');
      rcd_pmx_accrls.additional_info := lics_inbound_utility.get_variable('ADDITIONAL_INFO');
      rcd_pmx_accrls.prom_is_closed := lics_inbound_utility.get_variable('PROM_IS_CLOSED');
      rcd_pmx_accrls.px_division_code := lics_inbound_utility.get_variable('PX_DIVISION_CODE');
      rcd_pmx_accrls.px_company_code := null; --lics_inbound_utility.get_variable('PX_COMPANY_CODE');        -- CONFIRM ABOVE
      
      var_result := pmx_interface_lookup.lookup_matl_tdu_num(rcd_pmx_accrls.product_number, var_matl_tdu_code, rcd_pmx_accrls.buy_start_date, rcd_pmx_accrls.buy_stop_date);
      --var_result := pmx_interface_lookup.lookup_division_code(rcd_pmx_accrls.product_number, var_division_code);
      var_result := pmx_interface_lookup.lookup_division_code(var_matl_tdu_code, var_division_code);
      var_result := pmx_interface_lookup.lookup_plant_code(rcd_pmx_accrls.product_number, var_plant_code);
      var_result := pmx_interface_lookup.lookup_distbn_chnl_code(rcd_pmx_accrls.product_number, var_distbn_chnl_code);
      
	  var_result := pmx_common.format_matl_code(var_matl_tdu_code, var_matl_tdu_code);
	  
      rcd_pmx_accrls.matl_tdu_code := var_matl_tdu_code;
      rcd_pmx_accrls.bus_sgmnt := var_division_code;
      rcd_pmx_accrls.plant_code := var_plant_code;
      rcd_pmx_accrls.distbn_chnl_code := var_distbn_chnl_code;
      
      if (var_division_code = '01') then
        rcd_pmx_accrls.profit_ctr_code := '0000110001';
      elsif (var_division_code = '02') then
        rcd_pmx_accrls.profit_ctr_code := '0000110006';
      else  
        rcd_pmx_accrls.profit_ctr_code := '0000110005';
      end if;
      
      
      -- these are hard coded for now based on the values from the PDS (Promax) logic
      rcd_pmx_accrls.gl_tax_code := 'GL';
      rcd_pmx_accrls.cust_vndr_code := ' ';
      rcd_pmx_accrls.int_claim_num := 0;
      
      rcd_pmx_accrls.last_updtd_user := var_trn_user;
      rcd_pmx_accrls.last_updtd_time := sysdate;


      -- Exceptions raised
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
         return;
      end if;

      insert into pmx_accrls values rcd_pmx_accrls;

*/
