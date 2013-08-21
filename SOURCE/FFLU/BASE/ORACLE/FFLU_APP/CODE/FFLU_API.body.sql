create or replace 
package body fflu_api as

/*******************************************************************************
** Package Constants
*******************************************************************************/
  -- Package Name
  pc_package_name          constant fflu_common.st_name := 'FFLU_API';
  -- Load Executor Group
  pc_load_executor_group   constant fflu_common.st_name := 'FFLU';
  -- Load Status Code
  pc_all_status            constant fflu_common.st_status := '*';

/*******************************************************************************
** Package Exceptions
*******************************************************************************/
  pe_execption_users          exception;
  pe_execption_interface      exception;
  pe_exception_security       exception;
  pe_exception_filename       exception;
  pe_exception_load           exception;
  pe_exception_segment        exception;
  pe_exception_xaction_seq    exception;
  pe_exception_pagenation     exception;
  
  pragma exception_init(pe_execption_users,        -20001);
  pragma exception_init(pe_execption_interface,    -20002);
  pragma exception_init(pe_exception_security,     -20003);
  pragma exception_init(pe_exception_filename,     -20004);
  pragma exception_init(pe_exception_load,         -20005);
  pragma exception_init(pe_exception_segment,      -20006);
  pragma exception_init(pe_exception_xaction_seq,  -20007);
  pragma exception_init(pe_exception_pagenation,   -20008);
  
/*******************************************************************************
  NAME:      SIMPLE_USER_CODE_CHECK                                      PRIVATE
  PURPOSE:   Trims and Uppers the supplied user code, raising exceptions if 
             empty string and user codes greater than 30 characters.

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
    fflu_common.validate_non_empty_string(fflu_common.gc_execption_users,v_code,'user_code');
    fflu_common.validate_string_length(fflu_common.gc_execption_users,v_code,1,30,'user_code');
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
  1.2   2013-05-30 Chris Horn           Added Interface Exists Check.
*******************************************************************************/
  function simple_interface_code_check (i_interface_code in varchar2) return varchar2 is
    v_code fflu_common.st_string;
    v_status fflu_common.st_status;  
  begin
    v_code := upper(trim(substrb(i_interface_code,1,4000)));
    fflu_common.validate_non_empty_string(fflu_common.gc_execption_interface,v_code,'interface_code');
    fflu_common.validate_string_length(fflu_common.gc_execption_interface,v_code,1,32,'interface_code');
    -- Now check if the interface is configured and is defined as active. 
    begin
      select int_status into v_status from lics_interface where int_interface = v_code;
      if v_status <> lics_constant.status_active then 
        raise_application_error(fflu_common.gc_execption_interface,'[interface] value [' || i_interface_code || '] is not currently active.');
      end if;
    exception
      when no_data_found then 
        raise_application_error(fflu_common.gc_execption_interface,'[interface] value [' || i_interface_code || '] was not found.');
    end;
    -- Now return the code.  
    return v_code;
  end simple_interface_code_check;

/*******************************************************************************
  NAME:      USER_INTERFACE_SECURITY_CHECK                               PRIVATE
  PURPOSE:   Checks that this user is allowed to carry out a data load against
             this interface.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------
  1.0   2013-05-30 Chris Horn           Created
  1.1   2013-06-05 Chris Horn           Made more generic.
*******************************************************************************/
  procedure user_interface_security_check (
    i_user_code in varchar2, 
    i_interface_code in varchar2,
    i_security_code in varchar2) is
    v_user_code fflu_common.st_user;
  begin
    select user_code into v_user_code 
    from table(get_user_interface_options(i_user_code)) 
    where interface_code = i_interface_code and option_code = i_security_code;
  exception
    when no_data_found then
      raise_application_error(fflu_common.gc_exception_security,'[user] value [' || i_user_code || '], [interface] value [' || i_interface_code || '] user does not have permission to [' || i_security_code || '].');
  end user_interface_security_check;


/*******************************************************************************
  NAME:      SIMPLE_FILENAME_CHECK                                       PRIVATE
  PURPOSE:   Checks that the file name is not null and length is greater
             than 1 and less than 64.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------
  1.0   2013-05-29 Chris Horn           Created.

*******************************************************************************/
  function simple_filename_check (i_interface_code in varchar2) return varchar2 is
    v_filename fflu_common.st_string;
  begin
    v_filename := trim(substrb(i_interface_code,1,4000));
    fflu_common.validate_non_empty_string(fflu_common.gc_exception_filename,v_filename,'file_name');
    fflu_common.validate_string_length(fflu_common.gc_exception_filename,v_filename,1,64,'file_name');
    return v_filename;
  end simple_filename_check;

/*******************************************************************************
  NAME:      SIMPLE_LOAD_SEQ_CHECK                                       PRIVATE
  PURPOSE:   Check that the supplied load sequence record exists.  Raise 
             exception if it doesn't.  Returns the status of the header 
             record.  

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------
  1.0   2013-05-29 Chris Horn           Created.

*******************************************************************************/
  function simple_load_seq_check (i_load_sequence in fflu_common.st_sequence) return fflu_common.st_load_status is
    v_load_status fflu_common.st_load_status;  
  begin
    select load_status into v_load_status 
    from fflu_load_header where load_seq = i_load_sequence; 
    return v_load_status; 
  exception
    when no_data_found then 
      raise_application_error(fflu_common.gc_exception_load,'[load] value [' || i_load_sequence || '] load was not found.');
  end simple_load_seq_check;

/*******************************************************************************
  NAME:      SIMPLE_LOAD_HEADER_CHECK                                    PRIVATE
  PURPOSE:   Check that the supplied header fields match the existing record.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------
  1.0   2013-05-29 Chris Horn           Created.

*******************************************************************************/
  procedure simple_load_header_check (
    i_load_sequence in fflu_common.st_sequence, 
    i_user_code in fflu_common.st_user,
    i_interface_code in fflu_common.st_interface,
    i_file_name in fflu_common.st_filename
    ) is
    v_user_code fflu_common.st_user;
    v_interface_code fflu_common.st_interface;
    v_file_name fflu_common.st_filename;
  begin
    -- Select the load header details. 
    select user_code, interface_code, file_name 
    into v_user_code, v_interface_code, v_file_name    
    from fflu_load_header where load_seq = i_load_sequence; 
    -- Now check that each field matches.
    if v_user_code is null or v_user_code <> i_user_code then 
      raise_application_error(fflu_common.gc_exception_load,'[load] value [' || i_load_sequence || '], [user code] value [' || i_user_code || '] did not match header value of [' || v_user_code || '].');
    end if;
    if v_interface_code is null or v_interface_code <> i_interface_code then 
      raise_application_error(fflu_common.gc_exception_load,'[load] value [' || i_load_sequence || '], [interface code] value [' || i_interface_code || '] did not match header value of [' || v_interface_code || '].');
    end if;
    if v_file_name is null or v_file_name <> i_file_name then 
      raise_application_error(fflu_common.gc_exception_load,'[load] value [' || i_load_sequence || '], [interface code] value [' || i_file_name || '] did not match header value of [' || v_file_name || '].');
    end if;
  exception 
    when no_data_found then 
      raise_application_error(fflu_common.gc_exception_load,'[load] value [' || i_load_sequence || '] load was not found.');
  end simple_load_header_check;


/*******************************************************************************
  NAME:      SIMPLE_LICS_SEQ_CHECK                                       PRIVATE
  PURPOSE:   Check that the supplied lics sequence record exists.  Raise 
             exception if it doesn't.  Returns the status of the header 
             record. 

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------
  1.0   2013-06-03 Chris Horn           Created.

*******************************************************************************/
  function simple_lics_seq_check (i_lics_sequence in fflu_common.st_sequence) return fflu_common.st_status is
    v_load_status fflu_common.st_status;  
  begin
    select hea_status into v_load_status 
    from lics_header where hea_header = i_lics_sequence; 
    return v_load_status; 
  exception
    when no_data_found then 
      raise_application_error(fflu_common.gc_exception_xaction_seq,'[transaction] value [' || i_lics_sequence || '] was not found.');
  end simple_lics_seq_check;

