
set define off;

create or replace package quo_quocdw10 as
/*******************************************************************************
** Package Definition
********************************************************************************
  
  System  : quo
  Owner   : ods_app
  Package : quo_quocdw10
  Author  : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader Package - Interface [quocdw10] Entity [CustomerNote] Table [quo_cust_note] 
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created
  
*******************************************************************************/

  -- Public : Procedures
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  procedure process_batch(p_source_id in number, p_batch_id in number);

end quo_quocdw10;
/

create or replace package body quo_quocdw10 as

  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  -- Private : Procedures
  procedure perform_preprocessing;
  procedure process_header_row(p_row in varchar2);
  procedure process_data_row(p_row in varchar2);

  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'ods_app.quo_quocdw10';
  g_entity_name constant varchar2(32 char) := 'CustomerNote';
  g_delimiter constant varchar2(1)  := ',';
  g_text_qualifier constant varchar2(1) := '"';
  
  -- Private : Flags
  g_abort_processing_flag boolean;
  g_source_file_error_flag boolean;

  g_first_row_flag boolean;
  g_footer_row_found_flag boolean;

  -- Private : Counters
  g_row_count number(10);
  g_data_row_count number(10);

  -- Private : Variables
  g_load_seq number;
  g_interface_name varchar2(32 char);
  g_source_id number(4);
  g_source_desc varchar2(256 char);
  g_file_name varchar2(512 char);
  g_batch_id number(15);
  g_timestamp date;

  -- Private : Rowtypes
  g_interface_hrd_row ods.quo_interface_hdr%rowtype;

  g_entity_load_row ods.quo_cust_note_load%rowtype;
  g_entity_row ods.quo_cust_note%rowtype;
  g_entity_hist_row ods.quo_cust_note_hist%rowtype;

  /*****************************************************************************
  ** Procedure : On Start - Call Back for LICS Framework
  **             Called by the LICS Framework BEFORE Processing the Record Set
  *****************************************************************************/
  procedure on_start is

  begin
    -- Initialise : Transaction flags
    g_abort_processing_flag := false;
    g_source_file_error_flag := false;
    
    g_first_row_flag := true;
    g_footer_row_found_flag := false;

    -- Initialise : Counters
    g_row_count := 0;
    g_data_row_count := 0;

    -- Initialise : Layout definitions
    lics_inbound_utility.clear_definition;
    lics_inbound_utility.set_csv_definition('id',1);
    lics_inbound_utility.set_csv_definition('id_lookup',2);
    lics_inbound_utility.set_csv_definition('created_date',3);
    lics_inbound_utility.set_csv_definition('cust_id',4);
    lics_inbound_utility.set_csv_definition('cust_id_lookup',5);
    lics_inbound_utility.set_csv_definition('is_active',6);
    lics_inbound_utility.set_csv_definition('note_text',7);
    lics_inbound_utility.set_csv_definition('rep_id',8);
    lics_inbound_utility.set_csv_definition('rep_id_lookup',9);
    lics_inbound_utility.set_csv_definition('cust_id_desc',10);
    lics_inbound_utility.set_csv_definition('full_name',11);

  end on_start;

  /*****************************************************************************
  ** Procedure : On Data - Call Back for LICS Framework
  **             Called by the LICS Framework FOR EACH Record of the Record Set
  *****************************************************************************/
  procedure on_data(p_row in varchar2) is

    l_row varchar2(4000 char);

  begin
    -- Return if Abort Processing Flag set / Stops Unnecessary Processing
    if g_abort_processing_flag = true then
      return;
    end if ;

    -- Remove leading and trailing whitespace (including cr/lf/tab/etc..)
    l_row := trim(regexp_replace(p_row,'[[:space:]]*$',null));
    if l_row is null then
      return; -- Return on EMPTY Line
    end if;

    -- Process CSV ..
    -- HEADER Row
    if g_first_row_flag = true then
      g_first_row_flag := false;
      perform_preprocessing; -- Raises Exception on Failure
      process_header_row(l_row);
    else
      -- FOOTER row .. Starts with FTR followed by any APLHA, NUMERIC, [_] and [.] .. Note, NO Comma [,]
      if regexp_instr(l_row,'^FTR[A-Z0-9._]*$',1,1,0,'i') = 1 then -- Simple Check to Distinguish from DATA row   
        g_footer_row_found_flag := true;
        if upper(l_row) != upper('FTR'||g_file_name) then -- Invalid FOOTER row / More Specific Check
          lics_inbound_utility.add_exception('['||g_package_name||'.on_data] Invalid Footer Row .. Expected [FTR'||g_file_name||']');
          g_source_file_error_flag := true;
          return; -- Invalid Footer
        end if;
      -- DATA row
      else
        if g_footer_row_found_flag then -- cannot have DATA row after FOOTER row
          lics_inbound_utility.add_exception('['||g_package_name||'.on_data] DATA Row Found After FOOTER Row');
          g_source_file_error_flag := true;
        end if;
        process_data_row(l_row);
      end if;
    end if;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.on_data] : '||SQLERRM, 1, 4000));

  end on_data;

  /*****************************************************************************
  ** Procedure : Perform Preprocessing
  *****************************************************************************/
  procedure perform_preprocessing as

  begin
    -- Set Interface and Source File Names ..
    g_file_name := lics_inbound_processor.callback_file_name;
    g_interface_name := upper(lics_inbound_processor.callback_interface); -- delibrate upper

    -- Each of the remaining Procedures / Functions Raise Exception on Failure

    -- Valid Interface Name
    quo_util.validate_interface_name(g_entity_name, g_interface_name);

    -- Valid File Name
    quo_util.validate_file_name(g_entity_name, g_file_name);

    -- Interface Name, Extract .. Source Id     
    g_source_id := quo_util.get_interface_source_id(g_interface_name);
    g_source_desc := quo_util.get_source_desc(g_source_id);
    
    -- File Name, Extract .. Timestamp, Batch Id
    g_timestamp := quo_util.get_file_timestamp(g_file_name);
    g_batch_id := quo_util.get_file_batch_id(g_file_name);
    
  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.perform_preprocessing] : '||SQLERRM, 1, 4000));

  end perform_preprocessing;

  /*****************************************************************************
  ** Procedure : On End - Call Back for LICS Framework
  **             Called by the LICS Framework AFTER Processing the Record Set
  *****************************************************************************/
  procedure on_end is

  begin

    -- Commit/Rollback as necessary ..
    if g_abort_processing_flag = false and g_source_file_error_flag = false and g_footer_row_found_flag = true then
      quo_interface.complete_load(g_load_seq, g_source_id, g_batch_id, g_entity_name, g_data_row_count); 
      commit;
    else
      rollback;
    end if;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.on_end] : '||SQLERRM, 1, 4000));

  end on_end;

  /*****************************************************************************
  ** Procedure : Process HEADER Row
  *****************************************************************************/
  procedure process_header_row(p_row in varchar2) is

    l_expected_row varchar2(4000 char) := 'ID,ID_Lookup,CreatedDate,Customer_Id,Customer_Id_Lookup,IsActive,NoteText,Rep_Id,Rep_Id_Lookup,Customer_ID_Description,Fullname';

  begin
  
    if upper(p_row) = upper(l_expected_row) then -- Valid HEADER Row 
      -- Start Interface Loader .. Raised Exception on Failure   
      g_load_seq := quo_interface.start_load(g_source_id, g_batch_id, g_entity_name, g_interface_name, g_file_name, g_timestamp); 
    else
      lics_inbound_utility.add_exception('['||g_package_name||'.process_header_row] Invalid Header Row .. Expected ['||l_expected_row||']');
      g_abort_processing_flag := true;
      g_source_file_error_flag := true;
    end if;
    
  exception
    when others then
      g_abort_processing_flag := true;
      raise_application_error(-20000, substr('['||g_package_name||'.process_header_row] : '||SQLERRM, 1, 4000));

  end process_header_row;

  /*****************************************************************************
  ** Procedure : Process DATA Row
  *****************************************************************************/
  procedure process_data_row(p_row in varchar2) is

    l_entity_load_row ods.quo_cust_note_load%rowtype;
    l_raw_column_value varchar2(4000 char);
  
  begin
    -- Should NEVER reach this point .. Return if Abort Processing Flag set / Stops Unnecessary Processing
    if g_abort_processing_flag = true then
      return;
    end if ;

    -- Increment data row count
    g_data_row_count := g_data_row_count + 1;
    
    -- Parse DATA Row 
    lics_inbound_utility.parse_csv_record(p_row, g_delimiter, g_text_qualifier);

    -- Populate DATA Row - CONTROL Columns
    l_entity_load_row.q4x_load_seq := g_load_seq;
    l_entity_load_row.q4x_load_data_seq := g_data_row_count;
    l_entity_load_row.q4x_create_user := user;
    l_entity_load_row.q4x_create_time := sysdate;
    l_entity_load_row.q4x_modify_user := user;
    l_entity_load_row.q4x_modify_time := sysdate;
    l_entity_load_row.q4x_source_id := g_source_id;
    l_entity_load_row.q4x_batch_id := g_batch_id;
    l_entity_load_row.q4x_timestamp := g_timestamp;
    -- Populate DATA Row - DATA Columns
    begin
      l_entity_load_row.id := quo_util.get_number('id',10,0,false,g_source_file_error_flag);
      l_entity_load_row.id_lookup := quo_util.get_string('id_lookup',50,true,g_source_file_error_flag);
      l_entity_load_row.created_date := quo_util.get_datetime('created_date',true,g_source_file_error_flag);
      l_entity_load_row.cust_id := quo_util.get_number('cust_id',10,0,true,g_source_file_error_flag);
      l_entity_load_row.cust_id_lookup := quo_util.get_string('cust_id_lookup',50,true,g_source_file_error_flag);
      l_entity_load_row.is_active := quo_util.get_boolean_as_number('is_active',true,g_source_file_error_flag);
      l_entity_load_row.note_text := quo_util.get_string('note_text',200,true,g_source_file_error_flag);
      l_entity_load_row.rep_id := quo_util.get_number('rep_id',10,0,true,g_source_file_error_flag);
      l_entity_load_row.rep_id_lookup := quo_util.get_string('rep_id_lookup',50,true,g_source_file_error_flag);
      l_entity_load_row.cust_id_desc := quo_util.get_string('cust_id_desc',50,true,g_source_file_error_flag);
      l_entity_load_row.full_name := quo_util.get_string('full_name',101,true,g_source_file_error_flag);
    exception
      when others then
         lics_inbound_utility.add_exception(substr('['||g_package_name||'.process_data_row] Unexpected Parsing Error : '||SQLERRM, 1, 4000));
         g_source_file_error_flag := true;
    end;

    -- Retrieve exceptions raised
    if lics_inbound_utility.has_errors = true then
       g_source_file_error_flag := true;
    end if;

    -- Error, bypass the update when required 
    if g_source_file_error_flag = true then
       return;
    end if;

    -- Insert row
    begin
      insert into ods.quo_cust_note_load values l_entity_load_row;
    exception
      when others then
         lics_inbound_utility.add_exception(substr('['||g_package_name||'.process_data_row] Insert Failed [ods.quo_cust_note_load] : '||SQLERRM, 1, 4000));
         g_source_file_error_flag := true;
    end;

  end process_data_row;

  /*****************************************************************************
  ** Procedure : Process Batch .. Called from Batch / Digest Process
  **             DO NOT COMMIT/ROLLBACK .. This is Performed by Calling Function
  *****************************************************************************/
  procedure process_batch(p_source_id in number, p_batch_id in number) is

    l_batch_row_count number;
    
  begin
  
    -- Check if Anything to Process
    select count(1) into l_batch_row_count
    from ods.quo_cust_note_load
    where q4x_source_id = p_source_id
    and q4x_batch_id = p_batch_id;

    -- Return is Nothing to Process
    if l_batch_row_count = 0 then
      return;
    end if;
    
    -- Remove Load Batch Matching Key Entries from Current, Where Batch Id is Older
    delete from ods.quo_cust_note
    where q4x_source_id = p_source_id
    and q4x_batch_id < p_batch_id
    and (q4x_source_id,id) in (
      select q4x_source_id,id 
      from ods.quo_cust_note_load 
      where q4x_source_id = p_source_id
      and q4x_batch_id = p_batch_id
    );
    
    -- Update Modified User/Time
    update ods.quo_cust_note_load
    set q4x_modify_user = user,
      q4x_modify_time = sysdate
    where q4x_source_id = p_source_id
    and q4x_batch_id = p_batch_id;
    
    -- Insert Load Batch into Current, Where Not Matching Key
    insert into ods.quo_cust_note
    select * 
    from ods.quo_cust_note_load
    where q4x_source_id = p_source_id
    and q4x_batch_id = p_batch_id
    and (q4x_source_id,id) not in (
      select q4x_source_id,id 
      from ods.quo_cust_note 
      where q4x_source_id = p_source_id
    );

    -- Insert ALL of Load Batch into History
    insert into ods.quo_cust_note_hist
    select * 
    from ods.quo_cust_note_load
    where q4x_source_id = p_source_id
    and q4x_batch_id = p_batch_id;
    
    -- Delete Load Batch
    delete from ods.quo_cust_note_load 
    where q4x_source_id = p_source_id
    and q4x_batch_id = p_batch_id;
    
  exception
    when others then
      g_abort_processing_flag := true;
      raise_application_error(-20000, substr('['||g_package_name||'.process_batch] Failed [ods.quo_cust_note/_load/_hist] : '||SQLERRM, 1, 4000));

  end process_batch;
  
end quo_quocdw10;
/

-- Synonyms
create or replace public synonym quo_quocdw10 for ods_app.quo_quocdw10;

-- Grants
grant execute on ods_app.quo_quocdw10 to lics_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/