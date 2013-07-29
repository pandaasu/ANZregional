create or replace 
PACKAGE body LOGRWOD06_LOADER AS 

/*******************************************************************************
  Interface Field Definitions
*******************************************************************************/  
  pc_field_version constant fflu_common.st_name := 'Time';
  pc_field_brand constant fflu_common.st_name := 'Brand';
  pc_field_segment constant fflu_common.st_name := 'Segment';
  pc_field_period constant fflu_common.st_name := 'Period';
  pc_field_year constant fflu_common.st_name := 'Year';
  pc_field_weeks_on_air constant fflu_common.st_name := 'Weeks on Air';
  pc_field_4_weekly_reach constant fflu_common.st_name := '4 Weekly Reach';

/*******************************************************************************
  Interface Sufix's
*******************************************************************************/  
  
/*******************************************************************************
  Package Variables
*******************************************************************************/  
  pv_prev_version logr_wod_tv_activity.version%type;
  
/*******************************************************************************
  NAME:      ON_START                                                     PUBLIC
*******************************************************************************/  
  procedure on_start is 
  begin
    -- Initialise any package processing variables.
    pv_prev_version := null;
    -- Now initialise the data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,true,false);
    -- Now define the column structure
    fflu_data.add_number_field_csv(pc_field_version,1,'Version',null,1900,999913,fflu_data.gc_not_allow_null);
    fflu_data.add_char_field_csv(pc_field_brand,2,'Brand',null,100,fflu_data.gc_allow_null);
    fflu_data.add_char_field_csv(pc_field_segment,3,'Segment',null,100,fflu_data.gc_allow_null);
    fflu_data.add_number_field_csv(pc_field_period,4,'Period',null,1,13,fflu_data.gc_not_allow_null);
    fflu_data.add_number_field_csv(pc_field_year,5,'Year',null,1900,9999,fflu_data.gc_not_allow_null);
    fflu_data.add_number_field_csv(pc_field_weeks_on_air,6,'Weeks on Air',null,0,null,fflu_data.gc_allow_null);
    fflu_data.add_number_field_csv(pc_field_4_weekly_reach,7,'4 Weekly Reach',null,0,null,fflu_data.gc_allow_null);
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
      if pv_prev_version is null then 
        pv_prev_version := fflu_data.get_number_field(pc_field_version);
        -- Clear out any previous data for this same mars period.
        delete from logr_wod_tv_activity where version = pv_prev_version;
      else
        -- Now check that each supplied mars period is the same as the first one that was supplied in the file. 
        if pv_prev_version <> fflu_data.get_number_field(pc_field_version) then 
          fflu_data.log_field_error(pc_field_version,'Version was different to first version found in data file. [' || pv_prev_version || '].');
          v_ok := false;
        end if;
      end if;
      -- Now insert the logr sales scan data.
      if v_ok = true then 
        insert into logr_wod_tv_activity (
          version,
          brand,
          sgmnt,
          period,
          year,
          weeks_on_air,
          four_weekly_reach
        ) values (
          fflu_data.get_number_field(pc_field_version), 
          fflu_data.get_char_field(pc_field_brand),
          fflu_data.get_char_field(pc_field_segment),
          fflu_data.get_number_field(pc_field_period),
          fflu_data.get_number_field(pc_field_year),
          fflu_data.get_number_field(pc_field_weeks_on_air),
          fflu_data.get_number_field(pc_field_4_weekly_reach)
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
  pv_prev_version := null;
END LOGRWOD06_LOADER;