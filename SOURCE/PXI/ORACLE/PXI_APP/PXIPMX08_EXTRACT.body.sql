create or replace 
PACKAGE body PXIPMX08_EXTRACT AS

/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'PXIPMX08_EXTRACT';
  pc_interface_name constant pxi_common.st_interface_name := 'PXIPMX08';

/*******************************************************************************
  Package Variables
*******************************************************************************/
  pv_inbound_rec rt_inbound;
  pv_inbound_array tt_inbound_array;
/*******************************************************************************
  Interface Field Definitions
*******************************************************************************/
  pc_rec_type constant fflu_common.st_name := 'Rec Type';
  pc_rec_type_control constant fflu_common.st_string := 'CTL';
  pc_rec_type_detail constant fflu_common.st_string := 'DET';

  -- CTL (pc_rec_type_control)
  pc_idoc_type constant fflu_common.st_name := 'iDoc Type';
  pc_idoc_no constant fflu_common.st_name := 'iDoc No';
  pc_idoc_date constant fflu_common.st_name := 'iDoc Date';

  -- DET (pc_rec_type_detail)
  pc_company_code constant fflu_common.st_name := 'Company Code';
  pc_div_code constant fflu_common.st_name := 'Div Code';
  pc_cust_code constant fflu_common.st_name := 'Cust Code';
  pc_claim_amount constant fflu_common.st_name := 'Claim Amount';
  pc_claim_ref constant fflu_common.st_name := 'Claim Ref';
  pc_assignment_no constant fflu_common.st_name := 'Assignment No';
  pc_tax_base constant fflu_common.st_name := 'Tax Base';
  pc_posting_date constant fflu_common.st_name := 'Posting Date';
  pc_fiscal_period constant fflu_common.st_name := 'Fiscal Period';
  pc_reason_code constant fflu_common.st_name := 'Reason Code';
  pc_accounting_doc_no constant fflu_common.st_name := 'Accounting Doc No';
  pc_fiscal_year constant fflu_common.st_name := 'Fiscal Year';
  pc_line_item_no constant fflu_common.st_name := 'Line Item No';
  pc_bus_partner_ref constant fflu_common.st_name := 'Bus Partner Ref';
  pc_tax_code constant fflu_common.st_name := 'Tax Code';

