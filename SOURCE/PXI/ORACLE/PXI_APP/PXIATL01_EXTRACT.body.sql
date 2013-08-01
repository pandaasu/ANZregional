create or replace 
package body          pxiatl01_extract as

/*******************************************************************************
  Application Exception Definitions
*******************************************************************************/
   pc_package_name pxi_common.st_package_name := 'PXIATL01_EXTRACT';

/*******************************************************************************
  NAME:      ADD_HEADER_RECORD                                            PUBLIC
*******************************************************************************/
  procedure add_header_record(ti_data in out tt_data, i_company in st_data, i_division in st_data,i_currency in st_data, i_doc_type in st_doc_type, i_doc_date in date, i_posting_date in date, i_reference_doc_no in st_data) is
    v_data st_data;
    v_doc_type st_data;
  begin
    -- Determine the document type string to use for the this document type.
    case i_doc_type 
      when gc_doc_type_accrual then v_doc_type := 'Accrl';
      when gc_doc_type_accrual_reversal then v_doc_type := 'AcRvs';
      when gc_doc_type_accrual_journal then v_doc_type := 'Jrnal';
      else
        v_doc_type := 'Unknn';
    end case;
    -- Now generate the data line.
    v_data := 
      rpad('H',1) ||                                       -- INDICATOR
      rpad('IDOC',5) ||                                    -- OBJ_TYPE
      rpad('PX' || to_char(sysdate,'YYYYMMDDHH24MISS') || lpad(to_char(ti_data.count),4,'0'),20) || -- OBJ_KEY
      rpad('RFBU',4) ||                                    -- BUS_ACT
      rpad('BATCHSCHE',12) ||                              -- USERNAME
      rpad('PXI ' || rpad(v_doc_type,5) || ' ' || rpad(i_company,3) || rpad(i_division,3) || ' ' || to_char(sysdate,'YYYYMMDD'),25) || -- HEADER_TEXT
      rpad(nvl(i_company,' '),4) ||                        -- COMP_CODE
      rpad(nvl(i_currency,' '),5) ||                       -- DOC_CURR
      rpad(nvl(to_char(i_doc_date,'YYYYMMDD'),' '),8) ||   -- DOC_DATE
      rpad(nvl(to_char(i_posting_date,'YYYYMMDD'),' '),8) || -- PSTNG_DATE
      rpad(nvl(to_char(i_posting_date,'YYYYMMDD'),' '),8) || -- TRANS_DATE
      rpad(nvl(i_doc_type,' '),2) ||                       -- DOC_TYPE
      rpad(nvl(i_reference_doc_no,' '),16)  ||             -- REF_DOC_NO
      rpad('PROMAX PX',10) ||                              -- LOG_SYS 
      rpad(' ',9) ||                                       -- EXCH_RATE
      rpad(' ',9) ||                                       -- EXCH_RATE_INDIRECT
      rpad(' ',10);                                        -- AC_DOC_NO
    -- Now add the line to the data collection in position 0.
    ti_data(0) := v_data;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'ADD_HEADER_RECORD');
  end add_header_record;

/*******************************************************************************
  NAME:      ADD_TAX_RECORD                                               PUBLIC
*******************************************************************************/
  procedure add_tax_record(ti_data in out tt_data, i_tax_code in st_tax_code, i_tax in pxi_common.st_amount, i_tax_base in pxi_common.st_amount) is
    v_data st_data;
  begin
    -- Now generate the tax data line.
    v_data := 
      rpad('T',1) ||                                                -- INDICATOR
      rpad(nvl(i_tax_code,' '),2) ||                                -- TAX_CODE
      lpad(nvl(to_char(i_tax,'9999999999999999999.99'),'0.00'),' ',23) || -- AMOUNT
      lpad(nvl(to_char(i_tax_base,'9999999999999999999.99'),'0.00'),' ',23) || -- AMT_BASE
      rpad(' ',4) ||                                                -- COND_KEY
      rpad(' ',3) ||                                                -- ACCT_KEY
      rpad(' ',1);                                                  -- AUTO_TAX
    -- Now add the line to the data collection in position 0.
    if ti_data.exists(ti_data.count) = true then 
      pxi_common.raise_promax_error(pc_package_name,'ADD_TAX_RECORD','Tax line was to be added, however its calculated position in the extract contained data.  Header may not have been created.  This has to be done first.');
    end if;
    -- Now add the line to the current collection. 
    ti_data(ti_data.count) := v_data;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'ADD_TAX_RECORD');
  end add_tax_record;

