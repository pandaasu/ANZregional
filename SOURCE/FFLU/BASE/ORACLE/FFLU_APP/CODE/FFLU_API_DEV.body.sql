create or replace 
package body fflu_api_dev as

/*******************************************************************************
** Package Constants
*******************************************************************************/
  pc_load_status_started   constant fflu_common.st_load_status := 'Started';
  pc_load_status_loading   constant fflu_common.st_load_status := 'Loading';
  pc_load_status_completed constant fflu_common.st_load_status := 'Completed';
  pc_load_status_errored   constant fflu_common.st_load_status := 'Errored';
  pc_load_status_cancelled constant fflu_common.st_load_status := 'Cancelled';

/*******************************************************************************
  NAME:      SIMPLE_USER_CODE_CHECK                                      PRIVATE
  PURPOSE:   Trims and Uppers the supplied user code, raising exceptions if 
             empty string and user codes greater than 32 characters.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------
  1.0   2013-05-14 Mal Chamberyon       Created.
  1.1   2013-05-23 Chris Horn           Reviewed.  
*******************************************************************************/
  function simple_user_code_check (i_user_code in varchar2) return varchar2 is
    v_code fflu_common.st_string;
  begin
    v_code := upper(trim(substrb(i_user_code,1,4000)));
    fflu_common.validate_non_empty_string(gc_execption_users,v_code,'user_code');
    fflu_common.validate_string_length(gc_execption_users,v_code,1,30,'user_code');
    return v_code;
  end simple_user_code_check;
  
/*******************************************************************************
  NAME:      SIMPLE_INTERFACE_CODE_CHECK                                 PRIVATE
  PURPOSE:   Checks that the interface code is not null and length is greater
             than 1 and less than 32.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------
  1.0   2013-05-14 Mal Chamberyon       Created.
  1.1   2013-05-23 Chris Horn           Reviewed.  
*******************************************************************************/
  function simple_interface_code_check (i_interface_code in varchar2) return varchar2 is
    v_code fflu_common.st_string;
  begin
    v_code := upper(trim(substrb(i_interface_code,1,4000)));
    fflu_common.validate_non_empty_string(gc_execption_interface,v_code,'interface_code');
    fflu_common.validate_string_length(gc_execption_interface,v_code,1,32,'interface_code');
    return v_code;
  end simple_interface_code_check;

/*******************************************************************************
  NAME:      LOOKUP_HEADER_STATUS                                        PRIVATE
  PURPOSE:   Takes the interface header status value and converts to a string.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------
  1.0   2013-05-28 Chris Horn           Created.
  *****************************************************************************/
  function lookup_header_status(i_hea_status in lics_header.hea_status%type) 
    return fflu_common.st_load_status is
    v_result fflu_common.st_load_status; 
  begin
    case i_hea_status 
      when lics_constant.header_load_working then v_result := 'Load Working';
      when lics_constant.header_load_completed then v_result := 'Load Completed';
      when lics_constant.header_load_completed_error then v_result := 'Load Completed Error';
      when lics_constant.header_process_working then v_result := 'Process Working';
      when lics_constant.header_process_working_error then v_result := 'Process Working Error';
      when lics_constant.header_process_completed then v_result := 'Process Completed';
      when lics_constant.header_process_completed_error then v_result := 'Process Completed Error';
      else v_result := 'Unknown'; 
    end case;
    return v_result;
  end lookup_header_status;

  /*****************************************************************************
  ** Public Functions : Expose Constants / Parameters / Conventions
  *****************************************************************************/
  -- LICS Constants
  function get_const_int_type_inbound return varchar2     is begin return lics_constant.type_inbound; end get_const_int_type_inbound; -- *INBOUND
  function get_const_int_type_outbound return varchar2    is begin return lics_constant.type_outbound; end get_const_int_type_outbound; -- *OUTBOUND
  -- LICS Parameters
  function get_const_system_unit return varchar2          is begin return lics_parameter.system_unit; end get_const_system_unit; -- Unique System  Identifier .. eg. CDW | PROMAX | EFEX | .. 
  function get_const_system_environment return varchar2   is begin return lics_parameter.system_environment; end get_const_system_environment; -- Tier .. DEVP | TEST | PROD
  function get_const_system_url return varchar2           is begin return lics_parameter.system_url; end get_const_system_url; -- ICS URL
  function get_const_log_database return varchar2         is begin return lics_parameter.log_database; end get_const_log_database; -- ICS Database
  -- LICS Conventions
  function get_const_all_code return varchar2             is begin return '*ALL'; end get_const_all_code; -- *ALL
  function get_const_guest_code return varchar2           is begin return '*GUEST'; end get_const_guest_code; -- *GUEST
  function get_const_loader_option return varchar2        is begin return 'ICS_INT_LOADER'; end get_const_loader_option; -- ICS_INT_LOADER
  function get_const_monitor_option return varchar2       is begin return 'ICS_INT_MONITOR'; end get_const_monitor_option; -- ICS_INT_MONITOR
  function get_const_process_option return varchar2       is begin return 'ICS_INT_PROCESS'; end get_const_process_option; -- ICS_INT_PROCESS
  -- API Constants
  function get_const_all_interfaces return varchar2       is begin return 'ALL Interfaces'; end get_const_all_interfaces; -- ALL Interfaces
  function get_const_load_completed return varchar2       is begin return lookup_header_status(lics_constant.header_load_completed); end get_const_load_completed;
  function get_const_process_working return varchar2      is begin return lookup_header_status(lics_constant.header_process_working); end get_const_process_working;

