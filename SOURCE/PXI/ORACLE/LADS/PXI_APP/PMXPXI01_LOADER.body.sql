create or replace 
package body pmxpxi01_loader as

/*******************************************************************************
  Package Constants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'PMXPXI01_LOADER';
  
/*******************************************************************************
  Interface Field Definitions
*******************************************************************************/  
  pc_ic_record_type constant fflu_common.st_name := 'IC Record Type';
  pc_px_company_code constant fflu_common.st_name := 'PX Company Code';
  pc_px_division_code constant fflu_common.st_name := 'PX Division Code';
  pc_rec_type constant fflu_common.st_name := 'Rec Type';
  pc_document_date constant fflu_common.st_name := 'Document Date';
  pc_posting_date constant fflu_common.st_name := 'Posting Date';
  pc_document_type constant fflu_common.st_name := 'Document Type';
  pc_currency constant fflu_common.st_name := 'Currency';
  pc_reference constant fflu_common.st_name := 'Reference';
  pc_document_header_text constant fflu_common.st_name := 'Document Header Text';
  pc_posting_key constant fflu_common.st_name := 'Posting Key';
  pc_account constant fflu_common.st_name := 'Account';
  pc_pa_assignment_flag constant fflu_common.st_name := 'PA Assignment Flag';
  pc_amount constant fflu_common.st_name := 'Amount';
  pc_payment_method constant fflu_common.st_name := 'Payment Method';
  pc_allocation constant fflu_common.st_name := 'Allocation';
  pc_text constant fflu_common.st_name := 'Text';
  pc_profit_centre constant fflu_common.st_name := 'Profit Centre';
  pc_cost_centre constant fflu_common.st_name := 'cost Centre';
  pc_sales_organisation constant fflu_common.st_name := 'Sales Organisation';
  pc_sales_office constant fflu_common.st_name := 'Sales Office';
  pc_product_number constant fflu_common.st_name := 'Product Number';
  pc_pa_code constant fflu_common.st_name := 'PA Code';
  pc_glt_row_id constant fflu_common.st_name := 'GLT Row Id';
  pc_user_1 constant fflu_common.st_name := 'User 1';
  pc_user_2 constant fflu_common.st_name := 'User 2';
  pc_buy_start_date constant fflu_common.st_name := 'Buy Start Date';
  pc_buy_stop_date constant fflu_common.st_name := 'Buy Stop Date';
  pc_start_date constant fflu_common.st_name := 'Start Date';
  pc_stop_date constant fflu_common.st_name := 'Stop Date';
  pc_quantity constant fflu_common.st_name := 'Quantity';
  pc_additional_info constant fflu_common.st_name := 'Additional Info';
  pc_promotion_is_closed constant fflu_common.st_name := 'Promotion Is Closed';

  -- Posting Key
  subtype st_posting_key is varchar2(4);
  pc_posting_key_dr constant st_posting_key := 'DR';    -- Debit   Positive
  pc_posting_key_cr constant st_posting_key := 'CR';    -- Credit  Negative
  pc_posting_key_wcr constant st_posting_key := 'WCR';  -- Writeback Credit  Positive
  pc_posting_key_wdr constant st_posting_key := 'WDR';  -- Writeback Debit   Negative

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
    fflu_data.add_char_field_txt(pc_ic_record_type,1,6,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_px_company_code,7,3,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_px_division_code,10,3,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_rec_type,13,1,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_date_field_txt(pc_document_date,14,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_txt(pc_posting_date,22,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_txt(pc_document_type,30,2,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_currency,32,3,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_reference,35,16,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_document_header_text,51,25,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_posting_key,76,4,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_account,80,17,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_pa_assignment_flag,97,1,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_number_field_txt(pc_amount,98,13,'9999999999.99',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_txt(pc_payment_method,111,1,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_allocation,112,18,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_text,130,30,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_profit_centre,160,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_cost_centre,170,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_sales_organisation,180,4,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_sales_office,184,5,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_product_number,189,18,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_pa_code,207,5,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_glt_row_id,212,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_user_1,222,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_user_2,232,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_date_field_txt(pc_buy_start_date,242,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_txt(pc_buy_stop_date,250,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_txt(pc_start_date,258,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_txt(pc_stop_date,266,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_txt(pc_quantity,274,15,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_additional_info,289,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_promotion_is_closed,299,1,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
  exception 
    when others then 
      fflu_data.log_interface_exception('ON_START');
end on_start;

/*******************************************************************************
  NAME:      ON_DATA                                                      PUBLIC
*******************************************************************************/  
  procedure on_data(p_row in varchar2) is 
    rv_gl pxiatl01_extract.rt_gl_record;
    v_bus_sgmnt pxi_common.st_bus_sgmnt; 
  begin
    -- Initialse Variable
    v_bus_sgmnt := null;
    -- Now parse the row. 
    if fflu_data.parse_data(p_row) = true then
      -- Only look for detail records at this time, header records are ignored.
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
        -- Assign the various number fields.
        rv_gl.tax_amount := 0;
        rv_gl.tax_amount_base := fflu_data.get_number_field(pc_amount);
        -- Update the amount field based on the various posting keys.  
        case fflu_data.get_char_field(pc_posting_key)
          when pc_posting_key_dr then 
            rv_gl.tax_amount_base := rv_gl.tax_amount_base * 1;
          when pc_posting_key_cr then 
            rv_gl.tax_amount_base := rv_gl.tax_amount_base * -1;
          when pc_posting_key_wcr then 
            rv_gl.tax_amount_base := rv_gl.tax_amount_base * 1;
          when pc_posting_key_wdr then
            rv_gl.tax_amount_base := rv_gl.tax_amount_base * -1;
          else
            fflu_data.log_field_error(pc_posting_key,'Unknown Posting Key');
        end case;
        -- Now set amount to the same as tax amount base so that the zero sum
        -- check works correctly to find a correct break point for large 
        -- accruals.
        rv_gl.amount := rv_gl.tax_amount_base;
        -- Create the Item Reference Field.  Product, Customer, Promo, Text.
        rv_gl.item_text := rpad(
          fflu_data.get_char_field(pc_product_number) || ' ' || -- ZREP
          fflu_data.get_char_field(pc_allocation) || ' ' ||  -- Customer
          fflu_data.get_char_field(pc_reference) ||  ' ' || -- Promo Num
          fflu_data.get_char_field(pc_text), -- Accrual Text 
          50);
        -- Promax Internal Reference ID.
        rv_gl.alloc_ref := fflu_data.get_char_field(pc_glt_row_id);
        -- Define the tax Code as a Constant.
        rv_gl.tax_code := pxi_common.gc_tax_code_gl;
        -- COPA Related Fields
        rv_gl.sales_org := fflu_data.get_char_field(pc_px_company_code);
        -- Assign an empty vendor value to this field.
        rv_gl.vendor_code := pxi_common.full_vend_code(null);  
        -- Lookup the business segment for the curent material. 
        v_bus_sgmnt := pxi_utils.determine_bus_sgmnt(
          fflu_data.get_char_field(pc_px_company_code),
          fflu_data.get_char_field(pc_px_division_code),
          fflu_data.get_char_field(pc_product_number));
        if v_bus_sgmnt is null then 
          fflu_data.log_field_error(pc_px_division_code,'Could not determine a business segment from company, promax division, and zrep.');
        end if;
        -- Now lookup the traded unit material code.
        rv_gl.material_code := pxi_utils.lookup_tdu_from_zrep(
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
        -- Now lookup the plant code from the traded unit and distribution channels from the zrep.
        rv_gl.plant_code := pxi_utils.determine_matl_plant_code(
          fflu_data.get_char_field(pc_px_company_code),
          rv_gl.material_code);
        rv_gl.dstrbtn_chnnl := pxi_utils.determine_dstrbtn_chnnl(
          fflu_data.get_char_field(pc_px_company_code),
          fflu_data.get_char_field(pc_product_number),
          fflu_data.get_char_field(pc_allocation));  -- Customer
        -- Other unused fields.
        rv_gl.claim_text := null;
        -- Now add this record to the general ledger collection.
        ptv_gl_data(ptv_gl_data.count+1) := rv_gl;
      end if;
    end if;
  exception 
    when others then 
      fflu_data.log_interface_exception('ON_DATA');
  end on_data;
  
/*******************************************************************************
  NAME:      ON_END                                                       PUBLIC
*******************************************************************************/  
  procedure on_end is 
  begin 
    -- Only perform a commit if there were no errors at all. 
    if fflu_data.was_errors = false then 
      if pxiatl01_extract.sum_gl_data(ptv_gl_data) <> 0 then 
        fflu_utils.log_interface_error(
         pc_amount,pxiatl01_extract.sum_gl_data(ptv_gl_data),'Expected sum of accrual amounts to equal zero.');
      elsif ptv_gl_data.count = 0 then
        fflu_utils.log_interface_error('General Ledger Count',ptv_gl_data.count,'No accrual detail records were supplied.');
      else 
        -- Now lets create the atlas IDOC interfaces with the data we have in 
        -- memory.
        pxiatl01_extract.send_data(ptv_gl_data,pxiatl01_extract.gc_doc_type_accrual,'ICS ID : ' || fflu_utils.get_interface_no);
      end if;
    end if;
    -- Perform a final cleanup and a last progress logging.
    fflu_data.cleanup;
  exception 
    when others then 
      fflu_utils.log_interface_exception('ON_END');
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
end pmxpxi01_loader;
/

