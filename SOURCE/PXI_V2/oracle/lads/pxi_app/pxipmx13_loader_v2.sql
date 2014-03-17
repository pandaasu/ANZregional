prompt :: Compile Package [pxipmx13_loader_v2] ::::::::::::::::::::::::::::::::::::::::

create or replace package pxi_app.pxipmx13_loader_v2 as
/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System  : LADS
  Package : PXIPMX13_LOADER_V2
  Owner   : PXI_APP
  Author  : Mal Chambeyron

  Description
  ------------------------------------------------------------------------------
  FFLU -> Promax PX - Spendvision Claims - 361SPENDV

  Functions
  ------------------------------------------------------------------------------
  + LICS Hooks
    - on_start                   Called on starting the interface.
    - on_data(i_row in varchar2) Called for each row of data in the interface.
    - on_end                     Called at the end of processing.
  + FFLU Hooks
    - on_get_file_type           Returns the type of file format expected.
    - on_get_csv_qualifier       Returns the CSV file format qualifier.

  Date        Author                Description
  ----------  --------------------  --------------------------------------------
  2014-02-20  Mal Chambeyron        Created Interface
  2014-03-12  Mal Chambeyron        After Promax PX Fix, Forward both Total Amount
                                    and Tax Amount

*******************************************************************************/
  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

  procedure execute;

end pxipmx13_loader_v2;
/

create or replace package body pxi_app.pxipmx13_loader_v2 as

  -- Package Cosntants
  pc_package_name constant pxi_common.st_package_name := 'PXIPMX13_LOADER_V2';
  pc_inbound_interface_name constant pxi_common.st_interface_name := 'SPVPXI13';
  pc_outbound_interface_name constant pxi_common.st_interface_name := 'PXIPMX13';
  pc_schema_name constant pxi_common.st_package_name := 'PXI_APP';

  -- Package Variables
  pv_interface_suffix varchar2(3 char);
  pv_user fflu_common.st_user;

  -- Interface Field Definitions
  pc_company_code constant fflu_common.st_name := 'Company Code';
  pc_division_code constant fflu_common.st_name := 'Division Code';
  pc_cust_code constant fflu_common.st_name := 'Cust Code';
  pc_promotion_code constant fflu_common.st_name := 'Promotion Code';
  pc_claim_amount_ex_gst constant fflu_common.st_name := 'Claim Amount Ex GST';
  pc_tax_amount constant fflu_common.st_name := 'Tax Amount';
  pc_doc_type constant fflu_common.st_name := 'Doc Type';
  pc_claim_code constant fflu_common.st_name := 'Claim Code';
  pc_invoice_date constant fflu_common.st_name := 'Invoice Date';
  pc_claim_comment constant fflu_common.st_name := 'Claim Comment';

