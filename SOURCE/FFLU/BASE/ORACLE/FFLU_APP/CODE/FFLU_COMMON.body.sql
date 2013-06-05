create or replace 
PACKAGE BODY FFLU_COMMON AS 

/*******************************************************************************
** Package Constants
*******************************************************************************/
  -- Package Name
  pc_package_name          constant fflu_common.st_name := 'FFLU_COMMON';
  -- Days to keep load data for any load.
  pc_load_data_history     constant fflu_common.st_count := 2;

/*******************************************************************************
** Package Exceptions
*******************************************************************************/
  pe_exception_housekeeping   exception;
  
  pragma exception_init(pe_exception_housekeeping, -20009);


/*******************************************************************************
  NAME:      VALIDATE_NON_EMPTY_STRING                                    PUBLIC
*******************************************************************************/
  procedure validate_non_empty_string(i_exception_code in st_exception_code, i_string in st_string, i_name in st_name) is
  begin
    if i_string is null then 
      raise_application_error(i_exception_code,'['||i_name || '] cannot be EMPTY / NULL');
    end if;
  end validate_non_empty_string;

/*******************************************************************************
  NAME:      VALIDATE_STRING_LENGTH                                       PUBLIC
*******************************************************************************/
  procedure validate_string_length(i_exception_code in st_exception_code, i_string in st_string, i_min_len in st_size, i_max_len in st_size, i_name in st_name) is
  begin
    if lengthb(i_string) < i_min_len then 
      raise_application_error(i_exception_code,'[' ||i_name || '] value [' || i_string || '] length [' || lengthb(i_string) ||'] cannot be less than ' || i_min_len || ' characters.'); 
    end if;
    if lengthb(i_string) > i_max_len then 
      raise_application_error(i_exception_code,'[' ||i_name || '] value [' || i_string || '] length [' || lengthb(i_string) ||'] cannot be greater than ' || i_max_len || ' characters.'); 
    end if;
  end validate_string_length;

/*******************************************************************************
  NAME:      SQLERROR_STRING                                              PUBLIC
*******************************************************************************/
  function sqlerror_string(i_message in varchar2) return st_string is
  begin
    return substrb(i_message || ' : ' || SQLERRM, 1, 4000);
  end sqlerror_string;


/*******************************************************************************
  NAME:      LOAD_EXECUTE                                                 PUBLIC
*******************************************************************************/    
  procedure load_execute is
    cursor csr_completed_loads is
      select 
        t1.load_seq, 
        t1.interface_code, 
        t1.load_status
      from fflu_load_header t1
      where t1.load_status = gc_load_status_completed;
    rv_load csr_completed_loads%rowtype;
    v_finished boolean;
    v_lock_name fflu_common.st_string;
    v_locked boolean;
    -- Copy the data out of the load staging table into the lics tables.
    procedure transfer_data is
    begin
      null;
    end transfer_data;
    -- Now perform the lics execution spray to wake up the inbound processors.
    procedure execute_interface is
    begin
      null;
    end execute_interface;
  begin
    -- Start the Job Logging
    v_lock_name := 'FFLU_LOAD_EXECUTE';
    
    lics_logging.start_log('Flat File Loading Utility',v_lock_name);
    -- Request the Lock To Perform The House Keeping
    v_locked := false;
    begin
      lics_locking.request(v_lock_name);
      v_locked := true;
    exception
      when others then
        lics_logging.write_log(fflu_common.sqlerror_string('Failed requesting lock ['||v_lock_name||']'));
    end;

    -- If we have the lock then carry out the house keeping
    if v_locked = true then
      lics_logging.write_log('Scanning Loading Header Table for Completed Loads.');
      -- Now scan the load header table and look for any completed interfaces
      loop 
        open csr_completed_loads;
        fetch csr_completed_loads into rv_load;
        if csr_completed_loads%notfound then 
          v_finished := true;
        end if;
        close csr_completed_loads;
        exit when v_finished = true;
        -- Since we must have a completed load at this point commence the the 
        -- process of execution. 
        lics_logging.write_log('* Processing Load Data for Load Sequence : ' || rv_load.load_seq || ', Interface : ' || rv_load.interface_code);
        begin
          transfer_data;
          lics_logging.write_log('* Successfully Loaded Data for Load Sequence : ' || rv_load.load_seq || ', Interface : ' || rv_load.interface_code);
          execute_interface;
          lics_logging.write_log('* Successfully Executed Interface for Load Sequence : ' || rv_load.load_seq || ', Interface : ' || rv_load.interface_code);
          update fflu_load_header set load_status = gc_load_status_executed where load_seq = rv_load.load_seq;
        exception 
          -- Now mark the job as errored.
          when others then 
            lics_logging.write_log(fflu_common.sqlerror_string('* Error whilst processing Load Sequence : ' || rv_load.load_seq || ', Interface : ' || rv_load.interface_code));
            rollback;
            -- Now update the header table as errored.
            update fflu_load_header set load_status = gc_load_status_errored where load_seq = rv_load.load_seq;
            commit;
        end;
      end loop;
       -- Release the Lock.
      lics_locking.release(v_lock_name);
    else
      -- Lock was already held.
      lics_logging.write_log('Lock already held on ['||v_lock_name||']');
    end if;
    -- End Logging
    lics_logging.end_log;
  exception
    when others then
      raise_application_error(fflu_common.gc_exception_load, fflu_common.sqlerror_string('['||pc_package_name||'.load_execute]'));
  end load_execute;

