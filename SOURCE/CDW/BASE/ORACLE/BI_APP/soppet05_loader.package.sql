create or replace package soppet05_loader as
  /*****************************************************************************
  ** PACKAGE DEFINITION
  ******************************************************************************
  
    Schema    : bi_app 
    Package   : soppet05_loader 
    Author    : Trevor Keon   
  
    Description
    ----------------------------------------------------------------------------
    [soppet05] SnOP+ - Petcare - Step 5 Scorecard  
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
    2014-10-21  Trevor Keon           Created 
    2014-11-25  Trevor Keon           Added validation for Updated line 
  
  *****************************************************************************/

  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

end soppet05_loader;
/

create or replace package body soppet05_loader as 
  
  -- Private Functions 
  function is_number(p_number in varchar2) return boolean;

  -- Interface column constants 
  pc_data_last_update constant fflu_common.st_name := 'Data Last Update';
  pc_level_1 constant fflu_common.st_name := 'Level 1';
  pc_level_2 constant fflu_common.st_name := 'Level 2';
  pc_level_3 constant fflu_common.st_name := 'Level 3';
  pc_data_format constant fflu_common.st_name := 'Data Format';
  pc_data_year constant fflu_common.st_name := 'Data Year';
  pc_field_name constant fflu_common.st_name := 'Field Name';
  pc_field_value constant fflu_common.st_name := 'Field Value'; 
  
  -- Package variables 
  pv_user fflu_common.st_user;
  pv_line_count pls_integer;
  pv_data_count pls_integer;
  
  pv_previous_level_1 varchar2(500);
  pv_previous_level_2 varchar2(500);  
  
  type step_scorecard_type is table of bi.sop_step_v_scorecard%rowtype index by pls_integer;
  scorecard_table step_scorecard_type;
  
  type typ_value is table of varchar2(4000) index by pls_integer;
  tbl_value typ_value;
  
  -- Store the column heading data 
  type column_rcd is record
  (
      data_year number,
      data_field varchar2(500)
  );
  type column_collection is table of column_rcd index by pls_integer;
  column_table column_collection;
  
  ------------------------------------------------------------------------------
  -- LICS : ON_START 
  ------------------------------------------------------------------------------
  procedure on_start is
  
  begin
    -- Initialise data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,fflu_data.gc_no_file_header,fflu_data.gc_allow_missing);
    