/*******************************************************************************
  NAME:      LOOKUP_INTERFACE_CODE                                       PRIVATE
  PURPOSE:   Find the interface code for the specific lics interface.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------
  1.0   2013-06-05 Chris Horn           Created.

*******************************************************************************/
  function lookup_interface_code (i_lics_sequence in fflu_common.st_sequence) return fflu_common.st_interface is
    v_interface fflu_common.st_interface;
  begin
    select hea_interface into v_interface 
    from lics_header where hea_header = i_lics_sequence; 
    return v_interface; 
  exception
    when no_data_found then 
      raise_application_error(fflu_common.gc_exception_xaction_seq,'[transaction] value [' || i_lics_sequence || '] was not found.');
  end lookup_interface_code;

/*******************************************************************************
  NAME:      SIMPLE_LICS_SEQ_TRACE_CHECK                                 PRIVATE
  PURPOSE:   Check that the supplied lics sequence trace number exists.  Raise 
             exception if it doesn't.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------
  1.0   2013-06-05 Chris Horn           Created.

*******************************************************************************/
  procedure simple_lics_seq_trace_check(
    i_lics_sequence in fflu_common.st_sequence, 
    i_lics_trace_sequence in fflu_common.st_trace) is
    v_sequence fflu_common.st_sequence; 
  begin
    select 
      het_header 
    into 
      v_sequence
    from 
      lics_hdr_trace 
    where 
      het_header = i_lics_sequence and
      het_hdr_trace = i_lics_trace_sequence;
  exception
    when no_data_found then 
      raise_application_error(fflu_common.gc_exception_xaction_seq,'[transaction] value [' || i_lics_sequence || '], [trace] value [' || i_lics_trace_sequence || '] was not found.');
  end simple_lics_seq_trace_check;

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
  function get_const_process_working_err return varchar2   is begin return lookup_header_status(lics_constant.header_process_working_error); end get_const_process_working_err;

/*******************************************************************************
  NAME:      GET_USER_LIST                                                PUBLIC
*******************************************************************************/
function get_user_list return tt_user_list pipelined is
  begin
    for rv_row in (
      select seu_user as user_code,
        seu_description as user_name
      from lics_sec_user
      where seu_status = 1 -- active user
      order by seu_user
    )
    loop
      pipe row(rv_row);
    end loop;
  end get_user_list;

/*******************************************************************************
  NAME:      GET_AUTHORISED_LIST                                          PUBLIC
*******************************************************************************/
function get_authorised_user (i_user_code in varchar2) return tt_user_list pipelined is
    v_user_code fflu_common.st_user;
    rv_row rt_user_list;
  begin
    -- Check the user code is valid.
    v_user_code := simple_user_code_check(i_user_code); 
    begin 
      -- Look for active user
      select seu_user as user_code,
        seu_description as user_name
      into rv_row.user_code,
        rv_row.user_name
      from lics_sec_user
      where seu_status = lics_constant.status_active  -- Active User
      and seu_user = v_user_code;
    exception 
      when no_data_found then
        begin
          -- If active user not found .. look for active *GUEST
          select seu_user as user_code,
            seu_description as user_name
          into rv_row.user_code,
            rv_row.user_name
          from lics_sec_user
          where seu_status = lics_constant.status_active -- active user
          and seu_user = get_const_guest_code;
       exception
          when no_data_found then
            null;
       end;
    end;
    -- Pipe the one resultant row back as the result set.
    pipe row(rv_row);
  end get_authorised_user;

/*******************************************************************************
  NAME:      GET_INTERFACE_LIST                                           PUBLIC
*******************************************************************************/
  function get_interface_list return tt_interface_list pipelined is
    cursor csr_interface is 
      select int_interface as interface_code,
        int_description as interface_name,
        int_type as interface_type_code,
        int_group as interface_thread_code,
        int_procedure as interface_package
      from lics_interface
      where int_status = lics_constant.status_active -- active interface
      and int_type in (get_const_int_type_inbound, get_const_int_type_outbound)
      order by 1;
      rv_data csr_interface%rowtype; 
      rv_row rt_interface_list;
  begin
    open csr_interface;
    loop
      fetch csr_interface into rv_data;
      exit when csr_interface%notfound;
      -- Transfer the other data columns across.
      rv_row.interface_code := rv_data.interface_code;
      rv_row.interface_name := rv_data.interface_name;
      rv_row.interface_type_code := rv_data.interface_type_code;
      rv_row.interface_thread_code := rv_data.interface_thread_code;
      -- Call the interface procedure hooks.
      -- Now perform a get file type interface callbacks to determine file types and csv qualifiers. 
      declare
        v_filetype fflu_common.st_filetype;
      begin
        execute immediate 'begin :v_filetype := ' || rv_data.interface_package ||'.on_get_file_type; end;' USING OUT v_filetype;
        rv_row.interface_filetype := v_filetype;
      exception 
        when others then 
          rv_row.interface_filetype := null;
      end;
      declare 
        v_qualifier fflu_common.st_qualifier;
      begin
        execute immediate 'begin :v_qualifier := ' || rv_data.interface_package ||'.on_get_csv_qualifier; end;' USING OUT v_qualifier;
        rv_row.interface_csv_qual := v_qualifier;
      exception 
        when others then 
          rv_row.interface_csv_qual := null; 
      end;
      -- Now pipe the row back out to the pipeline.
      pipe row(rv_row);
    end loop;
    close csr_interface;
  end get_interface_list;