/*******************************************************************************
  NAME:      ON_START                                                     PUBLIC
*******************************************************************************/
  procedure on_start is
  begin
    -- Now initialise the data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,fflu_data.gc_no_csv_header,fflu_data.gc_allow_missing);

    -- Control Record - Type
    fflu_data.add_record_type_txt(pc_rec_type,1,3,pc_rec_type_control);
    -- Control Record - Fields
    fflu_data.add_char_field_txt(pc_idoc_type,4,30,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_number_field_txt(pc_idoc_no,34,16,'9999999999999990',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_txt(pc_idoc_date,50,14,'yyyymmddhh24miss',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);

    -- Detail Record - Type
    fflu_data.add_record_type_txt(pc_rec_type,1,3,pc_rec_type_detail);
    -- Detail Record - Fields
    fflu_data.add_char_field_txt(pc_company_code,4,3,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_div_code,7,3,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_cust_code,10,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_number_field_txt(pc_claim_amount,20,15,'9999999990.0000',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_txt(pc_claim_ref,35,12,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_assignment_no,47,18,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_number_field_txt(pc_tax_base,65,15,'9999999990.0000',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_txt(pc_posting_date,80,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_txt(pc_fiscal_period,88,2,'90',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_txt(pc_reason_code,90,3,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_number_field_txt(pc_accounting_doc_no,93,10,fflu_data.gc_null_format,fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_txt(pc_fiscal_year,103,4,'9990',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_txt(pc_line_item_no,107,3,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_bus_partner_ref,110,12,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_tax_code,122,2,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);

    -- Empty Inbound Array
    pv_inbound_array.delete;

  exception
    when others then
      fflu_data.log_interface_exception('ON_START');
  end on_start;

/*******************************************************************************
  NAME:      ON_DATA                                                      PUBLIC
*******************************************************************************/
  procedure on_data(p_row in varchar2) is
    v_ok boolean;
  begin
    if fflu_data.parse_data(p_row) = true then

      -- Switch on Record Type ..
      case fflu_data.get_record_type
        when pc_rec_type_control then
          begin
            if trim(fflu_data.get_char_field(pc_idoc_type)) = 'FIDCCP02' then
              pv_inbound_rec.idoc_type := fflu_data.get_char_field(pc_idoc_type);
              pv_inbound_rec.idoc_no := fflu_data.get_number_field(pc_idoc_no);
              pv_inbound_rec.idoc_date := fflu_data.get_date_field(pc_idoc_date);
            else
              fflu_data.log_field_error(pc_rec_type,'Unexpected iDoc Type Value [' || fflu_data.get_char_field(pc_idoc_type) || '].');
            end if;
          end;
        when pc_rec_type_detail then null;
          begin
            pv_inbound_rec.company_code := fflu_data.get_char_field(pc_company_code);
            pv_inbound_rec.div_code := fflu_data.get_char_field(pc_div_code);
            pv_inbound_rec.cust_code := fflu_data.get_char_field(pc_cust_code);
            pv_inbound_rec.claim_amount := fflu_data.get_number_field(pc_claim_amount);
            pv_inbound_rec.claim_ref := fflu_data.get_char_field(pc_claim_ref);
            pv_inbound_rec.assignment_no := fflu_data.get_char_field(pc_assignment_no);
            pv_inbound_rec.tax_base := fflu_data.get_number_field(pc_tax_base);
            pv_inbound_rec.posting_date := fflu_data.get_date_field(pc_posting_date);
            pv_inbound_rec.fiscal_period := fflu_data.get_number_field(pc_fiscal_period);
            pv_inbound_rec.reason_code := fflu_data.get_char_field(pc_reason_code);
            pv_inbound_rec.accounting_doc_no := fflu_data.get_number_field(pc_accounting_doc_no);
            pv_inbound_rec.fiscal_year := fflu_data.get_number_field(pc_fiscal_year);
            pv_inbound_rec.line_item_no := fflu_data.get_char_field(pc_line_item_no);
            pv_inbound_rec.bus_partner_ref := fflu_data.get_char_field(pc_bus_partner_ref);
            pv_inbound_rec.tax_code := fflu_data.get_char_field(pc_tax_code);
            --
            /******************************************************************/
            /* 31/07/2006 CF: Only load TP Claims into PDS (previously all Accounting Document lines were loaded).
            /* Division (Business Segment) is derived in ICS only for Accounting Document lines which
            /* have a TP Claim Reason Codes ..
            /* - Food =  '40', '41', '51'
            /* - Snack = '42', '43', '53'
            /* - Pet =   '44', '45', '55'
            /* Ignore any Accounting Document line which does not have a Division (as it will be non-TP)
            /******************************************************************/
            if trim(pv_inbound_rec.reason_code) in ('40', '41', '42', '43', '44', '45', '51', '53', '55') then
              pv_inbound_array(pv_inbound_array.count+1) := pv_inbound_rec;
            end if;
          end;
        else
          begin
            fflu_data.log_field_error(pc_rec_type,'Unexpected Record Type Value [' || fflu_data.get_record_type || '].');
          end;
      end case;

    end if;
  exception
    when others then
      fflu_data.log_interface_exception('ON_DATA');
  end on_data;

/*******************************************************************************
  NAME:      EXECUTE (*MUST* be loacated before ON_END, as is Private)   PRIVATE
*******************************************************************************/
   procedure execute is
    -- Variables     
     v_instance number(15,0);
     v_data pxi_common.st_data;
 
     -- The extract query.
     cursor csr_input is
        --======================================================================
        select
        ------------------------------------------------------------------------
        -- FORMAT OUTPUT
        ------------------------------------------------------------------------
          pxi_common.char_format('361001', 6, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT '361001' -> ICRecordType
          pxi_common.char_format(promax_company, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_company -> PXCompanyCode
          pxi_common.char_format(promax_division, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_division -> PXDivisionCode
          pxi_common.char_format(bus_partner_ref, 10, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_not_nullable) || -- bus_partner_ref -> AccountCode
          pxi_common.char_format(tax_cust_ref, 20, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- tax_cust_ref -> Reference
          pxi_common.char_format('A', 1, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT 'A' -> ActionFlag
          pxi_common.char_format('1', 1, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- CONSTANT '1' -> Type
          pxi_common.date_format(posting_date, 'yyyymmdd', pxi_common.fc_is_not_nullable) || -- posting_date -> Date
          pxi_common.char_format(claim_ref, 18, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- claim_ref -> Number
          pxi_common.char_format('0', 18, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT '0' -> ParentNumber
          pxi_common.char_format(assignment_no, 65, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- assignment_no -> ExtReference
          pxi_common.char_format('', 80, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- CONSTANT '' -> InvoiceLink
          pxi_common.char_format(reason_code, 5, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- reason_code -> ReasonCode
          pxi_common.numb_format(amount, '9999999990.00', pxi_common.fc_is_not_nullable) || -- amount -> Amount
          pxi_common.numb_format(tax_amount, '9999999990.00', pxi_common.fc_is_not_nullable) || -- tax_amount -> TaxAmount
          pxi_common.char_format('', 256, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- CONSTANT '' -> Note
          pxi_common.char_format(currency, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) -- currency -> Currency
        ------------------------------------------------------------------------
        from (
        ------------------------------------------------------------------------
        -- SQL
        ------------------------------------------------------------------------
          /*****************************
          /* TP Claim Reason Codes ..
          /* - Food =  '40', '41', '51'
          /* - Snack = '42', '43', '53'
          /* - Pet =   '44', '45', '55'
            --
          *****************************/
          select
            t1.company_code as promax_company,
            case t1.company_code when pxi_common.gc_australia then t1.div_code when pxi_common.gc_new_zealand then pxi_common.gc_new_zealand else null end as promax_division,
            trim(t1.bus_partner_ref) as bus_partner_ref,
            decode(nvl(trim(t1.reason_code),'99'), '40', 'No Tax', '42', 'No Tax', '44', 'No Tax', 'Inc Tax') || ' ' || ltrim(t1.cust_code, 0) tax_cust_ref, -- No Tax for Reason Code 40, 42, 44 .. Else Inc Tax
            t1.posting_date,
            t1.claim_ref,
            t1.assignment_no,
            t1.reason_code,
            t1.claim_amount + t1.tax_base as amount,
            t1.tax_base as tax_amount,
            case t1.company_code when pxi_common.gc_australia then 'AUD' when pxi_common.gc_new_zealand then 'NZD' else null end as currency
         from
            table(get_inbound) t1
        ------------------------------------------------------------------------
        );
        --======================================================================

  begin
     -- Open cursor with the extract data.
     open csr_input;
     loop
       fetch csr_input into v_data;
       exit when csr_input%notfound;
      -- Create the new interface when required
      if lics_outbound_loader.is_created = false then
        v_instance := lics_outbound_loader.create_interface(pc_interface_name);
      end if;
      -- Append the interface data
      lics_outbound_loader.append_data(v_data);
    end loop;
    close csr_input;

    -- Finalise the interface when required
    if lics_outbound_loader.is_created = true then
      lics_outbound_loader.finalise_interface;
    end if;

  exception
     when others then
       rollback;
       if lics_outbound_loader.is_created = true then
         lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
         lics_outbound_loader.finalise_interface;
       end if;
       pxi_common.reraise_promax_exception(pc_package_name,'EXECUTE');
   end execute;

/*******************************************************************************
  NAME:      ON_END                                                       PUBLIC
*******************************************************************************/
  procedure on_end is
  begin
    -- Only perform a commit if there were no errors at all.
    if fflu_data.was_errors = true then
      rollback;
    else
      execute; -- outbound processing
      commit;
    end if;
    -- Perform a final cleanup and a last progress logging.
    fflu_data.cleanup;
  exception
    when others then
      fflu_data.log_interface_exception('ON_END');
  end on_end;

/*******************************************************************************
  NAME:      GET_INBOUND                                                  PUBLIC
*******************************************************************************/
  function get_inbound return tt_inbound pipelined is
    v_counter pls_integer;
  begin
     v_counter := 0;
     loop
       v_counter := v_counter + 1;
       exit when v_counter > pv_inbound_array.count;
       pipe row(pv_inbound_array(v_counter));
     end loop;
  end get_inbound;

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

END PXIPMX08_EXTRACT;