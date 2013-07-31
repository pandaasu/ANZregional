create or replace 
package body          pxiatl01_extract as

/*******************************************************************************
  Application Exception Definitions
*******************************************************************************/
   pc_application_exception pls_integer := -20000;
   e_application_exception exception;
   pragma exception_init(e_application_exception, -20000);

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
      raise_application_error(pc_application_exception,'Tax line was to be added, however its calculated position in the extract contained data.  Header may not have been created.  This has to be done first.');
    end if;
    -- Now add the line to the current collection. 
    ti_data(ti_data.count) := v_data;
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
       raise_application_error(pc_application_exception,'No data was supplied for creating interface.');
     elsif ti_data.count > gc_max_idoc_rows then 
       raise_application_error(pc_application_exception,'More data than is allowed in interface was supplied.');
     else
       -- Now output the current data extract as an IDOC.   Note that header record starts in position zero.
       v_instance := lics_outbound_loader.create_interface('PXIATL01');
       for v_counter in 0..ti_data.count-1 loop
         lics_outbound_loader.append_data(ti_data(v_counter));
       end loop;
       lics_outbound_loader.finalise_interface;
     end if;
   exception
     when e_application_exception then 
       raise;
     when others then
       if lics_outbound_loader.is_created = true then
          lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
          lics_outbound_loader.finalise_interface;
       end if;
       -- Re Raise the exception. 
       raise;
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
   end debug_interface;

/*******************************************************************************
  NAME:      SEND_DATA                                                    PUBLIC
*******************************************************************************/
   procedure send_data(ti_gl_data in tt_gl_data, i_doc_type in st_doc_type) is
   begin
     null;
   end send_data;


end pxiatl01_extract;