/*******************************************************************************
  NAME:      ON_START                                                     PUBLIC
*******************************************************************************/
  procedure on_start is

  begin
    -- Get Interface Suffix
    pv_interface_suffix := fflu_app.fflu_utils.get_interface_suffix;
    if pv_interface_suffix not in (pxi_common.fc_interface_snack,pxi_common.fc_interface_food,pxi_common.fc_interface_pet,pxi_common.fc_interface_nz) then
      pxi_common.raise_promax_error(pc_package_name,'ON_START','Unknown Suffix ['||pv_interface_suffix||'], Expected ['||
        pxi_common.fc_interface_snack||','||
        pxi_common.fc_interface_food||','||
        pxi_common.fc_interface_pet||','||
        pxi_common.fc_interface_nz||']');
    end if;

    -- request lock (on interface)
    begin
      lics_locking.request(pc_inbound_interface_name);
    exception
      when others then
        pxi_common.raise_promax_error(pc_package_name,'EXECUTE',substr('Unable to obtain interface lock ['||pc_inbound_interface_name||'] - '||sqlerrm, 1, 4000));
    end;

    -- Initialise FFLU
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,fflu_data.gc_no_file_header,fflu_data.gc_allow_missing);

    -- Configure FFLU Record
    fflu_data.add_char_field_del(pc_company_code,1,pc_company_code,fflu_data.gc_null_min_length,3,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_del(pc_division_code,2,pc_division_code,fflu_data.gc_null_min_length,3,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_del(pc_cust_code,3,pc_cust_code,fflu_data.gc_null_min_length,10,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_del(pc_promotion_code,4,pc_promotion_code,fflu_data.gc_null_min_length,20,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_number_field_del(pc_claim_amount_ex_gst,5,'9999999990.00',pc_claim_amount_ex_gst,fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_del(pc_tax_amount,6,'9999999990.00',pc_tax_amount,fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_del(pc_doc_type,7,pc_doc_type,fflu_data.gc_null_min_length,1,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_del(pc_claim_code,8,pc_claim_code,fflu_data.gc_null_min_length,20,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_date_field_del(pc_invoice_date,9,pc_invoice_date,'dd/mm/yyyy',fflu_data.gc_null_offset,fflu_data.gc_null_offset_len,fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_del(pc_claim_comment,10,pc_claim_comment,fflu_data.gc_null_min_length,32,fflu_data.gc_allow_null,fflu_data.gc_trim);

    -- Get FFLU User (Must be called after initialising fflu_data, or after fflu_utils.log_interface_progress)
    pv_user := fflu_utils.get_interface_user;

  exception
    when others then
      fflu_data.log_interface_exception('ON_START');
  end on_start;

/*******************************************************************************
  NAME:      ON_DATA                                                      PUBLIC
*******************************************************************************/
  procedure on_data(p_row in varchar2) is

    vr_spendvision pxi.pxi_361_spendv_history%rowtype;
    v_previous_claim_found number;
    v_customer_found number;

  begin

    vr_spendvision.created_by := pv_user;
    vr_spendvision.created_date := sysdate;

    if fflu_data.parse_data(p_row) = true then

      vr_spendvision.company_code := fflu_data.get_char_field(pc_company_code);
      vr_spendvision.division_code := fflu_data.get_char_field(pc_division_code);
      vr_spendvision.cust_code := fflu_data.get_char_field(pc_cust_code);
      vr_spendvision.promotion_code := fflu_data.get_char_field(pc_promotion_code);
      vr_spendvision.claim_amount_ex_gst := fflu_data.get_number_field(pc_claim_amount_ex_gst);
      vr_spendvision.tax_amount := fflu_data.get_number_field(pc_tax_amount);
      vr_spendvision.doc_type := fflu_data.get_char_field(pc_doc_type);
      vr_spendvision.claim_code := fflu_data.get_char_field(pc_claim_code);
      vr_spendvision.invoice_date := fflu_data.get_date_field(pc_invoice_date);
      vr_spendvision.claim_comment := fflu_data.get_char_field(pc_claim_comment);

      -- Check and Set Company Code
      if vr_spendvision.company_code not in ('47','49') then
          fflu_data.log_field_error(pc_company_code,'Expecting [47 (Australia), 49 (New Zealand)]');
      end if;
      vr_spendvision.promax_company_code := '1'||vr_spendvision.company_code;

      -- Check and Set Division Code
      if vr_spendvision.division_code not in ('1','2', '5') then
          fflu_data.log_field_error(pc_division_code,'Expecting [1 (Snack), 2 (Food), 5 (Petcare)]');
      end if;
      if vr_spendvision.company_code = '49' then
        vr_spendvision.promax_division_code := vr_spendvision.promax_company_code;
      else
        vr_spendvision.promax_division_code := '0'||vr_spendvision.division_code;
      end if;

      -- Check Suffix against Expected Promax Company / Division
      case pv_interface_suffix
        when pxi_common.fc_interface_snack then
          if not (vr_spendvision.promax_company_code = pxi_common.fc_australia and vr_spendvision.promax_division_code = pxi_common.fc_bus_sgmnt_snack) then
            fflu_data.log_field_error(pc_division_code,'Wrong Promax Company / Division ['||vr_spendvision.company_code||' / '||vr_spendvision.division_code||
              '] for Suffix ['||pv_interface_suffix||'], Expected ['||ltrim(pxi_common.fc_australia,'1')||' / '||ltrim(pxi_common.fc_bus_sgmnt_snack,'0')||']');
          end if;
        when pxi_common.fc_interface_food then
          if not (vr_spendvision.promax_company_code = pxi_common.fc_australia and vr_spendvision.promax_division_code = pxi_common.fc_bus_sgmnt_food) then
            fflu_data.log_field_error(pc_division_code,'Wrong Promax Company / Division ['||vr_spendvision.company_code||' / '||vr_spendvision.division_code||
              '] for Suffix ['||pv_interface_suffix||'], Expected ['||ltrim(pxi_common.fc_australia,'1')||' / '||ltrim(pxi_common.fc_bus_sgmnt_food,'0')||']');
          end if;
        when pxi_common.fc_interface_pet then
          if not (vr_spendvision.promax_company_code = pxi_common.fc_australia and vr_spendvision.promax_division_code = pxi_common.fc_bus_sgmnt_petcare) then
            fflu_data.log_field_error(pc_division_code,'Wrong Promax Company / Division ['||vr_spendvision.company_code||' / '||vr_spendvision.division_code||
              '] for Suffix ['||pv_interface_suffix||'], Expected ['||ltrim(pxi_common.fc_australia,'1')||' / '||ltrim(pxi_common.fc_bus_sgmnt_petcare,'0')||']');
          end if;
        when pxi_common.fc_interface_nz then
          if not (vr_spendvision.promax_company_code = pxi_common.fc_new_zealand and vr_spendvision.promax_division_code = pxi_common.fc_new_zealand) then
            fflu_data.log_field_error(pc_division_code,'Wrong Promax Company / Division ['||vr_spendvision.company_code||' / '||vr_spendvision.division_code||
              '] for Suffix ['||pv_interface_suffix||'], Expected ['||ltrim(pxi_common.fc_new_zealand,'1')||' / '||ltrim(pxi_common.fc_new_zealand,'0')||']');
          end if;
        else
          fflu_data.log_field_error(pc_division_code,'Unknown Suffix ['||pv_interface_suffix||'], Expected ['||
            pxi_common.fc_interface_snack||','||
            pxi_common.fc_interface_food||','||
            pxi_common.fc_interface_pet||','||
            pxi_common.fc_interface_nz||']');
      end case;

      -- Check if Customer Code Exists
      select count(1) into v_customer_found
      from bds_cust_header
      where customer_code = lpad(vr_spendvision.cust_code, 10, '0');
      if v_customer_found = 0 then
        fflu_data.log_field_error(pc_cust_code,'Customer Code NOT FOUND');
      end if;

      -- Calculate last day of month for Month/Year extracted from [claim_comment], example 'CD_May13_191597'
      begin
        vr_spendvision.promax_invoice_date := last_day(to_date('01'||substr(vr_spendvision.claim_comment,instr(vr_spendvision.claim_comment, '_')+1,5),'DDMONYY'));
      exception
        when others then
          fflu_data.log_field_error(pc_claim_comment,'Extract of Month/Year Failed : '||substr(sqlerrm, 1, 512));
      end;

      -- Check for Claim Code ALREADY Processed - History
      select count(1) into v_previous_claim_found from pxi.pxi_361_spendv_history where claim_code = vr_spendvision.claim_code;
      if v_previous_claim_found > 0 then
        fflu_data.log_field_error(pc_claim_code,'Claim Code has ALREADY been Processed');
      end if;

      -- Check for Claim Code ALREADY Processed - This Load
      select count(1) into v_previous_claim_found from pxi.pxi_361_spendv_history_temp where claim_code = vr_spendvision.claim_code;
      if v_previous_claim_found > 0 then
        fflu_data.log_field_error(pc_claim_code,'Claim Code has ALREADY Encountered This Load');
      end if;

      -- Set Promax Amount
      vr_spendvision.promax_amount := vr_spendvision.claim_amount_ex_gst + vr_spendvision.tax_amount;

      insert into pxi.pxi_361_spendv_history_temp values vr_spendvision;

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

    if fflu_data.was_errors = true then
      rollback;
    else
      execute; -- Create/Send 361SPENDV.txt
      commit;
    end if;
    -- Perform a final cleanup and a last progress logging.
    fflu_data.cleanup;

    -- Release lock (on interface)
    lics_locking.release(pc_inbound_interface_name);

  exception
    when others then
      fflu_data.log_interface_exception('ON_END');
      -- Release lock (on interface)
      lics_locking.release(pc_inbound_interface_name);
  end on_end;

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
*******************************************************************************/
  procedure execute is

    v_interface_name_with_suffix varchar2(64 char);
    v_instance number(15,0);

  begin

    -- Set interface name (including Suffix)
    v_interface_name_with_suffix := pc_outbound_interface_name || '.' || pv_interface_suffix;

    for rv_row in (

      select
        pxi_common.char_format('361002', 6, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT '361002' -> ICRecordType
        pxi_common.char_format(promax_company_code, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_company -> PXCompanyCode
        pxi_common.char_format(promax_division_code, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_division -> PXDivisionCode
        pxi_common.char_format(cust_code, 10, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- cust_code -> AccountCode
        pxi_common.char_format(claim_comment, 20, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- claim_comment -> Reference
        pxi_common.char_format('A', 1, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT 'A' -> ActionFlag
        pxi_common.char_format('1', 1, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- CONSTANT '1' -> Type
        pxi_common.date_format(promax_invoice_date, 'yyyymmdd', pxi_common.fc_is_not_nullable) || -- posting_date -> Date
        pxi_common.char_format(claim_code, 18, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- claim_ref -> Number
        pxi_common.char_format('0', 18, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT '0' -> ParentNumber
        pxi_common.char_format('', 65, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- CONSTANT '' -> ExtReference
        pxi_common.char_format('', 80, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- CONSTANT '' -> InvoiceLink
        pxi_common.char_format('', 5, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- CONSTANT '' -> ReasonCode
        pxi_common.numb_format(promax_amount, '9999999990.00', pxi_common.fc_is_not_nullable) || -- claim_amount_ex_gst -> Amount
        --pxi_common.numb_format(claim_amount_ex_gst, '9999999990.00', pxi_common.fc_is_not_nullable) || -- claim_amount_ex_gst -> Amount
        pxi_common.numb_format(tax_amount, '9999999990.00', pxi_common.fc_is_not_nullable) || -- tax_amount -> TaxAmount
        -- pxi_common.numb_format(0, '9999999990.00', pxi_common.fc_is_not_nullable) || -- tax_amount -> TaxAmount
        pxi_common.char_format('Promotion ['||promotion_code||'] Customer ['||cust_code||'] Vendor ['||case when promax_company_code = '147' then '15110074' when promax_company_code = '149' then '15064445' else '*ERROR' end||']', 256, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- CONSTANT '' -> Note
        -- pxi_common.char_format('', 256, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- CONSTANT '' -> Note
        pxi_common.char_format(case when promax_company_code = '147' then 'AUD' when promax_company_code = '149' then 'NZD' else '***' end, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) -- currency -> Currency
        as output_record
      from pxi.pxi_361_spendv_history_temp

    )
    loop

      -- Create interface when required
      if lics_outbound_loader.is_created = false then
        v_instance := lics_outbound_loader.create_interface(v_interface_name_with_suffix);
      end if;

      -- Append Data
      lics_outbound_loader.append_data(rv_row.output_record);

    end loop;

    -- Add current Spendvision Transactions to History
    insert into pxi.pxi_361_spendv_history select * from pxi.pxi_361_spendv_history_temp; -- pxi_361_spendv_history and pxi_361_spendv_history_temp have identical structures

    -- Finalise interface when required
    if lics_outbound_loader.is_created = true then
      lics_outbound_loader.finalise_interface;
    end if;

    -- Commit Spendvision Transactions to History
    commit;

  exception
    when others then
      rollback;
       if lics_outbound_loader.is_created = true then
         lics_outbound_loader.add_exception(substr(sqlerrm, 1, 512));
         lics_outbound_loader.finalise_interface;
       end if;
       fflu_data.log_interface_exception('EXECUTE');
  end execute;

/*******************************************************************************
  NAME:      ON_GET_FILE_TYPE                                             PUBLIC
*******************************************************************************/
  function on_get_file_type return varchar2 is
  begin
    return fflu_common.gc_file_type_csv;
  end on_get_file_type;

/*******************************************************************************
  NAME:      ON_GET_CSV_QUALIFER                                          PUBLIC
*******************************************************************************/
  function on_get_csv_qualifier return varchar2 is
  begin
    return fflu_common.gc_csv_qualifier_null;
  end on_get_csv_qualifier;

end pxipmx13_loader_v2;
/

grant execute on pxi_app.pxipmx13_loader_v2 to lics_app, fflu_app, site_app;
