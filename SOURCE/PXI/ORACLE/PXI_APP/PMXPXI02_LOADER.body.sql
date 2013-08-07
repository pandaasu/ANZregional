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

  -- Posting Key
  subtype st_posting_key is varchar2(2);
  pc_posting_key_payment_credit  st_posting_key := '11';   -- Payment Credit
  pc_posting_key_payment_debit   st_posting_key := '40';   -- Payment Debit
  pc_posting_key_reversal_credit st_posting_key := '1';    -- Reversal Credit
  pc_posting_key_reversal_debit  st_posting_key := '50';   -- Reversal Debit
  subtype st_flag is varchar2(2 char);
  pc_cust_is_vendor st_flag := 'V';   -- This is a vendor payment.

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
    fflu_data.add_char_field_txt(pc_ic_record_type,1,6,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_px_company_code,7,3,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_px_division_code,10,3,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_type,13,1,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_date_field_txt(pc_document_date,14,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_txt(pc_posting_date,22,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_txt(pc_claim_date,30,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_txt(pc_reference,38,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_document_header_text,48,25,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_expenditure_type,73,5,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_posting_key,78,7,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_account_code,85,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_number_field_txt(pc_amount,95,14,'99999999999.99',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_txt(pc_spend_amount,109,14,'99999999999.99',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_txt(pc_tax_amount,123,14,'99999999999.99',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_txt(pc_payment_method,137,1,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_allocation,138,12,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_pc_reference,150,18,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_px_reference,168,60,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_ext_reference,228,65,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_product_number,293,18,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_transaction_code,311,40,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_deduction_ac_code,351,20,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_payee_code,371,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_debit_code,381,20,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_credit_code,401,20,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_customer_is_a_vendor,421,1,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_currency,422,3,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_promo_claim_detail_row_id,425,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_promo_claim_group_row_id,435,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_promo_claim_group_pub_id,445,30,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_reason_code,475,5,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_pc_message,480,65,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_pc_comment,545,200,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_text_1,745,40,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_text_2,785,40,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_date_field_txt(pc_buy_start_date,825,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_txt(pc_buy_stop_date,833,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_txt(pc_bom_header_sku_stock_code,841,40,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
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
      if fflu_data.get_char_field(pc_type) = 'D' then 
        -- Header Reference Fields.
        rv_gl.company := fflu_data.get_char_field(pc_px_company_code);
        rv_gl.promax_division := fflu_data.get_char_field(pc_px_division_code);
        rv_gl.posting_date := fflu_data.get_date_field(pc_posting_date);
        rv_gl.document_date := fflu_data.get_date_field(pc_document_date);
        rv_gl.currency := fflu_data.get_char_field(pc_currency);
        -- Now commence processing this accrual into actual atlas extract records.
        rv_gl.cost_center := null;
        rv_gl.profit_center := null;
        rv_gl.amount := fflu_data.get_number_field(pc_amount);
        rv_gl.tax_amount := fflu_data.get_number_field(pc_tax_amount);
        rv_gl.tax_amount_base := fflu_data.get_number_field(pc_spend_amount);
        if rv_gl.amount <> rv_gl.tax_amount + rv_gl.tax_amount_base then 
          fflu_data.log_field_error(pc_amount,'Was not equal to spend amount plus the tax amount, it was [' || (rv_gl.tax_amount + rv_gl.tax_amount_base) || '.');
        end if;
        -- Now lookup the tax reason code to use for the processing.
        -- Note : This will have to be updated for Australia.
        if rv_gl.tax_amount > 0 then 
          rv_gl.tax_code := pxi_common.gc_tax_code_s2;
        else 
          rv_gl.tax_code := pxi_common.gc_tax_code_s3; 
        end if;
        -- Perform any speicifc posting key functionality.  
        -- NOTE : Of which there is no special processing at this stage. Left as a template for future if required.  
        case fflu_data.get_char_field(pc_posting_key)
          when pc_posting_key_payment_debit then null;
          when pc_posting_key_payment_credit then null;
          when pc_posting_key_reversal_debit then null;
          when pc_posting_key_reversal_credit then null;
          else
            fflu_data.log_field_error(pc_posting_key,'Unknown Posting Key');
        end case;
        -- Specific AP Claims processing / Setup
        if fflu_data.get_char_field(pc_customer_is_a_vendor) = pc_cust_is_vendor then 
          -- Set the account code to be the same as the promax debit code field.
          rv_gl.account_code :=  fflu_data.get_char_field(pc_credit_code);
          -- Set the vendor and customer
          rv_gl.vendor_code := fflu_data.get_char_field(pc_payee_code);
          rv_gl.customer_code := pxi_common.full_cust_code(null);
          -- Accounts Payable GL Item Text.
          rv_gl.item_text := rpad(
            'AP ' || 
            'Ref#' || 
            fflu_data.get_char_field(pc_allocation) || 
            ' Pm#' || 
            fflu_data.get_char_field(pc_reference) || ' Vn#' || 
            fflu_data.get_char_field(pc_payee_code)
            ,50);
          -- Set the allocation reference field to be allocation field from promax as well.
          rv_gl.alloc_ref := fflu_data.get_char_field(pc_allocation);
        else 
          -- Specific AR Claims Processing / Setup
          -- Set the vendor and customer
          rv_gl.vendor_code := pxi_common.full_vend_code(null);
          rv_gl.customer_code := fflu_data.get_char_field(pc_account_code);        
          -- Accounts Receivable GL Item Text.
          rv_gl.item_text := rpad(
            'AR ' ||
            'IC#' ||
            fflu_data.get_char_field(pc_pc_reference) || 
            ' Prom#' || 
            fflu_data.get_char_field(pc_reference) ||
            ' Mt#' ||
            fflu_data.get_char_field(pc_product_number) ||
            ' Cs#' ||
            fflu_data.get_char_field(pc_account_code),50);
          -- Set the allocation reference field to be the external supplied promax reference.
          rv_gl.alloc_ref := fflu_data.get_char_field(pc_ext_reference);
        end if;
        -- COPA Related Fields
        -- Set the sales organsiation
        rv_gl.sales_org := fflu_data.get_char_field(pc_px_company_code);
        -- Set the distribution channel.
        rv_gl.dstrbtn_chnnl := pxi_common.determine_dstrbtn_chnnl(
          fflu_data.get_char_field(pc_px_company_code),
          fflu_data.get_char_field(pc_product_number),
          fflu_data.get_char_field(pc_account_code));  -- Customer
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
          case v_bus_sgmnt 
            when pxi_common.gc_bus_sgmnt_snack then 
              rv_gl.profit_center := '0000110001';
            when pxi_common.gc_bus_sgmnt_food then 
              rv_gl.profit_center := '0000110006';
            when pxi_common.gc_bus_sgmnt_petcare then 
              rv_gl.profit_center := '0000110005';
            else 
              fflu_data.log_field_error(pc_product_number,'Tried to determine profit center from business segment.  Which was unknown [' || v_bus_sgmnt || ']');
          end case;
        end if; 
        -- Now lookup the plant code from the traded unit material code.  
        rv_gl.plant_code := pxi_common.determine_matl_plant_code(
          fflu_data.get_char_field(pc_px_company_code),
          rv_gl.material_code);
        -- Now add this record to the general ledger collections / if V put as a vendor payment. 
        if fflu_data.get_char_field(pc_customer_is_a_vendor) = pc_cust_is_vendor then 
          ptv_gl_ap_data(ptv_gl_ap_data.count+1) := rv_gl;
        else 
          ptv_gl_ar_data(ptv_gl_ar_data.count+1) := rv_gl;
        end if;
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
      pxiatl01_extract.send_data(ptv_gl_ap_data,pxiatl01_extract.gc_doc_type_ap_claim,null);
      -- Send Accounts Receivable Claims
      pxiatl01_extract.send_data(ptv_gl_ar_data,pxiatl01_extract.gc_doc_type_ar_claim,null);
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