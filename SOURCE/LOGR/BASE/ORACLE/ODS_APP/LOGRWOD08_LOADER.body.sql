create or replace 
PACKAGE body LOGRWOD08_LOADER AS 

/*******************************************************************************
  Interface Field Definitions
*******************************************************************************/  
  pc_field_time constant fflu_common.st_name := 'Time';
  pc_field_period constant fflu_common.st_name := 'Period';
  pc_field_mars_period constant fflu_common.st_name := 'Mars Period';
  pc_field_measure constant fflu_common.st_name := 'Measure';
  pc_field_product constant fflu_common.st_name := 'Product';
  pc_field_market constant fflu_common.st_name := 'Market';
  pc_field_data_value constant fflu_common.st_name := 'Data Value';
  pc_field_manufacturer constant fflu_common.st_name := 'Manufacturer';
  pc_field_brand constant fflu_common.st_name := 'Brand';
  pc_field_animal_type constant fflu_common.st_name := 'Animal Type';
  pc_field_department constant fflu_common.st_name := 'Department';
  pc_field_category constant fflu_common.st_name := 'Category';
  pc_field_segment constant fflu_common.st_name := 'Segment';
  pc_field_packtype constant fflu_common.st_name := 'Packtype';
  pc_field_packsize constant fflu_common.st_name := 'Packsize';
  pc_field_size constant fflu_common.st_name := 'Size';
  pc_field_ean constant fflu_common.st_name := 'Ean';

/*******************************************************************************
  Interface Sufix's
*******************************************************************************/  
  
/*******************************************************************************
  Package Variables
*******************************************************************************/  
  pv_prev_mars_period logr_wod_sales_scan.mars_period%type;
  
/*******************************************************************************
  NAME:      ON_START                                                     PUBLIC
*******************************************************************************/  
  procedure on_start is 
  begin
    -- Initialise any package processing variables.
    pv_prev_mars_period := null;
    -- Now initialise the data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,true,false);
    -- Now define the column structure
    fflu_data.add_char_field_csv(pc_field_period,1,pc_field_time,null,14);
    fflu_data.add_mars_date_field_csv(pc_field_mars_period,1,pc_field_time,'MARS_PERIOD','DD/MM/YY',6,8);
    fflu_data.add_char_field_csv(pc_field_measure,2,pc_field_measure,null,100);
    fflu_data.add_char_field_csv(pc_field_product,3,pc_field_product,null,100);
    fflu_data.add_char_field_csv(pc_field_market,4,pc_field_market,null,100);
    fflu_data.add_number_field_csv(pc_field_data_value,5,pc_field_data_value,null,-1000000,1000000,true);
    fflu_data.add_char_field_csv(pc_field_manufacturer,6,pc_field_manufacturer,null,100);
    fflu_data.add_char_field_csv(pc_field_brand,7,pc_field_brand,null,100);
    fflu_data.add_char_field_csv(pc_field_animal_type,8,pc_field_animal_type,null,100);
    fflu_data.add_char_field_csv(pc_field_department,9,pc_field_department,null,100);
    fflu_data.add_char_field_csv(pc_field_category,10,pc_field_category,null,100);
    fflu_data.add_char_field_csv(pc_field_segment,11,pc_field_segment,null,100,true);
    fflu_data.add_char_field_csv(pc_field_packtype,12,pc_field_packtype,null,100,true);
    fflu_data.add_char_field_csv(pc_field_packsize,13,pc_field_packsize,null,100,true);
    fflu_data.add_number_field_csv(pc_field_size,14,pc_field_size,null,0,100000,false);
    fflu_data.add_char_field_csv(pc_field_ean,15,pc_field_ean,null,100);
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
      if pv_prev_mars_period is null then 
        pv_prev_mars_period := fflu_data.get_mars_date_field(pc_field_mars_period);
        -- Clear out any previous data for this same mars period.
        delete from logr_wod_sales_scan where mars_period = pv_prev_mars_period;
      else
        -- Now check that each supplied mars period is the same as the first one that was supplied in the file. 
        if pv_prev_mars_period <> fflu_data.get_mars_date_field(pc_field_mars_period) then 
          fflu_data.log_field_error(pc_field_mars_period,'Mars period was different to first period found in data file. [' || pv_prev_mars_period || '].');
          v_ok := false;
        end if;
      end if;
      -- Now insert the logr sales scan data.
      if v_ok = true then 
        insert into logr_wod_sales_scan (
          period, 
          mars_period, 
          measure, 
          product, 
          market, 
          data_value, 
          MANUFACTURER,
          BRAND,
          ANIMAL_TYPE,
          DEPARTMENT,
          CATGRY,
          SGMNT,
          PACKTYPE,
          PACKSIZE,
          SZE_GRAMS,
          EAN
        ) values (
          fflu_data.get_char_field(pc_field_period), 
          fflu_data.get_mars_date_field(pc_field_mars_period),
          fflu_data.get_char_field(pc_field_measure),
          fflu_data.get_char_field(pc_field_product),
          fflu_data.get_char_field(pc_field_market),
          fflu_data.get_number_field(pc_field_data_value),
          fflu_data.get_char_field(pc_field_manufacturer),
          fflu_data.get_char_field(pc_field_brand),
          fflu_data.get_char_field(pc_field_animal_type),
          fflu_data.get_char_field(pc_field_department),
          fflu_data.get_char_field(pc_field_category),
          fflu_data.get_char_field(pc_field_segment),
          fflu_data.get_char_field(pc_field_packtype),
          fflu_data.get_char_field(pc_field_packsize),
          fflu_data.get_number_field(pc_field_size),
          fflu_data.get_char_field(pc_field_ean)
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
  pv_prev_mars_period := null;
END LOGRWOD08_LOADER;