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
    if nvl(lengthb(i_string),0) < i_min_len then 
      raise_application_error(i_exception_code,'[' ||i_name || '] value [' || i_string || '] length [' || nvl(lengthb(i_string),0) ||'] cannot be less than ' || i_min_len || ' characters.'); 
    end if;
    if nvl(lengthb(i_string),0) > i_max_len then 
      raise_application_error(i_exception_code,'[' ||i_name || '] value [' || i_string || '] length [' || nvl(lengthb(i_string),0) ||'] cannot be greater than ' || i_max_len || ' characters.'); 
    end if;
  end validate_string_length;

/*******************************************************************************
  NAME:      SQLERROR_STRING                                              PUBLIC
*******************************************************************************/
  function sqlerror_string(i_message in varchar2) return st_string is
  begin
    -- Note the replace to Oracle is done so that the code in the flu front end doesn't remove it.  
    return substrb(i_message || ' : [' || replace(SQLERRM,'ORA-','Oracle-') || ']', 1, 4000);  
  end sqlerror_string;


/*******************************************************************************
  NAME:      LOAD_EXECUTE                                                 PUBLIC
*******************************************************************************/    
  procedure load_execute is
    cursor csr_completed_loads is
      select 
        t1.load_seq, 
        t1.interface_code, 
        t1.load_status, 
        t1.user_code,
        t1.file_name,
        t1.lics_header_seq
      from fflu_load_header t1
      where t1.load_status = gc_load_status_completed;
    rv_load csr_completed_loads%rowtype;
    v_finished boolean;
    v_lock_name fflu_common.st_string;
    v_locked boolean;

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_lics_interface lics_interface%rowtype;
   rcd_lics_header lics_header%rowtype;
   rcd_lics_hdr_trace lics_hdr_trace%rowtype;
   rcd_lics_hdr_message lics_hdr_message%rowtype;
   var_hdr_message lics_hdr_message.hem_msg_seq%type;

   /************************************************************/
   /* This procedure performs the add header exception routine */
   /************************************************************/
   procedure add_header_exception(par_exception in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Update the header status when required
      /* note - header_load_working_error
      /*-*/
      if rcd_lics_header.hea_status = lics_constant.header_load_working then
         rcd_lics_header.hea_status := lics_constant.header_load_working_error;
         update lics_header
            set hea_status = rcd_lics_header.hea_status
          where hea_header = rcd_lics_header.hea_header;
         if sql%notfound then
            raise_application_error(-20000, 'Add Header Exception - Header (' || to_char(rcd_lics_header.hea_header,'FM999999999999990') || ') does not exist');
         end if;
      end if;

      /*-*/
      /* Update the header trace status when required
      /* note - header_load_working_error
      /*-*/
      if rcd_lics_hdr_trace.het_status = lics_constant.header_load_working then
         rcd_lics_hdr_trace.het_status := lics_constant.header_load_working_error;
         update lics_hdr_trace
            set het_status = rcd_lics_hdr_trace.het_status
          where het_header = rcd_lics_hdr_trace.het_header
            and het_hdr_trace = rcd_lics_hdr_trace.het_hdr_trace;
         if sql%notfound then
            raise_application_error(-20000, 'Add Header Exception - Header/trace (' || to_char(rcd_lics_hdr_trace.het_header,'FM999999999999990') || '/' || to_char(rcd_lics_hdr_trace.het_hdr_trace,'FM99990') || ') does not exist');
         end if;
      end if;

      /*-*/
      /* Insert the header message
      /*-*/
      var_hdr_message := var_hdr_message + 1;
      rcd_lics_hdr_message.hem_header := rcd_lics_hdr_trace.het_header;
      rcd_lics_hdr_message.hem_hdr_trace := rcd_lics_hdr_trace.het_hdr_trace;
      rcd_lics_hdr_message.hem_msg_seq := var_hdr_message;
      rcd_lics_hdr_message.hem_text := par_exception;
      insert into lics_hdr_message
         (hem_header,
          hem_hdr_trace,
          hem_msg_seq,
          hem_text)
      values(rcd_lics_hdr_message.hem_header,
             rcd_lics_hdr_message.hem_hdr_trace,
             rcd_lics_hdr_message.hem_msg_seq,
             rcd_lics_hdr_message.hem_text);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end add_header_exception;

   /*********************************************************/
   /* This procedure performs the receive interface routine */
   /*********************************************************/
   procedure receive_interface is

      /*-*/
      /* Local definitions
      /*-*/
      var_procedure varchar2(128);
      var_opened boolean;
      var_fil_handle utl_file.file_type;
      var_size number(5,0);
      var_work number(5,0);
      var_count number(9,0);
      var_data varchar2(4000);
      type tab_sequence is table of number(9,0) index by binary_integer;
      type tab_record is table of varchar2(4000) index by binary_integer;
      var_sequence tab_sequence;
      var_record tab_record;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_data_01 is
         select t01.dat_header,
                t01.dat_dta_seq,
                t01.dat_record,
                t01.dat_status
           from lics_data t01
          where t01.dat_header = rcd_lics_header.hea_header
       order by t01.dat_dta_seq asc;
      rcd_lics_data_01 csr_lics_data_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
     cursor csr_load_data is 
     select 
        data_seq as dat_dta_seq,
        data_record as dat_record
        from fflu_load_data where load_seq = rv_load.load_seq;
     rv_load_data csr_load_data%rowtype;
     v_counter st_size;
     -- Update the load header status.
     procedure update_load_header is 
       pragma autonomous_transaction; 
     begin
       update fflu_load_header set row_count_tran = v_counter where load_seq = rv_load.load_seq; 
       commit;
     end update_load_header;
   begin
      
      -- FFLU Start - Specif Code.  -- UTIL Component has been removed.
      v_counter := 0;
      open csr_load_data;
      loop
        fetch csr_load_data into rv_load_data;
        exit when csr_load_data%notfound;
        v_counter := v_counter + 1;
        insert into lics_data (dat_header,dat_dta_seq, dat_record,dat_status) values (
          rcd_lics_header.hea_header,
          rv_load_data.dat_dta_seq,
          rv_load_data.dat_record,
          lics_constant.status_active);
        if v_counter mod 1000 = 0 then 
          update_load_header;
        end if;
      end loop;
      close csr_load_data;
      update_load_header;
      -- FFLU Stop 

      /*-*/
      /* Commit the database (data)
      /*-*/
      commit;

      /*-*/
      /* Search the inbound interface file when required
      /*-*/
      if not(rcd_lics_interface.int_search is null) then

         /*-*/
         /* Initialise the interface search
         /*-*/
         lics_interface_search.initialise(rcd_lics_header.hea_header);

         /*-*/
         /* Search the inbound data
         /*-*/
         var_procedure := 'begin ' || rcd_lics_interface.int_search || '.on_data(:data); end;';
         open csr_lics_data_01;
         loop
            fetch csr_lics_data_01 into rcd_lics_data_01;
            if csr_lics_data_01%notfound then
               exit;
            end if;

            /*-*/
            /* Fire the on data event in the inbound search implementation
            /*-*/
            execute immediate var_procedure using rcd_lics_data_01.dat_record;

         end loop;
         close csr_lics_data_01;

         /*-*/
         /* Finalise the interface search
         /*-*/
         lics_interface_search.finalise;

      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception
      /*-*/
      /* Exception trap
      /*-*/
      when others then
         add_header_exception('SQL ERROR - FFLU Transfer Interface - ' || substr(SQLERRM, 1, 512));
   /*-------------*/
   /* End routine */
   /*-------------*/
   end receive_interface;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_interface in varchar2, par_fil_name in varchar2, par_usr_name in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_usr_name  varchar2(20);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_interface_01 is
         select t01.int_interface,
                t01.int_description,
                t01.int_type,
                t01.int_group,
                t01.int_fil_path,
                t01.int_opr_alert,
                t01.int_ema_group,
                t01.int_search,
                t01.int_status
           from lics_interface t01
          where t01.int_interface = rcd_lics_interface.int_interface;
      rcd_lics_interface_01 csr_lics_interface_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the interface variable
      /*-*/
      rcd_lics_interface.int_interface := par_interface;
      var_usr_name := upper(par_usr_name);
      
      /*-*/
      /* Retrieve the requested interface
      /* notes - must exist
      /*         must be inbound type
      /*         must be active
      /*-*/
      open csr_lics_interface_01;
      fetch csr_lics_interface_01 into rcd_lics_interface_01;
      if csr_lics_interface_01%notfound then
         raise_application_error(-20000, 'Execute - Interface (' || rcd_lics_interface.int_interface || ') does not exist');
      end if;
      close csr_lics_interface_01;
      if rcd_lics_interface_01.int_type <> lics_constant.type_inbound then
         raise_application_error(-20000, 'Execute - Interface (' || rcd_lics_interface.int_interface || ') must be type ' || lics_constant.type_inbound);
      end if;
      if rcd_lics_interface_01.int_status <> lics_constant.status_active then
         raise_application_error(-20000, 'Execute - Interface (' || rcd_lics_interface.int_interface || ') is not active');
      end if;

      /*-*/
      /* Set the private variables
      /*-*/
      rcd_lics_interface.int_interface := rcd_lics_interface_01.int_interface;
      rcd_lics_interface.int_description := rcd_lics_interface_01.int_description;
      rcd_lics_interface.int_type := rcd_lics_interface_01.int_type;
      rcd_lics_interface.int_group := rcd_lics_interface_01.int_group;
      rcd_lics_interface.int_fil_path := rcd_lics_interface_01.int_fil_path;
      rcd_lics_interface.int_opr_alert := rcd_lics_interface_01.int_opr_alert;
      rcd_lics_interface.int_ema_group := rcd_lics_interface_01.int_ema_group;
      rcd_lics_interface.int_search := rcd_lics_interface_01.int_search;
      rcd_lics_interface.int_status := rcd_lics_interface_01.int_status;

      /*-*/
      /* Create the new header
      /* notes - header_load_working
      /*-*/
      select lics_header_sequence.nextval into rcd_lics_header.hea_header from dual;
      -- FFLU CODE START
      rv_load.lics_header_seq := rcd_lics_header.hea_header;
      -- FFLU CODE STOP
      rcd_lics_header.hea_interface := rcd_lics_interface.int_interface;
      rcd_lics_header.hea_trc_count := 1;
      rcd_lics_header.hea_crt_time := sysdate;
      rcd_lics_header.hea_fil_name := par_fil_name;
      rcd_lics_header.hea_msg_name := par_fil_name;
      rcd_lics_header.hea_status := lics_constant.header_load_working;
      
      if (par_usr_name is null) then
        rcd_lics_header.hea_crt_user := user;
      else
        rcd_lics_header.hea_crt_user := var_usr_name;
      end if;
      
      insert into lics_header
         (hea_header,
          hea_interface,
          hea_trc_count,
          hea_crt_user,
          hea_crt_time,
          hea_fil_name,
          hea_msg_name,
          hea_status)
         values(rcd_lics_header.hea_header,
                rcd_lics_header.hea_interface,
                rcd_lics_header.hea_trc_count,
                rcd_lics_header.hea_crt_user,
                rcd_lics_header.hea_crt_time,
                rcd_lics_header.hea_fil_name,
                rcd_lics_header.hea_msg_name,
                rcd_lics_header.hea_status);

      /*-*/
      /* Create the new header trace
      /* notes - header_load_working
      /*-*/
      rcd_lics_hdr_trace.het_header := rcd_lics_header.hea_header;
      rcd_lics_hdr_trace.het_hdr_trace := rcd_lics_header.hea_trc_count;
      rcd_lics_hdr_trace.het_execution := null;
      -- FFLU Variation on Standard Start
      rcd_lics_hdr_trace.het_user := rcd_lics_header.hea_crt_user;
      -- FFLU Variation on Standard End
      rcd_lics_hdr_trace.het_str_time := sysdate;
      rcd_lics_hdr_trace.het_end_time := sysdate;
      rcd_lics_hdr_trace.het_status := lics_constant.header_load_working;
      insert into lics_hdr_trace
         (het_header,
          het_hdr_trace,
          het_execution,
          het_user,
          het_str_time,
          het_end_time,
          het_status)
         values(rcd_lics_hdr_trace.het_header,
                rcd_lics_hdr_trace.het_hdr_trace,
                rcd_lics_hdr_trace.het_execution,
                rcd_lics_hdr_trace.het_user,
                rcd_lics_hdr_trace.het_str_time,
                rcd_lics_hdr_trace.het_end_time,
                rcd_lics_hdr_trace.het_status);

      /*-*/
      /* Reset the header message sequence
      /*-*/
      var_hdr_message := 0;

      /*-*/
      /* Commit the database (header/trace)
      /*-*/
      commit;

      /*-*/
      /* Receive the interface file
      /*-*/
      receive_interface;

      /*-*/
      /* Update the header trace end time and status
      /* note - header_load_completed
      /*        header_load_completed_error
      /*-*/
      rcd_lics_hdr_trace.het_end_time := sysdate;
      if rcd_lics_hdr_trace.het_status = lics_constant.header_load_working then
         rcd_lics_hdr_trace.het_status := lics_constant.header_load_completed;
      else
         rcd_lics_hdr_trace.het_status := lics_constant.header_load_completed_error;
      end if;
      update lics_hdr_trace
         set het_end_time = rcd_lics_hdr_trace.het_end_time,
             het_status = rcd_lics_hdr_trace.het_status
       where het_header = rcd_lics_hdr_trace.het_header
         and het_hdr_trace = rcd_lics_hdr_trace.het_hdr_trace;
      if sql%notfound then
         raise_application_error(-20000, 'Execute - Header/trace (' || to_char(rcd_lics_hdr_trace.het_header,'FM999999999999990') || '/' || to_char(rcd_lics_hdr_trace.het_hdr_trace,'FM99990') || ') does not exist');
      end if;

      /*-*/
      /* Update the header status
      /* note - header_load_completed
      /*        header_load_completed_error
      /*-*/
      if rcd_lics_header.hea_status = lics_constant.header_load_working then
         rcd_lics_header.hea_status := lics_constant.header_load_completed;
      else
         rcd_lics_header.hea_status := lics_constant.header_load_completed_error;
      end if;
      update lics_header
         set hea_status = rcd_lics_header.hea_status
       where hea_header = rcd_lics_header.hea_header;
      if sql%notfound then
         raise_application_error(-20000, 'Execute - Header (' || to_char(rcd_lics_header.hea_header,'FM999999999999990') || ') does not exist');
      end if;

      /*-*/
      /* Commit the database (header/trace)
      /*-*/
      commit;

      /*-*/
      /* Log the header/trace event
      /*-*/
      if rcd_lics_header.hea_status = lics_constant.header_load_completed then
         lics_notification.log_success(lics_constant.job_loader,
                                       null,
                                       lics_constant.type_inbound,
                                       rcd_lics_interface.int_group,
                                       null,
                                       rcd_lics_interface.int_interface,
                                       rcd_lics_header.hea_header,
                                       rcd_lics_hdr_trace.het_hdr_trace,
                                       'INBOUND LOADER SUCCESS');
      else
         lics_notification.log_error(lics_constant.job_loader,
                                     null,
                                     lics_constant.type_inbound,
                                     rcd_lics_interface.int_group,
                                     null,
                                     rcd_lics_interface.int_interface,
                                     rcd_lics_header.hea_header,
                                     rcd_lics_hdr_trace.het_hdr_trace,
                                     'INBOUND LOADER ERROR - see trace messages for more details',
                                     rcd_lics_interface.int_opr_alert,
                                     rcd_lics_interface.int_ema_group);
      end if;

      /*-*/
      /* Wake up the inbound processor when required
      /*-*/
      if rcd_lics_header.hea_status = lics_constant.header_load_completed then
         lics_pipe.spray(lics_constant.type_inbound, rcd_lics_interface.int_group, lics_constant.pipe_wake);
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Log the event fatal
         /*-*/
         begin
            lics_notification.log_fatal(lics_constant.job_loader,
                                        null,
                                        lics_constant.type_inbound,
                                        rcd_lics_interface.int_group,
                                        null,
                                        rcd_lics_interface.int_interface,
                                        rcd_lics_header.hea_header,
                                        rcd_lics_hdr_trace.het_hdr_trace,
                                        'INBOUND LOADER FAILED - ' ||  substr(SQLERRM, 1, 512));
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Inbound Loader - ' || substr(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

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
          lics_logging.write_log('* Successfully Loaded Data for Load Sequence : ' || rv_load.load_seq || ', Interface : ' || rv_load.interface_code);
          execute(rv_load.interface_code, rv_load.file_name, rv_load.user_code);
          -- Now update our header record.
          update fflu_load_header set load_status = gc_load_status_executed,
            lics_header_seq = rv_load.lics_header_seq, load_executed = sysdate
          where load_seq = rv_load.load_seq;
          -- Insert a user code write back into into the interface in case we want to track the user code against actual processing trace.
          insert into fflu_xaction_writeback (lics_header_seq, user_code, last_updtd_time) values (rv_load.lics_header_seq,rv_load.user_code, sysdate);
          commit;
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
        delete fflu_load_data where load_seq = tv_data(v_counter);
        if sql%ROWCOUNT > 0 THEN 
          lics_logging.write_log('* Deleted Load Data Records of Load : ' || tv_data(v_counter) || ', ' || SQL%ROWCOUNT || ' rows.');
        end if;
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
      
      lics_logging.write_log('Deleting old Transaction Writeback Records.');
      delete from fflu_xaction_writeback where last_updtd_time < sysdate - pc_load_data_history;
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