/*******************************************************************************
  NAME:      ADD_GENERAL_LEDGER_RECORD                                   PUBLIC
*******************************************************************************/
  procedure add_general_ledger_record(ti_data in out tt_data, 
      i_account in st_data, i_cost_center in st_data, i_profit_center in st_data, 
      i_amount in pxi_common.st_amount, i_item_text in st_data, i_alloc_number in st_data,
      i_tax_code in st_tax_code, i_material in st_data, 
      i_plant_code in st_data, i_cust_code in st_data, i_sales_org in st_data,
      i_distribution_channel in st_data) is
    v_data st_data;
  begin
    -- Now generate the general ledger line.
    v_data := 
      rpad('G',1) ||                                            -- INDICATOR
      lpad(nvl(i_account,'0'),10,'0') ||                        -- GL_ACCOUNT
      lpad(nvl(to_char(i_amount,'9999999999999999999.99'),'0.00'),' ',23) || -- AMOUNT
      rpad(nvl(i_item_text,' '),50) ||                          -- ITEM_TEXT
      rpad(nvl(i_alloc_number,' '),18) ||                       -- ALLOC_NMBR
      rpad(nvl(i_tax_code,' '),2) ||                            -- TAX_CODE
      rpad(nvl(i_cost_center,' '),10) ||                        -- COSTCENTER
      rpad(' ',12) ||                                           -- ORDERID 
      rpad(' ',24) ||                                           -- WBS_ELEMENT 
      rpad(' ',13) ||                                           -- QUANTITY
      rpad(' ',3) ||                                            -- BASE_UOM
      rpad(nvl(pxi_common.full_matl_code(i_material),' '),18) ||-- MATERIAL
      rpad(nvl(i_plant_code,' '),4) ||                          -- PLANT_CODE
      rpad(nvl(i_cust_code,' '),10) ||                          -- CUSTOMER
      lpad(nvl(i_profit_center,' '),10) ||                      -- PROFIT CENTER
      rpad(nvl(i_sales_org,' '),4) ||                           -- SALES ORG
      rpad(nvl(i_distribution_channel,' '),2);                  -- DIST CHANNEL
    -- Now add the line to the current collection.
    ti_data(ti_data.count+1) := v_data;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'ADD_GENERAL_LEDGER_RECORD');
  end add_general_ledger_record;

/*******************************************************************************
  NAME:      ADD_PAYMENT_RECORD                                          PUBLIC
*******************************************************************************/
  procedure add_payment_record(ti_data in out tt_data, 
      i_account in st_data, i_vendor in st_data, 
      i_amount in pxi_common.st_amount, i_item_text in st_data, i_alloc_number in st_data) is
    v_data st_data;
  begin
    -- Now generate the general ledger line.
    v_data := 
      rpad('P',1) ||                                            -- INDICATOR
      lpad(nvl(i_vendor,'0'),10,'0') ||                         -- VENDOR_NO
      lpad(nvl(to_char(i_amount,'9999999999999999999.99'),'0.00'),' ',23) || -- AMOUNT
      rpad('*',4) ||                                            -- PMNTTRMS
      rpad(' ',8) ||                                            -- BLINE_DATE
      rpad('B',1) ||                                            -- PMNT_BLOCK
      rpad(nvl(i_alloc_number,' '),18) ||                               -- ALLOC_NMBR
      rpad(nvl(i_item_text,' '),50) ||                          -- ITEM_TEXT
      rpad(' ',2) ||                                            -- W_TAX_CODE
      rpad(' ',23);                                             -- DISC_BASE
    -- Now add the line to the current collection.
    ti_data(ti_data.count+1) := v_data;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'ADD_PAYMENT_RECORD');        
  end add_payment_record;


/*******************************************************************************
  NAME:      CREATE_INTERFACE                                            PRIVATE
*******************************************************************************/
   procedure create_interface(ti_data in out tt_data) is 
     v_counter pls_integer;
     v_instance number(15,0); -- Lics Interface Header. 
   begin
     -- Check the number of rows in the created data file. 
     if ti_data.count = 0 then 
       pxi_common.raise_promax_error(pc_package_name,'CREATE_INTERFACE','No data was supplied for creating interface.');
     elsif ti_data.count > gc_max_idoc_rows+2 then -- Use plus two to allow header and tax lines to be automatically be added.
       pxi_common.raise_promax_error(pc_package_name,'CREATE_INTERFACE','More data than is allowed in interface was supplied.');
     else
       -- Now output the current data extract as an IDOC.   Note that header record starts in position zero.
       v_instance := lics_outbound_loader.create_interface('PXIATL01');
       for v_counter in 0..ti_data.count-1 loop
         lics_outbound_loader.append_data(ti_data(v_counter));
       end loop;
       lics_outbound_loader.finalise_interface;
     end if;
   exception
     when pxi_common.ge_application_exception then 
       raise;
     when others then
       if lics_outbound_loader.is_created = true then
          lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
          lics_outbound_loader.finalise_interface;
       end if;
       -- Re Raise the exception. 
       pxi_common.reraise_promax_exception(pc_package_name,'CREATE_INTERFACE');           
   end create_interface;
   