/*******************************************************************************
  NAME:      GET_USER_LIST                                                PUBLIC
*******************************************************************************/
function get_user_list return tt_user_list pipelined is
  begin
    for v_row in (
      select seu_user as user_code,
        seu_description as user_name
      from lics_sec_user
      where seu_status = 1 -- active user
      order by seu_user
    )
    loop
      pipe row(v_row);
    end loop;
  end get_user_list;

/*******************************************************************************
  NAME:      GET_AUTHORISED_LIST                                          PUBLIC
*******************************************************************************/
function get_authorised_user (i_user_code in varchar2) return tt_user_list pipelined is
    v_user_code lics_sec_user.seu_user%type;  -- varchar2(32 char)
    v_row rt_user_list;
  begin
    -- Check the user code is valid.
    v_user_code := simple_user_code_check(i_user_code); 
    begin 
      -- Look for active user
      select seu_user as user_code,
        seu_description as user_name
      into v_row.user_code,
        v_row.user_name
      from lics_sec_user
      where seu_status = lics_constant.status_active  -- Active User
      and seu_user = v_user_code;
    exception 
      when no_data_found then
        begin
          -- If active user not found .. look for active *GUEST
          select seu_user as user_code,
            seu_description as user_name
          into v_row.user_code,
            v_row.user_name
          from lics_sec_user
          where seu_status = lics_constant.status_active -- active user
          and seu_user = get_const_guest_code;
       exception
          when no_data_found then
            null;
       end;
    end;
    -- Pipe the one resultant row back as the result set.
    pipe row(v_row);
  end get_authorised_user;

/*******************************************************************************
  NAME:      GET_INTERFACE_LIST                                           PUBLIC
*******************************************************************************/
  function get_interface_list return tt_interface_list pipelined is
  begin
    -- Return the Interface List.
    for v_row in (
      select int_interface as interface_code,
        int_description as interface_name,
        int_type as interface_type_code,
        int_group as interface_thread_group_code,
        null as interface_filetype,
        null as interface_csv_qualifier
      from lics_interface
      where int_status = lics_constant.status_active -- active interface
      and int_type in (get_const_int_type_inbound, get_const_int_type_outbound)
      order by 1
    )
    loop
      pipe row(v_row);
    end loop;

  end get_interface_list;

