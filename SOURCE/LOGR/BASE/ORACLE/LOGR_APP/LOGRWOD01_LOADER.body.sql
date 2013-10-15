create or replace 
PACKAGE body LOGRWOD01_LOADER AS 
/*******************************************************************************
  Interface : Laws of Growth - Australia Petcare - Sales Scan Data
*******************************************************************************/

/*******************************************************************************
  Data File Column Headings.
*******************************************************************************/  
  pc_column_time constant fflu_common.st_name := 'Time';

/*******************************************************************************
  Interface Field Definitions
*******************************************************************************/  
  pc_field_period constant fflu_common.st_name := 'Period';
  pc_field_mars_period constant fflu_common.st_name := 'Mars Period';
  pc_field_measure constant fflu_common.st_name := 'Measure';
  pc_field_product constant fflu_common.st_name := 'Product';
  pc_field_market constant fflu_common.st_name := 'Market';
  pc_field_data_value constant fflu_common.st_name := 'Data Value';
  pc_field_manufacturer constant fflu_common.st_name := 'Manufacturer';
  pc_field_brand constant fflu_common.st_name := 'Brand';
  pc_field_category constant fflu_common.st_name := 'Category';
  pc_field_segment constant fflu_common.st_name := 'Segment';
  pc_field_packtype constant fflu_common.st_name := 'Pack Type';
  pc_field_packsize constant fflu_common.st_name := 'Pack Size';
  pc_field_size constant fflu_common.st_name := 'Size';
  pc_field_ean constant fflu_common.st_name := 'EAN';
  pc_field_sub_brand constant fflu_common.st_name := 'Sub Brand';
  pc_field_multiple constant fflu_common.st_name := 'Multiple';
  pc_field_multi_pack constant fflu_common.st_name := 'Multi Pack';
  pc_field_occasion constant fflu_common.st_name := 'Occasion';

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
  Package Types
*******************************************************************************/  
  type tt_periods is table of logr_wod_sales_scan.mars_period%type index by pls_integer;
  
/*******************************************************************************
  Package Variables
*******************************************************************************/  
  pv_data_animal_type logr_wod_sales_scan.data_animal_type%type;
  pv_user fflu_common.st_user;
  ptv_periods tt_periods;
  pv_last_mars_period logr_wod_sales_scan.mars_period%type;
  
  
