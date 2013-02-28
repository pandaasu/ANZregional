set define off;

create or replace package quo_quocdw99 as
  /*****************************************************************************
  ** Package Definition
  ******************************************************************************

   System  : quo
   Package : quo_quocdw99
   Owner   : ods_app
   Author  : Mal Chambeyron

   Description
   -----------------------------------------------------------------------------
   Quofore Interface Package [quo_quocdw99] Interface *ROUTER ..
   Identifies Source from Interface Extension
   Identifies Entity from File Name
   Then ROUTES File to Correct Interface Path

   YYYY-MM-DD   Author                 Description
   ----------   --------------------   -----------------------------------------
   2013-02-25   Mal Chambeyron         Created

  *****************************************************************************/

  -- Public : Procedures
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;

end quo_quocdw99;
/

create or replace
package body quo_quocdw99 as

  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'ods_app.quo_quocdw99';

  /*****************************************************************************
  ** Procedure : On Start - Call Back for LICS Framework
  **             Called by the LICS Framework BEFORE Processing the Record Set
  *****************************************************************************/
  procedure on_start is

    l_file_name varchar2(512 char);
    l_source_interface_name varchar2(32 char);
    l_target_interface_name varchar2(32 char);
    l_entity_name varchar2(32 char);
    l_source_id number(4);
    l_source_desc varchar2(256 char);

    l_archive_path varchar2(2048 char);
    l_temp_path varchar2(2048 char);
    l_bin_path varchar2(2048 char);
    l_interface_path varchar2(2048 char);

    l_log_header_text varchar2(4000 char);
    l_log_search_text varchar2(4000 char);

    l_error_msg varchar2(4000 char);
    l_zlib_error_flag boolean;

  begin

    -- Set Interface and Source File Names ..
    l_file_name := lics_inbound_processor.callback_file_name;
    l_source_interface_name := upper(lics_inbound_processor.callback_interface); -- delibrate upper

    -- Start Logging ..
    l_log_header_text := 'Quofore Inteface *ROUTER ['||l_file_name||']';
    l_log_search_text := 'QUOFORE_ROUTER_'||l_source_interface_name;
    --
    lics_logging.start_log(l_log_header_text,l_log_search_text);
    lics_logging.write_log('Process File ['||l_file_name||']');

    -- Each of the remaining Procedures / Functions Raise Exception on Failure

    -- File Name, Extract .. Entity Name
    begin
      l_entity_name := quo_util.get_file_entity_name(l_file_name);
    exception
      when others then
        lics_logging.write_log(substr('Cannot Extract Entity Name : '||SQLERRM, 1, 4000));
        lics_logging.end_log;
        raise_application_error(-20000, 'Check Log Monitor [LICS_LOG]['||l_log_search_text||']['||l_log_header_text||'] for Details');
    end;

    -- Validate File Name
    begin
      quo_util.validate_file_name(l_entity_name, l_file_name);
    exception
      when others then
        lics_logging.write_log(substr('Invalid File Name : '||SQLERRM, 1, 4000));
        lics_logging.end_log;
        raise_application_error(-20000, 'Check Log Monitor [LICS_LOG]['||l_log_search_text||']['||l_log_header_text||'] for Details');
    end;

    -- Interface Name, Extract .. Source Id
    begin
      l_source_id := quo_util.get_interface_source_id(l_source_interface_name);
    exception
      when others then
        lics_logging.write_log(substr('Cannot Extract Source Id : '||SQLERRM, 1, 4000));
        lics_logging.end_log;
        raise_application_error(-20000, 'Check Log Monitor [LICS_LOG]['||l_log_search_text||']['||l_log_header_text||'] for Details');
    end;

    -- Entity Name, Get .. Interface Name
    begin
      l_target_interface_name := quo_util.get_entity_interface_name(l_entity_name)||'.'||l_source_id;
    exception
      when others then
        lics_logging.write_log(substr('Cannot Extract Source Id : '||SQLERRM, 1, 4000));
        lics_logging.end_log;
        raise_application_error(-20000, 'Check Log Monitor [LICS_LOG]['||l_log_search_text||']['||l_log_header_text||'] for Details');
    end;

    -- Log Interface Routing
    lics_logging.write_log('ROUTE BEGIN : Entity ['||l_entity_name||'] to Interface ['||l_target_interface_name||']');

    -- Set Paths ..
    l_archive_path := lics_parameter.archive_directory;
    l_temp_path := lics_parameter.ics_path||'temp'||lics_parameter.folder_delimiter;
    l_bin_path := lics_parameter.ics_path||'bin'||lics_parameter.folder_delimiter;
    l_interface_path := lics_parameter.inbound_directory||lower(l_target_interface_name)||lics_parameter.folder_delimiter;

    -- Restore Archived File to Temp Path .. DO NOT Remove Archive .. DO NOT Replace Target
    l_zlib_error_flag := false;
    begin
      lics_filesystem.restore_file_gzip(l_archive_path, l_file_name||'.gz', l_temp_path, l_file_name, 0, 0);
      lics_logging.write_log('Restore Archive File, Using LICS.Oracle.Java ['||l_archive_path||l_file_name||'.gz] to ['||l_temp_path||l_file_name||']');
    exception
      when others then
        l_error_msg := SQLERRM;
        lics_logging.write_log(substr('Restore Archive File, Using LICS.Oracle.Java ['||l_archive_path||l_file_name||'.gz] to ['||l_temp_path||l_file_name||'] Failed : '||l_error_msg, 1, 4000));
        if instr(l_error_msg,'Unexpected end of ZLIB input stream',1,1) > 0 then -- Oracle Java ZLIB Uncompress Failed .. Try Restore Using Command Shell GUNZIP
          l_zlib_error_flag := true; -- Set Flag .. so can raise error at END of processing
          lics_logging.write_log('Oracle Java ZLIB Uncompress Failed .. Try Restore Using Command Shell GUNZIP');
          begin
            lics_filesystem.execute_external_procedure(l_bin_path||'quo_gunzip.ksh '||l_archive_path||l_file_name||'.gz > '||l_temp_path||l_file_name);
            lics_logging.write_log('Restore Archive File, Using LICS.Oracle.Ksh.Gunzip ['||l_archive_path||l_file_name||'.gz] to ['||l_temp_path||l_file_name||']');
          exception
            when others then
              lics_logging.write_log(substr('Restore Archive File, Using LICS.Oracle.Ksh.Gunzip ['||l_archive_path||l_file_name||'.gz] to ['||l_temp_path||l_file_name||'] Failed : '||SQLERRM, 1, 4000));
              lics_logging.end_log;
              raise_application_error(-20000, 'Check Log Monitor [LICS_LOG]['||l_log_search_text||']['||l_log_header_text||'] for Details');
          end;
        else
          lics_logging.end_log;
          raise_application_error(-20000, 'Check Log Monitor [LICS_LOG]['||l_log_search_text||']['||l_log_header_text||'] for Details');
        end if;
    end;

    -- Set File Attributes
    begin
      lics_filesystem.execute_external_procedure(replace(lics_parameter.file_attribute_command,'<FILE>',l_temp_path||l_file_name));
    exception
      when others then
        lics_logging.write_log(substr('Set File Attributes ['||replace(lics_parameter.file_attribute_command,'<FILE>',l_temp_path||l_file_name)||'] Failed : '||SQLERRM, 1, 4000));
        lics_logging.end_log;
        raise_application_error(-20000, 'Check Log Monitor [LICS_LOG]['||l_log_search_text||']['||l_log_header_text||'] for Details');
    end;
    lics_logging.write_log('Set File Attributes ['||replace(lics_parameter.file_attribute_command,'<FILE>',l_temp_path||l_file_name)||']');

    -- Move File to Interface Path .. DO NOT Replace Target
    begin
      lics_filesystem.move_file(l_temp_path, l_file_name, l_interface_path, l_file_name, 0);
    exception
      when others then
        lics_logging.write_log(substr('Move File ['||l_temp_path||l_file_name||'] to ['||l_interface_path||l_file_name||'] Failed : '||SQLERRM, 1, 4000));
        lics_logging.end_log;
        raise_application_error(-20000, 'Check Log Monitor [LICS_LOG]['||l_log_search_text||']['||l_log_header_text||'] for Details');
    end;
    lics_logging.write_log('Move File ['||l_temp_path||l_file_name||'] to ['||l_interface_path||l_file_name||']');

    if l_zlib_error_flag then
      lics_logging.write_log('ROUTE COMPLETE (with ZLIB Error) : Entity ['||l_entity_name||'] to Interface ['||l_target_interface_name||']');
      lics_logging.end_log;
      raise_application_error(-20000, 'Check Log Monitor [LICS_LOG]['||l_log_search_text||']['||l_log_header_text||'] for Details');
    else
      -- Successful Completion
      lics_logging.write_log('ROUTE COMPLETE : Entity ['||l_entity_name||'] to Interface ['||l_target_interface_name||']');
      lics_logging.end_log;
    end if;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.on_start] : '||SQLERRM, 1, 4000));

  end on_start;

  /*****************************************************************************
  ** Procedure : On Data - Call Back for LICS Framework
  **             Called by the LICS Framework FOR EACH Record of the Record Set
  *****************************************************************************/
  procedure on_data(p_row in varchar2) is

  begin

    return; -- Do nothing

  end on_data;

  /*****************************************************************************
  ** Procedure : On End - Call Back for LICS Framework
  **             Called by the LICS Framework AFTER Processing the Record Set
  *****************************************************************************/
  procedure on_end is

  begin

    commit; -- ALWAYS Commit

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.on_end] : '||SQLERRM, 1, 4000));

  end on_end;

end quo_quocdw99;
/

-- Synonyms
create or replace public synonym quo_quocdw99 for ods_app.quo_quocdw99;

-- Grants
grant execute on ods_app.quo_quocdw99 to lics_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/