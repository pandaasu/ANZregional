create or replace PACKAGE body PXIPMX08_EXTRACT AS

/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'PXIPMX08_EXTRACT';
  pc_interface_name constant pxi_common.st_interface_name := 'PXIPMX08';
  pc_schema_name constant pxi_common.st_package_name := 'PXI_APP';
  pc_dup_type_accntng_doc constant pmx_ar_claims_dups.dup_type%type := 'ACCNTNG_DOC';
  pc_dup_type_claim_ref constant pmx_ar_claims_dups.dup_type%type := 'CLAIM_REF';

/*******************************************************************************
  Package Variables
*******************************************************************************/
  pv_claim rt_claim;
  pv_claims tt_claims_array;
  pv_duplicate_claims tt_claims_array;
  pv_user fflu_common.st_user;

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
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,fflu_data.gc_no_file_header,fflu_data.gc_allow_missing);

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
    -- Now access the user name.  Must be called after initialising fflu_data, or after fflu_utils.log_interface_progress.
    pv_user := fflu_utils.get_interface_user;

    -- Empty Inbound Array
    pv_claims.delete;
    pv_duplicate_claims.delete;

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

        -- Process the control record.
        when pc_rec_type_control then
          if trim(fflu_data.get_char_field(pc_idoc_type)) = 'FIDCCP02' then
            pv_claim.idoc_type := fflu_data.get_char_field(pc_idoc_type);
            pv_claim.idoc_no := fflu_data.get_number_field(pc_idoc_no);
            pv_claim.idoc_date := fflu_data.get_date_field(pc_idoc_date);
          else
            fflu_data.log_field_error(pc_rec_type,'Unexpected iDoc Type Value [' || fflu_data.get_char_field(pc_idoc_type) || '].');
          end if;
         
        -- Proces the detail record. 
        when pc_rec_type_detail then 
          pv_claim.company_code := fflu_data.get_char_field(pc_company_code);
          pv_claim.cust_code := fflu_data.get_char_field(pc_cust_code);
          pv_claim.claim_amount := fflu_data.get_number_field(pc_claim_amount);
          pv_claim.claim_ref := fflu_data.get_char_field(pc_claim_ref);
          pv_claim.assignment_no := fflu_data.get_char_field(pc_assignment_no);
          pv_claim.posting_date := fflu_data.get_date_field(pc_posting_date);
          pv_claim.fiscal_period := fflu_data.get_number_field(pc_fiscal_period);
          pv_claim.reason_code := fflu_data.get_char_field(pc_reason_code);
          pv_claim.accounting_doc_no := fflu_data.get_number_field(pc_accounting_doc_no);
          pv_claim.fiscal_year := fflu_data.get_number_field(pc_fiscal_year);
          pv_claim.line_item_no := fflu_data.get_char_field(pc_line_item_no);
          pv_claim.bus_partner_ref := fflu_data.get_char_field(pc_bus_partner_ref);
          
          -- Now set the div code and tax code based on the reason code rules.
          -- Use the following reason codes to determine division and tax codes.
          -- Food =  '40', '41', '51'
          -- Snack = '42', '43', '53'
          -- Pet =   '44', '45', '55'
          case pv_claim.reason_code 
            when '40' then 
              pv_claim.div_code := '02'; 
              pv_claim.tax_code := pxi_common.gc_tax_code_s3; 
            when '42' then 
              pv_claim.div_code := '01'; 
              pv_claim.tax_code := pxi_common.gc_tax_code_s3; 
            when '41' then 
              pv_claim.div_code := '02'; 
              pv_claim.tax_code := pxi_common.gc_tax_code_s1; 
            when '43' then 
              pv_claim.div_code := '01'; 
              pv_claim.tax_code := pxi_common.gc_tax_code_s1; 
            when '44' then
              pv_claim.div_code := '05'; 
              pv_claim.tax_code := pxi_common.gc_tax_code_se;
            when '45' then
              pv_claim.div_code := '05'; 
              pv_claim.tax_code := pxi_common.gc_tax_code_s1;
            when '51' then 
              pv_claim.div_code := '02';
              pv_claim.tax_code := pxi_common.gc_tax_code_s2;
            when '53' then 
              pv_claim.div_code := '01';
              pv_claim.tax_code := pxi_common.gc_tax_code_s2;
            when '55' then 
              pv_claim.div_code := '05';
              pv_claim.tax_code := pxi_common.gc_tax_code_s2;
            else 
              pv_claim.div_code := fflu_data.get_char_field(pc_div_code);
              pv_claim.tax_code := fflu_data.get_char_field(pc_tax_code);
          end case; 
          
          -- Now set the tax base amount based on the tax code.
          case pv_claim.tax_code 
            when pxi_common.gc_tax_code_s1 then 
              pv_claim.tax_base := pv_claim.claim_amount - round(pv_claim.claim_amount / 1.1,2); -- 10% Australian GST
            when pxi_common.gc_tax_code_s2 then 
              pv_claim.tax_base := pv_claim.claim_amount - round(pv_claim.claim_amount / 1.15,2); -- 15% New Zealand GST,  Note, In SAP S2 for 147 is 0% for export.  However we have no reason code map for that combination. 
            when pxi_common.gc_tax_code_s3 then 
              pv_claim.tax_base := 0;  -- Australia 0% No Tax
            when pxi_common.gc_tax_code_se then 
              pv_claim.tax_base := 0;  -- New Zealand 0% No Tax.
            else 
              pv_claim.tax_base := fflu_data.get_number_field(pc_tax_base);
          end case;

          -- Ignore any Accounting Document line which does not have a Division (as it will be non-TP)
          if pv_claim.div_code is not null then
            pv_claims(pv_claims.count+1) := pv_claim;
          end if;
        
        else
          fflu_data.log_field_error(pc_rec_type,'Unexpected Record Type Value [' || fflu_data.get_record_type || '].');
      end case;

    end if;
  exception
    when others then
      fflu_data.log_interface_exception('ON_DATA');
  end on_data;


