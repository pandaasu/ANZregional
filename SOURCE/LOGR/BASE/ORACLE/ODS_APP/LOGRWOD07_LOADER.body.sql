create or replace 
PACKAGE body LOGRWOD07_LOADER AS 

/*******************************************************************************
  Data File Column Headings.
*******************************************************************************/  
  pc_column_sdesc constant fflu_common.st_name := 'SDESC';

/*******************************************************************************
  Data File Expected Values
*******************************************************************************/  
  pc_market_value constant fflu_common.st_name := 'AUS';
  pc_shopper_level_value constant fflu_common.st_name := 'ALL SHOPPERS';

/*******************************************************************************
  Interface Field Definitions
*******************************************************************************/  
  pc_field_market constant fflu_common.st_name := 'Market';
  pc_field_shopper_level constant fflu_common.st_name := 'Shopper Level';
  pc_field_quarter constant fflu_common.st_name := 'Quarter';
  pc_field_quarter_period constant fflu_common.st_name := 'Quarter Period';
  pc_field_product constant fflu_common.st_name := 'Product';
  pc_field_sub_category constant fflu_common.st_name := 'Sub Category';
  pc_field_brand constant fflu_common.st_name := 'Brand';
  pc_field_sub_brand constant fflu_common.st_name := 'Sub Brand';
  pc_field_packtype constant fflu_common.st_name := 'Pack Type';
  pc_field_serving_size constant fflu_common.st_name := 'Serving Size';
  pc_field_relative_penetration constant fflu_common.st_name := 'Relative Penetration';

/*******************************************************************************
  Interface Suffix's
*******************************************************************************/  
  pc_suffix_dog constant fflu_common.st_interface := '1';
  pc_suffix_cat constant fflu_common.st_interface := '2';

/*******************************************************************************
  Data Animal Types
*******************************************************************************/  
  pc_data_animal_type_dog constant logr_wod_sales_scan.data_animal_type%type := 'Dog';
  pc_data_animal_type_cat constant logr_wod_sales_scan.data_animal_type%type := 'Cat';
  
/*******************************************************************************
  Package Variables
*******************************************************************************/  
  pv_prev_mars_period logr_wod_sales_scan.mars_period%type;
  pv_data_animal_type logr_wod_sales_scan.data_animal_type%type;
  pv_user fflu_common.st_user;
  
/*******************************************************************************
  NAME:      ON_START                                                     PUBLIC
*******************************************************************************/  
  procedure on_start is 
  begin
    -- Initialise any package processing variables.
    pv_prev_mars_period := null;
    pv_data_animal_type := null;
    pv_user := null;
    -- Now determine what the interface sufix was and hence the data animal type. 
    case fflu_utils.get_interface_suffix
      when pc_suffix_dog then pv_data_animal_type := pc_data_animal_type_dog;
      when pc_suffix_cat then pv_data_animal_type := pc_data_animal_type_cat;
      else 
        fflu_utils.log_interface_error('Interface Suffix',fflu_utils.get_interface_suffix,'Unknown Interface Suffix.');
    end case;
    -- Now initialise the data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,true,true);
    -- Now define the column structure
    fflu_data.add_char_field_csv(pc_field_market,1,pc_column_sdesc,null,100,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_shopper_level,2,pc_column_sdesc,null,100,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_quarter,3,pc_column_sdesc,null,17,fflu_data.gc_not_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_mars_date_field_csv(pc_field_quarter_period,3,pc_column_sdesc,'MARS_PERIOD','DD/MM/YYYY',8,10,190001,999913,fflu_data.gc_not_allow_null);
    fflu_data.add_char_field_csv(pc_field_product,4,pc_column_sdesc,null,100,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_sub_category,5,'SUBCATEGORY',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_brand,6,'BRAND',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_sub_brand,7,'SUB_BRAND',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_packtype,8,'PACKTYPE',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_serving_size,9,'SERVING_SIZE',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_number_field_csv(pc_field_relative_penetration,10,'Relative Penetration (AUS)',null,-1000000,1000000,fflu_data.gc_allow_null);
    -- Now access the user name.  Must be called after initialising fflu_data, or after fflu_utils.log_interface_progress.
    pv_user := fflu_utils.get_interface_user;
    -- Delete out any previously loaded data for this data animal type.
    delete from logr_wod_house_pntrtn where data_animal_type = pv_data_animal_type;
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
      -- Now perform a sense check that the category if it contains Dog or Cat that it matches the interface suffix for this file.
      if instr(initcap(fflu_data.get_char_field(pc_field_sub_category)),pc_data_animal_type_dog) > 0 and fflu_utils.get_interface_suffix <> pc_suffix_dog then
        fflu_data.log_field_error(pc_field_sub_category,'This category contained reference to '|| pc_data_animal_type_dog ||' which was not expected for this interface.');
        v_ok := false;
      end if;
      if instr(initcap(fflu_data.get_char_field(pc_field_sub_category)),pc_data_animal_type_cat) > 0 and fflu_utils.get_interface_suffix <> pc_suffix_cat then
        fflu_data.log_field_error(pc_field_sub_category,'This category contained reference to '|| pc_data_animal_type_cat ||' which was not expected for this interface.');
        v_ok := false;
      end if;
      -- Check that market and shopper level are the expected values.
      if upper(fflu_data.get_char_field(pc_field_market)) <> pc_market_value then 
        fflu_data.log_field_error(pc_field_market,'Expected value to be ' || pc_market_value || '.');
        v_ok := false;
      end if;
      if upper(fflu_data.get_char_field(pc_field_shopper_level)) <> pc_shopper_level_value then 
        fflu_data.log_field_error(pc_field_shopper_level,'Expected value to be ' || pc_shopper_level_value || '.');
        v_ok := false;
      end if;
      -- Now insert the logr sales scan data.
      if v_ok = true then 
        insert into logr_wod_house_pntrtn (
          market,
          shopper_level,
          quarter,
          quarter_period,
          data_animal_type,
          product,
          sub_catgry,
          brand,
          sub_brand,
          packtype,
          serving_size,
          rltv_pntrtn,
          last_updtd_user,
          last_updtd_time
        ) values (
          upper(fflu_data.get_char_field(pc_field_market)), 
          upper(fflu_data.get_char_field(pc_field_shopper_level)), 
          fflu_data.get_char_field(pc_field_quarter),
          fflu_data.get_mars_date_field(pc_field_quarter_period),
          pv_data_animal_type,
          initcap(fflu_data.get_char_field(pc_field_product)),
          initcap(fflu_data.get_char_field(pc_field_sub_category)),
          initcap(fflu_data.get_char_field(pc_field_brand)),
          initcap(fflu_data.get_char_field(pc_field_sub_brand)),
          initcap(fflu_data.get_char_field(pc_field_packtype)),
          initcap(fflu_data.get_char_field(pc_field_serving_size)),
          fflu_data.get_number_field(pc_field_relative_penetration),
          pv_user,
          sysdate
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
  pv_data_animal_type := null;
  pv_user := null;
END LOGRWOD07_LOADER;