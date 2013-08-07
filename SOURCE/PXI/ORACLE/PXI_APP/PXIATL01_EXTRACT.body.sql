create or replace 
package body          pxiatl01_extract as

/*******************************************************************************
  Application Exception Definitions
*******************************************************************************/
   pc_package_name pxi_common.st_package_name := 'PXIATL01_EXTRACT';

/*******************************************************************************
  NAME:      INSERT_BLANK_RECORD                                         PRIVATE
*******************************************************************************/
  procedure insert_blank_record(ti_data in out tt_data) is
    v_counter pls_integer;
  begin
    v_counter := ti_data.count; 
    loop 
      exit when v_counter = 0;
      -- Now move the record to the new position. 
      ti_data(v_counter+1) := ti_data(v_counter); 
      -- Update the loop counter;
      v_counter := v_counter -1;
    end loop;
    ti_data(1) := null;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'INSERT_BLANK_RECORD');
  end insert_blank_record;


/*******************************************************************************
  NAME:      ADD_HEADER_RECORD                                            PUBLIC
*******************************************************************************/
  procedure add_header_record(ti_data in out tt_data, i_company in st_data, i_division in st_data,i_currency in st_data, i_doc_type in st_doc_type, i_doc_date in date, i_posting_date in date, i_reference_doc_no in st_data) is
    v_data st_data;
    v_doc_type st_data;
  begin
    -- Insert a blank space.
    insert_blank_record(ti_data);
    -- Determine the document type string to use for the this document type.
    case i_doc_type 
      when gc_doc_type_accrual then v_doc_type := 'Accrl';
      when gc_doc_type_accrual_reversal then v_doc_type := 'AcRvs';
      when gc_doc_type_ap_claim then v_doc_type := 'APclm';
      when gc_doc_type_ar_claim then v_doc_type := 'ARclm';
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
    ti_data(1) := v_data;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'ADD_HEADER_RECORD');
  end add_header_record;

/*******************************************************************************
  NAME:      ADD_TAX_RECORD                                               PUBLIC
*******************************************************************************/
  procedure add_tax_record(ti_data in out tt_data, i_tax_code in pxi_common.st_tax_code, i_tax in pxi_common.st_amount, i_tax_base in pxi_common.st_amount) is
    v_data st_data;
  begin
    -- Now generate the tax data line.
    v_data := 
      rpad('T',1) ||                                                -- INDICATOR
      rpad(nvl(i_tax_code,' '),2) ||                                -- TAX_CODE
      lpad(nvl(to_char(i_tax,'9999999999999999990.00'),'0.00'),23,' ') || -- AMOUNT
      lpad(nvl(to_char(i_tax_base,'9999999999999999990.00'),'0.00'),23,' ') || -- AMT_BASE
      rpad(' ',4) ||                                                -- COND_KEY
      rpad(' ',3) ||                                                -- ACCT_KEY
      rpad(' ',1);                                                  -- AUTO_TAX
    -- Now add the line to the current collection. 
    ti_data(ti_data.count+1) := v_data;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'ADD_TAX_RECORD');
  end add_tax_record;

/*******************************************************************************
  NAME:      ADD_GENERAL_LEDGER_RECORD                                   PUBLIC
*******************************************************************************/
  procedure add_general_ledger_record(ti_data in out tt_data, 
      i_account in st_data, i_cost_center in st_data, i_profit_center in st_data, 
      i_amount in pxi_common.st_amount, i_item_text in st_data, i_alloc_ref in st_data,
      i_tax_code in pxi_common.st_tax_code, i_material in st_data, 
      i_plant_code in st_data, i_cust_code in st_data, i_sales_org in st_data,
      i_distribution_channel in st_data) is
    v_data st_data;
    
  begin
    -- Now generate the general ledger line.
    v_data := 
      rpad('G',1) ||                                            -- INDICATOR
      lpad(nvl(i_account,'0'),10,'0') ||                        -- GL_ACCOUNT
      lpad(nvl(to_char(i_amount,'9999999999999999990.00'),'0.00'),23, ' ') || -- AMOUNT
      rpad(nvl(i_item_text,' '),50) ||                          -- ITEM_TEXT
      rpad(nvl(i_alloc_ref,' '),18) ||                       -- ALLOC_NMBR
      rpad(nvl(i_tax_code,' '),2) ||                            -- TAX_CODE
      rpad(nvl(i_cost_center,' '),10) ||                        -- COSTCENTER
      rpad(' ',12) ||                                           -- ORDERID 
      rpad(' ',24) ||                                           -- WBS_ELEMENT 
      rpad(' ',13) ||                                           -- QUANTITY
      rpad(' ',3) ||                                            -- BASE_UOM
      rpad(nvl(pxi_common.full_matl_code(i_material),' '),18) ||-- MATERIAL
      rpad(nvl(i_plant_code,' '),4) ||                          -- PLANT_CODE
      rpad(nvl(pxi_common.full_cust_code(i_cust_code),' '),10) ||                          -- CUSTOMER
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
  NAME:      ADD_AP_CLAIM_RECORD                                          PUBLIC
