create or replace 
package body          pmxpxi02_loader as

/*******************************************************************************
  Interface Field Definitions
*******************************************************************************/  
  pc_ic_record_type constant fflu_common.st_name := 'IC Record Type';
  pc_px_company_code constant fflu_common.st_name := 'PX Company Code';
  pc_px_division_code constant fflu_common.st_name := 'PX Division Code';
  pc_type constant fflu_common.st_name := 'Type';
  pc_document_date constant fflu_common.st_name := 'Document Date';
  pc_posting_date constant fflu_common.st_name := 'Posting Date';
  pc_claim_date constant fflu_common.st_name := 'Claim Date';
  pc_reference constant fflu_common.st_name := 'Reference';
  pc_document_header_text constant fflu_common.st_name := 'Document Header Text';
  pc_expenditure_type constant fflu_common.st_name := 'Expenditure Type';
  pc_posting_key constant fflu_common.st_name := 'Posting Key';
  pc_account_code constant fflu_common.st_name := 'Account Code';
  pc_amount constant fflu_common.st_name := 'Amount';
  pc_spend_amount constant fflu_common.st_name := 'Spend Amount';
  pc_tax_amount constant fflu_common.st_name := 'Tax Amount';
  pc_payment_method constant fflu_common.st_name := 'Payment Method';
  pc_allocation constant fflu_common.st_name := 'Allocation';
  pc_pc_reference constant fflu_common.st_name := 'PC Reference';
  pc_px_reference constant fflu_common.st_name := 'PX Reference';
  pc_ext_reference constant fflu_common.st_name := 'Ext Reference';
  pc_product_number constant fflu_common.st_name := 'Product Number';
  pc_transaction_code constant fflu_common.st_name := 'Transaction Code';
  pc_deduction_ac_code constant fflu_common.st_name := 'Deduction AC Code';
  pc_payee_code constant fflu_common.st_name := 'Payee Code';
  pc_debit_code constant fflu_common.st_name := 'Debit Code';
  pc_credit_code constant fflu_common.st_name := 'Credit Code';
  pc_customer_is_a_vendor constant fflu_common.st_name := 'Customer Is A Vendor';
  pc_currency constant fflu_common.st_name := 'Currency';
  pc_promo_claim_detail_row_id constant fflu_common.st_name := 'Promo Claim Detail Row ID';
  pc_promo_claim_group_row_id constant fflu_common.st_name := 'Promo Claim Group Row ID';
  pc_promo_claim_group_pub_id constant fflu_common.st_name := 'Promo Claim Group Pub Id';
  pc_reason_code constant fflu_common.st_name := 'Reason Code';
  pc_pc_message constant fflu_common.st_name := 'PC Message';
  pc_pc_comment constant fflu_common.st_name := 'PC Comment';
  pc_text_1 constant fflu_common.st_name := 'Text 1';
  pc_text_2 constant fflu_common.st_name := 'Text 2';
  pc_buy_start_date constant fflu_common.st_name := 'Buy Start Date';
  pc_buy_stop_date constant fflu_common.st_name := 'Buy Stop Date';
  pc_bom_header_sku_stock_code constant fflu_common.st_name := 'BOM Header Sku Stock Code';

/*******************************************************************************
  Package Variables
*******************************************************************************/  
   ptv_gl_ar_data pxiatl01_extract.tt_gl_data;
   ptv_gl_ap_data pxiatl01_extract.tt_gl_data;