/*******************************************************************************
  NAME:      GET_INTERFACE_LIST                                           PUBLIC
*******************************************************************************/
function get_interface_group_list return tt_interface_group_list pipelined is
  begin
    for l_row in (
      select get_const_all_code as interface_group_code, -- add pseudo *ALL group
        get_const_all_interfaces as interface_group_name 
      from dual
      union all
      select gro_group interface_group_code,
        gro_description interface_group_name
      from lics_group
      where gro_group in (
        select b.gri_group
        from lics_interface a,
          lics_grp_interface b
        where a.int_status = lics_constant.status_active -- active interface 
        and a.int_type in (get_const_int_type_inbound, get_const_int_type_outbound) 
        and a.int_interface = b.gri_interface
      )
      order by 1
    )
    loop
      pipe row(l_row);
    end loop;

  end get_interface_group_list;

  /*****************************************************************************
  ** Public Function : Get Interface Group Join .. add pseudo *ALL group
  *****************************************************************************/
  function get_interface_group_join return tt_interface_group_join pipelined is
  begin
    for v_row in (
        select get_const_all_code as interface_group_code, -- add pseudo *ALL group, for all interfaces
          a.int_interface as interace_code
        from lics_interface a
        where a.int_status = lics_constant.status_active
        and a.int_type in (get_const_int_type_inbound, get_const_int_type_outbound) 
      union all
        select c.gro_group interface_group_code,
          a.int_interface interace_code
        from lics_interface a,
          lics_grp_interface b,
          lics_group c
        where a.int_status = lics_constant.status_active
        and a.int_type in (get_const_int_type_inbound, get_const_int_type_outbound) 
        and a.int_interface = b.gri_interface
        and b.gri_group = c.gro_group
        order by 1, 2
    )
    loop
      pipe row(v_row);
    end loop;
  end get_interface_group_join;
  
  /*****************************************************************************
  ** Public Function : Get User Interface Option Join
  *****************************************************************************/
  function get_user_interface_options (i_user_code in varchar2) return tt_user_interface_options pipelined is
    v_user_code lics_sec_user.seu_user%type; -- varchar2(32 char)
  begin
    -- Set the user code.
    v_user_code := simple_user_code_check(i_user_code); -- varchar2(32 char)
    for v_row in (
      select v_user_code as user_code,
        a.interface_code,
        b.option_code
      from (
          select a.int_interface interface_code,
            a.int_type interface_type,
            a.int_usr_invocation interface_load_status,
            nvl(b.sei_user, get_const_all_code) user_code
          from lics_interface a,
            lics_sec_interface b
          where a.int_status = lics_constant.status_active
          and a.int_interface = b.sei_interface(+)
        ) a,
        (  
          select distinct v_user_code as user_code,
            b.option_code
          from lics_sec_user a,
            (
              select option_group_code,
                option_code
              from (
                select connect_by_root sel_menu option_group_code,
                  sel_link option_code
                from lics_sec_link
                connect by prior sel_link = sel_menu
              ) 
              where option_code in (
                select seo_option option_code
                from lics_sec_option
                where seo_status = lics_constant.status_active
                and seo_option in (get_const_loader_option, get_const_monitor_option, get_const_process_option)
              )
            ) b
          where a.seu_status = lics_constant.status_active
          and a.seu_user in (get_const_guest_code, v_user_code) -- include *GUEST and user options
          and a.seu_menu = b.option_group_code
        ) b
      where a.user_code in (get_const_all_code, v_user_code) -- include *ALL and user interfaces
      -- for option ICS_INT_LOADER .. filter for interfaces type *INBOUND and flagged as loadable 
      and ((b.option_code = get_const_loader_option and a.interface_type = get_const_int_type_inbound and a.interface_load_status = lics_constant.status_active) or b.option_code != get_const_loader_option)
      order by 2, 3 
    )
    loop
      pipe row(v_row);
    end loop;
  end get_user_interface_options; 
  
/*******************************************************************************
  NAME:      LOAD_START                                                   PUBLIC
*******************************************************************************/
  function load_start(
    i_user_code in varchar2, 
    i_interface_code in varchar2, 
    i_file_name in varchar2) return fflu_common.st_sequence is
  begin
    null;
  end load_start;
    
/*******************************************************************************
  NAME:      LOAD_SEGMENT                                                 PUBLIC
*******************************************************************************/
  procedure load_segment (
    i_load_sequence in fflu_common.st_sequence, 
    i_user_code in varchar2, 
    i_interface_code in varchar2, 
    i_file_name in varchar2,
    i_seg_count in fflu_common.st_count,    -- Current segement being processed.
    i_seg_size in fflu_common.st_count,     -- Byte Count of current segment.                       
    i_seg_rows in fflu_common.st_count,     -- Rows of data in this segement.
    i_seg_data in nclob) is
  begin
    null;
  end load_segment;


/*******************************************************************************
  NAME:      LOAD_CANCEL                                                  PUBLIC
*******************************************************************************/    
   procedure load_cancel (
    i_load_sequence in fflu_common.st_sequence,
    i_user_code in varchar2, 
    i_interface_code in varchar2, 
    i_file_name in varchar2) is
  begin
    null;
  end load_cancel;

/*******************************************************************************
  NAME:      LOAD_COMPLETE                                                PUBLIC
*******************************************************************************/    
  procedure load_complete (
    i_load_sequence in fflu_common.st_sequence,
    i_user_code in varchar2, 
    i_interface_code in varchar2, 
    i_file_name in varchar2,
    i_seg_count in fflu_common.st_count,    -- Total segements sent.
    i_seg_rows in fflu_common.st_count      -- Total rows sent.
  ) is 
  begin
    null;
  end load_complete;

/*******************************************************************************
  NAME:      LOAD_EXECUTE                                                 PUBLIC
*******************************************************************************/    
  procedure load_execute(i_load_sequence in fflu_common.st_sequence) is
  begin
    null;
  end load_execute;
  
/*******************************************************************************
  NAME:      LOAD_MONITOR                                                 PUBLIC
*******************************************************************************/    
  function load_monitor(i_load_sequence in fflu_common.st_sequence) 
    return tt_load_monitor pipelined is
  begin
    null;
  end load_monitor;

/*******************************************************************************
  NAME:      LICS_MONITOR                                                 PUBLIC
*******************************************************************************/    
  function lics_monitor(i_xaction_seq in lics_header.hea_header%type) 
    return tt_lics_monitor pipelined is
  begin
    null;
  end lics_monitor;

