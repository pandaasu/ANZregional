/******************/
/* Package Header */
/******************/
create or replace package lics_inbound_processor as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_inbound_processor
 Owner   : lics_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Interface Control System - Inbound Processor

 The package implements the inbound processor functionality.

 1. All packages must implement this interface to facilitate calling
    from the controlling application.

 2. The inbound processor can be aborted at any time using the
    callback exception method.

 3. The architecture supports multiple exceptions for each inbound interface.

 4. This package has been designed as a single instance class to facilitate
    re-engineering in an object oriented language. That is, in an OO environment
    the host would create one or more instances of this class and pass the reference
    to the target objects. However, in the PL/SQL environment only one global instance
    is available at any one time.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2005/11   Steve Gregan   Added callback_interface/callback_file_name functions
 2006/08   Steve Gregan   Added message name functionality
 2006/11   Steve Gregan   Added single processing functionality

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_group in varchar2,
                     par_job in varchar2,
                     par_execution in number);
   procedure callback_exception(par_exception in varchar2);
   function callback_interface return varchar2;
   function callback_file_name return varchar2;
   procedure execute_single(par_header in number);

end lics_inbound_processor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_inbound_processor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure select_interface;
   procedure process_interface;
   procedure split_interface;
   procedure add_header_exception(par_exception in varchar2);
   procedure add_data_exception(par_exception in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   cnt_process_count constant number(5,0) := 200;
   type typ_process is table of number(15,0) index by binary_integer;
   tbl_process typ_process;
   var_ctl_pipe varchar2(128);
   var_ctl_wake boolean;
   var_ctl_suspend boolean;
   var_ctl_stop boolean;
   rcd_lics_interface lics_interface%rowtype;
   rcd_lics_header lics_header%rowtype;
   rcd_lics_hdr_trace lics_hdr_trace%rowtype;
   rcd_lics_hdr_message lics_hdr_message%rowtype;
   rcd_lics_data lics_data%rowtype;
   rcd_lics_dta_message lics_dta_message%rowtype;
   var_hdr_message lics_hdr_message.hem_msg_seq%type;
   var_dta_message lics_dta_message.dam_msg_seq%type;
   var_group lics_job.job_int_group%type;
   var_search lics_job.job_int_group%type;
   var_job lics_job.job_job%type;
   var_execution lics_job_trace.jot_execution%type;

   /*******************************************************/
   /* This procedure performs the execute process routine */
   /*******************************************************/
   procedure execute(par_group in varchar2,
                     par_job in varchar2,
                     par_execution in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_suspended boolean;
      var_message varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the parameters
      /*-*/
      var_group := par_group;
      var_job := par_job;
      var_execution := par_execution;
      var_search := par_group;
      if instr(var_search,'#',1,1) <> 0 then
         var_search := substr(var_search,1,instr(var_search,'#',1,1)-1);
      end if;

      /*-*/
      /* Set the controls
      /*-*/
      var_ctl_pipe := lics_constant.queue_inbound || var_group;
      var_ctl_wake := false;
      var_ctl_suspend := false;
      var_ctl_stop := false;
      var_suspended := false;

      /*-*/
      /* Process the inbound group until stop requested
      /*-*/
      loop

         /*-*/
         /* Select the interface when requested
         /*-*/
         if var_suspended = false then

            /*-*/
            /* Update the job trace status
            /*-*/
            update lics_job_trace
               set jot_status = lics_constant.job_working
             where jot_execution = var_execution;
            if sql%notfound then
               raise_application_error(-20000, 'Execute - Job trace (' || to_char(var_execution,'FM999999999999990') || ') does not exist');
            end if;
            commit;

            /*-*/
            /* Select the interfaces until exhausted
            /*-*/
            loop
               var_ctl_wake := false;
               var_ctl_suspend := false;
               var_ctl_stop := false;
               select_interface;
               if var_ctl_suspend = true then
                  var_suspended := true;
               end if;
               if var_ctl_wake = false or
                  var_ctl_suspend = true or
                  var_ctl_stop = true then
                  exit;
               end if;
            end loop;

            /*-*/
            /* Exit when requested
            /*-*/
            if var_ctl_stop = true then
               exit;
            end if;

         end if;

         /*-*/
         /* Update the job trace status
         /*-*/
         if var_suspended = false then
            update lics_job_trace
               set jot_status = lics_constant.job_idle
             where jot_execution = var_execution;
         else
            update lics_job_trace
               set jot_status = lics_constant.job_suspended
             where jot_execution = var_execution;
         end if;
         if sql%notfound then
            raise_application_error(-20000, 'Execute - Job trace (' || to_char(var_execution,'FM999999999999990') || ') does not exist');
         end if;
         commit;

         /*-*/
         /* Wait for pipe message (blocked - no maximum)
         /* **note** this is the sleep code
         /*-*/
         var_message := lics_pipe.receive(var_ctl_pipe);
         if trim(var_message) = lics_constant.pipe_stop then
            exit;
         end if;
         if trim(var_message) = lics_constant.pipe_suspend then
            var_suspended := true;
         end if;
         if trim(var_message) = lics_constant.pipe_release then
            var_suspended := false;
         end if;

      end loop; 

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
            lics_notification.log_fatal(var_job,
                                        var_execution,
                                        lics_constant.type_inbound,
                                        var_group,
                                        null,
                                        null,
                                        null,
                                        null,
                                        'INBOUND PROCESSOR FAILED - ' || substr(SQLERRM, 1, 512));
         exception
            when others then
               raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Inbound Processor - ' || substr(SQLERRM, 1, 512));
         end;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /**********************************************************/
   /* This procedure performs the callback exception routine */
   /**********************************************************/
   procedure callback_exception(par_exception in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return when no header or trace active
      /*-*/
      if rcd_lics_header.hea_header is null or
         rcd_lics_hdr_trace.het_hdr_trace is null then
         return;
      end if;

      /*-*/
      /* Add the header/data exception as required
      /*-*/
      if rcd_lics_data.dat_dta_seq is null then
         add_header_exception(par_exception);
      else
         add_data_exception(par_exception);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end callback_exception;

   /*********************************************************/
   /* This function performs the callback interface routine */
   /*********************************************************/
   function callback_interface return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the current interface
      /*-*/
      return rcd_lics_interface.int_interface;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end callback_interface;

   /*********************************************************/
   /* This function performs the callback file name routine */
   /*********************************************************/
   function callback_file_name return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the current associated file name
      /*-*/
      return rcd_lics_header.hea_fil_name;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end callback_file_name;

   /******************************************************/
   /* This procedure performs the execute single routine */
   /******************************************************/
   procedure execute_single(par_header in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_header_01 is 
         select t01.*
           from lics_header t01
          where t01.hea_header = par_header
                for update nowait;
      rcd_lics_header_01 csr_lics_header_01%rowtype;

      cursor csr_lics_interface_01 is 
         select t01.*
           from lics_interface t01
          where t01.int_interface = rcd_lics_header_01.hea_interface;
      rcd_lics_interface_01 csr_lics_interface_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Attempt to lock the header row
      /* notes - must still exist
      /*         must still be status = header_load_completed
      /*         must not be locked
      /*-*/
      var_found := false;
      begin
         open csr_lics_header_01;
         fetch csr_lics_header_01 into rcd_lics_header_01;
         if csr_lics_header_01%found then
            var_found := true;
         end if;
         close csr_lics_header_01;
      exception
         when others then
            raise_application_error(-20000, 'Execute Single - Header (' || to_char(par_header) || ') is already locked');
      end;
      if var_found = false then
         raise_application_error(-20000, 'Execute Single - Header (' || to_char(par_header) || ') not found');
      end if;
      if rcd_lics_header_01.hea_status <> lics_constant.header_load_completed then
         raise_application_error(-20000, 'Execute Single - Header (' || to_char(par_header) || ') must be status (' || lics_constant.header_load_completed || ')');
      end if;

      /*-*/
      /* Set the private header variables
      /*-*/
      rcd_lics_header.hea_header := rcd_lics_header_01.hea_header;
      rcd_lics_header.hea_trc_count := rcd_lics_header_01.hea_trc_count;
      rcd_lics_header.hea_status := rcd_lics_header_01.hea_status;
      rcd_lics_header.hea_fil_name := rcd_lics_header_01.hea_fil_name;
      rcd_lics_header.hea_msg_name := rcd_lics_header_01.hea_msg_name;
      var_hdr_message := 0;

      /*-*/
      /* Retrieve the interface data
      /*-*/
      open csr_lics_interface_01;
      fetch csr_lics_interface_01 into rcd_lics_interface_01;
      if csr_lics_interface_01%notfound then
         raise_application_error(-20000, 'Execute Single - Interface (' || rcd_lics_header_01.hea_interface || ') not found');
      end if;
      close csr_lics_interface_01;
      if rcd_lics_interface_01.int_type <> lics_constant.type_inbound then
         raise_application_error(-20000, 'Execute Single - Interface (' || rcd_lics_header_01.hea_interface || ') is not ' || lics_constant.type_inbound);
      end if;
      if rcd_lics_interface_01.int_status <> lics_constant.status_active then
         raise_application_error(-20000, 'Execute Single - Interface (' || rcd_lics_header_01.hea_interface || ') is not active');
      end if;

      /*-*/
      /* Set the private interface variables
      /*-*/
      rcd_lics_interface.int_interface := rcd_lics_interface_01.int_interface;
      rcd_lics_interface.int_description := rcd_lics_interface_01.int_description;
      rcd_lics_interface.int_type := rcd_lics_interface_01.int_type;
      rcd_lics_interface.int_group := rcd_lics_interface_01.int_group;
      rcd_lics_interface.int_fil_path := rcd_lics_interface_01.int_fil_path;
      rcd_lics_interface.int_opr_alert := rcd_lics_interface_01.int_opr_alert;
      rcd_lics_interface.int_ema_group := rcd_lics_interface_01.int_ema_group;
      rcd_lics_interface.int_procedure := rcd_lics_interface_01.int_procedure;

      /*-*/
      /* Update the header trace count and status
      /* notes - status = header_process_working
      /*-*/
      rcd_lics_header.hea_trc_count := rcd_lics_header.hea_trc_count + 1;
      rcd_lics_header.hea_status := lics_constant.header_process_working;
      update lics_header
         set hea_trc_count = rcd_lics_header.hea_trc_count,
             hea_status = rcd_lics_header.hea_status
       where hea_header = rcd_lics_header.hea_header;
      if sql%notfound then
         raise_application_error(-20000, 'Execute Single - Header (' || to_char(rcd_lics_header.hea_header,'FM999999999999990') || ') does not exist');
      end if;

      /*-*/
      /* Create the new header trace
      /* notes - status = header_process_working
      /*         execution = null (not processed by job)
      /*-*/
      rcd_lics_hdr_trace.het_header := rcd_lics_header.hea_header;
      rcd_lics_hdr_trace.het_hdr_trace := rcd_lics_header.hea_trc_count;
      rcd_lics_hdr_trace.het_execution := null;
      rcd_lics_hdr_trace.het_user := user;
      rcd_lics_hdr_trace.het_str_time := sysdate;
      rcd_lics_hdr_trace.het_end_time := sysdate;
      rcd_lics_hdr_trace.het_status := lics_constant.header_process_working;
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
      /* Commit the database (header/trace)
      /*-*/
      commit;

      /*-*/
      /* Split/process the interface
      /*-*/
      if upper(substr(rcd_lics_interface.int_procedure,1,11)) = '*SPLIT_INTO' then
         split_interface;
      else
         process_interface;
      end if;

      /*-*/
      /* Update the header trace end time and status
      /* note - header_process_completed
      /*        header_process_completed_error
      /*-*/
      rcd_lics_hdr_trace.het_end_time := sysdate;
      if rcd_lics_hdr_trace.het_status = lics_constant.header_process_working then
         rcd_lics_hdr_trace.het_status := lics_constant.header_process_completed;
      else
         rcd_lics_hdr_trace.het_status := lics_constant.header_process_completed_error;
      end if;
      update lics_hdr_trace
         set het_end_time = rcd_lics_hdr_trace.het_end_time,
             het_status = rcd_lics_hdr_trace.het_status
       where het_header = rcd_lics_hdr_trace.het_header
         and het_hdr_trace = rcd_lics_hdr_trace.het_hdr_trace;
      if sql%notfound then
         raise_application_error(-20000, 'Execute Single - Header/trace (' || to_char(rcd_lics_hdr_trace.het_header,'FM999999999999990') || '/' || to_char(rcd_lics_hdr_trace.het_hdr_trace,'FM99990') || ') does not exist');
      end if;

      /*-*/
      /* Update the header status
      /* note - header_process_completed
      /*        header_process_completed_error
      /*-*/
      if rcd_lics_header.hea_status = lics_constant.header_process_working then
         rcd_lics_header.hea_status := lics_constant.header_process_completed;
      else
         rcd_lics_header.hea_status := lics_constant.header_process_completed_error;
      end if;
      update lics_header
         set hea_status = rcd_lics_header.hea_status
       where hea_header = rcd_lics_header.hea_header;
      if sql%notfound then
         raise_application_error(-20000, 'Execute Single - Header (' || to_char(rcd_lics_header.hea_header,'FM999999999999990') || ') does not exist');
      end if;

      /*-*/
      /* Commit the database (header/trace)
      /*-*/
      commit;

      /*-*/
      /* Log the header/trace event
      /*-*/
      if rcd_lics_header.hea_status = lics_constant.header_process_completed then
         lics_notification.log_success('*SINGLE',
                                       null,
                                       lics_constant.type_inbound,
                                       null,
                                       null,
                                       rcd_lics_interface.int_interface,
                                       rcd_lics_header.hea_header,
                                       rcd_lics_hdr_trace.het_hdr_trace,
                                       'INBOUND PROCESSOR SUCCESS');
      else
         lics_notification.log_error('*SINGLE',
                                     null,
                                     lics_constant.type_inbound,
                                     null,
                                     null,
                                     rcd_lics_interface.int_interface,
                                     rcd_lics_header.hea_header,
                                     rcd_lics_hdr_trace.het_hdr_trace,
                                     'INBOUND PROCESSOR ERROR - see trace messages for more details',
                                     rcd_lics_interface.int_opr_alert,
                                     rcd_lics_interface.int_ema_group);
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
            lics_notification.log_fatal('*SINGLE',
                                        null,
                                        lics_constant.type_inbound,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        'INBOUND PROCESSOR FAILED - ' || substr(SQLERRM, 1, 512));
         exception
            when others then
               raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Inbound Processor - ' || substr(SQLERRM, 1, 512));
         end;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_single;

   /********************************************************/
   /* This procedure performs the select interface routine */
   /********************************************************/
   procedure select_interface is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;
      var_check varchar2(4000);
      var_header lics_header.hea_header%type;

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
                t01.int_procedure
           from lics_interface t01
          where t01.int_type = lics_constant.type_inbound
            and t01.int_group = var_search
            and t01.int_status = lics_constant.status_active
       order by t01.int_priority asc,
                t01.int_interface asc;
      rcd_lics_interface_01 csr_lics_interface_01%rowtype;

      cursor csr_lics_header_01 is 
         select t01.hea_header
           from lics_header t01
          where t01.hea_interface = rcd_lics_interface.int_interface
            and t01.hea_status = lics_constant.header_load_completed
       order by t01.hea_header asc;
      rcd_lics_header_01 csr_lics_header_01%rowtype;

      cursor csr_lics_header_02 is 
         select t01.hea_header,
                t01.hea_trc_count,
                t01.hea_status,
                t01.hea_fil_name,
                t01.hea_msg_name
           from lics_header t01
          where t01.hea_header = var_header
                for update nowait;
      rcd_lics_header_02 csr_lics_header_02%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the interfaces related to the group
      /* notes - status = status_active
      /*       - sorted by priority ascending
      /*-*/
      open csr_lics_interface_01;
      loop
         fetch csr_lics_interface_01 into rcd_lics_interface_01;
         if csr_lics_interface_01%notfound then
            exit;
         end if;

         /*-*/
         /* Set the private interface variables
         /*-*/
         rcd_lics_interface.int_interface := rcd_lics_interface_01.int_interface;
         rcd_lics_interface.int_description := rcd_lics_interface_01.int_description;
         rcd_lics_interface.int_type := rcd_lics_interface_01.int_type;
         rcd_lics_interface.int_group := rcd_lics_interface_01.int_group;
         rcd_lics_interface.int_fil_path := rcd_lics_interface_01.int_fil_path;
         rcd_lics_interface.int_opr_alert := rcd_lics_interface_01.int_opr_alert;
         rcd_lics_interface.int_ema_group := rcd_lics_interface_01.int_ema_group;
         rcd_lics_interface.int_procedure := rcd_lics_interface_01.int_procedure;

         /*-*/
         /* Process headers in batches (based on process count constant)
         /*-*/
         loop

            /*-*/
            /* Retrieve the headers related to the interface
            /* notes - status = header_load_completed
            /*       - sorted by header ascending
            /*       - next processing count group
            /*-*/
            tbl_process.delete;
            open csr_lics_header_01;
            loop
               fetch csr_lics_header_01 into rcd_lics_header_01;
               if csr_lics_header_01%notfound then
                  exit;
               end if;
               tbl_process(tbl_process.count + 1) := rcd_lics_header_01.hea_header;
               if tbl_process.count >= cnt_process_count then
                  exit;
               end if;
            end loop;
            close csr_lics_header_01;

            /*-*/
            /* Break the processing loop when required
            /*-*/
            if tbl_process.count = 0 then
               exit;
            end if;

            /*-*/
            /* Process the current group of headers
            /*-*/
            for idx in 1..tbl_process.count loop

               /*-*/
               /* Set the next header
               /*-*/
               var_header := tbl_process(idx);

               /*-*/
               /* Attempt to lock the header row
               /* notes - must still exist
               /*         must still be status = header_load_completed
               /*         must not be locked
               /*-*/
               var_available := true;
               begin
                  open csr_lics_header_02;
                  fetch csr_lics_header_02 into rcd_lics_header_02;
                  if csr_lics_header_02%notfound then
                     var_available := false;
                  end if;
                  if rcd_lics_header_02.hea_status <> lics_constant.header_load_completed then
                     var_available := false;
                  end if;
               exception
                  when others then
                     var_available := false;
               end;
               if csr_lics_header_02%isopen then
                  close csr_lics_header_02;
               end if;

               /*-*/
               /* Release the header lock when not available
               /* 1. Cursor row locks are not released until commit or rollback
               /* 2. Cursor close does not release row locks
               /*-*/
               if var_available = false then

                  /*-*/
                  /* Rollback to release row locks
                  /*-*/
                  rollback;

               /*-*/
               /* Process the header when available
               /*-*/
               else

                  /*-*/
                  /* Set the private header variables
                  /*-*/
                  rcd_lics_header.hea_header := rcd_lics_header_02.hea_header;
                  rcd_lics_header.hea_trc_count := rcd_lics_header_02.hea_trc_count;
                  rcd_lics_header.hea_status := rcd_lics_header_02.hea_status;
                  rcd_lics_header.hea_fil_name := rcd_lics_header_02.hea_fil_name;
                  rcd_lics_header.hea_msg_name := rcd_lics_header_02.hea_msg_name;
                  var_hdr_message := 0;

                  /*-*/
                  /* Update the header trace count and status
                  /* notes - status = header_process_working
                  /*-*/
                  rcd_lics_header.hea_trc_count := rcd_lics_header.hea_trc_count + 1;
                  rcd_lics_header.hea_status := lics_constant.header_process_working;
                  update lics_header
                     set hea_trc_count = rcd_lics_header.hea_trc_count,
                         hea_status = rcd_lics_header.hea_status
                   where hea_header = rcd_lics_header.hea_header;
                  if sql%notfound then
                     raise_application_error(-20000, 'Select Interface - Header (' || to_char(rcd_lics_header.hea_header,'FM999999999999990') || ') does not exist');
                  end if;

                  /*-*/
                  /* Create the new header trace
                  /* notes - status = header_process_working
                  /*-*/
                  rcd_lics_hdr_trace.het_header := rcd_lics_header.hea_header;
                  rcd_lics_hdr_trace.het_hdr_trace := rcd_lics_header.hea_trc_count;
                  rcd_lics_hdr_trace.het_execution := var_execution;
                  rcd_lics_hdr_trace.het_user := user;
                  rcd_lics_hdr_trace.het_str_time := sysdate;
                  rcd_lics_hdr_trace.het_end_time := sysdate;
                  rcd_lics_hdr_trace.het_status := lics_constant.header_process_working;
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
                  /* Commit the database (header/trace)
                  /*-*/
                  commit;

                  /*-*/
                  /* Split/process the interface
                  /*-*/
                  if upper(substr(rcd_lics_interface.int_procedure,1,11)) = '*SPLIT_INTO' then
                     split_interface;
                  else
                     process_interface;
                  end if;

                  /*-*/
                  /* Update the header trace end time and status
                  /* note - header_process_completed
                  /*        header_process_completed_error
                  /*-*/
                  rcd_lics_hdr_trace.het_end_time := sysdate;
                  if rcd_lics_hdr_trace.het_status = lics_constant.header_process_working then
                     rcd_lics_hdr_trace.het_status := lics_constant.header_process_completed;
                  else
                     rcd_lics_hdr_trace.het_status := lics_constant.header_process_completed_error;
                  end if;
                  update lics_hdr_trace
                     set het_end_time = rcd_lics_hdr_trace.het_end_time,
                         het_status = rcd_lics_hdr_trace.het_status
                   where het_header = rcd_lics_hdr_trace.het_header
                     and het_hdr_trace = rcd_lics_hdr_trace.het_hdr_trace;
                  if sql%notfound then
                     raise_application_error(-20000, 'Select Interface - Header/trace (' || to_char(rcd_lics_hdr_trace.het_header,'FM999999999999990') || '/' || to_char(rcd_lics_hdr_trace.het_hdr_trace,'FM99990') || ') does not exist');
                  end if;

                  /*-*/
                  /* Update the header status
                  /* note - header_process_completed
                  /*        header_process_completed_error
                  /*-*/
                  if rcd_lics_header.hea_status = lics_constant.header_process_working then
                     rcd_lics_header.hea_status := lics_constant.header_process_completed;
                  else
                     rcd_lics_header.hea_status := lics_constant.header_process_completed_error;
                  end if;
                  update lics_header
                     set hea_status = rcd_lics_header.hea_status
                   where hea_header = rcd_lics_header.hea_header;
                  if sql%notfound then
                     raise_application_error(-20000, 'Select Interface - Header (' || to_char(rcd_lics_header.hea_header,'FM999999999999990') || ') does not exist');
                  end if;

                  /*-*/
                  /* Commit the database (header/trace)
                  /*-*/
                  commit;

                  /*-*/
                  /* Log the header/trace event
                  /*-*/
                  if rcd_lics_header.hea_status = lics_constant.header_process_completed then
                     lics_notification.log_success(var_job,
                                                   var_execution,
                                                   lics_constant.type_inbound,
                                                   rcd_lics_interface.int_group,
                                                   null,
                                                   rcd_lics_interface.int_interface,
                                                   rcd_lics_header.hea_header,
                                                   rcd_lics_hdr_trace.het_hdr_trace,
                                                   'INBOUND PROCESSOR SUCCESS');
                  else
                     lics_notification.log_error(var_job,
                                                 var_execution,
                                                 lics_constant.type_inbound,
                                                 rcd_lics_interface.int_group,
                                                 null,
                                                 rcd_lics_interface.int_interface,
                                                 rcd_lics_header.hea_header,
                                                 rcd_lics_hdr_trace.het_hdr_trace,
                                                 'INBOUND PROCESSOR ERROR - see trace messages for more details',
                                                 rcd_lics_interface.int_opr_alert,
                                                 rcd_lics_interface.int_ema_group);
                  end if;

               end if;

            end loop;

            /*-*/
            /* Check the pipe for new message
            /*
            /* **notes**
            /* 1. Wake - continue and remember the state to process any interfaces already passed
            /* 2. Suspend - break the processing and suspend the processor
            /* 3. Release - continue and reset the suspend control
            /* 4. Stop - break the processing and stop the processor
            /* 5. Default - continue and ignore the instruction
            /*-*/
            var_check := lics_pipe.check_queue(var_ctl_pipe);
            case trim(var_check)
               when lics_constant.pipe_wake then
                  var_ctl_wake := true;
               when lics_constant.pipe_suspend then
                  var_ctl_suspend := true;
               when lics_constant.pipe_release then
                  var_ctl_suspend := false;
               when lics_constant.pipe_stop then
                  var_ctl_stop := true;
               else
                  null;
            end case;
            if var_ctl_suspend = true or
               var_ctl_stop = true then
               exit;
            end if;

         end loop;

         /*-*/
         /* Break the loop when required
         /*-*/
         if var_ctl_suspend = true or
            var_ctl_stop = true then
            exit;
         end if;

      end loop;
      close csr_lics_interface_01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end select_interface;

   /*********************************************************/
   /* This procedure performs the process interface routine */
   /*********************************************************/
   procedure process_interface is

      /*-*/
      /* Local definitions
      /*-*/
      var_procedure varchar2(128);

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
   begin

      /*-*/
      /* Fire the on start event in the inbound interface implementation
      /*-*/
      rcd_lics_data.dat_dta_seq := null;
      var_procedure := 'begin ' || rcd_lics_interface.int_procedure || '.on_start; end;';
      execute immediate var_procedure;

      /*-*/
      /* Process the inbound interface data
      /*-*/
      var_procedure := 'begin ' || rcd_lics_interface.int_procedure || '.on_data(:data); end;';
      open csr_lics_data_01;
      loop
         fetch csr_lics_data_01 into rcd_lics_data_01;
         if csr_lics_data_01%notfound then
            exit;
         end if;

         /*-*/
         /* Set the private data variables
         /*-*/
         rcd_lics_data.dat_header := rcd_lics_data_01.dat_header;
         rcd_lics_data.dat_dta_seq := rcd_lics_data_01.dat_dta_seq;
         rcd_lics_data.dat_record:= rcd_lics_data_01.dat_record;
         rcd_lics_data.dat_status := rcd_lics_data_01.dat_status;
         var_dta_message := 0;

         /*-*/
         /* Fire the on data event in the inbound interface implementation
         /*-*/
         execute immediate var_procedure using rcd_lics_data.dat_record;

      end loop;
      close csr_lics_data_01;

      /*-*/
      /* Fire the on end event in the inbound interface implementation
      /*-*/
      rcd_lics_data.dat_dta_seq := null;
      var_procedure := 'begin ' || rcd_lics_interface.int_procedure || '.on_end; end;';
      execute immediate var_procedure;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Application exception
      /*-*/
      when application_exception then
         rollback;
         add_header_exception('APPLICATION ERROR - ' || substr(SQLERRM, 1, 512));

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         rollback;
         add_header_exception('SQL ERROR - Process Interface - ' || substr(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_interface;

   /*******************************************************/
   /* This procedure performs the split interface routine */
   /*******************************************************/
   procedure split_interface is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);
      type tab_token is table of varchar2(256) index by binary_integer;
      var_token tab_token;
      var_index binary_integer;
      var_value varchar2(256);
      var_char varchar2(1);
      var_number number;
      var_save varchar2(4000);
      var_create boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_data_01 is 
         select t01.dat_record
           from lics_data t01
          where t01.dat_header = rcd_lics_header.hea_header
       order by t01.dat_dta_seq asc;
      rcd_lics_data_01 csr_lics_data_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Token the split statement (space or comma delimited)
      /*-*/
      var_token.delete;
      if not(rcd_lics_interface.int_procedure is null) then
         var_index := 0;
         var_value := null;
         for idx in 1..length(rcd_lics_interface.int_procedure) loop
            var_char := substr(rcd_lics_interface.int_procedure, idx, 1);
            if var_char = ' ' or var_char = ',' then
               var_index := var_index + 1;
               var_token(var_index) := upper(trim(var_value));
               var_value := null;
            else
               var_value := var_value || var_char;
            end if;
         end loop;
         var_index := var_index + 1;
         var_token(var_index) := upper(trim(var_value));
      end if;

      /*-*/
      /* Validate the split control information
      /*-*/
      if var_token.count < 3 then
         raise_application_error(-20000, 'Split Interface - Split command is not complete');
      end if;
      if var_token(3) != 'WHEN_START_WITH' and
         var_token(3) != 'WHEN_SAME_SUBSTRING' and
         var_token(3) != 'FOR_EACH_ROW' then
         raise_application_error(-20000, 'Split Interface - Split action must be WHEN_START_WITH, WHEN_SAME_SUBSTRING or FOR_EACH_ROW');
      end if;
      if var_token(3) = 'WHEN_START_WITH' then
         if var_token.count != 4 then
            raise_application_error(-20000, 'Split Interface - Split action WHEN_START_WITH has wrong number of arguments');
         end if;
      end if;
      if var_token(3) = 'WHEN_SAME_SUBSTRING' then
         if var_token.count != 5 then
            raise_application_error(-20000, 'Split Interface - Split action WHEN_SAME_SUBSTRING has wrong number of arguments');
         end if;
         begin
            var_number := to_number(var_token(4));
         exception
            when others then
               raise_application_error(-20000, 'Split Interface - Split action WHEN_SAME_SUBSTRING - Unable to convert from (' || var_token(4) || ') to a number');
         end;
         begin
            var_number := to_number(var_token(5));
         exception
            when others then
               raise_application_error(-20000, 'Split Interface - Split action WHEN_SAME_SUBSTRING - Unable to convert for (' || var_token(5) || ') to a number');
         end;
      end if;
      if var_token(3) = 'FOR_EACH_ROW' then
         if var_token.count != 3 then
            raise_application_error(-20000, 'Split Interface - Split action FOR_EACH_ROW has wrong number of arguments');
         end if;
      end if;

      /*-*/
      /* Process the inbound interface data
      /*-*/
      var_create := false;
      var_save := null;
      open csr_lics_data_01;
      loop
         fetch csr_lics_data_01 into rcd_lics_data_01;
         if csr_lics_data_01%notfound then
            exit;
         end if;

         /*-*/
         /* Create the new file when required
         /*-*/
         if var_token(3) = 'WHEN_START_WITH' then
            if upper(substr(rcd_lics_data_01.dat_record,1,length(var_token(4)))) = var_token(4) then
               var_create := true;
            end if;
         elsif var_token(3) = 'WHEN_SAME_SUBSTRING' then
            if var_save is null or
               upper(substr(rcd_lics_data_01.dat_record,to_number(var_token(4)),to_number(var_token(5)))) != var_save then
               var_save := upper(substr(rcd_lics_data_01.dat_record,to_number(var_token(4)),to_number(var_token(5))));
               var_create := true;
            end if;
         elsif var_token(3) = 'FOR_EACH_ROW' then
            var_create := true;
         end if;
         if var_create = true then
            var_create := false;
            if lics_outbound_loader.is_created = true then
               lics_outbound_loader.finalise_interface;
            end if;
            var_instance := lics_outbound_loader.create_interface(var_token(2));
         end if;

         /*-*/
         /* Split prefix must exist
         /*-*/
         if lics_outbound_loader.is_created = false then
            raise_application_error(-20000, 'Split Interface - Split command (' || rcd_lics_interface.int_procedure || ') not satisfied');
         end if;

         /*-*/
         /* Append the data to the new file
         /*-*/
         lics_outbound_loader.append_data(rcd_lics_data_01.dat_record);

      end loop;
      close csr_lics_data_01;

      /*-*/
      /* Create the new file when required
      /*-*/
      if lics_outbound_loader.is_created = true then
         lics_outbound_loader.finalise_interface;
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Application exception
      /*-*/
      when application_exception then
         rollback;
         add_header_exception('APPLICATION ERROR - ' || substr(SQLERRM, 1, 512));
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
            lics_outbound_loader.finalise_interface;
         end if;

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         rollback;
         add_header_exception('SQL ERROR - Split Interface - ' || substr(SQLERRM, 1, 512));
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
            lics_outbound_loader.finalise_interface;
         end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end split_interface;

   /************************************************************/
   /* This procedure performs the add header exception routine */
   /************************************************************/
   procedure add_header_exception(par_exception in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Update the header status when required
      /* note - header_process_working_error
      /*-*/
      if rcd_lics_header.hea_status = lics_constant.header_process_working then
         rcd_lics_header.hea_status := lics_constant.header_process_working_error;
         update lics_header
            set hea_status = rcd_lics_header.hea_status
          where hea_header = rcd_lics_header.hea_header;
         if sql%notfound then
            raise_application_error(-20000, 'Add Header Exception - Header (' || to_char(rcd_lics_header.hea_header,'FM999999999999990') || ') does not exist');
         end if;
      end if;

      /*-*/
      /* Update the header trace status when required
      /* note - header_process_working_error
      /*-*/
      if rcd_lics_hdr_trace.het_status = lics_constant.header_process_working then
         rcd_lics_hdr_trace.het_status := lics_constant.header_process_working_error;
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
      /* note - isolated commit (autonomous transaction)
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end add_header_exception;

   /**********************************************************/
   /* This procedure performs the add data exception routine */
   /**********************************************************/
   procedure add_data_exception(par_exception in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Update the header status when required
      /* note - header_process_working_error
      /*-*/
      if rcd_lics_header.hea_status = lics_constant.header_process_working then
         rcd_lics_header.hea_status := lics_constant.header_process_working_error;
         update lics_header
            set hea_status = rcd_lics_header.hea_status
          where hea_header = rcd_lics_header.hea_header;
         if sql%notfound then
            raise_application_error(-20000, 'Add Data Exception - Header (' || to_char(rcd_lics_header.hea_header,'FM999999999999990') || ') does not exist');
         end if;
      end if;

      /*-*/
      /* Update the header trace status when required
      /* note - header_process_working_error
      /*-*/
      if rcd_lics_hdr_trace.het_status = lics_constant.header_process_working then
         rcd_lics_hdr_trace.het_status := lics_constant.header_process_working_error;
         update lics_hdr_trace
            set het_status = rcd_lics_hdr_trace.het_status
          where het_header = rcd_lics_hdr_trace.het_header
            and het_hdr_trace = rcd_lics_hdr_trace.het_hdr_trace;
         if sql%notfound then
            raise_application_error(-20000, 'Add Data Exception - Header/trace (' || to_char(rcd_lics_hdr_trace.het_header,'FM999999999999990') || '/' || to_char(rcd_lics_hdr_trace.het_hdr_trace,'FM99990') || ') does not exist');
         end if;
      end if;

      /*-*/
      /* Update the data status when required
      /* note - data_error
      /*-*/
      if rcd_lics_data.dat_status = lics_constant.data_available then
         rcd_lics_data.dat_status := lics_constant.data_error;
         update lics_data
            set dat_status = rcd_lics_data.dat_status
          where dat_header = rcd_lics_data.dat_header
            and dat_dta_seq = rcd_lics_data.dat_dta_seq;
         if sql%notfound then
            raise_application_error(-20000, 'Add Data Exception - Header/data (' || to_char(rcd_lics_data.dat_header,'FM999999999999990') || '/' || to_char(rcd_lics_data.dat_dta_seq,'FM999999999999990') || ') does not exist');
         end if;
      end if;

      /*-*/
      /* Insert the data message
      /*-*/
      var_dta_message := var_dta_message + 1;
      rcd_lics_dta_message.dam_header := rcd_lics_data.dat_header;
      rcd_lics_dta_message.dam_hdr_trace := rcd_lics_hdr_trace.het_hdr_trace;
      rcd_lics_dta_message.dam_dta_seq := rcd_lics_data.dat_dta_seq;
      rcd_lics_dta_message.dam_msg_seq := var_dta_message;
      rcd_lics_dta_message.dam_text := par_exception;
      insert into lics_dta_message
         (dam_header,
          dam_hdr_trace,
          dam_dta_seq,
          dam_msg_seq,
          dam_text)
      values(rcd_lics_dta_message.dam_header,
             rcd_lics_dta_message.dam_hdr_trace,
             rcd_lics_dta_message.dam_dta_seq,
             rcd_lics_dta_message.dam_msg_seq,
             rcd_lics_dta_message.dam_text);

      /*-*/
      /* Commit the database
      /* note - isolated commit (autonomous transaction)
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end add_data_exception;

end lics_inbound_processor;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_inbound_processor for lics_app.lics_inbound_processor;
grant execute on lics_inbound_processor to public;