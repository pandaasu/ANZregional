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
  pc_promotion_is_closed fflu_common.st_name := 'Promotio Is Closed';

  -- Posting Key
  subtype st_posting_key is varchar2(4);
  pc_posting_key_dr st_posting_key := 'DR';    -- Debit   Positive
  pc_posting_key_cr st_posting_key := 'CR';    -- Credit  Negative
  pc_posting_key_wcr st_posting_key := 'WCR';  -- Writeback Credit  Positive
  pc_posting_key_wdr st_posting_key := 'WDR';  -- Writeback Debit   Negative

/*******************************************************************************
  Package Variables
*******************************************************************************/  
  ptv_gl_data pxiatl01_extract.tt_gl_data;

/*******************************************************************************
  NAME:      ON_START                                                     PUBLIC
*******************************************************************************/  
  procedure on_start is 
  begin
    -- Ensure that the general ledger data is empty.
    ptv_gl_data.delete; 
    -- Now initialise the data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,true,true);
    -- Now define the column structure
    fflu_data.add_char_field_txt(pc_ic_record_type,0,6,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_px_company_code,6,3,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_px_division_code,9,3,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_rec_type,12,1,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_date_field_txt(pc_document_date,13,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_txt(pc_posting_date,21,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_txt(pc_document_type,29,2,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_currency,31,3,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_reference,34,16,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_document_header_text,50,25,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_posting_key,75,4,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_account,79,17,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_pa_assignment_flag,96,1,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_number_field_txt(pc_amount,97,13,'9999999999.99',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_txt(pc_payment_method,110,1,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_allocation,111,18,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_text,129,30,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_profit_centre,159,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_cost_centre,169,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_sales_organisation,179,4,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_sales_office,183,5,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_product_number,188,18,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_pa_code,206,5,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_glt_row_id,211,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_user_1,221,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_user_2,231,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_date_field_txt(pc_buy_start_date,241,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_txt(pc_buy_stop_date,249,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_txt(pc_start_date,257,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_txt(pc_stop_date,265,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_txt(pc_quantity,273,15,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_additional_info,288,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_promotion_is_closed,298,1,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
  exception 
    when others then 
      fflu_utils.log_interface_exception('On Start');
end on_start;

/*******************************************************************************
  NAME:      ON_START                                                     PUBLIC
*******************************************************************************/  
  procedure on_data(p_row in varchar2) is 
    rv_gl pxiatl01_extract.rt_gl_record;
    v_bus_sgmnt_code pxi_common.st_bus_sgmnt; 
  begin
    -- Initialse Variable
    v_bus_sgmnt_code := null;
    -- Now parse the row. 
    if fflu_data.parse_data(p_row) = true then
      -- Only look for detail records at this time.  
      -- NOTE: Possible Enhacnement check could be to ensure this detail line's 
      -- header fields match the previous header.
      if fflu_data.get_char_field(pc_rec_type) = 'D' then 
        -- Header Reference Fields.
        rv_gl.posting_date := fflu_data.get_date_field(pc_posting_date);
        rv_gl.document_date := fflu_data.get_date_field(pc_document_date);
        rv_gl.currency := fflu_data.get_char_field(pc_currency);
        -- Now commence processing this accrual into actual atlas extract records.
        rv_gl.account_code :=  fflu_data.get_char_field(pc_account);
        rv_gl.profit_center := fflu_data.get_char_field(pc_profit_center);
        rv_gl.cost_center := fflu_data.get_char_field(pc_cost_center);
        rv_gl.amount := fflu_data.get_number_field(pc_amount);
        case fflu_data.get_char_field(pc_posting_key)
          when pc_posting_key_dr then 
            rv_gl.amount := rv_gl.amount * 1;
          when pc_posting_key_cr then 
            rv_gl.amount := rv_gl.amount * -1;
          when pc_posting_key_wcr then 
            rv_gl.amount := rv_gl.amount * 1;
          when pc_posting_key_wdr then
            rv_gl.amount := rv_gl.amount * -1;
          else
            fflu_data.log_field_error(pc_field_posting_key,'Unknown Posting Key');
        end case;
        -- Create the Item Reference Field.  Product, Customer, Promo, Text.
        rv_gl.item_text := rpad(
          fflu_data.get_char_field(pc_field_product_number) || ' ' || -- ZREP
          fflu_data.get_char_field(pc_field_allocation) || ' ' ||  -- Customer
          fflu_data.get_char_field(pc_field_reference) ||  ' ' || -- Promo Num
          fflu_data.get_char_field(pc_field_text), -- Accrual Text 
          50);
        -- Promax Internal Reference ID.
        rv_gl.allocation_ref := fflu_data.get_char_field(pc_glt_row_id);
        -- Define the tax Code as a Constant.
        rv_gl.tax_code := pxiatl01_extract.gc_tax_code_gl;
        -- COPA Related Fields
        rv_gl.sales_org := fflu_data.get_char_field(pc_px_company_code);
        -- Lookup the business segment for the curent material. 
        v_bus_sgmnt := pxi_common.determine_bus_sgmnt(
          fflu_data.get_char_field(pc_px_division_code),
          fflu_data.get_char_field(pc_field_product_number));
        if v_bus_sgmnt is null then 
          fflu_data.log_field_error(pc_px_division_code,'Could not determine a business segment from company, promax division, and zrep.');
        end if;
        -- Now lookup the traded unit material code.
        rv_gl.material_code := pxi_common.lookup_tdu_from_zrep(
          fflu_data.get_char_field(pc_px_company_code),
          fflu_data.get_char_field(pc_product_number),
          fflu_data.get_date_field(pc_buy_start_date),
          fflu_data.get_date_field(pc_buy_stop_date));
        if rv_gl.material_code is null then 
          fflu_data.log_field_error(pc_product_number,'Unable to find via material determination a current TDU for this ZREP.');
        else 
          -- Perform a check 
          if rv_gl.profit_center is null then 
            case v_bus_sgmnt 
              when pxi_common.gc_bus_sgmnt_snack then 
                rv_gl.profit_center := '0000110001';
              when pxi_common.gc_bus_sgmnt_food then 
                rv_gl.profit_center := '0000110006';
              when pxi_common.gc_bus_sgmnt_petcare then 
                rv_gl.profit_center := '0000110005';
              else 
                fflu_data.log_field_error(pc_profit_center,'As profit center was null, tried to determine from business segment.  Which was unknown [' || v_bus_sgmnt || ']');
            end case;
          end if;
        end if; 
        rv_gl.customer_code := fflu_data.get_char_field(pc_field_allocation);
        -- Now lookup the plant code and distribution channels.  
        rv_gl.plant_code := pxi_common.determine_plant_code(
          fflu_data.get_char_field(pc_px_company_code),
          fflu_data.get_char_field(pc_product_number));
        rv_gl.dstrbtn_chnnl := pxi_common.determine_dstrbtn_chnnl(
          fflu_data.get_char_field(pc_px_company_code),
          fflu_data.get_char_field(pc_product_number),
          fflu_data.get_char_field(pc_field_allocation));
        -- Now add this record to the general ledger collection.
        ptv_gl_data(tv_gl_data.count+1) := rv_gl;
      end if;
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
    if fflu_data.was_errors = false then 
      -- Now lets create the atlas IDOC interfaces with the data we have in 
      -- memoruy.
      pxiatl01_extract.send_data(ptv_gl_data,pxiatl01_extract.gc_doc_type_accrual);
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
  ptv_gl_data.delete;
end pmxlad01_loader;

/*
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



   --*********************************************--
   -- This procedure performs the execute routine --
   --*********************************************--
   --function execute_old(par_int_id in number) return number is
   procedure execute_old(par_int_id in number) is

      -----
      -- Local definitions
      -----
      TYPE tbl_accrual IS TABLE OF VARCHAR2(220)
      INDEX BY BINARY_INTEGER;

      rcd_accrual_detail  tbl_accrual;
      rcd_reversal_detail tbl_accrual;
      
      var_exception varchar2(4000);
      var_history number;
      var_instance number(15,0);
      var_count integer;

      -- VARIABLE  DECLARATIONS
      v_instance             varchar2(8);
      var_result             number;
      v_data                 varchar2(4000);
      v_accrual_hdr          varchar2(4000);
      v_reversal_hdr         varchar2(4000);
      v_accrual_detail_summ  varchar2(4000);
      v_reversal_detail_summ varchar2(4000);
      v_accrual_tax          varchar2(4000);
      v_reversal_tax         varchar2(4000);
      v_item_count           binary_integer := 0;
      v_total_item_count     binary_integer := 0;
      v_start_item_count     binary_integer := 1;
      v_header_count         pls_integer := 0;
      v_total_accrl_amt      number(21,2) := 0;
      v_taxfree_base_amt     number(21,2) := 0;
      v_cmpny_code           varchar2(4);
      v_div_code             varchar2(4);
      v_cust_code            varchar2(10);
      v_acct_code            varchar2(20);
      v_currcy_code          varchar2(10);
      v_plant_code           varchar2(10);
      v_profit_ctr           varchar2(10);
      v_distbn_chnl_code     varchar2(10);
      v_previous_period_end  number(8);
      v_current_period_start number(8);
      v_item_processed       number := 0;

      -- EXCEPTION DECLARATIONS.
      e_processing_failure EXCEPTION;
      e_processing_error   EXCEPTION;

      -----
      -- Local cursors
      -----
      CURSOR csr_accruals IS
        select 
            px_cmpny_code as cmpny_code,
            bus_sgmnt as div_code,
            allocation as cust_code,
            ' ' as cust_vndr_code,
            product_number as matl_zrep_code, 
            reference as prom_num,
            RPAD(NVL(LTRIM(int_claim_num),' '),18) as internal_claim_num,
            amount as accrl_amt,
            matl_tdu_code as matl_tdu_code,
            account as acct_code,
            plant_code as plant_code,
            profit_ctr_code as profit_ctr_code, 
            distbn_chnl_code as distbn_chnl_code,
            currency
        from 
            pmx_accrls t01 
        where 
            int_id = par_int_id
            and rec_type = 'D'
            and posting_key = 'DR';
        --   
        WHERE
          cmpny_code = i_pmx_cmpny_code
          AND div_code = i_pmx_div_code
          AND valdtn_status = pc_valdtn_status_valid
          AND procg_status = pc_procg_status_processed;
         --
        
        rv_accruals csr_accruals%ROWTYPE;
      
      

   -----------------
   -- Begin block --
   -----------------
   begin

   SELECT count(*) INTO v_total_item_count
    from 
        pmx_accrls t01 
    where 
        int_id = par_int_id
        and rec_type = 'D'
        and posting_key = 'DR';


  --
  Retrieve the last day of the previous period.
  Note: The Interface is scheduled to run on the last day of the period (ie Saturday)
  just closed. The transaction date to be used for the Accrual is the same date (ie Last
  Saturday of the period just closed), irrespective of when the interface is actually run.
  This needs to be catered for in the interface. To allow for this we subtract 24 from
  the current (run) date. Provided it is run from the last Thursday of the Period up to
  23 days after the period end, it will always retrieve the dates of the period just closed.
  --
  SELECT MAX(yyyymmdd_date) INTO v_previous_period_end
  FROM mars_date
  WHERE mars_period = (SELECT MIN(mars_period)
                       FROM mars_date
                       WHERE calendar_date = trunc(SYSDATE - 24));
  --
  Retrieve the first day of the current period.
  Note: The Interface is scheduled to run on the last day of the period (ie Saturday)
  just closed. The transaction date to be used for the Reversal is first day of the next
  period (ie First Sunday of the next period), irrespective of when the interface is
  actually run. This needs to be catered for in the interface. To allow for this we add
  4 to the current (run) date. Provided it is run from the lats Thursday of the Period
  up to 23 days after the period end, it will always retrieve the dates of the period
  following the period just closed.
  --
  SELECT TO_CHAR(MIN(yyyymmdd_date)) INTO v_current_period_start
  FROM mars_date
  WHERE mars_period = (SELECT mars_period
                       FROM mars_date
                       WHERE calendar_date = TRUNC(SYSDATE + 4));


  -- Read through each of the accrual records to be interfaced.
  OPEN csr_accruals;
  LOOP
  
    FETCH csr_accruals INTO rv_accruals;
    EXIT WHEN csr_accruals%NOTFOUND;

    v_item_count := v_item_count + 1;
    v_item_processed := v_item_processed + 1;

    v_total_accrl_amt := v_total_accrl_amt + rv_accruals.accrl_amt;
    v_taxfree_base_amt := v_taxfree_base_amt + rv_accruals.accrl_amt;

    v_acct_code := rv_accruals.acct_code;
    v_plant_code := rv_accruals.plant_code;
    v_profit_ctr := rv_accruals.profit_ctr_code;
    v_cmpny_code := rv_accruals.cmpny_code;
    v_currcy_code := rv_accruals.currency;
    
    -- Format Customer Code.
    var_result := pmx_common.format_cust_code (rv_accruals.cust_code,v_cust_code);
    
    -- Lookup the Distribution Channel Code.
    v_distbn_chnl_code := rv_accruals.distbn_chnl_code;
    IF v_distbn_chnl_code IS NULL THEN
      v_distbn_chnl_code := '10';
    END IF;

    -- Writing Accrual Detail records to array.
    rcd_accrual_detail(v_item_count) := 'G' ||
      LPAD(v_acct_code,10,0) ||
      TO_CHAR((rv_accruals.accrl_amt * 1),'9999999999999999999.99') ||
      -- GORDOSTE 20130320 - Add promo num and trim all leading zeroes in the text field
      RPAD( LTRIM(rv_accruals.matl_tdu_code, '0')  || ' ' ||
            LTRIM(v_cust_code, '0')                || ' ' ||
            LTRIM(rv_accruals.cust_vndr_code, '0') || ' ' ||
            LTRIM(rv_accruals.prom_num, '0'),
        50) ||
      rv_accruals.internal_claim_num ||
      'GL' ||
      RPAD(' ',10) || -- Cost Centre
      RPAD(' ',12) || -- Order Identification
      RPAD(' ',24) || -- WBS Element
      RPAD(' ',13) || -- Accrual Quantity
      RPAD(' ',3) || -- Accrual Quantity BUOM
      RPAD(NVL(rv_accruals.matl_tdu_code,' '),18) ||
      RPAD(v_plant_code,4) ||
      RPAD(v_cust_code,10) ||
      LPAD(v_profit_ctr,10,0) ||
      RPAD(v_cmpny_code,4) ||
      RPAD(v_distbn_chnl_code,2);

    --
    If the record count has reached 900 or the total number of records to be processed
    has been reached then generate the creation of the extract file. Then continue
    processing records if there are more to be processed (i.e. greater than 900 records).

    Note: 909 (includes 9 SAP generated records) is the limitation of the number of
    records that can be contained within an IDOC loaded into Atlas.
    --
    IF (MOD(v_item_processed,900) = 0) OR v_item_processed = v_total_item_count THEN

      v_header_count := v_header_count + 1;

      -- Writing Accrual Header record.
      v_accrual_hdr := 'H' ||
        RPAD('IDOC',5) ||
        'PX' ||
        TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS') ||
        LPAD(TO_CHAR(v_header_count),4,'0') ||
        'RFBU' ||
        RPAD('BATCHSCHE',12) ||
        RPAD('Pmx Accr' || ' ' || LTRIM(RPAD(v_cmpny_code,4)) || rv_accruals.div_code ||
--        RPAD('Pmx Accr' || ' ' || LTRIM(RPAD(v_cmpny_code,4)) || v_div_code ||
        TO_CHAR(SYSDATE,'YYYYMMDD'),25) ||
        RPAD(v_cmpny_code,4) ||
        RPAD(v_currcy_code,5) ||
        v_previous_period_end ||
        v_previous_period_end ||
        v_previous_period_end ||
        'ZA' ||
        RPAD(' ',16)  || -- Reference Document Number
        RPAD('PROMAX',10);

      -- Writing Accrual Reversal Header record.
      v_reversal_hdr := 'H' ||
        RPAD('IDOC',5) ||
        'PX' ||
        TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS') ||
        LPAD(TO_CHAR(v_header_count),4,'0') ||
        'RFBU' ||
        RPAD('BATCHSCHE',12) ||
        RPAD('Pmx Accr' || ' ' || LTRIM(RPAD(v_cmpny_code,4)) || rv_accruals.div_code ||
--        RPAD('Pmx Accr' || ' ' || LTRIM(RPAD(v_cmpny_code,4)) || v_div_code ||
        TO_CHAR(SYSDATE,'YYYYMMDD'),25) ||
        RPAD(v_cmpny_code,4) ||
        RPAD(v_currcy_code,5) ||
        v_current_period_start ||
        v_current_period_start ||
        v_current_period_start ||
        'ZB' ||
        RPAD(' ',16)  || -- Reference Document Number
        RPAD('PROMAX',10);

      -- Writing Accrual Detail Summary record.
      -- The Taxfree Base Amount is negative to offset the positive detail amounts in the
      -- Accrual Balance Sheet account.
      v_accrual_detail_summ := 'G0000955136' ||
        TO_CHAR((-(v_taxfree_base_amt)),'9999999999999999999.99') ||
        RPAD(' ',50) || -- Item Text
        RPAD(' ',18) || -- Allocation Number
        'GL' ||
        RPAD(' ',10) || -- Cost Centre
        RPAD(' ',12) || -- Order Identification
        RPAD(' ',24) || -- WBS Element
        RPAD(' ',13) || -- Accrual Quantity
        RPAD(' ',3) || -- Accrual Quantity BUOM
        RPAD(' ',18) || -- Material Code (Blank)
        RPAD(' ',4) || -- Plant Code (Blank)
        RPAD(' ',10) || -- Customer Code (Blank)
        LPAD(v_profit_ctr,10,0) ||
        RPAD(' ',4) || -- Company Code (Blank)
        RPAD(' ',2); -- Distribution Channel (Blank)

      -- Writing Reversal Detail Summary record.
      -- The Taxfree Base Amount is positive  to offset the negative detail amounts in the
      -- Accrual Balance Sheet account.
      v_reversal_detail_summ := 'G0000955136' ||
        TO_CHAR(((v_taxfree_base_amt)),'9999999999999999999.99') ||
        RPAD(' ',50) || -- Item Text
        RPAD(' ',18) || -- Allocation Number
        'GL' ||
        RPAD(' ',10) || -- Cost Centre
        RPAD(' ',12) || -- Order Identification
        RPAD(' ',24) || -- WBS Element
        RPAD(' ',13) || -- Accrual Quantity
        RPAD(' ',3) || -- Accrual Quantity BUOM
        RPAD(' ',18) || -- Material Code (Blank)
        RPAD(' ',4) || -- Plant Code (Blank)
        RPAD(' ',10) || -- Customer Code (Blank)
        LPAD(v_profit_ctr,10,0) ||
        RPAD(' ',4) || -- Company Code (Blank)
        RPAD(' ',2); -- Distribution Channel (Blank)

      -- Writing Accrual Tax record.
      v_accrual_tax := 'T' ||
        'GL' ||
        RPAD( ' ',20) ||
        '000' ||
        RPAD( ' ',16) ||
        '000' ||
        RPAD( ' ',8);

      -- Writing Reversal Tax record.
      v_reversal_tax := 'T' ||
        'GL' ||
        RPAD( ' ',20) ||
        '000' ||
        RPAD( ' ',16) ||
        '000' ||
        RPAD( ' ',8);

        
      -- Create the Accrual file.
      v_instance := lics_outbound_loader.create_interface('PXIATL01');
      
      -- Write Accrual records to the file.
      lics_outbound_loader.append_data(v_accrual_hdr);

      FOR i IN v_start_item_count..v_item_count LOOP
        lics_outbound_loader.append_data(rcd_accrual_detail(i));
      END LOOP;

      lics_outbound_loader.append_data(v_accrual_detail_summ);
      lics_outbound_loader.append_data(v_accrual_tax);

      -- Finalise the Accrual interface.
      lics_outbound_loader.finalise_interface;
      -- Create the Accrual Reversal file.
      v_instance := lics_outbound_loader.create_interface('PXIATL01');

      -- Write Accrual Reversal records to the file.
      lics_outbound_loader.append_data(v_reversal_hdr);

      FOR i IN v_start_item_count..v_item_count LOOP
        lics_outbound_loader.append_data(rcd_reversal_detail(i));
      END LOOP;

      lics_outbound_loader.append_data(v_reversal_detail_summ);
      lics_outbound_loader.append_data(v_reversal_tax);

      -- Finalise the Accrual Reversal interface.
      lics_outbound_loader.finalise_interface;
      
      --
      dbms_output.put_line('Accrual Output');
      dbms_output.put_line(v_accrual_hdr);
      
      FOR i IN v_start_item_count..v_item_count LOOP
        dbms_output.put_line(rcd_accrual_detail(i));
      END LOOP;
      
      dbms_output.put_line(v_accrual_detail_summ);
      dbms_output.put_line(v_accrual_tax);
      dbms_output.put_line('Accrual End Out');
      
      
      dbms_output.put_line('Reversal Output');
      dbms_output.put_line(v_reversal_hdr);
      
      FOR i IN v_start_item_count..v_item_count LOOP
        dbms_output.put_line(rcd_reversal_detail(i));
      END LOOP;
      
      dbms_output.put_line(v_reversal_detail_summ);
      dbms_output.put_line(v_reversal_tax);
      dbms_output.put_line('Reversal End Out');
      --
      
      -- Reset variables.
      v_taxfree_base_amt := 0;
      v_item_count := 0;
      rcd_accrual_detail.DELETE;
      rcd_reversal_detail.DELETE;

    END IF;

  END LOOP;
  CLOSE csr_accruals;

   -----------------------
   -- Exception handler --
   -----------------------
   exception

      ----
      -- Exception trap
      ----
      when others then

         -----
         -- Rollback the database
         -----
         rollback;

         -----
         -- Save the exception
         -----
         var_exception := substr(SQLERRM, 1, 1024);

         -----
         -- Finalise the outbound loader when required
         -----
         if var_instance != -1 then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

         -----
         -- Raise an exception to the calling application
         -----
         raise_application_error(-20000, 'FATAL ERROR - PXIATL01 EXTRACT - ' || var_exception);

   -----------------
   -- End routine --
   -----------------
   end execute_old;
   
   
   
    -----
   -- Private exceptions
   -----
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   -----
   -- Private definitions
   -----
   con_group constant number := 900; -- Limit of 909 rows per IDOC when sending to ATLAS

   --*********************************************--
   -- This procedure performs the execute routine --
   --*********************************************--
   procedure execute(par_int_id in number) is

    -----
    -- Local definitions
    -----

    -- COLLECTION TYPE DECLARATIONS.
    type tbl_gledger is table of varchar2(220)
    index by binary_integer;

    -- COLLECTION DECLARATIONS.
    rcd_gledger tbl_gledger;


    var_exception varchar2(4000);
    var_history number;
    var_instance number(15,0);
    var_count integer;

    -- VARIABLE DECLARATIONS.
    var_result         number;
      
    v_error            boolean;
    --v_line_item        varchar2(2000);
    --v_agg_current      binary_integer := 1;
    --v_agg_maxagg       binary_integer := 0;
    --v_agg_counter      binary_integer := 0;
    --v_agg_addagg       boolean;
    v_item_count       binary_integer := 0;
    v_tax_base         number := 0;
    v_taxfree_base     number := 0;
    v_tax              number := 0;
    v_tax_code         varchar2(2);
    v_acct_amt         number;
    v_tran_date        date;
    v_text_field       varchar2(25);
    v_prom_num         varchar2(10);
    v_sales_org        varchar2(4);
    --v_ic_code          number(15,4);
    v_ic_code          varchar2(20);
    v_aggregation      boolean := false;
    v_cust_code        varchar2(10);
    v_dist_chan        varchar2(12);
    v_matl_code        varchar2(18);
    v_plant            varchar2(12);
    v_cost_centre      varchar2(50);
    v_cost_account     varchar2(50);
    v_profit_centre    varchar2(50);
    v_taxable_code     varchar2(2);
    v_taxfree_code     varchar2(2);
    v_tax_found        boolean := false;
    v_taxfree_found    boolean := false;
    v_currency         varchar2(50);
    v_pb_date_stamp    date;
    v_instance         number(15,0); -- Local definitions required for ICS interface invocation.
    v_total_accrl_amt  number(15,4) := 0;
    v_total_tax_amt    number(15,4) := 0;
    v_header_line_item varchar2(500);
    v_vendor_line_item varchar2(500);
    v_tax_line_item    varchar2(500);

    -- EXCEPTION DECLARATIONS.
    --e_processing_failure exception;
    --e_processing_error exception;
      

    -- Cursor used to retrieve all the necessary columns from the APClaims table.
    cursor csr_claim_det is       
     select 
        px_company_code as pmx_cmpny_code,
        bus_sgmnt as pmx_div_code,              -- Lookup
        line_num as ap_claims_seq,              -- NOT REQUIRED
        account_code as cust_code,      
        reference as prom_num,
        deduction_ac_code as cust_vndr_code,
        matl_tdu_code as matl_code,             -- Lookup Matl TDU
        --allocation as internal_claim_num,
        (promo_claim_grp_row_id||promo_claim_detail_row_id) as internal_claim_num,
        spend_amount as accrl_amt,
        --'1' as text_field,                       -- CHECK Value/Use
        allocation as text_field,                       -- CHECK Value/Use
        tax_amount as tax_amt,
        '' as doc_type_code,                    -- CHECK Value/Use
        posting_date as pb_date_stamp,          -- CHECK Value/Use
        '' as period_num,                       -- Lookup           -- Appears to always be 0
        doc_date as tran_date,
        --'NA' as prcg_status,                    -- NOT REQUIRED
        --'NA' as valdtn_status,                  -- NOT REQUIRED
        last_updtd_user as ap_claim_lupdp,      -- NOT REQUIRED
        last_updtd_time as ap_claim_lupdt,      -- NOT REQUIRED
        px_company_code as cmpny_code,
        bus_sgmnt as div_code,
        plant_code as plant_code,
        profit_ctr_code as profit_ctr_code, 
        distbn_chnl_code as distbn_chnl_code,
        currency as currency,
        'Y' as atlas_flag                       -- Set to Y for all company/division combinations in existing Promax
     from 
        pmx_payments
     where 
        rec_type = 'D'
        and int_id = par_int_id;
    rv_claim_det csr_claim_det  %ROWTYPE;


begin
    -- Start interface_apclaim_file procedure.

    -- Reading through csr_claim_det cursor to process AP CLAIM records.
    open csr_claim_det;
    loop
    fetch csr_claim_det into rv_claim_det;
    exit when csr_claim_det%notfound;

    -- Re-initialise fields.
    v_total_accrl_amt  := v_total_accrl_amt + rv_claim_det.accrl_amt;
    v_total_tax_amt    := v_total_tax_amt + rv_claim_det.tax_amt;

        
        
    -- Retrieve all necessary variables
    --pv_status := pds_common.format_cust_code(rv_claim_det.cust_code, v_cust_code, pv_log_level + 2,pv_result_msg);

    pv_status := pds_common.format_matl_code(rv_claim_det.matl_code, v_matl_code, pv_log_level + 2,pv_result_msg);

    pv_status := pds_lookup.lookup_distn_chnl_code (v_matl_code, v_cust_code, v_dist_chan, pv_log_level + 5, pv_result_msg);

    v_dist_chan := RPAD(NVL(v_dist_chan,' '),2);

    pv_status := pds_lookup.lookup_matl_dtrmntn(rv_claim_det.pmx_cmpny_code, rv_claim_det.pmx_div_code, rv_claim_det.prom_num, rv_claim_det.cust_code, rv_claim_det.matl_code, v_matl_code, pv_log_level + 5, pv_result_msg);
     
    pv_status := pds_lookup.lookup_matl_plant_code(rv_claim_det.pmx_cmpny_code, v_matl_code, v_plant, pv_log_level + 5, pv_result_msg);

    v_sales_org := RPAD(rv_claim_det.cmpny_code,4); -- Sales Org.--
        
        
    -- Retrieve all necessary variables.
    var_result := pmx_common.format_cust_code(rv_claim_det.cust_code, v_cust_code);
    var_result := pmx_common.format_matl_code(rv_claim_det.matl_code, v_matl_code);
        
    -- Lookup the Distribution Channel Code.
    v_dist_chan := rv_claim_det.distbn_chnl_code;
    IF v_dist_chan IS NULL THEN
      v_dist_chan := '10';
    END IF;
        
    v_dist_chan := rpad(nvl(v_dist_chan,' '),2);
        
    v_plant := rv_claim_det.plant_code;
    v_sales_org := RPAD(rv_claim_det.cmpny_code,4); -- Sales Org.
        
    -- Retrieve all necessary variables.
    --pv_status := pds_lookup.lookup_cntl_code(rv_claim_det.pmx_cmpny_code, rv_claim_det.pmx_div_code, 'COST_CENTRE_CODE', v_cost_centre, pv_log_level + 5, pv_result_msg);

    pv_status := pds_lookup.lookup_cntl_code(rv_claim_det.pmx_cmpny_code, rv_claim_det.pmx_div_code, 'COST_ACCOUNT_CODE', v_cost_account, pv_log_level + 5, pv_result_msg);

    pv_status := pds_lookup.lookup_cntl_code(rv_claim_det.pmx_cmpny_code, rv_claim_det.pmx_div_code, 'PROFIT_CENTRE_CODE', v_profit_centre, pv_log_level + 5, pv_result_msg);

    pv_status := pds_lookup.lookup_cntl_code(rv_claim_det.pmx_cmpny_code, rv_claim_det.pmx_div_code, 'TAX_CODE', v_taxable_code, pv_log_level + 5, pv_result_msg);

    pv_status := pds_lookup.lookup_cntl_code(rv_claim_det.pmx_cmpny_code, rv_claim_det.pmx_div_code, 'NOTAX_CODE', v_taxfree_code, pv_log_level + 5, pv_result_msg);

    pv_status := pds_lookup.lookup_cntl_code(rv_claim_det.pmx_cmpny_code, rv_claim_det.pmx_div_code, 'CURRENCY_CODE', v_currency, pv_log_level + 5, pv_result_msg);--


    v_cost_centre := '          ';
    v_cost_account := '0000170534';
    v_profit_centre := rv_claim_det.profit_ctr_code;
    v_taxable_code := 'S2';
    v_taxfree_code := 'SE';
    v_currency := rv_claim_det.currency;
        
        
    -- Total Tax Payments.
    --pv_status := pds_exist.exist_taxable(rv_claim_det.pmx_cmpny_code, rv_claim_det.pmx_div_code, rv_claim_det.doc_type_code,pv_log_level + 5, pv_result_msg);
        
    --IF pv_status = constants.success THEN
    IF rv_claim_det.tax_amt > 0 THEN
      v_tax_base := v_tax_base + rv_claim_det.accrl_amt;
      v_tax := v_tax + rv_claim_det.tax_amt;
      v_tax_code := v_taxable_code;
      v_tax_found := TRUE;
    ELSE
      v_taxfree_base := v_taxfree_base + rv_claim_det.accrl_amt;
      v_tax_code := v_taxfree_code;
      v_taxfree_found := TRUE;
    END IF;

    v_item_count := v_item_count + 1;

    -- Create 'G'/General Ledger List of lines.
    rcd_gledger(v_item_count) :=
      'G' || -- G Line Indicator.
      LPAD(v_cost_account,10,'0') || -- The Cost Account Code.
      LPAD(TO_CHAR(rv_claim_det.accrl_amt, '9999999999999999999.99'),23,'0') || -- The amount.
      -- The Item Text.
      RPAD(LTRIM(rv_claim_det.text_field) || ' ' || RTRIM(rv_claim_det.cust_vndr_code),50) ||
      RPAD(LTRIM(rv_claim_det.internal_claim_num),18) || -- Alloc Num aka Assignment.
      -- Other line details.
      RPAD(v_tax_code,2) || -- Tax code for the current line.
      RPAD(v_cost_centre,10) || -- Cost centre.
      RPAD(' ',12) || -- Order Id always blank.
      RPAD(' ',24) || -- WBS element.
      RPAD(' ',13) || -- Quantity.
      RPAD(' ',3) || -- Base Unit of Measure.
      RPAD(NVL(v_matl_code,' '),18) || -- Product Code.
      RPAD(v_plant,4); -- Plant Code.

    rcd_gledger(v_item_count) := rcd_gledger(v_item_count) || v_cust_code; -- Customer.

    -- Add Profit Centre Information.
    rcd_gledger(v_item_count)  := rcd_gledger(v_item_count) || RPAD(v_profit_centre,10);

    -- Now update the Sales Order and Distribution Channel.
    rcd_gledger(v_item_count) := rcd_gledger(v_item_count) ||
      RPAD(rv_claim_det.cmpny_code,4) || -- Sales Org.
      RPAD(v_dist_chan,2); -- Distribution Channel.

    -- These values are the same for each record, therefore they can be set
    -- at this point for later reference.
    v_tran_date     := rv_claim_det.tran_date;  
    v_text_field    := rv_claim_det.text_field;
    v_prom_num      := rv_claim_det.prom_num;
    v_ic_code       := rv_claim_det.internal_claim_num;
    v_pb_date_stamp := rv_claim_det.pb_date_stamp;
        

    END LOOP;
    -- End of loop.

      
      
    -- Create the 'H'/Header Line of the IDoc.
    v_header_line_item :=
    'HIDOC PX' ||
    TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS') ||
    LPAD(TO_CHAR(v_item_count),4,'0') ||
    'RFBUBATCHSCHE   ' ||
    RPAD('Promax '||LTRIM(rv_claim_det.cmpny_code)|| ' ' || LTRIM(rv_claim_det.div_code)||' ' ||LTRIM(v_prom_num),25)|| -- 25 char header text.
    RPAD(rv_claim_det.cmpny_code,4) || -- Company Code.
    RPAD(v_currency,5,' ') || -- Currency.
    TO_CHAR(v_tran_date,'YYYYMMDD') || -- Document Date.
    TO_CHAR(v_pb_date_stamp,'YYYYMMDD') || -- Posting Date.
    TO_CHAR(v_pb_date_stamp,'YYYYMMDD') || -- Trans Date  27/7/04 disappeared from spec
    'KN' || RPAD(v_text_field,16) || RPAD('PROMAX',10);

        
    -- Create the 'P'/Vendor line in the IDoc.
    v_vendor_line_item :=
    'P' ||
    LPAD(NVL(LTRIM(rv_claim_det.cust_vndr_code),'0000000000'),10,'0') ||
    TO_CHAR(-(v_taxfree_base + v_tax_base + v_tax),'9999999999999999999.99') ||
    '*   ' ||
    '        ' ||
    'B' ||
    RPAD(LTRIM(v_ic_code),18) ||
    RPAD(LPAD(LTRIM(v_prom_num),8,'0') ||
    ' ' ||
    RTRIM(v_ic_code) ||
    ' ' ||
    RTRIM(v_text_field),50) ||
    '  '; -- W_tax_code.

    -- Create 'T'/Tax line for the IDOC.
    IF v_tax_found THEN
    v_tax_line_item :=
      'T' || v_tax_code ||
      TO_CHAR(v_tax,'9999999999999999999.99') ||
      TO_CHAR(v_tax_base,'9999999999999999999.99') ||
      '    ' || -- Cond_key.
      '   '; -- Acct_key.
    END IF;

    -- If Tax Free Code is found.
    IF v_taxfree_found THEN
    v_tax_line_item :=
      'T' || v_tax_code ||
      '                    000' || -- No Tax.
      TO_CHAR(v_taxfree_base,'9999999999999999999.99') ||
      '       ' ||
      ' ';
    END IF;

    -- Close csr_apclaim_det cursor.
    CLOSE csr_claim_det;


  
    -- Open the ICS interface file.
    v_instance  := lics_outbound_loader.create_interface('PXIATL02');

    lics_outbound_loader.append_data(v_header_line_item);

    lics_outbound_loader.append_data(v_vendor_line_item);

    FOR i IN 1..v_item_count LOOP
    lics_outbound_loader.append_data(rcd_gledger(i));
    END LOOP;

    lics_outbound_loader.append_data(v_tax_line_item);

    -- Finalise the interface.
    lics_outbound_loader.finalise_interface;
    

    --
    dbms_output.put_line(v_header_line_item);
    dbms_output.put_line(v_vendor_line_item);

    FOR i IN 1..v_item_count LOOP
    dbms_output.put_line(rcd_gledger(i));
    END LOOP;

    dbms_output.put_line(v_tax_line_item);
    --


   -----------------------
   -- Exception handler --
   -----------------------
   exception

      ----
      -- Exception trap
      ----
      when others then

         -----
         -- Rollback the database
         -----
         rollback;

         -----
         -- Save the exception
         -----
         var_exception := substr(SQLERRM, 1, 1024);

         -----
         -- Finalise the outbound loader when required
         -----
         if var_instance != -1 then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

         -----
         -- Raise an exception to the calling application
         -----
         raise_application_error(-20000, 'FATAL ERROR - PXIATL02 EXTRACT - ' || var_exception);

   -----------------
   -- End routine --
   -----------------
   end execute;
   */