/*******************************************************************************
  NAME:      ON_START                                                     PUBLIC
*******************************************************************************/  
  procedure on_start is 
  begin
    -- Initialise any package processing variables.
    pv_last_mars_period := null;
    pv_data_animal_type := null;
    pv_user := null;
    ptv_periods.delete;
    -- Now determine what the interface sufix was and hence the data animal type. 
    case fflu_utils.get_interface_suffix
      when pc_suffix_dog then pv_data_animal_type := pc_data_animal_type_dog;
      when pc_suffix_cat then pv_data_animal_type := pc_data_animal_type_cat;
      else 
        fflu_data.log_interface_error('Interface Suffix',fflu_utils.get_interface_suffix,'Unknown Interface Suffix.');
    end case;
    -- Now initialise the data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,true,true);
    -- Now define the column structure
    fflu_data.add_char_field_del(pc_field_period,1,pc_column_time,null,14,fflu_data.gc_not_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_date_field_del(pc_field_mars_period,1,pc_column_time,'DD/MM/YY',5,8);
    fflu_data.add_char_field_del(pc_field_measure,2,'Measure',null,100,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_del(pc_field_product,3,'Product',null,100,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_del(pc_field_market,4,'Market',null,100,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_number_field_del(pc_field_data_value,5,'Data Value',null,-1000000,1000000,fflu_data.gc_allow_null);
    fflu_data.add_char_field_del(pc_field_manufacturer,6,'Manufacturer',null,100,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_del(pc_field_brand,7,'Brand',null,100,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_del(pc_field_category,8,'Category',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_del(pc_field_segment,9,'Segment',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_del(pc_field_packtype,10,'Packtype',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_del(pc_field_packsize,11,'Packsize',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_number_field_del(pc_field_size,12,'Size',null,0,100000,fflu_data.gc_not_allow_null);
    fflu_data.add_char_field_del(pc_field_ean,13,'EAN',null,100,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_del(pc_field_sub_brand,14,'Subbrand',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_del(pc_field_multiple,15,'Multiple',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_del(pc_field_multi_pack,16,'Multi_pack',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    -- Now parse an Occasion field that is only on the dog files.
    if  pv_data_animal_type = pc_data_animal_type_dog then 
      fflu_data.add_char_field_del(pc_field_occasion,17,'Occasion',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    end if;
    -- Now access the user name.  Must be called after initialising fflu_data, or after fflu_utils.log_interface_progress.
    pv_user := fflu_utils.get_interface_user;
  exception 
    when others then 
      fflu_data.log_interface_exception('On Start');
end on_start;


/*******************************************************************************
  NAME:      ON_DATA                                                      PUBLIC
*******************************************************************************/  
  procedure on_data(p_row in varchar2) is 
    v_ok boolean;
    v_mars_period logr_wod_sales_scan.mars_period%type;
    v_occasion logr_wod_sales_scan.occasion%type;
    cursor csr_mars_period(i_calendar_date in date) is 
      select mars_period 
      from mars_date 
      where calendar_date = i_calendar_date;
    -- Function to check if this period has been seen before.
    function seen_period return boolean is
      v_counter pls_integer;
      v_result boolean;
    begin
      v_counter := 0;
      v_result := false;
      -- Check if the value last row was the same, in which case we have seen.
      if pv_last_mars_period = v_mars_period then 
        v_result := true;
      else
        -- Else check the collection of periods previously seen.
        loop
          v_counter := v_counter + 1;
          exit when v_counter > ptv_periods.count or v_result = true;
          if ptv_periods(v_counter) = v_mars_period then 
            v_result := true;
          end if;
        end loop;
        -- Update the last period seen.
        pv_last_mars_period := v_mars_period;
        if v_result = false then 
          ptv_periods(ptv_periods.count + 1) := v_mars_period;
        end if;
      end if;
      return v_result;        
    end seen_period;
  begin
    if fflu_data.parse_data(p_row) = true then
      -- Set an OK Tracking variable.
      v_ok := true;
      -- Now determine the mars period, from the supplied date - 1.  This is done as data file is supplying the first day of the new period.
      open csr_mars_period(fflu_data.get_date_field(pc_field_mars_period)-1);
      fetch csr_mars_period into v_mars_period;
      if csr_mars_period%notfound = true then 
        fflu_data.log_field_error(pc_field_mars_period,'Mars Period could not be found for specified calendar date.');
        v_ok := false;
      end if;
      close csr_mars_period;
      -- Check if this period has been seen before.
      if seen_period = false then 
        -- Clear out any previous data for this same mars period.
        delete from logr_wod_sales_scan where mars_period = v_mars_period and data_animal_type = pv_data_animal_type;
      end if;
      -- Now perform a sense check that the category if it contains Dog or Cat that it matches the interface suffix for this file.
      if instr(initcap(fflu_data.get_char_field(pc_field_category)),pc_data_animal_type_dog) > 0 and fflu_utils.get_interface_suffix <> pc_suffix_dog then
        fflu_data.log_field_error(pc_field_category,'This category contained reference to '|| pc_data_animal_type_dog ||' which was not expected for this interface.');
        v_ok := false;
      end if;
      if instr(initcap(fflu_data.get_char_field(pc_field_category)),pc_data_animal_type_cat) > 0 and fflu_utils.get_interface_suffix <> pc_suffix_cat then
        fflu_data.log_field_error(pc_field_category,'This category contained reference to '|| pc_data_animal_type_cat ||' which was not expected for this interface.');
        v_ok := false;
      end if;
      -- Now insert the logr sales scan data.
      if v_ok = true then 
        -- If this is a dog file lets set the occasion field first.
        if  pv_data_animal_type = pc_data_animal_type_dog then 
          v_occasion := initcap(fflu_data.get_char_field(pc_field_occasion));
        else 
          v_occasion := null;
        end if;
        -- Now perform the insert
        insert into logr_wod_sales_scan (
          period,
          mars_period, 
          data_animal_type,
          measure, 
          product, 
          market, 
          data_value, 
          manufacturer,
          brand,
          catgry,
          sgmnt,
          packtype,
          packsize,
          sze_grams,
          ean,
          sub_brand,
          multiple,
          multi_pack,
          occasion,
          last_updtd_user, 
          last_updtd_time
        ) values (
          fflu_data.get_char_field(pc_field_period), 
          v_mars_period,
          pv_data_animal_type,
          initcap(fflu_data.get_char_field(pc_field_measure)),
          initcap(fflu_data.get_char_field(pc_field_product)),
          initcap(fflu_data.get_char_field(pc_field_market)),
          fflu_data.get_number_field(pc_field_data_value),
          initcap(fflu_data.get_char_field(pc_field_manufacturer)),
          initcap(fflu_data.get_char_field(pc_field_brand)),
          initcap(fflu_data.get_char_field(pc_field_category)),
          initcap(fflu_data.get_char_field(pc_field_segment)),
          initcap(fflu_data.get_char_field(pc_field_packtype)),
          initcap(fflu_data.get_char_field(pc_field_packsize)),
          fflu_data.get_number_field(pc_field_size),
          fflu_data.get_char_field(pc_field_ean),
          initcap(fflu_data.get_char_field(pc_field_sub_brand)),
          initcap(fflu_data.get_char_field(pc_field_multiple)),
          initcap(fflu_data.get_char_field(pc_field_multi_pack)),
          v_occasion,
          pv_user,
          sysdate
        );
      end if;
    end if;
  exception 
    when others then 
      fflu_data.log_interface_exception('On Data');
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
      fflu_data.log_interface_exception('On End');
      rollback;
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
  pv_last_mars_period := null;
  pv_data_animal_type := null;
  pv_user := null;
  ptv_periods.delete;
END LOGRWOD01_LOADER;