*******************************************************************************/
  procedure add_ap_claim_record(ti_data in out tt_data, 
      i_vendor in st_data, i_amount in pxi_common.st_amount, 
      i_alloc_ref in st_data, i_item_text in st_data) is
    v_data st_data;
  begin
    -- Insert Blank Space.
    insert_blank_record(ti_data);
    -- Now generate the general ledger line.
    v_data := 
      rpad('P',1) ||                                            -- INDICATOR
      lpad(nvl(pxi_common.full_vend_code(i_vendor),'0'),10,'0') || -- VENDOR_NO
      lpad(nvl(to_char(i_amount,'9999999999999999990.00'),'0.00'),23,' ') || -- AMOUNT
      rpad('*',4) ||                                            -- PMNTTRMS
      rpad(' ',8) ||                                            -- BLINE_DATE
      rpad('B',1) ||                                            -- PMNT_BLOCK
      rpad(nvl(i_alloc_ref,' '),18) ||                          -- ALLOC_NMBR
      rpad(nvl(i_item_text,' '),50) ||                          -- ITEM_TEXT
      rpad(' ',2) ||                                            -- W_TAX_CODE
      rpad(' ',23);                                             -- DISC_BASE
    -- Now add the line to the current collection.
    ti_data(1) := v_data;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'ADD_AP_CLAIM_RECORD');        
  end add_ap_claim_record;

/*******************************************************************************
  NAME:      ADD_CLAIM_RECORD                                             PUBLIC
*******************************************************************************/
  procedure add_ar_claim_record(ti_data in out tt_data, 
      i_cust_code in st_data, i_amount in pxi_common.st_amount, 
      i_alloc_ref in st_data, i_item_text in st_data) is
    v_data st_data;
  begin
    -- Insert a space in the collection. 
    insert_blank_record(ti_data);
    -- Now generate the general ledger line.
    v_data := 
      rpad('R',1) ||                                            -- INDICATOR
      lpad(pxi_common.full_cust_code(i_cust_code),10,'0') ||    -- CUSTOMER
      lpad(nvl(to_char(i_amount,'9999999999999999990.00'),'0.00'),23,' ') || -- AMOUNT
      rpad(' ',4) ||                                            -- PMNTTRMS
      rpad(' ',8) ||                                            -- BLINE_DATE
      rpad(' ',1) ||                                            -- PMNT_BLOCK
      rpad(nvl(i_alloc_ref,' '),18) ||                       -- ALLOC_NMBR
      rpad(nvl(i_item_text,' '),50) ||                          -- ITEM_TEXT
      rpad(' ',1);                                              -- DUNN_BLOCK
    -- Now add the line to the current collection.
    ti_data(1) := v_data;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'ADD_AR_CLAIM_RECORD');
  end add_ar_claim_record;

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
     elsif ti_data.count > gc_max_idoc_rows then 
       pxi_common.raise_promax_error(pc_package_name,'CREATE_INTERFACE','More data than is allowed in interface was supplied.');
     else
       -- Now output the current data extract as an IDOC.   Note that header record starts in position zero.
       v_instance := lics_outbound_loader.create_interface('PXIATL01');
       for v_counter in 1..ti_data.count loop
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
  function sum_gl_data(ti_gl_data in tt_gl_data) return pxi_common.st_amount is
    v_counter pls_integer;
    v_result pxi_common.st_amount;
  begin
    v_result := 0;
    v_counter := 0;
    loop 
      v_counter := v_counter + 1;
      exit when v_counter > ti_gl_data.count;
      v_result := v_result + ti_gl_data(v_counter).amount;
    end loop;
    return v_result;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'SUM_GL_DATA');  
  end sum_gl_data;