/*******************************************************************************
  NAME:      GET_XACTION_STATUS_LIST                                      PUBLIC
*******************************************************************************/  
  -- Pipelined table function to retrieve the transaction status list.
  function get_xaction_status_list return tt_xaction_status_list pipelined is
  begin
    null;
  end get_xaction_status_list;

/*******************************************************************************
  NAME:      GET_XACTION_COUNT                                            PUBLIC
*******************************************************************************/  
    function get_xaction_count (
    i_interface_group_code in varchar2,
    i_interface_code in varchar2, 
    i_interface_type_code in varchar2, 
    i_xaction_seq in fflu_common.st_sequence,
    i_xaction_status_code in fflu_common.st_status,
    i_start_datetime in date,
    i_end_datetime in date
  ) return fflu_common.st_count is
  begin
    return null;
  end get_xaction_count;

/*******************************************************************************
  NAME:      GET_XACTION_LIST                                             PUBLIC
*******************************************************************************/  
  -- Pipelined table function for returning the interface transaction records.
  function get_xaction_list( 
    i_interface_group_code in varchar2,
    i_interface_code in varchar2, 
    i_interface_type_code in varchar2, 
    i_xaction_seq in fflu_common.st_sequence,
    i_xaction_status_code in fflu_common.st_status,
    i_start_datetime in date,
    i_end_datetime in date,
    i_start_row in fflu_common.st_count,
    i_no_rows in fflu_common.st_count
  ) return tt_xaction_list pipelined is
  begin
    null;
  end get_xaction_list;

/*******************************************************************************
  NAME:      GET_XACTION_TRACE_LIST                                       PUBLIC
*******************************************************************************/  
  -- Pipelined table function for returning the list of interfaces.
  function get_xaction_trace_list ( 
    i_xaction_seq in fflu_common.st_sequence,
    i_xaction_trace_seq in fflu_common.st_trace
  ) return tt_xaction_list pipelined is
  begin
    null;
  end get_xaction_trace_list;

/*******************************************************************************
  NAME:      GET_XACTION_DATA                                             PUBLIC
*******************************************************************************/  
  function get_xaction_data (
    i_xaction_seq in fflu_common.st_sequence, 
    i_start_dat_seq in fflu_common.st_count,
    i_no_rows in fflu_common.st_count) return tt_xaction_data pipelined is
  begin
    null;
  end get_xaction_data;

/*******************************************************************************
  NAME:      GET_XACTION_DATA_WITH_ERRORS                                 PUBLIC
*******************************************************************************/  
  function get_xaction_data_with_errors (
    i_xaction_seq in fflu_common.st_sequence, 
    i_start_row in fflu_common.st_count,
    i_no_rows in fflu_common.st_count) return tt_xaction_data pipelined is
  begin
    null;
  end get_xaction_data_with_errors;

/*******************************************************************************
  NAME:      GET_XACTION_ERRORS                                           PUBLIC
*******************************************************************************/  
  function get_xaction_errors (
    i_xaction_seq fflu_common.st_sequence,
    i_xaction_trace_seq fflu_common.st_trace
  ) return tt_xaction_errors pipelined is
  begin
    null;
  end get_xaction_errors;
  
/*******************************************************************************
  NAME:      GET_XACTION_DATA_ERRORS_BY_DAT                               PUBLIC
*******************************************************************************/  
  function get_xaction_data_errors_by_dat (
    i_xaction_seq fflu_common.st_sequence,
    i_xaction_trace_seq fflu_common.st_trace,
    i_from_data_seq fflu_common.st_count,
    i_to_data_seq fflu_common.st_count
  ) return tt_xaction_data_errors pipelined is
  begin
    null;
  end get_xaction_data_errors_by_dat;
  
/*******************************************************************************
  NAME:      GET_XACTION_DATA_ERRORS_BY_ROW                               PUBLIC
*******************************************************************************/  
  function get_xaction_data_errors_by_row (
    i_xaction_seq fflu_common.st_sequence,
    i_xaction_trace_seq fflu_common.st_trace,
    i_start_row in fflu_common.st_count,
    i_no_rows in fflu_common.st_count
    ) return tt_xaction_data_errors pipelined is
  begin
    null;
  end get_xaction_data_errors_by_row;
  
/*******************************************************************************
  NAME:      REPROCESS_INTERFACE                                          PUBLIC
*******************************************************************************/    
    procedure reprocess_interface(
    i_xaction_seq in lics_header.hea_header%type,
    i_interface_code in varchar2) is
    begin
      null;
    end reprocess_interface;
  
  
/*******************************************************************************
  NAME:      PERFORM_HOUSEKEEPING                                         PUBLIC
*******************************************************************************/    
  procedure perform_housekeeping is
  begin
    null;
  end perform_housekeeping;
  
end fflu_api_dev;