/*******************************************************************************
  NAME:      GET_INTERFACE_LIST                                           PUBLIC
*******************************************************************************/
function get_interface_group_list return tt_interface_group_list pipelined is
  begin
    for rv_row in (
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
      pipe row(rv_row);
    end loop;

  end get_interface_group_list;

  /*****************************************************************************
  ** Public Function : Get Interface Group Join .. add pseudo *ALL group
  *****************************************************************************/
  function get_interface_group_join return tt_interface_group_join pipelined is
  begin
    for rv_row in (
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
      pipe row(rv_row);
    end loop;
  end get_interface_group_join;
  
  /*****************************************************************************
  ** Public Function : Get User Interface Option Join
  *****************************************************************************/
  function get_user_interface_options (i_user_code in varchar2) return tt_user_interface_options pipelined is
    v_user_code fflu_common.st_user;
  begin
    -- Set the user code.
    v_user_code := simple_user_code_check(i_user_code); -- varchar2(32 char)
    for rv_row in (
      select v_user_code as user_code,
        a.interface_code,
        b.option_code
      from (
          select a.int_interface interface_code,
            a.int_type interface_type,
            a.int_usr_invocation interface_load_status
          from lics_interface a
          where a.int_status = lics_constant.status_active
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
      where 
        -- for option ICS_INT_LOADER .. filter for interfaces type *INBOUND and flagged as loadable 
        ((b.option_code = get_const_loader_option and a.interface_type = get_const_int_type_inbound and a.interface_load_status = lics_constant.status_active) or b.option_code != get_const_loader_option) and
        (((select count(*) from lics_sec_interface t0 where t0.sei_user = v_user_code) > 0 and exists (select t0.sei_interface from lics_sec_interface t0 where a.interface_code = t0.sei_interface and t0.sei_user = v_user_code)) or
         (select count(*) from lics_sec_interface t0 where t0.sei_user = v_user_code) = 0)
      order by 2, 3 
    )
    loop
      pipe row(rv_row);
    end loop;
  end get_user_interface_options; 
  
/*******************************************************************************
  NAME:      LOAD_START                                                   PUBLIC
*******************************************************************************/
  function load_start(
    i_user_code in varchar2, 
    i_interface_code in varchar2, 
    i_file_name in varchar2) return fflu_common.st_sequence is
    -- Variable Declarations
    v_user_code fflu_common.st_user;
    v_sequence fflu_common.st_sequence;
    v_interface_code fflu_common.st_interface;
    v_file_name fflu_common.st_filename;
  begin
    -- Initialise Variables.
    v_sequence := null;
    -- Perfrom Basic Validation Checks.
    v_user_code := simple_user_code_check(i_user_code);
    v_interface_code := simple_interface_code_check(i_interface_code);
    v_file_name := simple_filename_check(i_file_name);
    -- Perform a security check. 
    user_interface_security_check(v_user_code,v_interface_code, get_const_loader_option);
    -- Allocate the new Sequence Number.
    v_sequence := fflu_load_seq.nextval;
    -- Insert a record into the header table.
    insert into fflu_load_header (
      load_seq, user_code, interface_code, 
      file_name,load_status, load_start_time
    ) values (
      v_sequence, v_user_code, v_interface_code, 
      v_file_name,fflu_common.gc_load_status_started, sysdate
    );
    -- Commit the creation of the record.
    commit;
    -- Return the new sequence number.
    return v_sequence;
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
    -- Variable Declarations
    v_user_code fflu_common.st_user;
    v_sequence fflu_common.st_sequence;
    v_interface_code fflu_common.st_interface;
    v_file_name fflu_common.st_filename;
    v_load_status fflu_common.st_load_status;
    v_load_header fflu_load_header%rowtype;
    v_seg_data nclob;
    v_clob_len fflu_common.st_size;
    v_buffer varchar2(32000 byte); -- Large Buffer for reading data.  4 * read buffer size. 
    v_line fflu_common.st_string; -- To store each row.
    v_read_offset fflu_common.st_size;  -- 
    v_read_amount fflu_common.st_size;  -- Amount of bytes read.
    v_read_bytes fflu_common.st_size;   -- Number of actual bytes read.
    v_wrote_bytes fflu_common.st_size;  -- Number of bytes written back out as lines.
    v_row_counter fflu_common.st_size;  -- The number of rows processed.
    v_errormsg fflu_common.st_string;   
    
    -- Now process the line into the database.
    procedure process_line(io_row_counter in out fflu_common.st_size, io_line in out fflu_common.st_string, io_wrote_bytes in out fflu_common.st_size) is
    begin
      io_row_counter := io_row_counter + 1;
      insert into fflu_load_data (LOAD_SEQ, DATA_SEQ, DATA_RECORD,DATA_SEG) values (i_load_sequence, io_row_counter, io_line,i_seg_count);
      io_wrote_bytes := io_wrote_bytes + nvl(lengthb(io_line),0);
      io_line := '';
    exception
      when others then 
        raise_application_error(fflu_common.gc_exception_segment,fflu_common.sqlerror_string('[load] value [' || i_load_sequence || '], row ' || io_row_counter || ' failed to be inserted into load data table.'));
    end process_line;
    
    -- This procedure is used to process the contents of the buffer and perform validations as necessary and then store in the load data table.
    procedure process_buffer(i_buffer in varchar2, io_row_counter in out fflu_common.st_size, io_line in out fflu_common.st_string, io_wrote_bytes in out fflu_common.st_size) is
      v_pos fflu_common.st_size;
      v_line_feed fflu_common.st_size;
      v_line_buf varchar2(32000 byte);
      v_buf_len fflu_common.st_size; 
    begin 
      v_pos := 1;
      v_buf_len := length(i_buffer);
      while v_pos <= v_buf_len loop 
        v_line_feed := instr(i_buffer,chr(10),v_pos,1);
        -- Check if there is a line feed present.
        if v_line_feed = 0 then 
          -- If not take everything we have left in the buffer and copy to line.
          v_line_buf := substr(i_buffer,v_pos);
          if nvl(lengthb(io_line),0) + nvl(lengthb(v_line_buf),0) > 4000 then 
            raise_application_error(fflu_common.gc_exception_segment,'[load] value [' || i_load_sequence || '], row ' || io_row_counter || ' line construction length is greater than 4000 bytes.');
          end if;
          io_line := io_line || v_line_buf;
          v_pos := v_pos + nvl(length(v_line_buf),0);
        else 
          v_line_buf := substr(i_buffer,v_pos,v_line_feed + 1 - v_pos); -- Plus 1 includes the line feed.
          if nvl(lengthb(io_line),0) + nvl(lengthb(v_line_buf),0) > 4000 then 
            raise_application_error(fflu_common.gc_exception_segment,'[load] value [' || i_load_sequence || '], row ' || io_row_counter || ' complete line length was greater than 4000 bytes.');
          end if;
          io_line := io_line || v_line_buf; 
          process_line(io_row_counter,io_line,io_wrote_bytes);
          v_pos := v_line_feed+1;
        end if;
      end loop;
    end process_buffer;
    
  begin
    -- Perfrom Basic Validation Checks.
    v_load_status := simple_load_seq_check(i_load_sequence);
    v_user_code := simple_user_code_check(i_user_code);
    v_interface_code := simple_interface_code_check(i_interface_code);
    v_file_name := simple_filename_check(i_file_name);
    simple_load_header_check(i_load_sequence, v_user_code, v_interface_code, v_file_name);
    -- Perform a security check. 
    user_interface_security_check(v_user_code,v_interface_code, get_const_loader_option);
    -- Now fetch the load status and validate.
    if v_load_status = fflu_common.gc_load_status_started then 
      -- Now update the status of the header to loading.
      update fflu_load_header set load_status = fflu_common.gc_load_status_loading 
      where load_seq = i_load_sequence;
      v_load_status := fflu_common.gc_load_status_loading;
    end if;
    -- Ensure that the status of this load is currently loading.  
    if v_load_status <> fflu_common.gc_load_status_loading then 
      raise_application_error(fflu_common.gc_exception_load,'[load] value [' || i_load_sequence || '], [status] values [' || v_load_status || '] is not in the loading status.');
    end if;
    -- Now fetch the whole header record.
    select * into v_load_header from fflu_load_header where load_seq = i_load_sequence;
    -- Now check that this segement sequence numbers are what we would expect.
    if v_load_header.segment_count is null then 
      v_load_header.segment_count := 0;
    end if;
    if i_seg_count is null then 
      raise_application_error(fflu_common.gc_exception_segment,'[load] value [' || i_load_sequence || '], segement sequence no was null.');
    end if;
    if v_load_header.segment_count + 1 <> i_seg_count then 
      raise_application_error(fflu_common.gc_exception_segment,'[load] value [' || i_load_sequence || '], segement sequence expected was  [' || (v_load_header.segment_count + 1) || '] received segment [' || i_seg_count ||'].');
    end if;
    -- Check that the segement data is correct.
    if i_seg_data is null then
      raise_application_error(fflu_common.gc_exception_segment,'[load] value [' || i_load_sequence || '], supplied segment data was null.');
    end if;
    -- Now process the segment data.  
    v_seg_data := i_seg_data;
    begin
      DBMS_LOB.OPEN(v_seg_data,DBMS_LOB.LOB_READONLY);
      v_clob_len := DBMS_LOB.GETLENGTH(v_seg_data);
      v_read_offset := 1;
      v_read_bytes := 0;
      v_wrote_bytes := 0;
      v_line := '';
      v_row_counter := nvl(v_load_header.row_count,0);
      -- Check if the clob is empty and raise exception if it is.
      if v_clob_len = 0 then 
        raise_application_error(fflu_common.gc_exception_segment,'[load] value [' || i_load_sequence || '], supplied segment was empty.');
      end if;
      while v_read_offset <= v_clob_len loop 
        v_read_amount := 8000;
        dbms_lob.read(v_seg_data,v_read_amount,v_read_offset,v_buffer);
        if v_read_amount = 0 then 
          raise_application_error(fflu_common.gc_exception_segment,'[load] value [' || i_load_sequence || '], read segment and received nothing when expected something.');
        end if;
        -- Update the read counters.
        v_read_offset := v_read_offset + v_read_amount;
        v_read_bytes := v_read_bytes + nvl(lengthb(v_buffer),0);
        -- Now process this buffer.
        process_buffer(v_buffer,v_row_counter,v_line,v_wrote_bytes);
      end loop;
      if lengthb(v_line) > 0 then 
        raise_application_error(fflu_common.gc_exception_segment,'[load] value [' || i_load_sequence || '], segement did not end with a complete line.');
      end if; 
      -- Now check that the row count 
      if v_row_counter - nvl(v_load_header.row_count,0) <> i_seg_rows then 
        raise_application_error(fflu_common.gc_exception_segment,'[load] value [' || i_load_sequence || '], segement expected ' || i_seg_rows || ' rows and received ' || (v_row_counter - nvl(v_load_header.row_count,0)) || ' instead.');
      end if;
      -- Now check that the byte count matched.
      if v_read_bytes <> i_seg_size then 
        raise_application_error(fflu_common.gc_exception_segment,'[load] value [' || i_load_sequence || '], segement expected ' || i_seg_size || ' bytes and received ' || v_read_bytes || ' instead.');
      end if;
      -- Now compare with written bytes. then
      if v_wrote_bytes <> i_seg_size then 
        raise_application_error(fflu_common.gc_exception_segment,'[load] value [' || i_load_sequence || '], segement expected to write ' || i_seg_size || ' bytes but wrote out ' || v_wrote_bytes || ' instead.'); 
      end if;
      -- Now close the clob.  
      DBMS_LOB.CLOSE(v_seg_data);
    exception 
      when pe_exception_segment then 
        -- Attempt to close the clob, ignore any exceptions when trying to close.  
        begin
          DBMS_LOB.CLOSE(v_seg_data);
        exception 
          when others then 
            null;
        end;
        raise;
      when others then 
        -- Define the error message. 
        v_errormsg := fflu_common.sqlerror_string('[load] value [' || i_load_sequence || '], segment clob exception.');
        -- Attempt to close the clob, ignore any exceptions when trying to close.  
        begin
          DBMS_LOB.CLOSE(v_seg_data);
        exception 
          when others then 
            null;
        end;
        raise_application_error(fflu_common.gc_exception_segment,v_errormsg);
    end;
    -- Now update the header record with the updated segement count and row count.
    update fflu_load_header 
    set 
      segment_count = v_load_header.segment_count + 1,
      row_count = v_row_counter
    where load_seq = i_load_sequence;
    -- Now commit the changes we have made.
    commit;
  exception 
    -- Trap any exceptions and rollback any actions taken to the point of the 
    -- exception then re raise.
    when others then
      rollback;
      -- Now mark the header as errored. 
      update fflu_load_header set load_status = fflu_common.gc_load_status_errored where load_seq = i_load_sequence;
      commit;
      raise; 
  end load_segment;


/*******************************************************************************
  NAME:      LOAD_CANCEL                                                  PUBLIC
*******************************************************************************/    
   procedure load_cancel (
    i_load_sequence in fflu_common.st_sequence,
    i_user_code in varchar2, 
    i_interface_code in varchar2, 
    i_file_name in varchar2) is
    v_user_code fflu_common.st_user;
    v_sequence fflu_common.st_sequence;
    v_interface_code fflu_common.st_interface;
    v_file_name fflu_common.st_filename;
    v_load_status fflu_common.st_load_status;
  begin
    -- Perfrom Basic Validation Checks.
    v_load_status := simple_load_seq_check(i_load_sequence);
    v_user_code := simple_user_code_check(i_user_code);
    v_interface_code := simple_interface_code_check(i_interface_code);
    v_file_name := simple_filename_check(i_file_name);
    simple_load_header_check(i_load_sequence, v_user_code, v_interface_code, v_file_name);
    -- Perform a security check. 
    user_interface_security_check(v_user_code,v_interface_code, get_const_loader_option);
    -- Now fetch the load status and validate.
    if v_load_status in (fflu_common.gc_load_status_started,fflu_common.gc_load_status_loading) then 
      -- Now update the status of the header to loading.
      update fflu_load_header set load_status = fflu_common.gc_load_status_cancelled 
      where load_seq = i_load_sequence;
    else 
      raise_application_error(fflu_common.gc_exception_load,'[load] value [' || i_load_sequence || '], [status] value [' || v_load_status || '] cannot cancel load as it is not in the started or loading status.');
    end if;
    -- Commit any changes.
    commit;
  exception 
    when others then 
      rollback;
      raise;
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
    v_user_code fflu_common.st_user;
    v_sequence fflu_common.st_sequence;
    v_interface_code fflu_common.st_interface;
    v_file_name fflu_common.st_filename;
    v_load_status fflu_common.st_load_status;
  begin
    -- Perfrom Basic Validation Checks.
    v_load_status := simple_load_seq_check(i_load_sequence);
    v_user_code := simple_user_code_check(i_user_code);
    v_interface_code := simple_interface_code_check(i_interface_code);
    v_file_name := simple_filename_check(i_file_name);
    simple_load_header_check(i_load_sequence, v_user_code, v_interface_code, v_file_name);
    -- Perform a security check. 
    user_interface_security_check(v_user_code,v_interface_code, get_const_loader_option);
    -- Now fetch the load status and validate.
    if v_load_status in (fflu_common.gc_load_status_started,fflu_common.gc_load_status_loading) then 
      -- Now update the status of the header to loading.
      update fflu_load_header set load_status = fflu_common.gc_load_status_completed,
        load_complete_time = sysdate
      where load_seq = i_load_sequence;
    else 
      raise_application_error(fflu_common.gc_exception_load,'[load] value [' || i_load_sequence || '], [status] value [' || v_load_status || '] cannot complete load as it is not in the loading status.');
    end if;
    -- Commit any changes.
    commit;
    -- Now wake up the load executor.
    lics_pipe.spray(lics_constant.type_poller,pc_load_executor_group, lics_constant.pipe_wake);
  exception 
    when others then 
      rollback;
      raise;
  end load_complete;

/*******************************************************************************
  NAME:      CALC_ESTIMATED                                              PRIVATE
  PURPOSE:   This function is used by the two monitoring functions to 
             calculate the estimated number of seconds remaining to complete
             the current processing.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------
  1.0   2013-05-30 Chris Horn           Created.
  1.1   2013-06-03 Chris Horn           Revised to make more generic.

*******************************************************************************/
    function calc_estimated(i_row_count in fflu_common.st_size, i_rows_processed in fflu_common.st_size, i_start_time in date) return fflu_common.st_count is
      v_result fflu_common.st_count;
      v_time_taken fflu_common.st_count;
      v_ratio_to_go number(18,9);
    begin
      v_time_taken := (sysdate - nvl(i_start_time,sysdate)) * 60*60*24;
      v_result := (v_time_taken * nvl(i_row_count,1)) / nvl(i_rows_processed,1);
      v_result := v_result - v_time_taken;
      return v_result;
    exception 
      -- If for any reason the calculation overflows, just return 1.  Could happen if someone monitors a job that has been going for a very long time or if
      -- there is a division by zero error.
      when others then 
        return 1; 
    end calc_estimated; 

  
/*******************************************************************************
  NAME:      LOAD_MONITOR                                                 PUBLIC
*******************************************************************************/    
  function load_monitor(
    i_user_code in varchar2,
    i_load_sequence in fflu_common.st_sequence) 
    return tt_load_monitor pipelined is
    rv_monitor rt_load_monitor;  
    rv_header fflu_load_header%rowtype;
    v_load_status fflu_common.st_load_status; 
    v_user_code fflu_common.st_user;
  begin
    -- Check that the header record exists for this load sequence.
    v_load_status := simple_load_seq_check(i_load_sequence);
    -- Check the user code. 
    v_user_code := simple_user_code_check(i_user_code);
    -- Now fetch the load status and validate.
    if v_load_status not in (fflu_common.gc_load_status_completed, fflu_common.gc_load_status_executed) then 
      raise_application_error(fflu_common.gc_exception_load,'[load] value [' || i_load_sequence || '], [status] value [' || v_load_status || '] cannot be monitored as it is not in the completed or executed status.');
    end if;
    -- Now fetch the rest of the header record to calculate the monitor record results. 
    select * into rv_header from fflu_load_header where load_seq = i_load_sequence;
    -- Perform a security check. 
    user_interface_security_check(v_user_code,rv_header.interface_code, get_const_monitor_option);
    -- Now manipulate the row count to prevent division by zero errors.
    if rv_header.row_count is null then 
      rv_header.row_count := 1;
    elsif rv_header.row_count = 0 then 
      rv_header.row_count := 1;
    end if;
    -- Now perform the row calculation and transfer of records.
    rv_monitor.rows_complete := rv_header.row_count_tran; 
    rv_monitor.percent_complete := nvl(rv_header.row_count_tran,0) * 100 / rv_header.row_count; 
    rv_monitor.estimated_time := calc_estimated(rv_header.row_count, rv_header.row_count_tran, rv_header.load_complete_time);
    rv_monitor.load_status := rv_header.load_status;
    rv_monitor.lics_int_sequence := rv_header.lics_header_seq;
    -- Now pipe the single row monitor result status back out. 
    pipe row(rv_monitor);
  end load_monitor;

/*******************************************************************************
  NAME:      LICS_MONITOR                                                 PUBLIC
*******************************************************************************/    
  function lics_monitor(
    i_user_code in varchar2,
    i_xaction_seq in lics_header.hea_header%type) 
    return tt_lics_monitor pipelined is
    rv_monitor rt_lics_monitor;
    v_lics_status fflu_common.st_status; 
    cursor csr_xaction is 
      select 
        t2.HET_STR_TIME as start_time,
        t2.HET_END_TIME as end_time,
        t3.dat_count as row_count,
        t3.dat_seq as rows_complete,
        (select count(t0.hem_msg_seq) from lics_hdr_message t0 where t0.HEM_HEADER = t1.hea_header and t0.HEM_HDR_TRACE = t1.HEA_TRC_COUNT) as int_errors,
        (select count(distinct t0.DAM_DTA_SEQ) from lics_dta_message t0 where t0.dam_header = t1.hea_header and t0.DAM_HDR_TRACE = t1.hea_trc_count) as rows_in_error
      from lics_header t1, lics_hdr_trace t2, fflu_xaction_progress t3
      where 
        t1.hea_header = i_xaction_seq and t1.hea_header = t2.HET_HEADER and 
        t1.HEA_TRC_COUNT = t2.HET_HDR_TRACE and t1.hea_header = t3.lics_header_seq (+);
    rv_xaction csr_xaction%rowtype;
    v_user_code fflu_common.st_user; 
    v_interface fflu_common.st_interface;
begin
    -- Check that the interface sequence number exists.
    v_lics_status := simple_lics_seq_check(i_xaction_seq);
    -- Check the user code is valid.
    v_user_code := simple_user_code_check(i_user_code);
    -- Check the interface code is valid.
    v_interface := lookup_interface_code(i_xaction_seq);
    -- Check that the user security is allowed to carry out this action
    user_interface_security_check(v_user_code,v_interface,get_const_monitor_option);
    -- Return the interface status as a string.
    rv_monitor.lics_status := lookup_header_status(v_lics_status);
    -- Fetch the rest of the details.
    open csr_xaction;
    fetch csr_xaction into rv_xaction;
    close csr_xaction;
    -- Manipulate the row count as required to prevent divsion by zero errors.
    if rv_xaction.row_count is null then 
      rv_xaction.row_count := 1;
    elsif rv_xaction.row_count = 0 then 
      rv_xaction.row_count := 1;
    end if;
    -- Now update the output row details.  
    rv_monitor.rows_complete := rv_xaction.rows_complete;
    rv_monitor.percent_complete := nvl(rv_xaction.rows_complete,0) * 100 / rv_xaction.row_count; 
    if rv_xaction.end_time is not null then 
      rv_monitor.estimated_time := calc_estimated(rv_xaction.row_count, rv_xaction.rows_complete, rv_xaction.start_time);
    else 
      rv_monitor.estimated_time := 0;
    end if; 
    rv_monitor.int_errors := rv_xaction.int_errors;
    rv_monitor.rows_in_error := rv_xaction.rows_in_error;
    -- Now pipe the monitor result out.
    pipe row (rv_monitor);
  end lics_monitor;

/*******************************************************************************
  NAME:      GET_XACTION_STATUS_LIST                                      PUBLIC
*******************************************************************************/  
  -- Pipelined table function to retrieve the transaction status list.
  function get_xaction_status_list return tt_xaction_status_list pipelined is
    rv_row rt_xaction_status_list;
    procedure add_status_row(i_hea_status in lics_header.hea_status%type) is
    begin
      rv_row.xaction_status_code := i_hea_status;
      rv_row.xaction_status_name := lookup_header_status(rv_row.xaction_status_code);
    end add_status_row;
  begin
    -- Now add the special all row.
    rv_row.xaction_status_code := pc_all_status; 
    rv_row.xaction_status_name := get_const_all_code;
    pipe row (rv_row);  
    -- Add each of the various status rows.
    add_status_row(lics_constant.header_load_working);
    pipe row (rv_row);  
    add_status_row(lics_constant.header_load_completed);
    pipe row (rv_row);  
    add_status_row(lics_constant.header_load_completed_error);
    pipe row (rv_row);  
    add_status_row(lics_constant.header_process_working);
    pipe row (rv_row);  
    add_status_row(lics_constant.header_process_working_error);
    pipe row (rv_row);  
    add_status_row(lics_constant.header_process_completed);
    pipe row (rv_row);  
    add_status_row(lics_constant.header_process_completed_error);
    pipe row (rv_row);  
  end get_xaction_status_list;

/*******************************************************************************
  NAME:      GET_XACTION_COUNT                                            PUBLIC
*******************************************************************************/  
  function get_xaction_count (
    i_user_code in varchar2,
    i_interface_group_code in varchar2,
    i_interface_code in varchar2, 
    i_interface_type_code in varchar2, 
    i_xaction_seq in fflu_common.st_sequence,
    i_xaction_status_code in fflu_common.st_status,
    i_start_datetime in date,
    i_end_datetime in date
  ) return fflu_common.st_count is
    v_count fflu_common.st_count;
    v_user_code fflu_common.st_user;
  begin
    -- Check the user code is valid.
    v_user_code := simple_user_code_check(i_user_code);
    -- Now perform the count.
    select count(*) as xaction_count into v_count
    from 
      lics_header t1, 
      lics_hdr_trace t2,
      -- Filter the list of interfaces to those interfaces this user is allowed to monitor.
      (select * from lics_interface t0 where exists (select * from table(get_user_interface_options(v_user_code)) t00 where t00.interface_code = t0.int_interface and t00.option_code = get_const_monitor_option)) t3
    where 
      t1.hea_header = t2.HET_HEADER and 
      t1.HEA_TRC_COUNT = t2.HET_HDR_TRACE and 
      t1.hea_interface = t3.int_interface and
      (t1.hea_header = i_xaction_seq or i_xaction_seq is null) and 
      (t1.hea_interface = i_interface_code or i_interface_code is null) and
      (t3.int_type = i_interface_type_code or i_interface_type_code is null) and 
      (t1.hea_status = i_xaction_status_code or i_xaction_status_code is null) and 
      (t2.het_str_time >= i_start_datetime or i_start_datetime is null) and 
      (t2.het_end_time <= i_end_datetime or i_end_datetime is null) and
      (i_interface_group_code is null or exists (
        select * 
          from lics_grp_interface t0 
        where 
          t0.gri_group = i_interface_group_code and 
          t0.gri_interface = t1.hea_interface
       ));
    return v_count;
  end get_xaction_count;

/*******************************************************************************
  NAME:      GET_XACTION_LIST                                             PUBLIC
*******************************************************************************/  
  -- Pipelined table function for returning the interface transaction records.
  function get_xaction_list(
    i_user_code in varchar2,
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
    v_user_code fflu_common.st_user;
    cursor csr_xaction_list_data is 
      select t20.*,
      (select count(*) from lics_data t0 where t0.dat_header = t20.xaction_seq) as xaction_row_count,
      (select count(distinct t0.DAM_DTA_SEQ) from lics_dta_message t0 where t0.dam_header = t20.xaction_seq and t0.DAM_HDR_TRACE = t20.xaction_trace_seq) as xaction_rows_in_error,
      (select count(*) from lics_dta_message t0 where t0.dam_header = t20.xaction_seq and t0.DAM_HDR_TRACE = t20.xaction_trace_seq) as xaction_row_errors,
      (select count(*) from lics_hdr_message t0 where t0.hem_header = t20.xaction_seq and t0.HEM_HDR_TRACE = t20.xaction_trace_seq) as xaction_int_errors
    from (
      select t10.*, rownum as row_num from (
        select 
          t1.hea_header as xaction_seq,
          t1.hea_trc_count as xaction_trace_seq,
          t1.hea_fil_name as xaction_filename,
          t2.het_user as xaction_user_code,
          t1.hea_interface as xaction_interface_code,
          t3.int_description as xaction_interface_name,
          t3.int_procedure as interface_package,
          t2.het_str_time as xaction_start_datetime,
          t2.het_end_time as xaction_end_datetime,
          t1.hea_status as status_code
        from 
          lics_header t1, 
          lics_hdr_trace t2,
          -- Filter the list of interfaces to those interfaces this user is allowed to monitor.
          (select * from lics_interface t0 where exists (select * from table(get_user_interface_options(v_user_code)) t00 where t00.interface_code = t0.int_interface and t00.option_code = get_const_monitor_option)) t3
        where 
          t1.hea_header = t2.het_header and 
          t1.hea_trc_count = t2.het_hdr_trace and 
          t1.hea_interface = t3.int_interface and
          (t1.hea_header = i_xaction_seq or i_xaction_seq is null) and 
          (t1.hea_interface = i_interface_code or i_interface_code is null) and
          (t3.int_type = i_interface_type_code or i_interface_type_code is null) and 
          (t1.hea_status = i_xaction_status_code or i_xaction_status_code is null) and 
          (t2.het_str_time >= i_start_datetime or i_start_datetime is null) and 
          (t2.het_end_time <= i_end_datetime or i_end_datetime is null) and
          (i_interface_group_code is null or exists (
            select * 
              from lics_grp_interface t0 
            where 
              t0.gri_group = i_interface_group_code and 
              t0.gri_interface = t1.hea_interface
           ))
           order by t1.hea_header desc
           ) t10 where rownum < i_start_row + i_no_rows
         ) t20 where row_num >= i_start_row;
       rv_xaction_list_data csr_xaction_list_data%rowtype;
       rv_xaction_list rt_xaction_list;
  begin
    -- Check the user code is valid.
    v_user_code := simple_user_code_check(i_user_code);
    -- Now fetch the user data.
    open csr_xaction_list_data;
    loop
      fetch csr_xaction_list_data into rv_xaction_list_data;
      exit when csr_xaction_list_data%notfound;
      -- Now process each row of data.
      rv_xaction_list.xaction_seq := rv_xaction_list_data.xaction_seq;
      rv_xaction_list.xaction_trace_seq := rv_xaction_list_data.xaction_trace_seq;
      rv_xaction_list.xaction_filename := rv_xaction_list_data.xaction_filename;
      rv_xaction_list.xaction_user_code := rv_xaction_list_data.xaction_user_code;
      rv_xaction_list.xaction_interface_code := rv_xaction_list_data.xaction_interface_code;
      rv_xaction_list.xaction_interface_name := rv_xaction_list_data.xaction_interface_name;
      rv_xaction_list.xaction_start_datetime := rv_xaction_list_data.xaction_start_datetime;
      rv_xaction_list.xaction_end_datetime := rv_xaction_list_data.xaction_end_datetime;
      rv_xaction_list.xaction_status := lookup_header_status(rv_xaction_list_data.status_code);
      rv_xaction_list.xaction_row_count := rv_xaction_list_data.xaction_row_count;
      rv_xaction_list.xaction_rows_in_error := rv_xaction_list_data.xaction_rows_in_error;
      rv_xaction_list.xaction_row_errors := rv_xaction_list_data.xaction_row_errors;
      rv_xaction_list.xaction_int_errors := rv_xaction_list_data.xaction_int_errors;
      -- Now perform a get file type interface callbacks to determine file types and csv qualifiers. 
      declare
        v_filetype fflu_common.st_filetype;
      begin
        execute immediate 'begin :v_filetype := ' || rv_xaction_list_data.interface_package ||'.on_get_file_type; end;' USING OUT v_filetype;
        rv_xaction_list.xaction_filetype := v_filetype;
      exception 
        when others then 
          rv_xaction_list.xaction_filetype := null;
      end;
      declare 
        v_qualifier fflu_common.st_qualifier;
      begin
        execute immediate 'begin :v_qualifier := ' || rv_xaction_list_data.interface_package ||'.on_get_csv_qualifier; end;' USING OUT v_qualifier;
        rv_xaction_list.xaction_csv_qualifier := v_qualifier;
      exception 
        when others then 
          rv_xaction_list.xaction_csv_qualifier := null; 
      end;
      -- Pipe that row into the output.
      pipe row (rv_xaction_list);
    end loop;
    close csr_xaction_list_data;
  end get_xaction_list;

/*******************************************************************************
  NAME:      GET_XACTION_TRACE_LIST                                       PUBLIC
*******************************************************************************/  
  -- Pipelined table function for returning each of the trace records for an interface
  function get_xaction_trace_list ( 
    i_user_code in varchar2,
    i_xaction_seq in fflu_common.st_sequence
  ) return tt_xaction_list pipelined is
    cursor csr_xaction_list_data is 
      select 
        t1.hea_header as xaction_seq,
        t2.het_hdr_trace as xaction_trace_seq,
        t1.hea_fil_name as xaction_filename,
        t2.het_user as xaction_user_code,
        t1.hea_interface as xaction_interface_code,
        t3.int_description as xaction_interface_name,
        t3.int_procedure as interface_package,
        t2.het_str_time as xaction_start_datetime,
        t2.het_end_time as xaction_end_datetime,
        t1.hea_status as status_code,
        (select count(*) from lics_data t0 where t0.dat_header = t1.hea_header) as xaction_row_count,
        (select count(distinct t0.DAM_DTA_SEQ) from lics_dta_message t0 where t0.dam_header = t1.hea_header and t0.DAM_HDR_TRACE = t2.het_hdr_trace) as xaction_rows_in_error,
        (select count(*) from lics_dta_message t0 where t0.dam_header = t1.hea_header and t0.DAM_HDR_TRACE = t2.het_hdr_trace) as xaction_row_errors,
        (select count(*) from lics_hdr_message t0 where t0.hem_header = t1.hea_header and t0.HEM_HDR_TRACE = t2.het_hdr_trace) as xaction_int_errors
      from 
        lics_header t1, 
        lics_hdr_trace t2,
        lics_interface t3
      where 
        t1.hea_header = t2.het_header and 
        t1.hea_header = i_xaction_seq and 
        t2.het_hdr_trace <= t1.hea_trc_count and 
        t1.hea_interface = t3.int_interface 
    order by t2.het_hdr_trace desc;
    rv_xaction_list_data csr_xaction_list_data%rowtype;
    rv_xaction_list rt_xaction_list;
    v_lics_status fflu_common.st_status;
    v_user_code fflu_common.st_user; 
    v_interface fflu_common.st_interface;
  begin
    -- Check the header sequence exists.
    v_lics_status := simple_lics_seq_check(i_xaction_seq);
    -- Check the user code is valid.
    v_user_code := simple_user_code_check(i_user_code);
    -- Check the interface code is valid.
    v_interface := lookup_interface_code(i_xaction_seq);
    -- Check that the user security is allowed to carry out this action
    user_interface_security_check(v_user_code,v_interface,get_const_monitor_option);
    -- Now fetch the xaction list data.
    open csr_xaction_list_data;
    loop
      fetch csr_xaction_list_data into rv_xaction_list_data;
      exit when csr_xaction_list_data%notfound;
      -- Now process each row of data.
      rv_xaction_list.xaction_seq := rv_xaction_list_data.xaction_seq;
      rv_xaction_list.xaction_trace_seq := rv_xaction_list_data.xaction_trace_seq;
      rv_xaction_list.xaction_filename := rv_xaction_list_data.xaction_filename;
      rv_xaction_list.xaction_user_code := rv_xaction_list_data.xaction_user_code;
      rv_xaction_list.xaction_interface_code := rv_xaction_list_data.xaction_interface_code;
      rv_xaction_list.xaction_interface_name := rv_xaction_list_data.xaction_interface_name;
      rv_xaction_list.xaction_start_datetime := rv_xaction_list_data.xaction_start_datetime;
      rv_xaction_list.xaction_end_datetime := rv_xaction_list_data.xaction_end_datetime;
      rv_xaction_list.xaction_status := lookup_header_status(rv_xaction_list_data.status_code);
      rv_xaction_list.xaction_row_count := rv_xaction_list_data.xaction_row_count;
      rv_xaction_list.xaction_rows_in_error := rv_xaction_list_data.xaction_rows_in_error;
      rv_xaction_list.xaction_row_errors := rv_xaction_list_data.xaction_row_errors;
      rv_xaction_list.xaction_int_errors := rv_xaction_list_data.xaction_int_errors;
      -- Now perform a get file type interface callbacks to determine file types and csv qualifiers. 
      declare
        v_filetype fflu_common.st_filetype;
      begin
        execute immediate 'begin :v_filetype := ' || rv_xaction_list_data.interface_package ||'.on_get_file_type; end;' USING OUT v_filetype;
        rv_xaction_list.xaction_filetype := v_filetype;
      exception 
        when others then 
          rv_xaction_list.xaction_filetype := null;
      end;
      declare 
        v_qualifier fflu_common.st_qualifier;
      begin
        execute immediate 'begin :v_qualifier := ' || rv_xaction_list_data.interface_package ||'.on_get_csv_qualifier; end;' USING OUT v_qualifier;
        rv_xaction_list.xaction_csv_qualifier := v_qualifier;
      exception 
        when others then 
          rv_xaction_list.xaction_csv_qualifier := null; 
      end;
      -- Pipe that row into the output.
      pipe row (rv_xaction_list);
    end loop;
    close csr_xaction_list_data;
  end get_xaction_trace_list;

/*******************************************************************************
  NAME:      GET_XACTION_DATA                                             PUBLIC
*******************************************************************************/  
  function get_xaction_data (
    i_user_code in varchar2,
    i_xaction_seq in fflu_common.st_sequence, 
    i_xaction_trace_seq in fflu_common.st_trace,
    i_start_row in fflu_common.st_count,
    i_no_rows in fflu_common.st_count) return tt_xaction_data pipelined is
    cursor csr_xaction_data is 
      select 
        dat_dta_seq as xaction_row,
        dat_record as xaction_data,
        (select count(*) from lics_dta_message t0 where t0.dam_header = t1.dat_header and t0.dam_hdr_trace = i_xaction_trace_seq) as xaction_errors
      from lics_data t1
      where
        t1.dat_header = i_xaction_seq and t1.dat_dta_seq between i_start_row and i_start_row + i_no_rows - 1
      order by 
        t1.dat_dta_seq asc;
    rv_xaction_csr_data csr_xaction_data%rowtype;
    rv_xaction_data rt_xaction_data;
    v_lics_status fflu_common.st_status;
    v_user_code fflu_common.st_user; 
    v_interface fflu_common.st_interface;
  begin
    -- Check the header sequence exists.
    v_lics_status := simple_lics_seq_check(i_xaction_seq);
    -- Check the user code is valid.
    v_user_code := simple_user_code_check(i_user_code);
    -- Check the interface code is valid.
    v_interface := lookup_interface_code(i_xaction_seq);
    -- Check that the user security is allowed to carry out this action
    user_interface_security_check(v_user_code,v_interface,get_const_monitor_option);
    -- Check that the interface trace is valid.
    simple_lics_seq_trace_check(i_xaction_seq,i_xaction_trace_seq);
    -- Now fetch the data and return it to the client.
    open csr_xaction_data;
    loop
      fetch csr_xaction_data into rv_xaction_csr_data;
      exit when csr_xaction_data%notfound;
      -- Now process each row of data.
      rv_xaction_data.xaction_row := rv_xaction_csr_data.xaction_row;
      rv_xaction_data.xaction_data := rv_xaction_csr_data.xaction_data;
      rv_xaction_data.xaction_errors := rv_xaction_csr_data.xaction_errors;
      -- Pipe that row into the output.
      pipe row (rv_xaction_data);
    end loop;
    close csr_xaction_data;
  end get_xaction_data;

/*******************************************************************************
  NAME:      GET_XACTION_DATA_WITH_ERRORS                                 PUBLIC
*******************************************************************************/  
  function get_xaction_data_with_errors (
    i_user_code in varchar2,
    i_xaction_seq in fflu_common.st_sequence,
    i_xaction_trace_seq in fflu_common.st_trace,
    i_start_row in fflu_common.st_count,
    i_no_rows in fflu_common.st_count) return tt_xaction_data pipelined is
    cursor csr_xaction_data is 
      select t20.*
      from (
        select 
          t10.*, rownum as row_num 
        from (
          select 
            dat_dta_seq as xaction_row,
            dat_record as xaction_data,
            (select count(*) from lics_dta_message t0 where t0.dam_header = t1.dat_header and t0.dam_hdr_trace = i_xaction_trace_seq) as xaction_errors
          from lics_data t1
          where
            t1.dat_header = i_xaction_seq and 
            exists (select * from lics_dta_message t0 where t0.dam_header = t1.dat_header and t0.dam_hdr_trace = i_xaction_trace_seq and t0.dam_dta_seq = t1.dat_dta_seq)
          order by 
            t1.dat_dta_seq asc
        ) t10 where rownum < i_start_row + i_no_rows
      ) t20 where row_num >= i_start_row;
    rv_xaction_csr_data csr_xaction_data%rowtype;
    rv_xaction_data rt_xaction_data;
    v_lics_status fflu_common.st_status;
    v_user_code fflu_common.st_user; 
    v_interface fflu_common.st_interface;
  begin
    -- Check the header sequence exists.
    v_lics_status := simple_lics_seq_check(i_xaction_seq);
    -- Check the user code is valid.
    v_user_code := simple_user_code_check(i_user_code);
    -- Check the interface code is valid.
    v_interface := lookup_interface_code(i_xaction_seq);
    -- Check that the user security is allowed to carry out this action
    user_interface_security_check(v_user_code,v_interface,get_const_monitor_option);
    -- Check that the interface trace is valid.
    simple_lics_seq_trace_check(i_xaction_seq,i_xaction_trace_seq);
    -- Now fetch the data and return it to the client.
    open csr_xaction_data;
    loop
      fetch csr_xaction_data into rv_xaction_csr_data;
      exit when csr_xaction_data%notfound;
      -- Now process each row of data.
      rv_xaction_data.xaction_row := rv_xaction_csr_data.xaction_row;
      rv_xaction_data.xaction_data := rv_xaction_csr_data.xaction_data;
      rv_xaction_data.xaction_errors := rv_xaction_csr_data.xaction_errors;
      -- Pipe that row into the output.
      pipe row (rv_xaction_data);
    end loop;
    close csr_xaction_data;
  end get_xaction_data_with_errors;
  

/*******************************************************************************
  NAME:      GET_XACTION_ERRORS                                           PUBLIC
*******************************************************************************/  
  function get_xaction_errors (
    i_user_code in varchar2,
    i_xaction_seq fflu_common.st_sequence,
    i_xaction_trace_seq fflu_common.st_trace
  ) return tt_xaction_errors pipelined is
    cursor csr_xaction_errors is 
      select
        hem_msg_seq as xaction_msg_seq,
        hem_text as xaction_msg
      from 
        lics_hdr_message t1
      where
        t1.hem_header = i_xaction_seq and t1.hem_hdr_trace = i_xaction_trace_seq 
      order by
        t1.hem_msg_seq;
    rv_xaction_csr_error csr_xaction_errors%rowtype;
    rv_xaction_error rt_xaction_error;
    v_lics_status fflu_common.st_status;
    v_user_code fflu_common.st_user; 
    v_interface fflu_common.st_interface;
  begin
    -- Check the header sequence exists.
    v_lics_status := simple_lics_seq_check(i_xaction_seq);
    -- Check the user code is valid.
    v_user_code := simple_user_code_check(i_user_code);
    -- Check the interface code is valid.
    v_interface := lookup_interface_code(i_xaction_seq);
    -- Check that the user security is allowed to carry out this action
    user_interface_security_check(v_user_code,v_interface,get_const_monitor_option);
    -- Check that the interface trace is valid.
    simple_lics_seq_trace_check(i_xaction_seq,i_xaction_trace_seq);
    -- Now fetch the data and return it to the client.
    open csr_xaction_errors;
    loop
      fetch csr_xaction_errors into rv_xaction_csr_error;
      exit when csr_xaction_errors%notfound;
      -- Now process each row of data.
      rv_xaction_error.xaction_msg_seq := rv_xaction_csr_error.xaction_msg_seq;
      rv_xaction_error.xaction_msg := rv_xaction_csr_error.xaction_msg;
      -- Pipe that row into the output.
      pipe row (rv_xaction_error);
    end loop;
    close csr_xaction_errors;
  end get_xaction_errors;


/*******************************************************************************
  NAME:      GET_XACTION_DATA_ERRORS_BY_PGE                               PUBLIC
*******************************************************************************/  
  function get_xaction_data_errors_by_pge (
    i_user_code in varchar2,
    i_xaction_seq fflu_common.st_sequence,
    i_xaction_trace_seq fflu_common.st_trace,
    i_from_data_row fflu_common.st_count,
    i_to_data_row fflu_common.st_count
    ) return tt_xaction_data_errors pipelined is
    cursor csr_xaction_data_errors is 
      select 
        t1.dam_dta_seq as xaction_data_row, 
        t1.dam_msg_seq as xaction_msg_seq,
        t1.dam_text as xaction_msg 
      from 
        lics_dta_message t1
      where 
        t1.dam_header = i_xaction_seq and
        t1.dam_hdr_trace = i_xaction_trace_seq and 
        t1.dam_dta_seq between i_from_data_row and i_to_data_row
      order by
        t1.dam_dta_seq, t1.dam_msg_seq;
    rv_xaction_data_csr_error csr_xaction_data_errors%rowtype;
    rv_xaction_data_error rt_xaction_data_error;
    v_lics_status fflu_common.st_status;
    v_user_code fflu_common.st_user; 
    v_interface fflu_common.st_interface;
  begin
    -- Check the header sequence exists.
    v_lics_status := simple_lics_seq_check(i_xaction_seq);
    -- Check the user code is valid.
    v_user_code := simple_user_code_check(i_user_code);
    -- Check the interface code is valid.
    v_interface := lookup_interface_code(i_xaction_seq);
    -- Check that the user security is allowed to carry out this action
    user_interface_security_check(v_user_code,v_interface,get_const_monitor_option);
    -- Check that the interface trace is valid.
    simple_lics_seq_trace_check(i_xaction_seq,i_xaction_trace_seq);
    -- Now fetch the data and return it to the client.
    open csr_xaction_data_errors;
    loop
      fetch csr_xaction_data_errors into rv_xaction_data_csr_error;
      exit when csr_xaction_data_errors%notfound;
      -- Now process each row of data.
      rv_xaction_data_error.xaction_data_row := rv_xaction_data_csr_error.xaction_data_row;
      rv_xaction_data_error.xaction_msg_seq := rv_xaction_data_csr_error.xaction_msg_seq;
      rv_xaction_data_error.xaction_msg := rv_xaction_data_csr_error.xaction_msg;
      -- Pipe that row into the output.
      pipe row (rv_xaction_data_error);
    end loop;
    close csr_xaction_data_errors;
  end get_xaction_data_errors_by_pge;
  
/*******************************************************************************
  NAME:      GET_XACTION_DATA_ERRORS_BY_ROW                               PUBLIC
*******************************************************************************/  
  function get_xaction_data_errors_by_row (
    i_user_code in varchar2,
    i_xaction_seq fflu_common.st_sequence,
    i_xaction_trace_seq fflu_common.st_trace,
    i_start_row in fflu_common.st_count,
    i_no_rows in fflu_common.st_count
    ) return tt_xaction_data_errors pipelined is
    cursor csr_xaction_data_errors is 
      select 
        t20.* 
      from (
        select t10.*, rownum as row_num 
        from (
          select 
            t1.dam_dta_seq as xaction_data_row, 
            t1.dam_msg_seq as xaction_msg_seq,
            t1.dam_text as xaction_msg 
          from 
            lics_dta_message t1
          where 
            t1.dam_header = i_xaction_seq and
            t1.dam_hdr_trace = i_xaction_trace_seq 
          order by
            t1.dam_dta_seq, t1.dam_msg_seq  
        ) t10 where rownum < i_start_row + i_no_rows
      ) t20 where row_num >= i_start_row;
    rv_xaction_data_csr_error csr_xaction_data_errors%rowtype;
    rv_xaction_data_error rt_xaction_data_error;
    v_lics_status fflu_common.st_status;
    v_user_code fflu_common.st_user; 
    v_interface fflu_common.st_interface;
  begin
    -- Check the header sequence exists.
    v_lics_status := simple_lics_seq_check(i_xaction_seq);
    -- Check the user code is valid.
    v_user_code := simple_user_code_check(i_user_code);
    -- Check the interface code is valid.
    v_interface := lookup_interface_code(i_xaction_seq);
    -- Check that the user security is allowed to carry out this action
    user_interface_security_check(v_user_code,v_interface,get_const_monitor_option);
    -- Check that the interface trace is valid.
    simple_lics_seq_trace_check(i_xaction_seq,i_xaction_trace_seq);
    -- Now fetch the data and return it to the client.
    open csr_xaction_data_errors;
    loop
      fetch csr_xaction_data_errors into rv_xaction_data_csr_error;
      exit when csr_xaction_data_errors%notfound;
      -- Now process each row of data.
      rv_xaction_data_error.xaction_data_row := rv_xaction_data_csr_error.xaction_data_row;
      rv_xaction_data_error.xaction_msg_seq := rv_xaction_data_csr_error.xaction_msg_seq;
      rv_xaction_data_error.xaction_msg := rv_xaction_data_csr_error.xaction_msg;
      -- Pipe that row into the output.
      pipe row (rv_xaction_data_error);
    end loop;
    close csr_xaction_data_errors;
  end get_xaction_data_errors_by_row;

  
/*******************************************************************************
  NAME:      REPROCESS_INTERFACE                                          PUBLIC
*******************************************************************************/    
  procedure reprocess_interface(
    i_user_code in varchar2,
    i_xaction_seq in fflu_common.st_sequence,
    i_interface_code in varchar2) is
    v_lics_status fflu_common.st_status;
    v_interface_code fflu_common.st_interface;
    v_user_code fflu_common.st_user;
    v_return_code fflu_common.st_string;
  begin
    -- Check the header sequence exists.
    v_lics_status := simple_lics_seq_check(i_xaction_seq);
    -- Check the user code is valid.
    v_user_code := simple_user_code_check(i_user_code);
    -- Check the interface code is valid.
    v_interface_code := simple_interface_code_check(i_interface_code);
    -- Check that the user security is allowed to carry out this action
    user_interface_security_check(v_user_code,v_interface_code,get_const_process_option);
    -- Now add an entry to the reprocess user code writeback table so we can track the user that reprossed this interface.
    insert into fflu_xaction_writeback (lics_header_seq, user_code, last_updtd_time) values (i_xaction_seq,i_user_code, sysdate);
    commit;
    -- Now perform the update of the interface to start it reprocessing. 
    -- Ignore Return code, only ever returns *OK or an exception. 
    v_return_code := lics_interface_process.update_status(i_xaction_seq);
  end reprocess_interface;
  
end fflu_api;