/*******************************************************************************
  NAME:      DEBUG_INTERFACE                                              PUBLIC
*******************************************************************************/
   procedure debug_interface(ti_data in tt_data) is 
     v_counter pls_integer;
   begin
     dbms_output.put_line('Interface Data Extract : ' || ti_data.count() || ' rows.');
     dbms_output.put_line('----------------------------------');
     for v_counter in 1..ti_data.count loop
       dbms_output.put_line(ti_data(v_counter));
     end loop;
     dbms_output.put_line('----------------------------------');
     dbms_output.put_line('');
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'DEBUG_INTERFACE');      
   end debug_interface;

/*******************************************************************************
  NAME:      SEND_DATA                                                    PUBLIC
*******************************************************************************/
   procedure send_data(
     ti_gl_data in tt_gl_data, 
     i_doc_type in st_doc_type,
     i_doc_reference in st_data) is
     v_counter pls_integer;
     tv_data tt_data;
     -- Document Change Tracking Variables.
     v_cur_company pxi_common.st_company;
     v_cur_promax_division pxi_common.st_promax_division;
     v_cur_posting_date date;
     v_cur_doc_date date;
     v_cur_currency pxi_common.st_currency;
     v_cur_tax_code st_tax_code;
    
     -- Summation Fields
     v_tax pxi_common.st_amount;
     v_tax_base pxi_common.st_amount;
     
     procedure perform_send is
     begin
       -- Add the header record.
       add_header_record(tv_data, 
         v_cur_company,
         v_cur_promax_division,
         v_cur_currency,
         i_doc_type,
         v_cur_doc_date,
         v_cur_posting_date,
         i_doc_reference);
       add_tax_record(tv_data,v_cur_tax_code,v_tax,v_tax_base);
       -- Now acutally create the interface and send it.
       create_interface(tv_data);
       -- Now clear out the current information and clear sumation counters. 
       tv_data.delete;
       v_cur_company := null;
       v_cur_tax_code := null;
       v_tax_base := 0;
       v_tax := 0;
     exception
       when others then 
         pxi_common.reraise_promax_exception(pc_package_name,'SEND_DATA');           
     end perform_send;
   begin
     v_counter := 0;
     v_cur_company := null; 
     v_cur_tax_code := null;
     v_cur_promax_division := null;
     v_cur_doc_date := null;
     v_cur_posting_date := null;
     v_cur_currency := null; 
     v_tax_base := 0;
     v_tax := 0;
     loop 
       -- Now send the current data block.  
       if mod(v_counter,gc_max_idoc_rows) = 0 and tv_data.count > 0 then 
         perform_send();
       end if;
       v_counter := v_counter + 1;
       exit when v_counter > ti_gl_data.count;
       -- Detect if there is any change in the company or the tax code.  If there is then lets send this document and start a new one. 
       if (v_cur_company is not null and v_cur_tax_code is not null and 
           v_cur_doc_date is not null and v_cur_posting_date is not null and 
           v_cur_currency is not null and v_cur_promax_division is not null and (
             v_cur_company <> ti_gl_data(v_counter).company or 
             v_cur_promax_division <> ti_gl_data(v_counter).promax_division or
             v_cur_tax_code <> ti_gl_data(v_counter).tax_code or 
             v_cur_doc_date <> ti_gl_data(v_counter).document_date or 
             v_cur_posting_date <> ti_gl_data(v_counter).posting_date or 
             v_cur_currency <> ti_gl_data(v_counter).currency
             )) then 
         perform_send;
       end if;
       -- Now make sure the company and tax code tracking variables are set.
       v_cur_company := ti_gl_data(v_counter).company;
       v_cur_promax_division := ti_gl_data(v_counter).promax_division;
       v_cur_tax_code := ti_gl_data(v_counter).tax_code;
       v_cur_doc_date := ti_gl_data(v_counter).document_date;
       v_cur_posting_date := ti_gl_data(v_counter).posting_date;
       v_cur_currency := ti_gl_data(v_counter).currency; 
       -- Now add create the current gl record. 
       add_general_ledger_record(tv_data,
         ti_gl_data(v_counter).account_code,
         ti_gl_data(v_counter).cost_center, 
         ti_gl_data(v_counter).profit_center,
         ti_gl_data(v_counter).amount, 
         ti_gl_data(v_counter).item_text, 
         ti_gl_data(v_counter).allocation_ref,
         ti_gl_data(v_counter).tax_code,
         ti_gl_data(v_counter).material_code,
         ti_gl_data(v_counter).plant_code,
         ti_gl_data(v_counter).customer_code,
         ti_gl_data(v_counter).sales_org,
         ti_gl_data(v_counter).dstrbtn_chnnl);
      -- Now update the value summation fields.
      v_tax_base := v_tax_base + nvl(ti_gl_data(v_counter).tax_amount_base,0);
      v_tax := v_tax + nvl(ti_gl_data(v_counter).tax_amount,0);
     end loop;
     -- Check if there is any data in the collection ready for sending.
     if tv_data.count > 0 then 
       perform_send;
     end if;
   exception
     when others then 
       pxi_common.reraise_promax_exception(pc_package_name,'SEND_DATA');
   end send_data;

end pxiatl01_extract;


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