/*******************************************************************************
  NAME:      VALIDATE_CLAIMS                                             PRIVATE
  PURPOSE:   Checks for any duplicates in the data.  Inserts new valid records
             into the tracking table PMX_AR_CLAIMS.
             
             If Duplicate is found then the record is deleted from the output
             and moved to the duplicates array.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-10-07 Chris Horn           Created.

*******************************************************************************/
  procedure validate_claims is 
    v_counter pls_integer;
    v_no_recs pls_integer;
    v_dup_type pmx_ar_claims_dups.dup_type%type;
    -- Checks if this claim already exists from an account document perspective.
    function is_duplicate_accounting_doc return boolean is
      v_result boolean;
      cursor csr_is_duplicate(
        i_company_code in pmx_ar_claims.company_code%type,
        i_fiscal_year in pmx_ar_claims.fiscal_year%type, 
        i_accounting_doc_no in pmx_ar_claims.accounting_doc_no%type, 
        i_line_item_no in pmx_ar_claims.line_item_no%type) is
        select *
        from pmx_ar_claims  
        where 
          company_code = i_company_code and
          fiscal_year = i_fiscal_year and
          accounting_doc_no = i_accounting_doc_no and
          line_item_no = i_line_item_no;
      -- Record Variable
      rv_duplicate pmx_ar_claims%rowtype;
    begin
      v_result := false;
      -- Perform a duplicate check based accounting document number, update the duplicates detected count as a result.  
      open csr_is_duplicate(pv_claims(v_counter).company_code, pv_claims(v_counter).fiscal_year, pv_claims(v_counter).accounting_doc_no, pv_claims(v_counter).line_item_no);
      fetch csr_is_duplicate into rv_duplicate;
      if csr_is_duplicate%found then 
        v_result := true;
        v_dup_type := pc_dup_type_accntng_doc;
        update pmx_ar_claims 
        set DPLCTS_DTCTD = DPLCTS_DTCTD + 1
        where 
          company_code = pv_claims(v_counter).company_code and
          fiscal_year = pv_claims(v_counter).fiscal_year and
          accounting_doc_no = pv_claims(v_counter).accounting_doc_no and
          line_item_no = pv_claims(v_counter).line_item_no;
      end if;
      close csr_is_duplicate;
      return v_result;
    exception
      when others then
        pxi_common.reraise_promax_exception(pc_package_name,'IS_DUPLICATE_ACCOUNTING_DOC');
    end is_duplicate_accounting_doc;

    -- Check if this claim exists from an existing claim ref perspective.
    function is_duplicate_claim_ref return boolean is
      v_result boolean;
      cursor csr_is_duplicate(
        i_company_code in pmx_ar_claims.company_code%type,
        i_div_code in pmx_ar_claims.div_code%type,
        i_cust_code in pmx_ar_claims.cust_code%type, 
        i_claim_ref in pmx_ar_claims.claim_ref%type) is
        select *
        from pmx_ar_claims  
        where 
          company_code = i_company_code and
          (div_code = i_div_code or i_company_code = pxi_common.gc_new_zealand) and 
          cust_code = i_cust_code and
          claim_ref = i_claim_ref;
      -- Record Variable
      rv_duplicate pmx_ar_claims%rowtype;
    begin
      v_result := false;
      -- Perform a duplicate check based accounting document number, update the duplicates detected count as a result.  
      open csr_is_duplicate(pv_claims(v_counter).company_code, pv_claims(v_counter).div_code, pv_claims(v_counter).cust_code, pv_claims(v_counter).claim_ref);
      fetch csr_is_duplicate into rv_duplicate;
      if csr_is_duplicate%found then 
        v_result := true;
        v_dup_type := pc_dup_type_claim_ref;
      end if;
      close csr_is_duplicate;
      return v_result;
    exception
      when others then
        pxi_common.reraise_promax_exception(pc_package_name,'IS_DUPLICATE_CLAIMREF');
    end is_duplicate_claim_ref;
    
  begin
    -- Now clear out the check table of any data that was successfully loaded from this batch before.  Ie.  If it is being reprocessed.
    delete from pmx_ar_claims where xactn_seq = fflu_utils.get_interface_no;
    delete from pmx_ar_claims_dups where xactn_seq = fflu_utils.get_interface_no;
    -- Now process each record that we have received.
    v_counter := 0;
    v_no_recs := pv_claims.count;
    loop
      -- Check if we have finished processing the array. 
      v_counter := v_counter + 1;
      exit when v_counter > v_no_recs;
      -- Now check if duplicate and if so, move to the duplicate claims array
      if is_duplicate_accounting_doc or is_duplicate_claim_ref then 
        pv_duplicate_claims(pv_duplicate_claims.count+1) := pv_claims(v_counter);
        -- Insert this claim into the claim tracking table.
        insert into pmx_ar_claims_dups (
          XACTN_SEQ,
          BATCH_REC_SEQ,
          IDOC_TYPE,
          IDOC_NO,
          IDOC_DATE,
          COMPANY_CODE,
          DIV_CODE,
          CUST_CODE,
          CLAIM_AMOUNT,
          CLAIM_REF,
          ASSIGNMENT_NO,
          TAX_BASE,
          POSTING_DATE,
          FISCAL_PERIOD,
          REASON_CODE,
          ACCOUNTING_DOC_NO,
          FISCAL_YEAR,
          LINE_ITEM_NO,
          BUS_PARTNER_REF,
          TAX_CODE,
          DUP_TYPE,
          LAST_UPDTD_USER,
          LAST_UPDTD_TIME
        ) values (
          -- Batch Fields
          fflu_utils.get_interface_no,
          v_counter,
          -- IDoc Fields
          pv_claims(v_counter).IDOC_TYPE,
          pv_claims(v_counter).IDOC_NO,
          pv_claims(v_counter).IDOC_DATE,
          pv_claims(v_counter).COMPANY_CODE,
          pv_claims(v_counter).DIV_CODE,
          pv_claims(v_counter).CUST_CODE,
          pv_claims(v_counter).CLAIM_AMOUNT,
          pv_claims(v_counter).CLAIM_REF,
          pv_claims(v_counter).ASSIGNMENT_NO,
          pv_claims(v_counter).TAX_BASE,
          pv_claims(v_counter).POSTING_DATE,
          pv_claims(v_counter).FISCAL_PERIOD,
          pv_claims(v_counter).REASON_CODE,
          pv_claims(v_counter).ACCOUNTING_DOC_NO,
          pv_claims(v_counter).FISCAL_YEAR,
          pv_claims(v_counter).LINE_ITEM_NO,
          pv_claims(v_counter).BUS_PARTNER_REF,
          pv_claims(v_counter).TAX_CODE,
          -- Calculated Fields
          v_dup_type,
          pv_user, 
          sysdate
        );        
        pv_claims.delete(v_counter);
      else 
        -- Insert this claim into the claim tracking table for the successfully interfaced products.
        insert into pmx_ar_claims (
          XACTN_SEQ,
          BATCH_REC_SEQ,
          IDOC_TYPE,
          IDOC_NO,
          IDOC_DATE,
          COMPANY_CODE,
          DIV_CODE,
          CUST_CODE,
          CLAIM_AMOUNT,
          CLAIM_REF,
          ASSIGNMENT_NO,
          TAX_BASE,
          POSTING_DATE,
          FISCAL_PERIOD,
          REASON_CODE,
          ACCOUNTING_DOC_NO,
          FISCAL_YEAR,
          LINE_ITEM_NO,
          BUS_PARTNER_REF,
          TAX_CODE,
          DPLCTS_DTCTD,
          LAST_UPDTD_USER,
          LAST_UPDTD_TIME
        ) values (
          -- Batch Fields
          fflu_utils.get_interface_no,
          v_counter,
          -- IDoc Fields
          pv_claims(v_counter).IDOC_TYPE,
          pv_claims(v_counter).IDOC_NO,
          pv_claims(v_counter).IDOC_DATE,
          pv_claims(v_counter).COMPANY_CODE,
          pv_claims(v_counter).DIV_CODE,
          pv_claims(v_counter).CUST_CODE,
          pv_claims(v_counter).CLAIM_AMOUNT,
          pv_claims(v_counter).CLAIM_REF,
          pv_claims(v_counter).ASSIGNMENT_NO,
          pv_claims(v_counter).TAX_BASE,
          pv_claims(v_counter).POSTING_DATE,
          pv_claims(v_counter).FISCAL_PERIOD,
          pv_claims(v_counter).REASON_CODE,
          pv_claims(v_counter).ACCOUNTING_DOC_NO,
          pv_claims(v_counter).FISCAL_YEAR,
          pv_claims(v_counter).LINE_ITEM_NO,
          pv_claims(v_counter).BUS_PARTNER_REF,
          pv_claims(v_counter).TAX_CODE,
          -- Calculated Fields
          0,
          pv_user, 
          sysdate
        );
      end if;
    end loop;
  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'VALIDATE_CLAIMS');
  end validate_claims; 

