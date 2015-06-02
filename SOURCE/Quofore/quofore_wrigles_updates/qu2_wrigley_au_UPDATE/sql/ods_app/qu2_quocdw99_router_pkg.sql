
set define off;

create or replace package ods_app.qu2_qu2cdw99 as
  /*****************************************************************************
  ** Package Definition
  ******************************************************************************

    System  : qu2
    Owner   : ods_app
    Package : qu2_qu2cdw99
    Author  : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu2] Quofore - Wrigley Australia
    Interface *ROUTER ..
      - Identifies Source from Interface Extension
      - Identifies Entity from File Name
      - ROUTES File to Correct Interface Path

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-25  Mal Chambeyron        Created
    2013-04-09  Mal Chambeyron        Re-Create Interface File - to Avoid ICS ZLIB Issue
    2013-06-24  Mal Chambeyron        Cloned for Wrigley AU
    2013-07-09  Mal Chambeyron        Fixed Inconsistent Naming Convention
    2013-07-10  Mal Chambeyron        Increase Entity Name from 32 > 64 char
    2013-07-31  Mal Chambeyron        Add Logic to Handle Prefixing of Interface Files to Avoid LICS Archiving Collisions
    2014-05-15  Mal Chambeyron        Make into a Template
    2015-03-18  Mal Chambeyron        Update LICS Logging ..to include Setting Group
    2015-03-27  Mal Chambeyron        Add .1 suffix to Interface Path for QUO (Original Instance)
    2015-05-26  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

  -- Public : Procedures
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;

end qu2_qu2cdw99;
/

create or replace package body ods_app.qu2_qu2cdw99 as

  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'ods_app.qu2_qu2cdw99';

  -- Private : Variables
  g_file_opened boolean;
  g_source_file_error_flag boolean;
  g_footer_row_found_flag boolean;

  g_file_handle utl_file.file_type;

  g_temp_path varchar2(2048 char);
  g_interface_path varchar2(2048 char);
  g_original_file_name varchar2(512 char);
  g_prefixed_file_name varchar2(512 char);

  g_source_interface_name varchar2(32 char);
  g_target_interface_name varchar2(32 char);
  g_entity_name varchar2(64 char);

  g_log_header_text varchar2(4000 char);
  g_log_search_text varchar2(4000 char);

  /*****************************************************************************
  ** Procedure : On Start - Call Back for LICS Framework
  **             Called by the LICS Framework BEFORE Processing the Record Set
  *****************************************************************************/
  procedure on_start is

    l_error_msg varchar2(4000 char);

  begin

    -- Initialise Flags
    g_file_opened := false;
    g_source_file_error_flag := false;
    g_footer_row_found_flag := false;

    -- Set Interface and Source File Names ..
    g_original_file_name := lics_inbound_processor.callback_file_name;
    g_prefixed_file_name := 'qu2_'||lics_inbound_processor.callback_file_name;
    g_source_interface_name := upper(lics_inbound_processor.callback_interface); -- delibrate upper

    -- Start Logging ..
    g_log_header_text := 'Quofore Inteface *ROUTER ['||g_original_file_name||']';
    g_log_search_text := qu2_constants.setting_group||'_ROUTER_'||g_source_interface_name;
    --
    lics_logging.start_log(g_log_header_text,g_log_search_text);
    lics_logging.write_log('Process File ['||g_original_file_name||']');

    -- Each of the remaining Procedures / Functions Raise Exception on Failure

    -- File Name, Extract .. Entity Name
    begin
      g_entity_name := qu2_util.get_file_entity_name(g_original_file_name);
    exception
      when others then
        lics_logging.write_log(substr('Cannot Extract Entity Name : '||SQLERRM, 1, 4000));
        lics_logging.end_log;
        raise_application_error(-20000, 'Check Log Monitor [LICS_LOG]['||g_log_search_text||']['||g_log_header_text||'] for Details');
    end;

    -- Validate File Name
    begin
      qu2_util.validate_file_name(g_entity_name, g_original_file_name);
    exception
      when others then
        lics_logging.write_log(substr('Invalid File Name : '||SQLERRM, 1, 4000));
        lics_logging.end_log;
        raise_application_error(-20000, 'Check Log Monitor [LICS_LOG]['||g_log_search_text||']['||g_log_header_text||'] for Details');
    end;

    -- Entity Name, Get .. Interface Name
    begin
      g_target_interface_name := qu2_util.get_entity_interface_name(g_entity_name);
    exception
      when others then
        lics_logging.write_log(substr('Cannot Extract Source Id : '||SQLERRM, 1, 4000));
        lics_logging.end_log;
        raise_application_error(-20000, 'Check Log Monitor [LICS_LOG]['||g_log_search_text||']['||g_log_header_text||'] for Details');
    end;

    -- Log Interface Routing
    lics_logging.write_log('ROUTE BEGIN : Entity ['||g_entity_name||'] to Interface ['||g_target_interface_name||']');

    -- Set Paths ..
    g_temp_path := lics_parameter.ics_path||'temp'||lics_parameter.folder_delimiter;
    g_interface_path := lics_parameter.inbound_directory||lower(g_target_interface_name)||lics_parameter.folder_delimiter;

    -- Open/Create File ..
    begin
      g_file_handle := utl_file.fopen('ICS_TEMP', g_prefixed_file_name, 'w', 32767);
    exception
      when others then
        lics_logging.write_log(substr('Open/Create File ['||g_temp_path||g_prefixed_file_name||'] Failed : '||SQLERRM, 1, 4000));
        lics_logging.end_log;
        raise_application_error(-20000, 'Check Log Monitor [LICS_LOG]['||g_log_search_text||']['||g_log_header_text||'] for Details');
    end;
    lics_logging.write_log('Open/Create File ['||g_temp_path||g_prefixed_file_name||']');
    g_file_opened := true;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.on_start] : '||SQLERRM, 1, 4000));

  end on_start;

  /*****************************************************************************
  ** Procedure : On Data - Call Back for LICS Framework
  **             Called by the LICS Framework FOR EACH Record of the Record Set
  *****************************************************************************/
  procedure on_data(p_row in varchar2) is

    l_row varchar2(4000 char);

  begin

    if g_file_opened = true then

      -- Write Unaltered Row
      begin
        utl_file.put_line(g_file_handle, p_row);
      exception
        when others then
          raise_application_error(-20000, substr('Writing Row ['||p_row||'] Error : '||SQLERRM, 1, 4000));
      end;

      -- Checks for Valid Footer ..
      -- ie. to NOT forward file for further processing on Invalid Footer

      -- Remove leading and trailing whitespace (including cr/lf/tab/etc..)
      l_row := trim(regexp_replace(p_row,'[[:space:]]*$',null));
      if l_row is null then
        return; -- Return on EMPTY Line
      end if;

      -- FOOTER row .. Starts with FTR followed by any APLHA, NUMERIC, [_] and [.] .. Note, NO Comma [,]
      if regexp_instr(l_row,'^FTR[A-Z0-9._]*$',1,1,0,'i') = 1 then -- Simple Check to Distinguish from DATA row
        g_footer_row_found_flag := true;
        if upper(l_row) != upper('FTR'||g_original_file_name) then -- Invalid FOOTER row / More Specific Check
          lics_inbound_utility.add_exception('['||g_package_name||'.on_data] Invalid Footer Row .. Expected [FTR'||g_original_file_name||']');
          lics_logging.write_log('['||g_package_name||'.on_data] Invalid Footer Row .. Expected [FTR'||g_original_file_name||']');
          g_source_file_error_flag := true;
          return; -- Invalid Footer
        end if;
      -- DATA row
      else
        if g_footer_row_found_flag then -- cannot have DATA row after FOOTER row
          lics_inbound_utility.add_exception('['||g_package_name||'.on_data] DATA Row Found After FOOTER Row');
          lics_logging.write_log('['||g_package_name||'.on_data] DATA Row Found After FOOTER Row');
          g_source_file_error_flag := true;
        end if;
      end if;

    end if;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.on_data] : '||SQLERRM, 1, 4000));

  end on_data;

  /*****************************************************************************
  ** Procedure : On End - Call Back for LICS Framework
  **             Called by the LICS Framework AFTER Processing the Record Set
  *****************************************************************************/
  procedure on_end is

  begin

    -- Close File
    if g_file_opened = true then
      begin
        utl_file.fclose(g_file_handle);
      exception
        when others then
        lics_logging.write_log(substr('Close File ['||g_temp_path||g_prefixed_file_name||'] Failed : '||SQLERRM, 1, 4000));
        lics_logging.end_log;
        raise_application_error(-20000, 'Check Log Monitor [LICS_LOG]['||g_log_search_text||']['||g_log_header_text||'] for Details');
      end;
      g_file_opened := false;
    end if;
    lics_logging.write_log('Close File ['||g_temp_path||g_prefixed_file_name||']');

    -- Set File Attributes
    begin
      lics_filesystem.execute_external_procedure(replace(lics_parameter.file_attribute_command,'<FILE>',g_temp_path||g_prefixed_file_name));
    exception
      when others then
        lics_logging.write_log(substr('Set File Attributes ['||replace(lics_parameter.file_attribute_command,'<FILE>',g_temp_path||g_prefixed_file_name)||'] Failed : '||SQLERRM, 1, 4000));
        lics_logging.end_log;
        raise_application_error(-20000, 'Check Log Monitor [LICS_LOG]['||g_log_search_text||']['||g_log_header_text||'] for Details');
    end;
    lics_logging.write_log('Set File Attributes ['||replace(lics_parameter.file_attribute_command,'<FILE>',g_temp_path||g_prefixed_file_name)||']');


    -- Check need to continue processing ..
    if g_source_file_error_flag = false and g_footer_row_found_flag = true then
      commit; -- and continue
    else
      rollback; -- and raise exception or return as appropriate

      if g_footer_row_found_flag = false then
        lics_logging.write_log('FOOTER NOT FOUND .. Expected [FTR'||g_original_file_name||']');
        lics_logging.end_log;
        raise_application_error(-20000, 'Check Log Monitor [LICS_LOG]['||g_log_search_text||']['||g_log_header_text||'] for Details');
      end if;

      if g_source_file_error_flag = true then
        lics_logging.write_log('Error in Source File ['||g_original_file_name||']');
        lics_logging.end_log;
        return;
      end if;

    end if;


    -- Continue processing .. Route file to Interface ..

    -- Move File to Interface Path .. DO NOT Replace Target
    begin
      lics_filesystem.move_file(g_temp_path, g_prefixed_file_name, g_interface_path, g_prefixed_file_name, 0);
    exception
      when others then
        lics_logging.write_log(substr('Move File ['||g_temp_path||g_prefixed_file_name||'] to ['||g_interface_path||g_prefixed_file_name||'] Failed : '||SQLERRM, 1, 4000));
        lics_logging.end_log;
        raise_application_error(-20000, 'Check Log Monitor [LICS_LOG]['||g_log_search_text||']['||g_log_header_text||'] for Details');
    end;
    lics_logging.write_log('Move File ['||g_temp_path||g_prefixed_file_name||'] to ['||g_interface_path||g_prefixed_file_name||']');

    -- Successful Completion
    lics_logging.write_log('ROUTE COMPLETE : Entity ['||g_entity_name||'] to Interface ['||g_target_interface_name||']');
    lics_logging.end_log;

    commit;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.on_end] : '||SQLERRM, 1, 4000));

  end on_end;

end qu2_qu2cdw99;
/

-- Synonyms
create or replace public synonym qu2_qu2cdw99 for ods_app.qu2_qu2cdw99;

-- Grants
grant execute on ods_app.qu2_qu2cdw99 to lics_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
