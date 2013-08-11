create or replace 
PACKAGE body PETSTOCKSCAN_LOADER AS 

/*******************************************************************************
  Interface Field Definitions
*******************************************************************************/  
  pc_field_branch constant fflu_common.st_name := 'Branch';
  pc_field_department constant fflu_common.st_name := 'Department';
  pc_field_grp_code constant fflu_common.st_name := 'Group Code';
  pc_field_sub_grp_code constant fflu_common.st_name := 'Sub Group Code';
  pc_field_sales_value constant fflu_common.st_name := 'Sales Value';
  pc_field_qty_sold constant fflu_common.st_name := 'Qty Sold';
  pc_field_month constant fflu_common.st_name := 'Month';
  pc_field_ean constant fflu_common.st_name := 'EAN';
  pc_field_product constant fflu_common.st_name := 'Product';
  pc_field_account_no constant fflu_common.st_name := 'Account No';
  pc_field_reference_no constant fflu_common.st_name := 'Reference No';

/*******************************************************************************
  Interface Sufix's
*******************************************************************************/  
  
/*******************************************************************************
  Package Variables
*******************************************************************************/  
  pv_prev_month petstock_sales_scan.month%type;
  
/*******************************************************************************
  NAME:      ON_START                                                     PUBLIC
*******************************************************************************/  
  procedure on_start is 
  begin
    -- Initialise any package processing variables.
    pv_prev_month := null;
    -- Now initialise the data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,true,false);
    -- Now define the column structure
    fflu_data.add_char_field_csv(pc_field_branch,1,'Branch Name',null,100);
    fflu_data.add_char_field_csv(pc_field_department,2,'Dept Code',null,100);
    -- BLANK COLUMN 3
    fflu_data.add_char_field_csv(pc_field_grp_code,4,'Group Code',null,100);
    fflu_data.add_char_field_csv(pc_field_sub_grp_code,5,'Sub Group Code',null,100);
    -- BLANK COLUMN 6
    fflu_data.add_number_field_csv(pc_field_sales_value,7,'Sales Inc GST','0.00',null,null,true);
    fflu_data.add_number_field_csv(pc_field_qty_sold,8,'Qty Sold','0',null,null,true);
    fflu_data.add_date_field_csv(pc_field_month,9,'Month','MON-YY');
    fflu_data.add_char_field_csv(pc_field_ean,10,'Barcode',null,100);  
    -- BLANK COLUMN 11
    fflu_data.add_char_field_csv(pc_field_product,12,'Description',null,100);
    -- BLANK COLUMN 13
    fflu_data.add_char_field_csv(pc_field_account_no,14,'Account No',null,100);
    fflu_data.add_char_field_csv(pc_field_reference_no,15,'Reference No',null,100);
  exception 
    when others then 
      fflu_utils.log_interface_exception('On Start');
end on_start;


/*******************************************************************************
  NAME:      ON_DATA                                                      PUBLIC
*******************************************************************************/  
  procedure on_data(p_row in varchar2) is 
    v_ok boolean;
  begin
    if fflu_data.parse_data(p_row) = true then
      -- Set an OK Tracking variable.
      v_ok := true;
      -- Check if this is the first data row and if the current mars period is set. 
      if pv_prev_month is null then 
        pv_prev_month := fflu_data.get_date_field(pc_field_month);
        -- Clear out any previous data for this same mars period.
        delete from petstock_sales_scan where month = pv_prev_month;
      else
        -- Now check that each supplied mars period is the same as the first one that was supplied in the file. 
        if pv_prev_month <> fflu_data.get_date_field(pc_field_month) then 
          fflu_data.log_field_error(pc_field_month,'Month was different to first month found in data file. [' || to_char(pv_prev_month,'MON-YYYY') || '].');
          v_ok := false;
        end if;
      end if;
      -- Now insert the logr sales scan data.
      if v_ok = true then 
        insert into petstock_sales_scan (
          branch,
          department,
          grp_code,
          sub_grp_code,
          sales_value,
          qty_sold,
          month,
          ean,
          product,
          account_no,
          reference_no
        ) values (
          fflu_data.get_char_field(pc_field_branch),
          fflu_data.get_char_field(pc_field_department),
          fflu_data.get_char_field(pc_field_grp_code),
          fflu_data.get_char_field(pc_field_sub_grp_code),
          fflu_data.get_number_field(pc_field_sales_value),
          fflu_data.get_number_field(pc_field_qty_sold),
          fflu_data.get_date_field(pc_field_month),
          fflu_data.get_char_field(pc_field_ean),
          fflu_data.get_char_field(pc_field_product), 
          fflu_data.get_char_field(pc_field_account_no),
          fflu_data.get_char_field(pc_field_reference_no)
        );
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
    -- Only perform a commit if there were no errors at all. 
    if fflu_data.was_errors = true then 
      rollback;
    else 
      commit;
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
    return fflu_common.gc_file_type_csv;
  end on_get_file_type;
  
/*******************************************************************************
  NAME:      ON_GET_CSV_QUALIFER                                          PUBLIC
*******************************************************************************/  
  function on_get_csv_qualifier return varchar2 is
  begin 
    return fflu_common.gc_csv_qualifier_double_quote;
  end on_get_csv_qualifier;

-- Initialise this package.  
begin
  pv_prev_month := null;
END PETSTOCKSCAN_LOADER;