/*******************************************************************************
  NAME:      TRIGGER_REPORT                                              PUBLIC
*******************************************************************************/
  procedure trigger_report(i_xactn_seq in fflu_common.st_sequence) is 
    c_report_name pxi_common.st_package_name := 'REPORT_DUPLICATES';
    -- This function is used to check if there were any duplicates detected
    -- for the specified transaction and interface suffix.  
    function check_for_duplicates(i_interface_suffix in fflu_common.st_interface) return boolean is
      cursor csr_check is 
        select 
          count(*) as count
        from 
          pmx_ar_claims_dups t1,
          table(pxi_common.promax_config(null,null)) t2
        where 
          t1.XACTN_SEQ = i_xactn_seq and
          t1.company_code = t2.promax_company and 
          ((t1.div_code = t2.promax_division and t1.company_code = pxi_common.gc_australia) or (t1.company_code = pxi_common.gc_new_zealand)) and
          t2.interface_suffix = i_interface_suffix;      
      rv_check csr_check%rowtype;
      v_result boolean;
    begin
      v_result := false;
      rv_check.count := null;
      open csr_check;
      fetch csr_check into rv_check;
      close csr_check;
      if rv_check.count is not null then 
        if rv_check.count > 0 then 
          v_result := true;
        end if;
      end if;
      return v_result;
    exception 
      when others then 
        pxi_common.reraise_promax_exception(pc_package_name,'CHECK_FOR_DUPLICATES');
    end check_for_duplicates;  
  
  begin
    -- Trigger NZ AR Claims Report
    if check_for_duplicates(pxi_common.gc_interface_nz) then 
      lics_trigger_loader.execute('NZ Promax AR Claims Report',
        pc_schema_name||'.'||pc_package_name||'.'||c_report_name||'(' ||i_xactn_seq || ',' || pxi_common.gc_interface_nz || ')',
        lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT',pc_interface_name),
        lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP',pc_interface_name || '.' || pxi_common.gc_interface_nz),
        lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP',pc_interface_name));
    end if;
    
    -- Trigger Petcare AR Claims Report
    if check_for_duplicates(pxi_common.gc_interface_pet) then 
      lics_trigger_loader.execute('Petcare Promax AR Claims Report',
        pc_schema_name||'.'||pc_package_name||'.'||c_report_name||'(' ||i_xactn_seq || ',' || pxi_common.gc_interface_pet || ')',
        lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT',pc_interface_name),
        lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP',pc_interface_name || '.' || pxi_common.gc_interface_pet),
        lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP',pc_interface_name));
    end if;
    -- Trigger Snackfood AR Claims Report
    if check_for_duplicates(pxi_common.gc_interface_snack) then 
      lics_trigger_loader.execute('Snackfood Promax AR Claims Report',
        pc_schema_name||'.'||pc_package_name||'.'||c_report_name||'(' ||i_xactn_seq || ',' || pxi_common.gc_interface_snack || ')',
        lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT',pc_interface_name),
        lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP',pc_interface_name || '.' || pxi_common.gc_interface_snack),
        lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP',pc_interface_name));
    end if;
    -- Trigger Food AR Claims Report
    if check_for_duplicates(pxi_common.gc_interface_food) then 
      lics_trigger_loader.execute('Food Promax AR Claims Report',
        pc_schema_name||'.'||pc_package_name||'.'||c_report_name||'(' ||i_xactn_seq || ',' || pxi_common.gc_interface_food || ')',
        lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT',pc_interface_name),
        lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP',pc_interface_name || '.' || pxi_common.gc_interface_food),
        lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP',pc_interface_name));
    end if;                            
  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'TRIGGER_REPORT');
  end trigger_report; 

/*******************************************************************************
  NAME:      EXECUTE                                                     PRIVATE
  PURPOSE:   This code creates the extract of the current valid AR claims and
             sends them to Promax. 

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-06-25 Chris Horn           Created. 
*******************************************************************************/
   procedure execute is
    -- Variables     
     v_instance number(15,0);
     v_data pxi_common.st_data;
     v_promax_division pxi_common.st_promax_division;
     v_promax_company pxi_common.st_company;
 
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
          pxi_common.char_format(currency, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable), -- currency -> Currency
          promax_company,
          promax_division
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
            t2.promax_company,
            t2.promax_division,
            trim(t1.bus_partner_ref) as bus_partner_ref,
            decode(nvl(trim(t1.tax_code),'-'), 'S3', 'No Tax', 'SE', 'No Tax', 'Inc Tax') || ' ' || ltrim(t1.cust_code, 0) tax_cust_ref, -- No Tax for Tax Codes S3 and SE .. Else Inc Tax
            t1.posting_date,
            t1.claim_ref,
            t1.assignment_no,
            t1.reason_code,
            t1.claim_amount as amount,
            -- Chris Horn : 26/02/2014 : NOTE : Once NZ Business Process has been updated to correcly bring across the tax amount, rather than them calculating automatically.  Remove the Decode below and just send the actual tax.
            decode(t1.company_code, pxi_common.gc_new_zealand, 0, t1.tax_base) as tax_amount,
            case t1.company_code when pxi_common.gc_australia then 'AUD' when pxi_common.gc_new_zealand then 'NZD' else null end as currency
         from
            table(get_claims) t1,
            table(pxi_common.promax_config(null,null)) t2  -- Promax Configuration table
         where 
            t1.company_code = t2.promax_company and 
            ((t1.company_code = pxi_common.gc_australia and t1.div_code =  t2.promax_division) or (t1.company_code = pxi_common.gc_new_zealand))
        );
        --======================================================================

  begin
     -- Open cursor with the extract data.
     open csr_input;
     loop
       fetch csr_input into v_data, v_promax_company, v_promax_division;
       exit when csr_input%notfound;
      -- Create the new interface when required
      if lics_outbound_loader.is_created = false then
        -- v_instance := lics_outbound_loader.create_interface(pc_interface_name);
        v_instance := lics_outbound_loader.create_interface(pc_interface_name||'.'||pxi_common.promax_interface_suffix( v_promax_company, v_promax_division ) );
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
      validate_claims;  -- Check and validate the claim records. 
      execute; -- Perform the interface extract.  
      commit;
      trigger_report(fflu_utils.get_interface_no); -- Report Duplicate Claims
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
  function get_claims return tt_claims_piped pipelined is
    v_counter pls_integer;
    v_found pls_integer;
  begin
     v_counter := 0;
     v_found := 0;
     loop
       v_counter := v_counter + 1;
       -- Only pipe out the records that were not duplicates. 
       if pv_claims.exists(v_counter) then 
         v_found := v_found + 1;
         pipe row(pv_claims(v_counter));
       end if; 
       -- Exit out of this loop when we have found all the items we want to send.
       exit when v_found = pv_claims.count;
     end loop;
  end get_claims;

/*******************************************************************************
  NAME:      GET_INBOUND                                                  PUBLIC
*******************************************************************************/
  function get_duplicate_claims return tt_claims_piped pipelined is
    v_counter pls_integer;
  begin
     v_counter := 0;
     loop
       v_counter := v_counter + 1;
       exit when v_counter > pv_duplicate_claims.count;
       pipe row(pv_duplicate_claims(v_counter));
     end loop;
  end get_duplicate_claims;

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

/*******************************************************************************
  NAME:      REPORT_AR_DUPLICATES                                         PUBLIC
*******************************************************************************/
  procedure report_duplicates(i_xactn_seq in fflu_common.st_sequence, i_interface_suffix in fflu_common.st_interface) is 

    procedure report_dup_claim_ref is
      -- Duplicate Claims Cursor.
      cursor csr_dup_claims is 
        select 
          t1.*,
          t1.fiscal_year as prev_fiscal_year,
          t3.accounting_doc_no as prev_accounting_doc_no,
          t3.line_item_no as prev_line_item_no,
          t3.claim_amount as prev_claim_amount
        from 
          pmx_ar_claims_dups t1,
          table(pxi_common.promax_config(null,null)) t2,
          pmx_ar_claims t3
        where 
          -- Report for this interface and Accounting Doc type errors.
          t1.XACTN_SEQ = i_xactn_seq and
          t1.dup_type = pc_dup_type_claim_ref and 
          -- Now ensure we are just reporting this company and division
          t1.company_code = t2.promax_company and 
          (t2.promax_company = pxi_common.gc_new_zealand or (t2.promax_company = pxi_common.gc_australia and t2.promax_division = t1.div_code)) and
          -- Now join to the previously sent claim
          t3.company_code = t1.company_code and 
          (t3.div_code = t1.div_code or t1.company_code = pxi_common.gc_new_zealand) and 
          t3.cust_code = t1.cust_code and 
          t3.claim_ref = t1.claim_ref
        order by 
          t1.batch_rec_seq;
      rv_dup_claim csr_dup_claims%rowtype;
      c_highlight constant pxi_common.st_data := ' class="highlight"';
  
      -- This function searches the claim history and trys to find a new claim ref
      -- that hasn't been used before.
      function suggest_new_claim_ref return pmx_ar_claims.claim_ref%type is
        v_base_claim_ref pmx_ar_claims.claim_ref%type;
        v_new_claim_ref pmx_ar_claims.claim_ref%type;
        v_found_claim_ref pmx_ar_claims.claim_ref%type;
        v_counter pls_integer;
        cursor csr_find_claim is 
          select claim_ref from pmx_ar_claims t1 
          where 
            t1.company_code = rv_dup_claim.company_code and 
            (t1.div_code = rv_dup_claim.div_code or t1.company_code = pxi_common.gc_new_zealand) and
            t1.cust_code = rv_dup_claim.cust_code and 
            t1.claim_ref = v_new_claim_ref;
        v_slash pls_integer;
      begin
        -- Determine if the current claim reference already has a slash, searchs 
        -- from the end of the string backwards for the first occuarance of a /
        v_slash := instr(rv_dup_claim.claim_ref,'/',-1);
        if v_slash is null then 
          v_slash := 0;
        end if;
        -- Now try and extract a count if one exists and set the base claim ref.
        if v_slash > 0 then 
          begin
            v_counter := to_number(substr(rv_dup_claim.claim_ref,v_slash+1));
            v_base_claim_ref := substr(rv_dup_claim.claim_ref,1,v_slash-1);
          exception 
            when others then 
              -- If there is text after the slash then include the slash
              v_counter := 1;
              v_base_claim_ref := rv_dup_claim.claim_ref;
          end;
        else 
          v_counter := 1;
          v_base_claim_ref := rv_dup_claim.claim_ref;
        end if;
        loop
          v_new_claim_ref := '/' || v_counter;
          v_new_claim_ref := substr(v_base_claim_ref,1,12-length(v_new_claim_ref)) || v_new_claim_ref;
          open csr_find_claim;
          fetch csr_find_claim into v_found_claim_ref;
          if csr_find_claim%notfound then
            v_found_claim_ref := null;
          end if;
          close csr_find_claim;
          exit when v_found_claim_ref is null;
          v_counter := v_counter + 1;
        end loop;
        return v_new_claim_ref;
      exception 
        when others then 
          pxi_common.reraise_promax_exception(pc_package_name,'SUGGEST_NEW_CLAIM_REF');
      end suggest_new_claim_ref;   
    begin
      -- Now report all the found duplicate claims. 
      open csr_dup_claims;
      fetch csr_dup_claims into rv_dup_claim;
      if csr_dup_claims%found then 
        lics_mailer.append_data('<p>' || chr(38) || 'nbsp;</p>');
        lics_mailer.append_data('<h3><strong>ERROR:</strong> Duplicate Claim References</h2>');
        lics_mailer.append_data('<p>Below is the list of duplicate claims that were received that');
        lics_mailer.append_data('have not been sent to promax because the claim reference has been used');
        lics_mailer.append_data('before for this customer. To fix, try changing the claim reference to the');
        lics_mailer.append_data('suggested value and then resend from SAP.</p>');
        lics_mailer.append_data('<p>' || chr(38) || 'nbsp;</p>');
        lics_mailer.append_data('<table>');
        lics_mailer.append_data('<tr>');
        lics_mailer.append_data('<th>Interface ID</th>');
        lics_mailer.append_data('<th>Company Code</th>');
        lics_mailer.append_data('<th>Division Code</th>');
        lics_mailer.append_data('<th>Cust Code</th>');
        lics_mailer.append_data('<th>Claim Amount</th>');
        lics_mailer.append_data('<th>Claim Ref</th>');
        lics_mailer.append_data('<th>Posting Date</th>');
        lics_mailer.append_data('<th>Fiscal Year</th>');
        lics_mailer.append_data('<th>Fiscal Period</th>');
        lics_mailer.append_data('<th>Reason Code</th>');
        lics_mailer.append_data('<th>Tax Code</th>');
        lics_mailer.append_data('<th>Accounting Doc No</th>');
        lics_mailer.append_data('<th>Line Item No</th>');
        lics_mailer.append_data('<th>Prev Fiscal Year</th>');
        lics_mailer.append_data('<th>Prev Accounting Doc No</th>');
        lics_mailer.append_data('<th>Prev Line Item No</th>');
        lics_mailer.append_data('<th>Prev Claim Amount</th>');
        lics_mailer.append_data('<th>Suggested New Claim Ref</th>');
        lics_mailer.append_data('</tr>');
        loop
          lics_mailer.append_data('<tr>');
          lics_mailer.append_data('<td>'||rv_dup_claim.xactn_seq || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_claim.company_code || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_claim.div_code || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_claim.cust_code || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_claim.claim_amount || '</td>');
          lics_mailer.append_data('<td'||c_highlight||'>'||rv_dup_claim.claim_ref || '</td>');
          lics_mailer.append_data('<td>'||to_char(rv_dup_claim.posting_date,'DD/MM/YYYY') || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_claim.fiscal_year || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_claim.fiscal_period || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_claim.reason_code || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_claim.tax_code || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_claim.accounting_doc_no || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_claim.line_item_no || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_claim.prev_fiscal_year || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_claim.prev_accounting_doc_no || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_claim.prev_line_item_no || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_claim.prev_claim_amount || '</td>');
          lics_mailer.append_data('<td'||c_highlight||'>'||suggest_new_claim_ref || '</td>');
          lics_mailer.append_data('</tr>');
          -- Now fetch the next record and exit once finished.
          fetch csr_dup_claims into rv_dup_claim;
          exit when csr_dup_claims%notfound;
        end loop;
        lics_mailer.append_data('</table>');
        lics_mailer.append_data('<p>' || chr(38) || 'nbsp;</p>');
      end if;
      close csr_dup_claims;
    exception 
      when others then 
        pxi_common.reraise_promax_exception(pc_package_name,'REPORT_DUP_CLAIM_REF');
    end report_dup_claim_ref;

    -- This procedure reports any accounting document mismatches that may have
    -- been detceted. 
    procedure report_dup_accntng_mismatch is 
      -- Duplicate Accounting Doc Mismatch.
      cursor csr_dup_accntng_mismatch is
        select 
          t1.*,
          t3.reason_code as prev_reason_code,
          t3.claim_ref as prev_claim_ref, 
          t3.cust_code as prev_cust_code,
          t3.claim_amount as prev_claim_amount,
          t3.tax_code as prev_tax_code
        from 
          pmx_ar_claims_dups t1,
          table(pxi_common.promax_config(null,null)) t2,
          pmx_ar_claims t3
        where 
          -- Report for this interface and Accounting Doc type errors.
          t1.XACTN_SEQ = i_xactn_seq and
          t1.dup_type = pc_dup_type_accntng_doc and 
          -- Now ensure we are just reporting this company and division
          t1.company_code = t2.promax_company and 
          (t2.promax_company = pxi_common.gc_new_zealand or (t2.promax_company = pxi_common.gc_australia and t2.promax_division = t1.div_code)) and
          -- Join to the previously sent data.  
          t3.company_code = t1.company_code and
          t3.fiscal_year = t1.fiscal_year and
          t3.accounting_doc_no = t1.accounting_doc_no and
          t3.line_item_no = t1.line_item_no and
          -- Ensure that the previously sent data is not the same in some way.
          ( t3.reason_code <> t1.reason_code or 
            t3.claim_ref <> t1.claim_ref or 
            t3.claim_amount <> t1.claim_amount or
            t3.cust_code <> t1.cust_code or
            t3.tax_code <> t1.tax_code
          )
        order by 
          t1.batch_rec_seq;
      rv_dup_accntng_mismatch csr_dup_accntng_mismatch%rowtype;
      c_mismatch constant pxi_common.st_data := ' class="mismatch"';
      v_mismatch pxi_common.st_data;
    begin
      -- Now report all the mismatches.
      open csr_dup_accntng_mismatch;
      fetch csr_dup_accntng_mismatch into rv_dup_accntng_mismatch;
      if csr_dup_accntng_mismatch%found then 
        lics_mailer.append_data('<p>' || chr(38) || 'nbsp;</p>');
        lics_mailer.append_data('<h3><strong>ERROR:</strong> Duplicates Account Document Mismatch</h2>');
        lics_mailer.append_data('<p>The below AR claims have been sent before to Promax, however the details');
        lics_mailer.append_data('are now different to the previously sent values.  To fix, contact the support');
        lics_mailer.append_data('team to delete incorrect data from Promax and the interfacing table before');
        lics_mailer.append_data('reprocessing this interface.</p>');
        lics_mailer.append_data('<p>' || chr(38) || 'nbsp;</p>');
        lics_mailer.append_data('<table>');
        lics_mailer.append_data('<tr>');
        lics_mailer.append_data('<th>Interface ID</th>');
        lics_mailer.append_data('<th>Company Code</th>');
        lics_mailer.append_data('<th>Division Code</th>');
        lics_mailer.append_data('<th>Cust Code</th>');
        lics_mailer.append_data('<th>Prev. Cust Code</th>');
        lics_mailer.append_data('<th>Claim Amount</th>');
        lics_mailer.append_data('<th>Prev. Claim Amount</th>');
        lics_mailer.append_data('<th>Claim Ref</th>');
        lics_mailer.append_data('<th>Prev. Claim Ref</th>');
        lics_mailer.append_data('<th>Posting Date</th>');
        lics_mailer.append_data('<th>Fiscal Year</th>');
        lics_mailer.append_data('<th>Fiscal Period</th>');
        lics_mailer.append_data('<th>Reason Code</th>');
        lics_mailer.append_data('<th>Prev. Reason Code</th>');
        lics_mailer.append_data('<th>Tax Code</th>');
        lics_mailer.append_data('<th>Prev. Tax Code</th>');
        lics_mailer.append_data('<th>Accounting Doc No</th>');
        lics_mailer.append_data('<th>Line Item No</th>');
        lics_mailer.append_data('</tr>');
        loop
          lics_mailer.append_data('<tr>');
          lics_mailer.append_data('<td>'||rv_dup_accntng_mismatch.xactn_seq || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_accntng_mismatch.company_code || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_accntng_mismatch.div_code || '</td>');
          if rv_dup_accntng_mismatch.cust_code <> rv_dup_accntng_mismatch.prev_cust_code then 
            v_mismatch := c_mismatch;
          else 
            v_mismatch := null;
          end if;
          lics_mailer.append_data('<td'||v_mismatch||'>'||rv_dup_accntng_mismatch.cust_code || '</td>');
          lics_mailer.append_data('<td'||v_mismatch||'>'||rv_dup_accntng_mismatch.prev_cust_code || '</td>');
          if rv_dup_accntng_mismatch.claim_amount <> rv_dup_accntng_mismatch.prev_claim_amount then 
            v_mismatch := c_mismatch;
          else 
            v_mismatch := null;
          end if;
          lics_mailer.append_data('<td'||v_mismatch||'>'||rv_dup_accntng_mismatch.claim_amount || '</td>');
          lics_mailer.append_data('<td'||v_mismatch||'>'||rv_dup_accntng_mismatch.prev_claim_amount || '</td>');
          if rv_dup_accntng_mismatch.claim_ref <> rv_dup_accntng_mismatch.prev_claim_ref then 
            v_mismatch := c_mismatch;
          else 
            v_mismatch := null;
          end if;
          lics_mailer.append_data('<td'||v_mismatch||'>'||rv_dup_accntng_mismatch.claim_ref || '</td>');
          lics_mailer.append_data('<td'||v_mismatch||'>'||rv_dup_accntng_mismatch.prev_claim_ref || '</td>');
          lics_mailer.append_data('<td>'||to_char(rv_dup_accntng_mismatch.posting_date,'DD/MM/YYYY') || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_accntng_mismatch.fiscal_year || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_accntng_mismatch.fiscal_period || '</td>');
          if rv_dup_accntng_mismatch.reason_code <> rv_dup_accntng_mismatch.prev_reason_code then 
            v_mismatch := c_mismatch;
          else 
            v_mismatch := null;
          end if;
          lics_mailer.append_data('<td'||v_mismatch||'>'||rv_dup_accntng_mismatch.reason_code || '</td>');
          lics_mailer.append_data('<td'||v_mismatch||'>'||rv_dup_accntng_mismatch.prev_reason_code || '</td>');
          if rv_dup_accntng_mismatch.tax_code <> rv_dup_accntng_mismatch.prev_tax_code then 
            v_mismatch := c_mismatch;
          else 
            v_mismatch := null;
          end if;
          lics_mailer.append_data('<td'||v_mismatch||'>'||rv_dup_accntng_mismatch.tax_code || '</td>');
          lics_mailer.append_data('<td'||v_mismatch||'>'||rv_dup_accntng_mismatch.prev_tax_code || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_accntng_mismatch.accounting_doc_no || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_accntng_mismatch.line_item_no || '</td>');
          lics_mailer.append_data('</tr>');
          -- Now fetch the next record and exit once finished.
          fetch csr_dup_accntng_mismatch into rv_dup_accntng_mismatch;
          exit when csr_dup_accntng_mismatch%notfound;
        end loop;
        lics_mailer.append_data('</table>');
        lics_mailer.append_data('<p>' || chr(38) || 'nbsp;</p>');
      end if;
      close csr_dup_accntng_mismatch;
    exception 
      when others then 
        pxi_common.reraise_promax_exception(pc_package_name,'REPORT_DUP_ACCNTNG_MISMATCH');
    end report_dup_accntng_mismatch;

    -- This procedure will send out all the received duplicate claims that were
    -- the same as the previously sent data.
    procedure report_dup_accntng_same is 
      -- Duplicate Account Docs 
      cursor csr_dup_accntng_same is
        select 
          t1.*
        from 
          pmx_ar_claims_dups t1,
          table(pxi_common.promax_config(null,null)) t2,
          pmx_ar_claims t3
        where 
          -- Report for this interface and Accounting Doc type errors.
          t1.XACTN_SEQ = i_xactn_seq and
          t1.dup_type = pc_dup_type_accntng_doc and 
          -- Now ensure we are just reporting this company and division
          t1.company_code = t2.promax_company and 
          (t2.promax_company = pxi_common.gc_new_zealand or (t2.promax_company = pxi_common.gc_australia and t2.promax_division = t1.div_code)) and
          -- Join to the previously sent data.  
          t3.company_code = t1.company_code and
          t3.fiscal_year = t1.fiscal_year and
          t3.accounting_doc_no = t1.accounting_doc_no and
          t3.line_item_no = t1.line_item_no and
          -- Ensure that the previously sent data is the same.
          t3.reason_code = t1.reason_code and
          t3.claim_ref = t1.claim_ref and
          t3.claim_amount = t1.claim_amount and 
          t3.cust_code = t1.cust_code and
          t3.tax_code = t1.tax_code 
        order by 
          t1.batch_rec_seq;
      rv_dup_accntng_same csr_dup_accntng_same%rowtype;
    begin
      -- Now report all the sames
      open csr_dup_accntng_same;
      fetch csr_dup_accntng_same into rv_dup_accntng_same;
      if csr_dup_accntng_same%found then 
        lics_mailer.append_data('');
        lics_mailer.append_data('<h3><strong>WARNING:</strong> Duplicates Account Document Resend</h2>');
        lics_mailer.append_data('<p>The below AR claims have been sent before and this entry was identical');
        lics_mailer.append_data('to the previously sent information.</p>');
        lics_mailer.append_data('<p>' || chr(38) || 'nbsp;</p>');
        lics_mailer.append_data('<table>');
        lics_mailer.append_data('<tr>');
        lics_mailer.append_data('<th>Interface ID</th>');
        lics_mailer.append_data('<th>Company Code</th>');
        lics_mailer.append_data('<th>Division Code</th>');
        lics_mailer.append_data('<th>Cust Code</th>');
        lics_mailer.append_data('<th>Claim Amount</th>');
        lics_mailer.append_data('<th>Claim Ref</th>');
        lics_mailer.append_data('<th>Posting Date</th>');
        lics_mailer.append_data('<th>Fiscal Year</th>');
        lics_mailer.append_data('<th>Fiscal Period</th>');
        lics_mailer.append_data('<th>Reason Code</th>');
        lics_mailer.append_data('<th>Tax Code</th>');
        lics_mailer.append_data('<th>Accounting Doc No</th>');
        lics_mailer.append_data('<th>Line Item No</th>');
        lics_mailer.append_data('</tr>');
        loop
          lics_mailer.append_data('<tr>');
          lics_mailer.append_data('<td>'||rv_dup_accntng_same.xactn_seq || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_accntng_same.company_code || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_accntng_same.div_code || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_accntng_same.cust_code || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_accntng_same.claim_amount || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_accntng_same.claim_ref || '</td>');
          lics_mailer.append_data('<td>'||to_char(rv_dup_accntng_same.posting_date,'DD/MM/YYYY') || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_accntng_same.fiscal_year || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_accntng_same.fiscal_period || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_accntng_same.reason_code || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_accntng_same.tax_code || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_accntng_same.accounting_doc_no || '</td>');
          lics_mailer.append_data('<td>'||rv_dup_accntng_same.line_item_no || '</td>');
          lics_mailer.append_data('</tr>');
          -- Now fetch the next record and exit once finished.
          fetch csr_dup_accntng_same into rv_dup_accntng_same;
          exit when csr_dup_accntng_same%notfound;
        end loop;
        lics_mailer.append_data('</table>');
        lics_mailer.append_data('<p>' || chr(38) || 'nbsp;</p>');
      end if;
      close csr_dup_accntng_same;
    exception 
      when others then 
        pxi_common.reraise_promax_exception(pc_package_name,'REPORT_DUP_ACCNTNG_SAME');
    end report_dup_accntng_same;
    
  begin
     lics_mailer.create_email(null,lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP',pc_interface_name || '.' || i_interface_suffix),'AR Claims Interface Duplicates Report',null,null);
     lics_mailer.create_part(null);
     lics_mailer.append_data('Please see the attached AR Claims Duplicates Report.');
     lics_mailer.append_data('');
     lics_mailer.create_part('ardups_report_'||i_xactn_seq ||'.html');
     lics_mailer.append_data('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">');
     lics_mailer.append_data('<html><head><style>');
     lics_mailer.append_data('table {');
     lics_mailer.append_data('  border-width:1px;');
     lics_mailer.append_data('  border-style:solid;');
     lics_mailer.append_data('  border-color:#aaaaaa;');
     lics_mailer.append_data('  border-collapse: collapse;');
     lics_mailer.append_data('}');
     lics_mailer.append_data('th, td {');
     lics_mailer.append_data('  border-width:1px;');
     lics_mailer.append_data('  border-style:solid;');
     lics_mailer.append_data('  border-color:#aaaaaa;');
     lics_mailer.append_data('  padding:2px;');
     lics_mailer.append_data('}');
     lics_mailer.append_data('td.mismatch {');
     lics_mailer.append_data('  background-color:#ee2222;');
     lics_mailer.append_data('}');
     lics_mailer.append_data('td.highlight {');
     lics_mailer.append_data('  background-color:#eeee22;');
     lics_mailer.append_data('}');
     lics_mailer.append_data('</style></head><body>');
     lics_mailer.append_data('<h1>Promax AR Claims Interface Duplicates Report</h1>');
     lics_mailer.append_data('<p>' || chr(38) || 'nbsp;</p>');
     lics_mailer.append_data('<table><tr><td><strong>Interface ID</strong></td><td>' || i_xactn_seq || '</td></tr>');
     lics_mailer.append_data('<tr><td><strong>Segment</strong></td><td>' || 
       case i_interface_suffix 
         when pxi_common.gc_interface_nz then 'New Zealand' 
         when pxi_common.gc_interface_pet then 'Australia Petcare'
         when pxi_common.gc_interface_snack then 'Australia Snackfood'
         when pxi_common.gc_interface_food then 'Australia Food'
         else 'Unknown'
      end || '</td></tr></table>');
     lics_mailer.append_data('<p>' || chr(38) || 'nbsp;</p>');
     -- Now report the duplciates based on the claim reference.
     report_dup_claim_ref;
     -- Report the duplicate accounting document mismatches.
     report_dup_accntng_mismatch;
     -- Report the duplciate accounting document resends. 
     report_dup_accntng_same;
     -- Now finalise the report.
     lics_mailer.append_data('<p>' || chr(38) || 'nbsp;</p>');
     lics_mailer.append_data('</body></html>');
     lics_mailer.finalise_email;    
   exception
     when others then
       if (lics_mailer.is_created) then
         lics_mailer.append_data('</pre></body></html>');
         lics_mailer.append_data('** FATAL ERROR DURING PROCESSING ** : ' || SQLERRM);
         lics_mailer.finalise_email;
       end if;
   end report_duplicates;

END PXIPMX08_EXTRACT;