--    -- Add column structure
--    fflu_data.add_char_field_del(pc_data_last_update,1,'Data Last Update',0,500,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
--    fflu_data.add_char_field_del(pc_level_1,2,'Level 1',0,500,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
--    fflu_data.add_char_field_del(pc_level_2,3,'Level 2',0,500,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
--    fflu_data.add_char_field_del(pc_level_3,4,'Level 3',0,500,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
--    fflu_data.add_char_field_del(pc_data_format,5,'Data Format',0,50,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
--    fflu_data.add_number_field_del(pc_data_year,6,'Data Year','9990',1,9999,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
--    fflu_data.add_char_field_del(pc_field_name,7,'Field Name',0,500,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
--    fflu_data.add_char_field_del(pc_field_value,8,'Field Value',0,500,fflu_data.gc_allow_null,fflu_data.gc_not_trim); 

    -- Get user name - MUST be called after initialising fflu_data, or after fflu_utils.log_interface_progress.
    pv_user := fflu_utils.get_interface_user;
    pv_line_count := 1;
    pv_data_count := 1;
            
  exception 
    when others then 
      fflu_data.log_interface_exception('On Start');
  end on_start;

  ------------------------------------------------------------------------------
  -- LICS : ON_DATA 
  ------------------------------------------------------------------------------
  procedure on_data(p_row in varchar2) is
  
    v_row_blank boolean;  
    v_update_row boolean; 
     
    v_column_count pls_integer;
    v_update_column number;
    v_previous_year number;
        
    v_current_field fflu_common.st_name;
    v_current_data varchar2(100);
    
    v_data_update bi.sop_step_v_scorecard.data_last_update%type;
    v_level_1 bi.sop_step_v_scorecard.level_1%type;
    v_level_2 bi.sop_step_v_scorecard.level_2%type;
    v_level_3 bi.sop_step_v_scorecard.level_3%type;
    v_data_format bi.sop_step_v_scorecard.data_format%type;

  begin
    v_column_count := 1;
    v_previous_year := 0;
    v_row_blank := true;
    v_update_row := false;
       
    -- Build up a collection of the comma-seperated data 
    loop    
      if v_column_count = 1 then
         tbl_value(v_column_count) := substr(p_row, 1, instr(p_row, ',', 1, v_column_count)-1);
      elsif instr(p_row, ',', 1, v_column_count) = 0 then
         tbl_value(v_column_count) := substr(p_row, instr(p_row, ',', 1, v_column_count-1)+1, length(p_row));
         exit;
      else
         tbl_value(v_column_count) := substr(p_row, instr(p_row, ',', 1, v_column_count-1)+1, instr(p_row, ',' ,1, v_column_count) - instr(p_row, ',' , 1, v_column_count-1)-1);
      end if;
      
      -- Check for blank rows or "Updated" row 
      if tbl_value(v_column_count) is not null then
         v_row_blank := false;
         if instr(tbl_value(v_column_count), 'Updated') = 1 then
            v_update_row := true;
            v_update_column := v_column_count;
         end if;         
      end if;
    
      v_column_count := v_column_count + 1;  
    end loop;  
        
    -- Ignore blank rows 
    if v_row_blank = true then
      return;
    end if;
        
    -- Calculate the last update date for the scorecard data 
    if v_update_row = true then   
      v_data_update := substr(tbl_value(v_update_column), Length('Updated')+2, 4) 
         || lpad(substr(tbl_value(v_update_column), instr(tbl_value(v_update_column), 'P')+1, instr(tbl_value(v_update_column), 'W')-(instr(tbl_value(v_update_column), 'P')+1)), 2, '0') 
         || substr(tbl_value(v_update_column), Length(tbl_value(v_update_column)), 1);         
    
      if length(v_data_update) <> 7 then         
         fflu_data.log_interface_error('Update Field', v_data_update, 'Invalid Update structure. Expecting "Updated yyyyPpWw". Example: Updated 2014P8W3');
         return;
      end if;
    
      for i in 1..scorecard_table.count
      loop        
         scorecard_table(i).data_last_update := v_data_update;
      end loop;
      
      -- Ensure old records are replaced  
      delete
      from bi.sop_step_v_scorecard
      where data_last_update = v_data_update;
      
      return;
    end if;
    
    for i in 1..v_column_count
    loop
      if pv_line_count = 1 then  
        v_current_data := substr(tbl_value(i), 1, 4);    -- Expecting only years (4 characters)                       
        if is_number(v_current_data) then
          column_table(i).data_year := to_number(v_current_data); 
          v_previous_year := to_number(v_current_data);
        elsif v_previous_year <> 0 then
          column_table(i).data_year := v_previous_year;
        else
          column_table(i).data_year := null;
        end if;
      elsif pv_line_count = 2 then
        column_table(i).data_field := tbl_value(i);
      else
        if i = 1 then             
          if tbl_value(i) is not null then
            pv_previous_level_1 := tbl_value(i);              
          end if;
          v_level_1 := pv_previous_level_1;  
        elsif i = 2 then
          if tbl_value(i) is not null then
            pv_previous_level_2 := tbl_value(i);              
          end if;            
          v_level_2 := pv_previous_level_2;         
        elsif i = 3 then
          v_level_3 := tbl_value(i);              
        elsif i = 4 then
          v_data_format := tbl_value(i);
        else
          v_current_field := pc_level_1;
          scorecard_table(pv_data_count).level_1 := v_level_1;        
          v_current_field := pc_level_2;
          scorecard_table(pv_data_count).level_2 := v_level_2;           
          v_current_field := pc_level_3;
          scorecard_table(pv_data_count).level_3 := v_level_3;          
          v_current_field := pc_data_format;
          scorecard_table(pv_data_count).data_format := v_data_format;                  
          v_current_field := pc_data_year;
          scorecard_table(pv_data_count).data_year := column_table(i).data_year;          
          v_current_field := pc_field_name;
          scorecard_table(pv_data_count).field_name := column_table(i).data_field;          
          v_current_field := pc_field_value;
          scorecard_table(pv_data_count).field_value := tbl_value(i);
                                                   
          -- Default Columns .. Added to ALL Tables
          -- Last Update User
          v_current_field := 'Last Update User';        
          scorecard_table(pv_data_count).last_update_user := pv_user;
          -- Last Update Date
          v_current_field := 'Last Update Date';        
          scorecard_table(pv_data_count).last_update_date := sysdate;
          
          -- Only use records that have a value and heading (ignore "blank" columns) 
          if tbl_value(i) is not null or column_table(i).data_field is not null then
            pv_data_count := pv_data_count + 1;           
          end if;
        end if;     
      end if;
    end loop;     

--    if pv_line_count > 2 then
--      pv_data_count := pv_data_count + 1;  -- Increment the count of data records
--    end if;
       
    pv_line_count := pv_line_count + 1;    -- Increment the row count     
    
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
      -- Bulk insert the scorecard data loaded   
      forall i in 1..scorecard_table.count     
        insert into bi.sop_step_v_scorecard values scorecard_table(i);
      
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

  ------------------------------------------------------------------------------
  -- IS_NUMBER 
  ------------------------------------------------------------------------------  
  function is_number(p_number in varchar2) return boolean is
    v_result number;
  begin    
    if p_number is null then
      return false;
    else
      v_result := to_number(p_number);
      return true;
    end if;
  exception
    when others then
      return false;  
  end;

end soppet05_loader;
/

grant execute on soppet05_loader to lics_app, fflu_app;

/*******************************************************************************
  END
*******************************************************************************/
