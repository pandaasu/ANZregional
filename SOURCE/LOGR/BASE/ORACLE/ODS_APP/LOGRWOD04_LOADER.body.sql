create or replace 
PACKAGE body LOGRWOD04_LOADER AS 

/*******************************************************************************
  Interface Field Definitions
*******************************************************************************/  
  pc_field_mars_period constant fflu_common.st_name := 'Mars Period';
  pc_field_category constant fflu_common.st_name := 'Category';
  pc_field_brand constant fflu_common.st_name := 'Brand';
  pc_field_segment constant fflu_common.st_name := 'Segment';
  pc_field_packtype constant fflu_common.st_name := 'Pack Type';
  pc_field_specific_sku constant fflu_common.st_name := 'Specific SKU';
  pc_field_time_to_find_mars constant fflu_common.st_name := 'Time To Find Mars';
  pc_field_percent_wrong_mars constant fflu_common.st_name := 'Percent Wrong Mars';
  pc_field_spi_mars constant fflu_common.st_name := 'SPI Mars';
  pc_field_time_to_find_cmpttr constant fflu_common.st_name := 'Time To Find Competitor';
  pc_field_percent_wrong_cmpttr constant fflu_common.st_name := 'Percent Wrong Competitor';
  pc_field_spi_cmpttr constant fflu_common.st_name := 'SPI Competitor';
  pc_field_performance constant fflu_common.st_name := 'Performance';
  
/*******************************************************************************
  Package Variables
*******************************************************************************/  
  pv_user fflu_common.st_user;
  
/*******************************************************************************
  NAME:      ON_START                                                     PUBLIC
*******************************************************************************/  
  procedure on_start is 
  begin
    -- Initialise any package processing variables.
    pv_user := null;
    -- Now initialise the data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,true,true);
    -- Now define the column structure
    fflu_data.add_number_field_csv(pc_field_mars_period,1,'Period',null,190001,999913,fflu_data.gc_not_allow_null);
    fflu_data.add_char_field_csv(pc_field_category,2,'Category',null,100,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_brand,3,'Brand',null,100,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_segment,4,'Segment',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_packtype,5,'Pack type',null,100,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_csv(pc_field_specific_sku,6,'Specific SKU',null,100,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_number_field_csv(pc_field_time_to_find_mars,7,'Time to find MARS',null,0,10000,fflu_data.gc_allow_null);
    fflu_data.add_number_field_csv(pc_field_percent_wrong_mars,8,'% people who got it wrong MARS',null,0,500,fflu_data.gc_not_allow_null);
    fflu_data.add_number_field_csv(pc_field_spi_mars,9,'SPI MARS',null,0,10000,fflu_data.gc_allow_null);
    fflu_data.add_number_field_csv(pc_field_time_to_find_cmpttr,10,'Time to find competitor (sec)',null,0,100000,fflu_data.gc_not_allow_null);
    fflu_data.add_number_field_csv(pc_field_percent_wrong_cmpttr,11,'% people who got it wrong Comp',null,0,500,fflu_data.gc_allow_null);
    fflu_data.add_number_field_csv(pc_field_spi_cmpttr,12,'SPI Competitor',null,0,10000,fflu_data.gc_not_allow_null);
    fflu_data.add_number_field_csv(pc_field_performance,13,'Performance',null,-10000,10000,fflu_data.gc_not_allow_null);
    -- Now access the user name.  Must be called after initialising fflu_data, or after fflu_utils.log_interface_progress.
    pv_user := fflu_utils.get_interface_user;
    -- Now clear out the table for the complete reload that is about to commence.
    delete from logr_wod_pack_effctvnss;
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
      -- Now insert the logr sales scan data.
      if v_ok = true then 
        insert into logr_wod_pack_effctvnss (
          mars_period,
          catgry,
          brand,
          sgmnt,
          packtype,
          specific_sku,
          time_to_find_mars,
          percent_wrong_mars,
          spi_mars,
          time_to_find_cmpttr,
          percent_wrong_cmpttr,
          spi_cmpttr,
          performance,
          last_updtd_user, 
          last_updtd_time
        ) values (
          fflu_data.get_number_field(pc_field_mars_period),
          initcap(fflu_data.get_char_field(pc_field_category)),
          initcap(fflu_data.get_char_field(pc_field_brand)),
          initcap(fflu_data.get_char_field(pc_field_segment)),
          initcap(fflu_data.get_char_field(pc_field_packtype)),
          initcap(fflu_data.get_char_field(pc_field_specific_sku)),
          fflu_data.get_number_field(pc_field_time_to_find_mars),
          fflu_data.get_number_field(pc_field_percent_wrong_mars),
          fflu_data.get_number_field(pc_field_spi_mars),
          fflu_data.get_number_field(pc_field_time_to_find_cmpttr),
          fflu_data.get_number_field(pc_field_percent_wrong_cmpttr),
          fflu_data.get_number_field(pc_field_spi_cmpttr),
          fflu_data.get_number_field(pc_field_performance),
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
END LOGRWOD04_LOADER;