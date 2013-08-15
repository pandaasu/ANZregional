create or replace 
PACKAGE body LOGRWOD08_LOADER AS 

/*******************************************************************************
  Interface Field Definitions
*******************************************************************************/  
  pc_field_mars_period constant fflu_common.st_name := 'Mars Period';
  pc_field_animal constant fflu_common.st_name := 'Animal';
  pc_field_category constant fflu_common.st_name := 'Category';
  pc_field_brand constant fflu_common.st_name := 'Brand';
  pc_field_product_family constant fflu_common.st_name := 'Product Family';
  pc_field_palatability_result constant fflu_common.st_name := 'Palatability Result';
  pc_field_digestibility_result constant fflu_common.st_name := 'Digestibility Result';
  pc_field_faeces_qlty_result constant fflu_common.st_name := 'Faeces Quality Result';
  
/*******************************************************************************
  Package Variables
*******************************************************************************/  
  pv_user fflu_common.st_user;
  pv_prev_mars_period logr_wod_prdct_prfrmnc.mars_period%type;

/*******************************************************************************
  NAME:      ON_START                                                     PUBLIC
*******************************************************************************/  
  procedure on_start is 
  begin
    -- Initialise any package processing variables.
    pv_user := null;
    pv_prev_mars_period := null;
    -- Now initialise the data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,true,true);
    -- Now define the column structure
    fflu_data.add_number_field_csv(pc_field_mars_period,1,'YYYYPP (Period Published)',null,190001,999913,fflu_data.gc_not_allow_null);
    fflu_data.add_char_field_csv(pc_field_animal,2,'Animal',null,100,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_category,3,'Category',null,100,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_brand,4,'Brand',null,100,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_product_family,5,'Product Family',null,100,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_palatability_result,6,'Palatability Result',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_digestibility_result,7,'Digestibility Result',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_faeces_qlty_result,8,'Faeces Quality Result',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
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
    v_mars_period number(6,0);
    cursor csr_mars_period(i_mars_period in number) is 
      select mars_period
      from mars_date 
      where mars_period = i_mars_period;
    
    -- Function to check if the result field contained a valid value.      
    function valid_result(i_field in fflu_common.st_name) return boolean is
      v_result boolean;
    begin
      if fflu_data.get_char_field(i_field) is not null and upper(fflu_data.get_char_field(i_field)) not in ('POSITIVE','NEGATIVE','0') then 
        fflu_data.log_field_error(i_field,'Result must be positive, negative, 0 or <strong>blank</strong>.');
        v_result := false;
      else 
        v_result := true;
      end if;
      return v_result;
    end valid_result;

  begin
    if fflu_data.parse_data(p_row) = true then
      -- Set an OK Tracking variable.
      v_ok := true;
      -- Now validate the mars date supplied is valid.
      open csr_mars_period(fflu_data.get_number_field(pc_field_mars_period));
      fetch csr_mars_period into v_mars_period;
      if csr_mars_period%notfound = true then 
        fflu_data.log_field_error(pc_field_mars_period,'Mars Period did not appear to be valid.');
        v_ok := false;
      end if;
      close csr_mars_period;
      -- Check if this is the first data row and if the current mars period is set. 
      if pv_prev_mars_period is null and v_mars_period is not null then 
        pv_prev_mars_period := v_mars_period;
        -- Clear out any previous data for this same mars period.
        delete from logr_wod_prdct_prfrmnc where mars_period = pv_prev_mars_period;
      else
        -- Now check that each supplied mars period is the same as the first one that was supplied in the file. 
        if pv_prev_mars_period <> v_mars_period then 
          fflu_data.log_field_error(pc_field_mars_period,'Mars period was different to first period found in data file. [' || pv_prev_mars_period || '].');
          v_ok := false;
        end if;
      end if;
      -- Now check each result field is valid.
      if valid_result(pc_field_palatability_result) = false then 
        v_ok := false;
      end if;
      if valid_result(pc_field_digestibility_result) = false then 
        v_ok := false;
      end if;
      if valid_result(pc_field_faeces_qlty_result) = false then 
        v_ok := false;
      end if;
      -- Now insert the logr wod product performance table.
      if v_ok = true then 
        insert into logr_wod_prdct_prfrmnc (
          mars_period,
          animal,
          catgry,
          brand,
          product_family,
          palatability_result,
          digestibility_result,
          faeces_qlty_result,
          last_updtd_user, 
          last_updtd_time
        ) values (
          fflu_data.get_number_field(pc_field_mars_period),
          initcap(fflu_data.get_char_field(pc_field_animal)),
          initcap(fflu_data.get_char_field(pc_field_category)),
          initcap(fflu_data.get_char_field(pc_field_brand)),
          initcap(fflu_data.get_char_field(pc_field_product_family)),
          upper(fflu_data.get_char_field(pc_field_palatability_result)),
          upper(fflu_data.get_char_field(pc_field_digestibility_result)),
          upper(fflu_data.get_char_field(pc_field_faeces_qlty_result)),
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
  pv_user := null;
END LOGRWOD08_LOADER;