/*******************************************************************************
  NAME:      SEND_DATA                                                    PUBLIC
*******************************************************************************/
   procedure send_data(
     ti_gl_data in tt_gl_data, 
     i_doc_type in st_doc_type,
     i_doc_reference in st_data) is
     c_method_name pxi_common.st_package_name := 'SEND_DATA';
     v_counter pls_integer;
     tv_data tt_data;
     -- Document Change Tracking Variables.
     v_cur_company pxi_common.st_company;
     v_cur_promax_division pxi_common.st_promax_division;
     v_cur_posting_date date;
     v_cur_doc_date date;
     v_cur_currency pxi_common.st_currency;
     v_cur_tax_code pxi_common.st_tax_code;
     v_cur_customer pxi_common.st_customer;
     v_cur_vendor pxi_common.st_vendor;
     v_cur_alloc_ref pxi_common.st_reference; 
     v_cur_claim_text pxi_common.st_text;
    
     -- Summation Fields
     v_sum_tax pxi_common.st_amount;
     v_sum_tax_base pxi_common.st_amount;
     v_sum_amount pxi_common.st_amount;

     procedure reset_variables is
     begin
       v_cur_company := null; 
       v_cur_tax_code := null;
       v_cur_promax_division := null;
       v_cur_doc_date := null;
       v_cur_posting_date := null;
       v_cur_currency := null; 
       v_cur_customer := null;
       v_cur_vendor := null;
       v_cur_alloc_ref := null;
       v_cur_claim_text := null;
       -- Update the summation variables
       v_sum_tax_base := 0;
       v_sum_tax := 0;
       v_sum_amount := 0;
     end reset_variables;
     
     procedure perform_send is
     begin
       -- Now add an accounts payable line if required.
       if i_doc_type = gc_doc_type_ap_claim then
         add_ap_claim_record(tv_data,
           v_cur_vendor,v_sum_amount*-1,
           v_cur_alloc_ref,v_cur_claim_text);
       end if;
       -- Now add a accounts receival line if required.
       if i_doc_type = gc_doc_type_ar_claim then 
         add_ar_claim_record(tv_data,
           v_cur_customer, v_sum_amount*-1, 
           v_cur_alloc_ref,v_cur_claim_text);
       end if;
       -- Add the header record.
       add_header_record(tv_data, 
         v_cur_company,
         v_cur_promax_division,
         v_cur_currency,
         i_doc_type,
         v_cur_doc_date,
         v_cur_posting_date,
         nvl(i_doc_reference,v_cur_alloc_ref));   -- For AP AR Claims use the alloc ref as the header.
       -- Now add a tax line data. 
       add_tax_record(tv_data,v_cur_tax_code,v_sum_tax,v_sum_tax_base);
       -- Now acutally create the interface and send it.
       create_interface(tv_data);
       -- Now clear out the current information and clear sumation counters. 
       tv_data.delete;
       -- Now perform a variable reset.
       reset_variables;
     exception
       when others then 
         pxi_common.reraise_promax_exception(pc_package_name,c_method_name);           
     end perform_send;
   begin
     v_counter := 0;
     reset_variables;
     loop 
       -- Now send the current data block if it is currently getting full.  But only send once the document balances to zero.  Start checking for zero 
       if i_doc_type in (gc_doc_type_accrual, gc_doc_type_accrual_reversal) then 
         if tv_data.count >= gc_max_idoc_rows - gc_search_for_balance and tv_data.count > 0 and v_sum_amount = 0 then 
           perform_send;
         end if;
         -- Now check if we have execeed the maximum rows, less the tax and header rows.
         if tv_data.count >= gc_max_idoc_rows - 2 then 
           pxi_common.raise_promax_error(pc_package_name,c_method_name,'Unable to find a record to balance this idoc data to zero within the last ' || gc_search_for_balance || ' rows of data.  Max IDOC size : ' || gc_max_idoc_rows || '.');
         end if;
       else 
         if tv_data.count >= gc_max_idoc_rows - gc_rows_for_header_footer and tv_data.count > 0 then 
           perform_send;
         end if;
       end if;
       -- Check if we are finished with the load processing.
       v_counter := v_counter + 1;
       exit when v_counter > ti_gl_data.count;
       -- Detect if there is any change in the key change fields.  If there is then lets send this document and start a new one. 
       if (v_cur_company <> ti_gl_data(v_counter).company or 
           v_cur_promax_division <> ti_gl_data(v_counter).promax_division or
           v_cur_tax_code <> ti_gl_data(v_counter).tax_code or 
           v_cur_doc_date <> ti_gl_data(v_counter).document_date or 
           v_cur_posting_date <> ti_gl_data(v_counter).posting_date or 
           v_cur_currency <> ti_gl_data(v_counter).currency or 
           -- If AR Claim create new IDOCs on change in customer as well.
           (i_doc_type = gc_doc_type_ar_claim and v_cur_customer <> ti_gl_data(v_counter).customer_code) or
           -- If AP Cliam create new IDOCs on change in vendor as well.
           (i_doc_type = gc_doc_type_ap_claim and v_cur_vendor <> ti_gl_data(v_counter).vendor_code) or  
           -- It either claim type 
           (i_doc_type in (gc_doc_type_ap_claim, gc_doc_type_ar_claim) and (v_cur_alloc_ref <> ti_gl_data(v_counter).alloc_ref or v_cur_claim_text <> ti_gl_data(v_counter).claim_text)) 
           ) then 
         perform_send;
       end if;
       -- Now make sure the company and tax code tracking variables are set.
       v_cur_company := ti_gl_data(v_counter).company;
       v_cur_promax_division := ti_gl_data(v_counter).promax_division;
       v_cur_tax_code := ti_gl_data(v_counter).tax_code;
       v_cur_doc_date := ti_gl_data(v_counter).document_date;
       v_cur_posting_date := ti_gl_data(v_counter).posting_date;
       v_cur_currency := ti_gl_data(v_counter).currency; 
       v_cur_customer := ti_gl_data(v_counter).customer_code;
       v_cur_vendor := ti_gl_data(v_counter).vendor_code;
       v_cur_alloc_ref := ti_gl_data(v_counter).alloc_ref;
       v_cur_claim_text := ti_gl_data(v_counter).claim_text;
       -- Now add create the current gl record. 
       add_general_ledger_record(tv_data,
         ti_gl_data(v_counter).account_code,
         ti_gl_data(v_counter).cost_center, 
         ti_gl_data(v_counter).profit_center,
         ti_gl_data(v_counter).tax_amount_base,
         ti_gl_data(v_counter).item_text, 
         ti_gl_data(v_counter).alloc_ref,
         ti_gl_data(v_counter).tax_code,
         ti_gl_data(v_counter).material_code,
         ti_gl_data(v_counter).plant_code,
         ti_gl_data(v_counter).customer_code,
         ti_gl_data(v_counter).sales_org,
         ti_gl_data(v_counter).dstrbtn_chnnl);
      -- Now update the value summation fields.
      v_sum_tax_base := v_sum_tax_base + ti_gl_data(v_counter).tax_amount_base;
      v_sum_tax := v_sum_tax + ti_gl_data(v_counter).tax_amount;
      v_sum_amount := v_sum_amount + ti_gl_data(v_counter).amount;
     end loop;
     -- Check if there is any data in the collection ready for sending.
     if tv_data.count > 0 then 
       if v_sum_amount <> 0 and i_doc_type in (gc_doc_type_accrual, gc_doc_type_accrual_reversal) then 
         pxi_common.raise_promax_error(pc_package_name,c_method_name,'Attempting to send Accrual IDOC data, currently it does not balance to zero.');
       else
         perform_send;
       end if;
     end if;
   exception
     when others then 
       pxi_common.reraise_promax_exception(pc_package_name,'SEND_DATA');
   end send_data;

end pxiatl01_extract;