/*******************************************************************************
  NAME:      PERFORM_HOUSEKEEPING                                         PUBLIC
*******************************************************************************/    
  procedure perform_housekeeping is
    v_lock_name fflu_common.st_string;
    v_locked boolean;
    
    cursor csr_loads is 
      select
        t1.load_seq, 
        t1.load_status, 
        t1.load_start_time, 
        t2.int_hdr_history
      from 
        fflu_load_header t1,
        lics_interface t2
      where 
        t1.interface_code = t2.int_interface (+);
    rv_load csr_loads%rowtype;
    -- Types and variables to track the list of loads to be deleted.
    type t_loads is table of fflu_common.st_sequence 
      index by fflu_common.st_size;
    tv_data t_loads;
    tv_headers t_loads;
    v_counter fflu_common.st_size; 
    v_days_to_keep fflu_common.st_count;
  begin
    -- Start the Job Logging
    v_lock_name := 'FFLU_HOUSEKEEPING';
    
    lics_logging.start_log('Flat File Loading Utility',v_lock_name);
    -- Request the Lock To Perform The House Keeping
    v_locked := false;
    begin
      lics_locking.request(v_lock_name);
      v_locked := true;
    exception
      when others then
        lics_logging.write_log(fflu_common.sqlerror_string('Failed requesting lock ['||v_lock_name||']'));
    end;

    -- If we have the lock then carry out the house keeping
    if v_locked = true then
      -- Perform the house keeping.
      lics_logging.write_log('Checking Loads For Housekeeping.');
      open csr_loads;
      loop 
        fetch csr_loads into rv_load;
        exit when csr_loads%notfound;
        -- Now check if the load is two days old.
        if rv_load.load_start_time < sysdate - pc_load_data_history then 
          tv_data(tv_data.count + 1) := rv_load.load_seq;
        end if;
        -- Now check if the header record should be deleted.
        v_days_to_keep := pc_load_data_history; 
        if rv_load.int_hdr_history is not null then
          if rv_load.int_hdr_history > v_days_to_keep then 
            v_days_to_keep := rv_load.int_hdr_history;
          end if;
        end if;
        if rv_load.load_start_time < sysdate - v_days_to_keep then 
          tv_headers(tv_headers.count + 1) := rv_load.load_seq;
        end if;
      end loop;
      close csr_loads;
      
      -- Now perform the data deletions.
      lics_logging.write_log('Deleting Load Data Records.');
      v_counter := 1;
      loop
        exit when v_counter > tv_data.count; 
        lics_logging.write_log('* Deleteing Load Data Records of Load : ' || tv_data(v_counter));
        delete fflu_load_data where load_seq = tv_data(v_counter);
        commit;
        v_counter := v_counter + 1;
      end loop;
      
      -- Now perform the header deletions.
      lics_logging.write_log('Deleteing Load Header Records.');
      v_counter := 1;
      loop
        exit when v_counter > tv_headers.count;
        lics_logging.write_log('* Deleteing Load Header Record of Load : ' || tv_headers(v_counter));
        delete fflu_load_data where load_seq = tv_headers(v_counter);
        delete fflu_load_header where load_seq = tv_headers(v_counter);
        commit;
        v_counter := v_counter + 1;
      end loop;
      
      lics_logging.write_log('Deleting old Tranaction Progress Records.');
      delete from fflu_xaction_progress where last_updtd_time < sysdate - pc_load_data_history;
      commit;

      -- Release the Lock.
      lics_locking.release(v_lock_name);
    else
      -- Lock was already held.
      lics_logging.write_log('Lock already held on ['||v_lock_name||']');
    end if;

    -- End Logging
    lics_logging.end_log;
  exception
    when others then
      raise_application_error(gc_exception_housekeeping, fflu_common.sqlerror_string('['||pc_package_name||'.perform_housekeeping]'));
  end perform_housekeeping;

END fflu_common;