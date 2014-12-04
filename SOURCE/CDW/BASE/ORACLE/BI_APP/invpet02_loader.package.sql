create or replace package invpet02_loader as
  /*****************************************************************************
  ** PACKAGE DEFINITION
  ******************************************************************************
  
    Schema    : bi_app 
    Package   : invpet02_loader 
    Author    : Trevor Keon         
  
    Description
    ----------------------------------------------------------------------------
    [invpet02] Inventory - Obsolete Stock Detail 
    [replace_all] Template 
    
    Functions
    ----------------------------------------------------------------------------
    + LICS Hooks 
      - on_start                   Called on starting the interface.
      - on_data(i_row in varchar2) Called for each row of data in the interface.
      - on_end                     Called at the end of processing.
    + FFLU Hooks
      - on_get_file_type           Returns the type of file format expected.
      - on_get_csv_qualifier       Returns the CSV file format qualifier.  
  
    Date        Author                Description
    ----------  --------------------  ------------------------------------------
    2014-11-11  Trevor Keon           [Auto Generated] 
  
  *****************************************************************************/

  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

end invpet02_loader;
/

create or replace package body invpet02_loader as 

  -- Interface column constants
  pc_matl_code constant fflu_common.st_name := 'Material';
  pc_batch constant fflu_common.st_name := 'Batch';
  pc_status constant fflu_common.st_name := 'Status';
  pc_original_rrp constant fflu_common.st_name := 'Original RRP';
  pc_max_clear_rrp constant fflu_common.st_name := 'Maximum Clearance RRP';
  pc_max_clear_rrp_ex_gst constant fflu_common.st_name := 'Maximum Clearance RRP (exc GST)';
  pc_cust_saving constant fflu_common.st_name := 'Customer Saving';
  pc_orig_list_price constant fflu_common.st_name := 'Original List Price';
  pc_curr_list_price constant fflu_common.st_name := 'Current List Price';
  pc_on_inv_case_deal constant fflu_common.st_name := 'On Invoice Discount or Case Deal to be Claimed';
  pc_case_deal constant fflu_common.st_name := 'Case Deal';
  pc_price_case constant fflu_common.st_name := 'Price/Case';
  pc_price_unit constant fflu_common.st_name := 'Price/Unit';
  pc_discount constant fflu_common.st_name := 'Discount';
  pc_margin constant fflu_common.st_name := 'Margin';
  pc_account constant fflu_common.st_name := 'Account';
  pc_deal_qty constant fflu_common.st_name := 'Deal QTY';
  pc_inv_date constant fflu_common.st_name := 'Invoice Date';
  pc_comment_1 constant fflu_common.st_name := 'Comment Field #1';
  pc_comment_2 constant fflu_common.st_name := 'Comment Field #2';  
  
  -- Package variables
  pv_user fflu_common.st_user;
 
  ------------------------------------------------------------------------------
  -- LICS : ON_START 
  ------------------------------------------------------------------------------
  procedure on_start is
  
  begin    
    -- Initialise data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,fflu_data.gc_file_header,fflu_data.gc_allow_missing);
    
    -- Add column structure
    fflu_data.add_char_field_del(pc_matl_code,1,'Material',1,32,fflu_data.gc_not_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_char_field_del(pc_batch,2,'Batch',1,16,fflu_data.gc_not_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_char_field_del(pc_status,3,'Status',1,100,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_number_field_del(pc_original_rrp,4,'Original RRP','999999.9',0,999999.99,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_del(pc_max_clear_rrp,5,'Maximum Clearance RRP','999999.9',0,999999.99,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_del(pc_max_clear_rrp_ex_gst,6,'Maximum Clearance RRP (exc GST)','999999.9',0,999999.99,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_del(pc_cust_saving,7,'Customer Saving','999999.9',0,999999.99,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_del(pc_orig_list_price,8,'Original List Price','999999.9',0,999999.99,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_del(pc_curr_list_price,9,'Current List Price','999999.9',0,999999.99,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_del(pc_on_inv_case_deal,10,'On Invoice Discount or Case Deal to be Claimed','999999.9',0,999999.99,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_del(pc_case_deal,11,'Case Deal','999999.9',0,999999.99,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_del(pc_price_case,12,'Price/Case','999999.9',0,999999.99,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_del(pc_price_unit,13,'Price/Unit','999999.9',0,999999.99,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_del(pc_discount,14,'Discount','999999.9',0,999999.99,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_del(pc_margin,15,'Margin','999999.9',-999999.99,999999.99,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_del(pc_account,16,'Account',1,100,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_number_field_del(pc_deal_qty,17,'Deal QTY','999999.9',0,999999.99,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_del(pc_inv_date, 18, 'Invoice Date', 'dd/mm/yyyy', fflu_data.gc_null_offset, fflu_data.gc_null_offset_len, fflu_data.gc_null_min_date, fflu_data.gc_null_max_date, fflu_data.gc_allow_null);    
    fflu_data.add_char_field_del(pc_comment_1,19,'Comment Field #1',1,1000,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_char_field_del(pc_comment_2,20,'Comment Field #2',1,1000,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    
    -- Get user name - MUST be called after initialising fflu_data, or after fflu_utils.log_interface_progress.
    pv_user := fflu_utils.get_interface_user;
        
    -- Delete previous table entries
    delete from bi.obsolete_stock_dtl;
        
  exception 
    when others then 
      fflu_data.log_interface_exception('On Start');
  end on_start;

  ------------------------------------------------------------------------------
  -- LICS : ON_DATA
  ------------------------------------------------------------------------------
  procedure on_data(p_row in varchar2) is
  
    v_row_status_ok boolean;
    v_current_field fflu_common.st_name;
    
    rv_insert_values bi.obsolete_stock_dtl%rowtype;

  begin
    
    if fflu_data.parse_data(p_row) = true then
      -- Set row status
      v_row_status_ok := true;
            
      -- Set insert row columns
      begin
        -- Assign Material
        v_current_field := pc_matl_code;
        rv_insert_values.matl_code := fflu_data.get_char_field(pc_matl_code);
        -- Assign Batch
        v_current_field := pc_batch;
        rv_insert_values.batch := fflu_data.get_char_field(pc_batch);
        -- Assign Status
        v_current_field := pc_status;
        rv_insert_values.status := fflu_data.get_char_field(pc_status);
        -- Assign Original RRP
        v_current_field := pc_original_rrp;
        rv_insert_values.original_rrp := fflu_data.get_number_field(pc_original_rrp);
        -- Assign Maximum Clearance RRP
        v_current_field := pc_max_clear_rrp;
        rv_insert_values.max_clear_rrp := fflu_data.get_number_field(pc_max_clear_rrp);
        -- Assign Maximum Clearance RRP (exc GST)
        v_current_field := pc_max_clear_rrp_ex_gst;
        rv_insert_values.max_clear_rrp_ex_gst := fflu_data.get_number_field(pc_max_clear_rrp_ex_gst);
        -- Assign Customer Saving
        v_current_field := pc_cust_saving;
        rv_insert_values.cust_saving := fflu_data.get_number_field(pc_cust_saving);
        -- Assign Original List Price
        v_current_field := pc_orig_list_price;
        rv_insert_values.orig_list_price := fflu_data.get_number_field(pc_orig_list_price);
        -- Assign Current List Price
        v_current_field := pc_curr_list_price;
        rv_insert_values.curr_list_price := fflu_data.get_number_field(pc_curr_list_price);
        -- Assign On Invoice Document or Case Deal to be Claimed
        v_current_field := pc_on_inv_case_deal;
        rv_insert_values.on_inv_case_deal := fflu_data.get_number_field(pc_on_inv_case_deal);
        -- Assign Case Deal
        v_current_field := pc_case_deal;
        rv_insert_values.case_deal := fflu_data.get_number_field(pc_case_deal);
        -- Assign Price/Case
        v_current_field := pc_price_case;
        rv_insert_values.price_case := fflu_data.get_number_field(pc_price_case);
        -- Assign Price/Unit
        v_current_field := pc_price_unit;
        rv_insert_values.price_unit := fflu_data.get_number_field(pc_price_unit);
        -- Assign Discount
        v_current_field := pc_discount;
        rv_insert_values.discount := fflu_data.get_number_field(pc_discount);
        -- Assign Margin
        v_current_field := pc_margin;
        rv_insert_values.margin := fflu_data.get_number_field(pc_margin);
        -- Assign Account
        v_current_field := pc_account;
        rv_insert_values.account := fflu_data.get_char_field(pc_account);
        -- Assign Deal QTY
        v_current_field := pc_deal_qty;
        rv_insert_values.deal_qty := fflu_data.get_number_field(pc_deal_qty);
        -- Assign Invoice Date
        v_current_field := pc_inv_date;
        rv_insert_values.inv_date := fflu_data.get_date_field(pc_inv_date);        
        -- Assign Comment Field #1
        v_current_field := pc_comment_1;
        rv_insert_values.comment_1 := fflu_data.get_char_field(pc_comment_1);
        -- Assign Comment Field #2
        v_current_field := pc_comment_2;
        rv_insert_values.comment_2 := fflu_data.get_char_field(pc_comment_2);

        -- Default Columns .. Added to ALL Tables
        -- Last Update User
        v_current_field := 'Last Update User';        
        rv_insert_values.last_update_user := pv_user;
        -- Last Update Date
        v_current_field := 'Last Update Date';        
        rv_insert_values.last_update_date := sysdate;
      exception
        when others then
          v_row_status_ok := false;
          fflu_data.log_field_exception(v_current_field, 'Field Assignment Error');
      end;
                  
      -- Insert row, if row status is ok 
      if v_row_status_ok = true then 
        insert into bi.obsolete_stock_dtl values rv_insert_values;
      end if;   
      
    end if;
  exception 
    when others then 
      fflu_data.log_interface_exception('On Data');
  end on_data;
  
  ------------------------------------------------------------------------------
  -- LICS : ON_END
  ------------------------------------------------------------------------------
  procedure on_end is 
  begin 
    -- Only perform a commit if there were no errors at all 
    if fflu_data.was_errors = true then 
      rollback;
    else 
      commit;
    end if;
    -- Perform a final cleanup and a last progress logging
    fflu_data.cleanup;
  exception 
    when others then 
      fflu_data.log_interface_exception('On End');
      rollback;
  end on_end;

  ------------------------------------------------------------------------------
  -- FFLU : ON_GET_FILE_TYPE
  ------------------------------------------------------------------------------
  function on_get_file_type return varchar2 is 
  begin 
    return fflu_common.gc_file_type_csv;
  end on_get_file_type;

  ------------------------------------------------------------------------------
  -- FFLU : ON_GET_CSV_QUALIFER
  ------------------------------------------------------------------------------
  function on_get_csv_qualifier return varchar2 is
  begin 
    return fflu_common.gc_csv_qualifier_null;
  end on_get_csv_qualifier;

end invpet02_loader;
/

grant execute on invpet02_loader to lics_app, fflu_app;

/*******************************************************************************
  END
*******************************************************************************/