/*******************************************************************************
  NAME:      ON_START                                                     PUBLIC
*******************************************************************************/  
  procedure on_start is 
  begin
    -- Ensure that the general ledger data is empty.
    ptv_gl_ap_data.delete;
    ptv_gl_ar_data.delete;
    -- Now initialise the data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,true,true);
    -- Now define the column structure
    fflu_data.add_char_field_txt(gc_ic_record_type,0,6,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_px_company_code,6,3,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_px_division_code,9,3,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_type,12,1,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_date_field_txt(gc_document_date,13,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_txt(gc_posting_date,21,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_txt(gc_claim_date,29,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_txt(gc_reference,37,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_document_header_text,47,25,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_expenditure_type,72,5,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_posting_key,77,7,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_account_code,84,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_number_field_txt(gc_amount,94,14,'99999999999.99',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_txt(gc_spend_amount,108,14,'99999999999.99',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_txt(gc_tax_amount,122,14,'99999999999.99',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_txt(gc_payment_method,136,1,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_allocation,137,12,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_pc_reference,149,18,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_px_reference,167,60,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_ext_reference,227,65,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_product_number,292,18,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_transaction_code,310,40,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_deduction_ac_code,350,20,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_payee_code,370,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_debit_code,380,20,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_credit_code,400,20,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_customer_is_a_vendor,420,1,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_currency,421,3,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_promo_claim_detail_row_id,424,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_promo_claim_group_row_id,434,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_promo_claim_group_pub_id,444,30,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_reason_code,474,5,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_pc_message,479,65,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_pc_comment,544,200,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_text_1,744,40,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(gc_text_2,784,40,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_date_field_txt(gc_buy_start_date,824,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_txt(gc_buy_stop_date,832,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_txt(gc_bom_header_sku_stock_code,840,40,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
  exception 
    when others then 
      fflu_utils.log_interface_exception('On Start');
end on_start;

/*******************************************************************************
  NAME:      ON_START                                                     PUBLIC
*******************************************************************************/  
  procedure on_data(p_row in varchar2) is 
       rv_gl pxiatl01_extract.rt_gl_record;
    v_bus_sgmnt pxi_common.st_bus_sgmnt; 
  begin
    -- Initialse Variable
    v_bus_sgmnt := null;
    -- Now parse the row. 
    if fflu_data.parse_data(p_row) = true then
      -- Only look for detail records at this time.  
      -- NOTE: Possible Enhacnement check could be to ensure this detail line's 
      -- header fields match the previous header.
      if fflu_data.get_char_field(pc_rec_type) = 'D' then 
        -- Header Reference Fields.
        rv_gl.company := fflu_data.get_char_field(pc_px_company_code);
        rv_gl.promax_division := fflu_data.get_char_field(pc_px_division_code);
        rv_gl.posting_date := fflu_data.get_date_field(pc_posting_date);
        rv_gl.document_date := fflu_data.get_date_field(pc_document_date);
        rv_gl.currency := fflu_data.get_char_field(pc_currency);
        -- Now commence processing this accrual into actual atlas extract records.
        rv_gl.account_code :=  fflu_data.get_char_field(pc_account);
        rv_gl.profit_center := fflu_data.get_char_field(pc_profit_centre);
        rv_gl.cost_center := fflu_data.get_char_field(pc_cost_centre);
        rv_gl.tax_amount := 0;
        rv_gl.tax_amount_base := 0;
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
            fflu_data.log_field_error(pc_posting_key,'Unknown Posting Key');
        end case;
        -- Create the Item Reference Field.  Product, Customer, Promo, Text.
        rv_gl.item_text := rpad(
          fflu_data.get_char_field(pc_product_number) || ' ' || -- ZREP
          fflu_data.get_char_field(pc_allocation) || ' ' ||  -- Customer
          fflu_data.get_char_field(pc_reference) ||  ' ' || -- Promo Num
          fflu_data.get_char_field(pc_text), -- Accrual Text 
          50);
        -- Promax Internal Reference ID.
        rv_gl.allocation_ref := fflu_data.get_char_field(pc_glt_row_id);
        -- Define the tax Code as a Constant.
        rv_gl.tax_code := pxiatl01_extract.gc_tax_code_gl;
        -- COPA Related Fields
        rv_gl.sales_org := fflu_data.get_char_field(pc_px_company_code);
        -- Lookup the business segment for the curent material. 
        v_bus_sgmnt := pxi_common.determine_bus_sgmnt(
          fflu_data.get_char_field(pc_px_company_code),
          fflu_data.get_char_field(pc_px_division_code),
          fflu_data.get_char_field(pc_product_number));
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
                fflu_data.log_field_error(pc_profit_centre,'As profit center was null, tried to determine from business segment.  Which was unknown [' || v_bus_sgmnt || ']');
            end case;
          end if;
        end if; 
        rv_gl.customer_code := fflu_data.get_char_field(pc_allocation);
        -- Now lookup the plant code and distribution channels.  
        rv_gl.plant_code := pxi_common.determine_matl_plant_code(
          fflu_data.get_char_field(pc_px_company_code),
          fflu_data.get_char_field(pc_product_number));
        rv_gl.dstrbtn_chnnl := pxi_common.determine_dstrbtn_chnnl(
          fflu_data.get_char_field(pc_px_company_code),
          fflu_data.get_char_field(pc_product_number),
          fflu_data.get_char_field(pc_allocation));  -- Customer
        -- Now add this record to the general ledger collection.
        ptv_gl_data(ptv_gl_data.count+1) := rv_gl;
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
    -- Only perform a commit / send data if there were no errors at all. 
    if fflu_data.was_errors = false then 
      -- Now lets create the atlas IDOC interfaces with the data we have in 
      -- memory.
      -- Send Accounts Payable Data
      pxiatl01_extract.send_data(ptv_gl_ap_data,pxiatl01_extract.gc_doc_type_accrual,'ICS ID : ' || fflu_utils.get_interface_no);
      -- Send Accounts Receivable Claims
      pxiatl01_extract.send_data(ptv_gl_ar_data,pxiatl01_extract.gc_doc_type_accrual,'ICS ID : ' || fflu_utils.get_interface_no);
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
  ptv_gl_ap_data.delete;
  ptv_gl_ar_data.delete;
end pmxpxi02_loader;


/* AP Vendor Payments. 

     --     RPAD('Claim#' || trim(tbl_work(idx).claim_ref) || ' against Promo#' || trim(tbl_work(idx).prom_num),50); -- Item Text.


    pv_status := pds_exist.exist_taxable(rv_claim_det.pmx_cmpny_code, rv_claim_det.pmx_div_code, rv_claim_det.doc_type_code,pv_log_level + 5, pv_result_msg);
    IF pv_status = constants.success THEN
      v_tax_base := v_tax_base + rv_claim_det.accrl_amt;
      v_tax := v_tax + rv_claim_det.tax_amt;
      v_tax_code := v_taxable_code;
      v_tax_found := TRUE;
    ELSE
      v_taxfree_base := v_taxfree_base + rv_claim_det.accrl_amt;
      v_tax_code := v_taxfree_code;
      v_taxfree_found := TRUE;
    END IF;


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

  -- Create the 'H'/Header Line of the IDoc.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,'IDoc Header (H) Line formation.');
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
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,'IDoc Vendor (P) Line formation.');
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
    
    
    */
    
    
    
    /* AR Claims Details 
    
     -- Bulk collect the AR Claims Approval records to be interfaced
  -- **notes** 1. frees the cursor and rollback space
  write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'Open and bulk collect csr_approval cursor.');
  tbl_work.delete;
  open csr_approval;
  fetch csr_approval bulk collect into tbl_work;
  close csr_approval;
  write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'Number of AR Claim Approval records: Promax Company:' || i_pmx_cmpny_code ||' Promax Division:' || i_pmx_div_code || ';' || 'Count:' || to_char(tbl_work.count) || '.');

  -- If there are no AR Claim Approval records to process then exit procedure (to avoid sending empty interface files).
  IF tbl_work.count = 0 THEN
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'No AR Claim Approvals to process for Promax Company:' || i_pmx_cmpny_code || ' Promax Division:' || i_pmx_div_code ||'.');
  ELSE
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'Processing AR Claim Approvals.');

    -- Lookup the GL Account Code.
    pv_status := pds_lookup.lookup_cntl_code(i_pmx_cmpny_code, i_pmx_div_code,'COST_ACCOUNT_CODE', v_glcode,pv_log_level + 2, pv_result_msg);
    check_result_status;

    -- Lookup the Currency Code.
    pv_status := pds_lookup.lookup_cntl_code(i_pmx_cmpny_code, i_pmx_div_code,'CURRENCY_CODE',v_currcy_code, pv_log_level + 2, pv_result_msg);
    check_result_status;

    -- Lookup the Profit Centre.
    pv_status := pds_lookup.lookup_cntl_code(i_pmx_cmpny_code, i_pmx_div_code,'PROFIT_CENTRE_CODE',v_profit_ctr, pv_log_level + 2, pv_result_msg);
    check_result_status;

    -- Lookup the No Tax Code.
    pv_status := pds_lookup.lookup_cntl_code(i_pmx_cmpny_code, i_pmx_div_code,'NOTAX_CODE',v_notax_code, pv_log_level + 2, pv_result_msg);
    check_result_status;

    -- Lookup the Atlas Company and Division Codes.
    pv_status := pds_lookup.lookup_cmpny_div_code (i_pmx_cmpny_code, i_pmx_div_code, v_cmpny_code, v_div_code, pv_log_level + 2, pv_result_msg);
    check_result_status;

    v_sap_cmpny_code := RPAD(v_cmpny_code,4);

    -- Now start processing the approvals.
    v_counter_approvals := 0;
    
    -- Looping through csr_approval cursor array.
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'Looping through csr_approval cursor array.');
    s_cmpny_code := null;
    for idx in 1..tbl_work.count loop

      -- Start change in group variables
      if s_cmpny_code is null or
         tbl_work(idx).cmpny_code != s_cmpny_code or
         tbl_work(idx).div_code != s_div_code or
         tbl_work(idx).internal_claim_num != s_internal_claim_num or
         tbl_work(idx).claim_ref != s_claim_ref or
         tbl_work(idx).cust_code != s_cust_code or
         tbl_work(idx).prom_num != s_prom_num or
         tbl_work(idx).doc_type != s_doc_type or
         tbl_work(idx).pb_date != s_pb_date or
         tbl_work(idx).tran_date != s_tran_date then
    
        -- Finalise the previous header when required
        if not(s_cmpny_code is null) then

          -- Update the previous header "R" claim amd tax totals
          rcd_approval_detail(s_item_count) := substr(rcd_approval_detail(s_item_count),1,11)||
                                               TO_CHAR(-1*(s_claim_amt + s_tax_amt),'9999999999999999999.99')||
                                               substr(rcd_approval_detail(s_item_count),35);                                                                                            

          -- Build the AR Claims Approval Tax output record.
          IF v_taxfree_found THEN
            v_item_count := v_item_count + 1;
            rcd_approval_detail(v_item_count) := 'T' || -- Indicator.
              v_tax_code ||
              RPAD( ' ',20) ||
              '000' ||
              TO_CHAR(v_taxfree_base,'9999999999999999999.99')||
              RPAD( ' ',8);
          END IF;
          IF v_tax_found THEN
            v_item_count := v_item_count + 1;
            rcd_approval_detail(v_item_count) := 'T' || -- Indicator.
              v_tax_code ||
              TO_CHAR(v_tax,'9999999999999999999.99')||
              TO_CHAR(v_tax_base,'9999999999999999999.99')||
              RPAD( ' ',4) ||
              RPAD( ' ',3);
          END IF;

          
          Now update the SAP ARClaims record (in pds_ar_claims). This is to identify that
          the original AR Claim has now been approved. Used in AR Claim when validating \
          the status of a claim (ie has it loaded into Promax, has it been approved?).
          CF 01/08/2006 Only update the record which loaded into Promax (ie the VALID Claim).
          
          UPDATE pds_ar_claims
            SET promax_ar_apprvl_date = sysdate
          WHERE acctg_doc_num = v_acctg_doc_num
            AND fiscl_year = v_fiscal_year
            AND line_item_num = v_line_item_num
            AND valdtn_status = pc_valdtn_status_valid;

        END IF;

        -- Save the group variables
        write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'Start csr_approval array header.');
        s_cmpny_code := tbl_work(idx).cmpny_code;
        s_div_code := tbl_work(idx).div_code;
        s_internal_claim_num := tbl_work(idx).internal_claim_num;
        s_claim_ref := tbl_work(idx).claim_ref;
        s_cust_code := tbl_work(idx).cust_code;
        s_prom_num := tbl_work(idx).prom_num;
        s_doc_type := tbl_work(idx).doc_type;
        s_pb_date := tbl_work(idx).pb_date;
        s_tran_date := tbl_work(idx).tran_date;
        s_claim_amt := 0;
        s_tax_amt := 0;

        -- Initialise tax values.
        v_tax_base := 0;
        v_tax := 0;
        v_taxfree_base := 0;
        v_tax_found := FALSE;
        v_taxfree_found := FALSE;

        -- Increment the counter.
        v_counter_approvals := v_counter_approvals + 1;

        -- Find the original Customer Code. The outbound claim approval may be for a different
        -- Customer code than the original inbound Claim. Once retrieved, the original claim
        -- Customer Code is stored in a variable and used as a key to lookup the original
        -- inbound claim in the PDS_AR_CLAIMS table. Lookup only performed for Company '47' and '49'.
        pv_status := pds_lookup.lookup_orig_claimdoc_cust_code (tbl_work(idx).cmpny_code, tbl_work(idx).div_code, tbl_work(idx).claim_ref, tbl_work(idx).internal_claim_num, v_promax_cust_code, pv_log_level + 3, pv_result_msg);
        check_result_status;
                   
        /*TL 23/09/2010 Get the tax code directly from the pds_ar_claims instead of the control table. This is to remove the dependence on the hardcoded tax_code variable.
        The Tax_code comes directly from SAP and this is all that is needed to be sent back to SAP*/
        -- Lookup the Tax Code.
        pv_status := pds_lookup.lookup_orig_claimdoc_taxCode(v_cmpny_code, v_div_code, v_promax_cust_code, tbl_work(idx).claim_ref, v_acctg_doc_num, v_fiscal_year, v_line_item_num, v_claim_cust_code, pv_log_level + 3, pv_result_msg, v_taxable_code);
        check_result_status;
                    
        /*
        Atlas segments raise claims in SAP and interface to Promax via the PDS_AR_CLAIMS staging tables.
        To allow a claim to be automatically cleared in SAP, the approved claims must be sent back
        (to SAP) with the original SAP claim document details (ie accounting  document number,
        line number, fiscal year). These key fields were written to the staging table pds_ar_claims
        when the claim was originally interfaced to Promax. This process looks up these key fields
        in the staging table (pds_ar_claims), and stores these values in variables for use in creating
        the interface data.
        */
        pv_status := pds_lookup.lookup_orig_claimdoc (v_cmpny_code, v_div_code, v_promax_cust_code, tbl_work(idx).claim_ref, v_acctg_doc_num, v_fiscal_year, v_line_item_num, v_claim_cust_code, pv_log_level + 3, pv_result_msg);
        check_result_status;
        -- Build the variable for storing the SAP required accounting document fields.
        v_alloc_nmbr:= RPAD(LPAD(v_acctg_doc_num,10,'0') || v_fiscal_year || LPAD(v_line_item_num,3,'0'),18);
        -- Now perform the output Customer Code conversion by using the original customer number.
        -- Customer codes have leading zeroes if they are numeric, otherwise the field
        -- is left justified with spaces padding (on the right). The width returned
        -- is 10 characters, req'd format for SAP (i.e. export).
        pv_status := pds_common.format_cust_code(v_claim_cust_code, v_sap_cust_code, pv_log_level + 3, pv_result_msg);

        -- Build the AR Claims Approval Header output record.
        v_item_count := v_item_count + 1;
        rcd_approval_detail(v_item_count) := 'H' || -- Indicator.
          'IDOC ' || -- Obj Type.
          'PX' || -- Obj Key.
          TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS') || -- Part of Obj Key.
          LPAD(TO_CHAR(v_counter_approvals),4,'0') ||    -- Obj Key Counter.
          'RFBU'|| -- Bus Act.
          'BATCHSCHE   '|| -- Username.
          RPAD('Pmx Claim '|| v_sap_cmpny_code || tbl_work(idx).div_code || -- Header Text.
          ' ' || -- Header Text con't.
          TO_CHAR(SYSDATE,'YYYYMMDD'),25) || -- Header Text con't.
          v_sap_cmpny_code || -- Company Code.
          RPAD(v_currcy_code,5,' ') || -- Currency.
          TO_CHAR(tbl_work(idx).tran_date,'YYYYMMDD') || -- Doc Date.
          TO_CHAR(tbl_work(idx).pb_date,'YYYYMMDD') || -- Posting Date.
          TO_CHAR(tbl_work(idx).pb_date,'YYYYMMDD') || -- Trans Date.
          'UE' ||
          RPAD(tbl_work(idx).claim_ref,16) || -- Ref Doc No.
          RPAD('PROMAX',10); -- Log Sys (req'd for SAP reporting).

        -- Build the AR Claims Approval Customer output record.
        v_item_count := v_item_count + 1;
        s_item_count := v_item_count;
        rcd_approval_detail(v_item_count) := 'R' || -- Indicator.
          LPAD(v_sap_cust_code,10,'0') || -- Customer.
          TO_CHAR(0,'9999999999999999999.99') || -- Amount.
          RPAD(' ',4) || -- Pmnttrms.
          RPAD(' ',8) || -- Bline Date.
          RPAD(' ',1) || -- Payment Block.
          v_alloc_nmbr || -- Alloc Number.
          RPAD('Claim#' || trim(tbl_work(idx).claim_ref) || ' against Promo#' || trim(tbl_work(idx).prom_num),50); -- Item Text.

      -- End change in group variables
      end if;

      -- Increment the item (and array) counter.
      v_item_count := v_item_count + 1;

      -- Sum the claim and tax amounts.
      s_claim_amt := s_claim_amt + tbl_work(idx).claim_amt;
      s_tax_amt := s_tax_amt + tbl_work(idx).tax_amt;

      -- Perform Distribution Channel lookup.
      pv_status := pds_common.format_matl_code(tbl_work(idx).matl_code,v_fmt_matl_code,pv_log_level + 3,pv_result_msg);
      check_result_status;
      pv_status := pds_lookup.lookup_distn_chnl_code (v_fmt_matl_code, v_sap_cust_code,v_distbn_chnl_code, pv_log_level + 3, pv_result_msg);

      /*
      Perform Material Determination lookups/conversions.
      Performs a material determination lookup to the lads database,  based on the
      selection criteria provided which is the promotion number, customer code, and
      the product code.  Ths promotion number is used to find  the start buy and end
      buy dates.  Using these dates overlap detection is applied. The greatest accuracy
      with regards to output data will be received if the start dates and end dates in
      Promax and the material determination tables are aligned. Otherwise the wrong real
      item may be returned.  The detection checking occurs  in the following order, by
      sold to, by Customer hierarchy, by distribution channel,
      */
      pv_status := pds_lookup.lookup_matl_dtrmntn(tbl_work(idx).cmpny_code, tbl_work(idx).div_code, tbl_work(idx).prom_num, tbl_work(idx).cust_code, tbl_work(idx).matl_code, v_matl_code, pv_log_level + 4, pv_result_msg);
      check_result_status;

      -- Now check if the product is taxable.
      IF pds_exist.exist_taxable(tbl_work(idx).cmpny_code, tbl_work(idx).div_code, tbl_work(idx).doc_type,pv_log_level + 4, pv_result_msg) = constants.success THEN
        v_tax_base := v_tax_base + tbl_work(idx).claim_amt;
        v_tax := v_tax + tbl_work(idx).tax_amt;
        v_tax_found := TRUE;
        v_tax_code := v_taxable_code;
      ELSE
        v_taxfree_base := v_taxfree_base + tbl_work(idx).claim_amt;
        v_taxfree_found := TRUE;
        v_tax_code := v_notax_code;
      END IF;

      -- Lookup Plant Code.
      pv_status := pds_lookup.lookup_matl_plant_code(tbl_work(idx).cmpny_code, v_matl_code, v_plant_code, pv_log_level + 4, pv_result_msg);
      check_result_status;

      -- Save the item line to the array. Array will be unloaded when all item lines have been retrieved.
      -- CF 01/08/2006 Include the IC Number as unique identifier in Promax.
      rcd_approval_detail(v_item_count) := 'G' || -- Indicator.
        v_glcode ||
        TO_CHAR((tbl_work(idx).claim_amt),'9999999999999999999.99') ||
        RPAD('IC#' || RTRIM(tbl_work(idx).internal_claim_num)||' Mat' || RTRIM(tbl_work(idx).matl_code)||' Promo' || trim(tbl_work(idx).prom_num) ||' Cus'||RTRIM(tbl_work(idx).cust_code),50) ||
        v_alloc_nmbr ||
        v_tax_code ||
        RPAD(' ',10,' ') || -- Cost Centre always blank.
        RPAD(' ',12,' ') || -- Order Id always blank.
        RPAD(' ',24,' ') || -- WBS element.
        RPAD(' ',13,' ') || -- Quantity.
        RPAD(' ', 3,' ') || -- Base Unit of Measure.
        RPAD(NVL(v_matl_code,' '),18) ||
        v_plant_code || -- plant
        v_sap_cust_code ||
        LPAD(v_profit_ctr,10,'0') || -- Profit Centre.
        RPAD(v_sap_cmpny_code,4) || -- Sales Org.
        RPAD(v_distbn_chnl_code,2); -- Distribution Channel.

      -- Update the processing Status.
      UPDATE pds_ar_claims_apprvl
        SET procg_status = pc_procg_status_completed
      WHERE intfc_batch_code = tbl_work(idx).intfc_batch_code
        AND cmpny_code = tbl_work(idx).cmpny_code
        AND div_code = tbl_work(idx).div_code
        AND ar_claims_apprvl_seq = tbl_work(idx).ar_claims_apprvl_seq;

    -- End of AR Claim Approval header cursor array.
    END LOOP;
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'End of csr_approval cursor array loop.');

    -- Finalise the final header when required
    IF NOT(s_cmpny_code IS NULL) THEN

      -- Update the previous header "R" claim amd tax totals
      rcd_approval_detail(s_item_count) := substr(rcd_approval_detail(s_item_count),1,11)||
                                           TO_CHAR(-1*(s_claim_amt + s_tax_amt),'9999999999999999999.99')||
                                           substr(rcd_approval_detail(s_item_count),35);

      -- Build the AR Claims Approval Tax output record.
      IF v_taxfree_found THEN
        v_item_count := v_item_count + 1;
        rcd_approval_detail(v_item_count) := 'T' || -- Indicator.
          v_tax_code ||
          RPAD( ' ',20) ||
          '000' ||
          TO_CHAR(v_taxfree_base,'9999999999999999999.99')||
          RPAD( ' ',8);
      END IF;
      IF v_tax_found THEN
        v_item_count := v_item_count + 1;
        rcd_approval_detail(v_item_count) := 'T' || -- Indicator.
          v_tax_code ||
          TO_CHAR(v_tax,'9999999999999999999.99')||
          TO_CHAR(v_tax_base,'9999999999999999999.99')||
          RPAD( ' ',4) ||
          RPAD( ' ',3);
      END IF;
      
      */