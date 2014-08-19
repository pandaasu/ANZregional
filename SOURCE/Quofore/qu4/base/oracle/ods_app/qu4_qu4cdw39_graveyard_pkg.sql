
set define off;

create or replace package ods_app.qu4_qu4cdw39 as
  /*****************************************************************************
  ** Package Definition
  ******************************************************************************

    System   : qu4
    Owner    : ods_app
    Package  : qu4_qu4cdw39
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu4] Quofore - Australia Chocolate
    Loader Package, Interface [qu4cdw39] Entity [Graveyard] Table [qu4_graveyard][_load/_hist]

    Package provides the standard LICS on_start, on_data, on_end callbacks,
    plus a process_batch callback which moves records from _load to _hist table
    on completion of batch

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-19  Mal Chambeyron        Created
    2014-05-15  Mal Chambeyron        Make into a Template
    2014-05-15  Mal Chambeyron        Cleanup source_id
    2014-05-15  Mal Chambeyron        Updated to Handle Special Case [digest]
    2014-05-27  Mal Chambeyron        Use column name (30 char) instead of attribute name
                                      for lics_inbound_utility.set_csv_definition
                                      to avoid 32 char lics restriction
    2014-06-03  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

  -- Public : Procedures
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  procedure process_batch(p_batch_id in number);

end qu4_qu4cdw39;
/

create or replace package body ods_app.qu4_qu4cdw39 as

  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  -- Private : Procedures
  procedure perform_preprocessing;
  procedure process_header_row(p_row in varchar2);
  procedure process_data_row(p_row in varchar2);

  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'ods_app.qu4_qu4cdw39';
  g_entity_name constant varchar2(64 char) := 'Graveyard';
  g_delimiter constant varchar2(1)  := ',';
  g_text_qualifier constant varchar2(1) := '"';

  -- Private : Flags
  g_abort_processing_flag boolean;
  g_source_file_error_flag boolean;

  g_first_row_flag boolean;
  g_valid_header_row_found_flag boolean;
  g_footer_row_found_flag boolean;

  -- Private : Counters
  g_row_count number(10);
  g_data_row_count number(10);

  -- Private : Variables
  g_load_seq number;
  g_interface_name varchar2(32 char);
  g_source_id number(4);
  g_source_desc varchar2(256 char);
  g_prefixed_file_name varchar2(512 char);
  g_original_file_name varchar2(512 char);
  g_batch_id number(15);
  g_timestamp date;

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
    g_valid_header_row_found_flag := false;
    g_footer_row_found_flag := false;

    -- Initialise : Counters
    g_row_count := 0;
    g_data_row_count := 0;

    -- Initialise : Layout definitions
    lics_inbound_utility.clear_definition;
    lics_inbound_utility.set_csv_definition('id',1);
    lics_inbound_utility.set_csv_definition('entity',2);
    lics_inbound_utility.set_csv_definition('unique_id',3);
    lics_inbound_utility.set_csv_definition('id_lookup',4);

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
        if upper(l_row) != upper('FTR'||g_original_file_name) then -- Invalid FOOTER row / More Specific Check
          lics_inbound_utility.add_exception('['||g_package_name||'.on_data] Invalid Footer Row .. Expected [FTR'||g_original_file_name||']');
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
    g_prefixed_file_name := lics_inbound_processor.callback_file_name;
    g_original_file_name := substr(g_prefixed_file_name, 5); -- remove prefix 'qu#_'
    g_interface_name := upper(lics_inbound_processor.callback_interface); -- delibrate upper

    -- Each of the remaining Procedures / Functions Raise Exception on Failure

    -- Valid Interface Name
    qu4_util.validate_interface_name(g_entity_name, g_interface_name);

    -- Valid File Name
    qu4_util.validate_file_name(g_entity_name, g_original_file_name);

    -- Interface Name, Extract .. Source Id
    g_source_id := qu4_util.get_interface_source_id(g_interface_name);
    g_source_desc := qu4_util.get_source_desc(g_source_id);

    -- File Name, Extract .. Timestamp, Batch Id
    g_timestamp := qu4_util.get_file_timestamp(g_original_file_name);
    g_batch_id := qu4_util.get_file_batch_id(g_original_file_name);

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
    if g_abort_processing_flag = false and g_source_file_error_flag = false and g_valid_header_row_found_flag = true and g_footer_row_found_flag = true then
      qu4_interface.complete_load(g_load_seq, g_batch_id, g_entity_name, g_data_row_count);
      commit;
    else
      rollback;
      if g_valid_header_row_found_flag = true and g_footer_row_found_flag = false then
        raise_application_error(-20000, 'FOOTER NOT FOUND .. Expected [FTR'||g_original_file_name||']');
      end if;
    end if;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.on_end] : '||SQLERRM, 1, 4000));

  end on_end;

  /*****************************************************************************
  ** Procedure : Process HEADER Row
  *****************************************************************************/
  procedure process_header_row(p_row in varchar2) is

    l_expected_row varchar2(4000 char) := 'ID,Entity,UniqueID,id_lookup';

  begin

    if upper(p_row) = upper(l_expected_row) then -- Valid HEADER Row
      g_valid_header_row_found_flag := true;
      -- Start Interface Loader .. Raised Exception on Failure
      g_load_seq := qu4_interface.start_load(g_batch_id, g_entity_name, g_interface_name, g_original_file_name, g_timestamp);
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

    l_entity_load_row ods.qu4_graveyard_load%rowtype;
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
    l_entity_load_row.q4x_batch_id := g_batch_id;
    l_entity_load_row.q4x_timestamp := g_timestamp; -- Interface File Timestamp used as Default Transaction Timestamp, as Quofore Advised that Create Date was not Reliable
    -- Populate DATA Row - DATA Columns
    begin
      l_entity_load_row.id := qu4_util.get_number('id',10,0,false,g_source_file_error_flag);
      l_entity_load_row.entity := qu4_util.get_string('entity',50,false,g_source_file_error_flag);
      l_entity_load_row.unique_id := qu4_util.get_string('unique_id',100,true,g_source_file_error_flag);
      l_entity_load_row.id_lookup := qu4_util.get_number('id_lookup',10,0,true,g_source_file_error_flag);
      exception
      when others then
         lics_inbound_utility.add_exception(substr('['||g_package_name||'.process_data_row] Unexpected Parsing Error : '||SQLERRM, 1, 4000));
         g_source_file_error_flag := true;
    end;

    -- Retrieve exceptions raised
    if lics_inbound_utility.has_errors = true then
       g_source_file_error_flag := true;
    end if;

    -- Error, bypass insert once an error is found
    if g_source_file_error_flag = true then
       return;
    end if;

    -- Insert row
    begin
      insert into ods.qu4_graveyard_load values l_entity_load_row;
    exception
      when others then
         lics_inbound_utility.add_exception(substr('['||g_package_name||'.process_data_row] Insert Failed [ods.qu4_graveyard_load] : '||SQLERRM, 1, 4000));
         g_source_file_error_flag := true;
    end;

  end process_data_row;

  /*****************************************************************************
  ** Procedure : Process Batch .. Called from Batch / Digest Process
  **             DO NOT COMMIT/ROLLBACK .. This is Performed by Calling Function
  *****************************************************************************/
  procedure process_batch(p_batch_id in number) is

    l_batch_row_count number;

  begin

    -- Check if Anything to Process
    select count(1) into l_batch_row_count
    from ods.qu4_graveyard_load
    where q4x_batch_id = p_batch_id;

    -- Return is Nothing to Process
    if l_batch_row_count = 0 then
      return;
    end if;

    -- Update Modified User/Time
    update ods.qu4_graveyard_load
    set q4x_modify_user = user,
      q4x_modify_time = sysdate
    where q4x_batch_id = p_batch_id;

    -- Insert ALL of Load Batch into History
    insert into ods.qu4_graveyard_hist
    select *
    from ods.qu4_graveyard_load
    where q4x_batch_id = p_batch_id;

    -- Delete Load Batch
    delete from ods.qu4_graveyard_load
    where q4x_batch_id = p_batch_id;

  exception
    when others then
      g_abort_processing_flag := true;
      raise_application_error(-20000, substr('['||g_package_name||'.process_batch] Failed [ods.qu4_graveyard/_load/_hist] : '||SQLERRM, 1, 4000));

  end process_batch;

end qu4_qu4cdw39;
/

-- Synonyms
create or replace public synonym qu4_qu4cdw39 for ods_app.qu4_qu4cdw39;

-- Grants
grant execute on ods_app.qu4_qu4cdw39 to lics_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
