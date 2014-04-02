create or replace package compet03_loader as
  /*****************************************************************************
  ** PACKAGE DEFINITION
  ******************************************************************************
  
    Schema    : bi_app
    Package   : compet03_loader
    Author    : Trevor Keon         
  
    Description
    ----------------------------------------------------------------------------
    [compet03_loader] Commercial - Petcare - Subjective Scores
    [replace_on_key] Template
    
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
    2014-03-11  Trevor Keon           [Auto Generated]
  
  *****************************************************************************/

  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

end compet03_loader;
/

create or replace package body compet03_loader as 

  -- Interface column constants 
  pc_segment constant fflu_common.st_name := 'Segment';
  pc_mars_period constant fflu_common.st_name := 'Mars Period';
  pc_supplier constant fflu_common.st_name := 'Supplier';
  pc_team constant fflu_common.st_name := 'Team (1 = Buyer, 2 = Inbound, 3 = RnD)';
  pc_rating_type constant fflu_common.st_name := 'Rating Type (CIP or SC)';
  pc_rating constant fflu_common.st_name := 'Rating';
  pc_user constant fflu_common.st_name := 'User 5/3';
  pc_comments constant fflu_common.st_name := 'Comments';  
  
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
    fflu_data.add_char_field_del(pc_segment,1,'Segment',1,5,fflu_data.gc_not_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_number_field_del(pc_mars_period,2,'Period','999990',190001,999913,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_del(pc_supplier,3,'Supplier',1,10,fflu_data.gc_not_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_number_field_del(pc_team,4,'Team','999990',1,3,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_del(pc_rating_type,5,'Rating Type',1,3,fflu_data.gc_not_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_number_field_del(pc_rating,6,'Rating','90.90',0,10,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_del(pc_user,7,'User',0,20,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_char_field_del(pc_comments,8,'Comments',0,4000,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    
    -- Get user name - MUST be called after initialising fflu_data, or after fflu_utils.log_interface_progress.
    pv_user := fflu_utils.get_interface_user;
    
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
    
    rv_insert_values bi.com_subjective_scores%rowtype;

  begin
    if fflu_data.parse_data(p_row) = true then
      -- Set row status
      v_row_status_ok := true;
            
      -- Set insert row columns
      begin
        -- Assign Segment
        v_current_field := pc_segment;
        rv_insert_values.bus_segment := fflu_data.get_char_field(pc_segment);
        -- Assign Mars Period
        v_current_field := pc_mars_period;
        rv_insert_values.mars_period := fflu_data.get_number_field(pc_mars_period);
        -- Assign Supplier
        v_current_field := pc_supplier;
        rv_insert_values.supplier := fflu_data.get_char_field(pc_supplier);
        -- Assign Team (1 = Buyer, 2 = Inbound, 3 = RnD)
        v_current_field := pc_team;
        rv_insert_values.team := fflu_data.get_number_field(pc_team);
        -- Assign Rating Type (CIP or SC)
        v_current_field := pc_rating_type;
        rv_insert_values.rating_type := fflu_data.get_char_field(pc_rating_type);
        -- Assign Rating
        v_current_field := pc_rating;
        rv_insert_values.rating := fflu_data.get_number_field(pc_rating);
        -- Assign User 5/3
        v_current_field := pc_user;
        rv_insert_values.comment_user := fflu_data.get_char_field(pc_user);
        -- Assign Comments
        v_current_field := pc_comments;
        rv_insert_values.comments := fflu_data.get_char_field(pc_comments);

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
      
      if v_row_status_ok = true then
      
        -- Delete any previous records
        delete from bi.com_subjective_scores
        where bus_segment = rv_insert_values.bus_segment
          and mars_period = rv_insert_values.mars_period
          and supplier = rv_insert_values.supplier
          and team = rv_insert_values.team
          and rating_type = rv_insert_values.rating_type;
        
        insert into bi.com_subjective_scores values rv_insert_values; 
      
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
    return fflu_common.gc_csv_qualifier_double_quote;
  end on_get_csv_qualifier;

end compet03_loader;
/

grant execute on compet03_loader to lics_app, fflu_app;

/*******************************************************************************
  END
*******************************************************************************/
