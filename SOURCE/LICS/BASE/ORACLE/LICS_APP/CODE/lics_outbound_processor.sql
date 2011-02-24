/******************/
/* Package Header */
/******************/
create or replace package lics_outbound_processor as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_outbound_processor
    Owner   : lics_app
    Author  : Steve Gregan - January 2004

    DESCRIPTION
    -----------
    Local Interface Control System - Outbound Processor

    The package implements the outbound processor functionality.

    1. This package has been designed as a single instance class to facilitate
       re-engineering in an object oriented language. That is, in an OO environment
       the host would create one or more instances of this class and pass the reference
       to the target objects. However, in the PL/SQL environment only one global instance
       is available at any one time.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2004/01   Steve Gregan   Created
    2006/08   Steve Gregan   Added message name functionality
    2006/11   Steve Gregan   Added single processing functionality
    2011/02   Steve Gregan   End point architecture version

   *******************************************************************************/

   /**/
   /* Public declarations
   /**/
   procedure execute(par_group in varchar2,
                     par_job in varchar2,
                     par_execution in number);
   procedure execute_single(par_header in number);

end lics_outbound_processor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_outbound_processor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /**/
   /* Private declarations
   /**/
   procedure select_interface;
   procedure send_interface;
   procedure add_header_exception(par_exception in varchar2);

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
   var_hdr_message lics_hdr_message.hem_msg_seq%type;
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
      /* Set the parameter variable
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
      var_ctl_pipe := lics_constant.queue_outbound || var_group;
      var_ctl_wake := false;
      var_ctl_suspend := false;
      var_ctl_stop := false;
      var_suspended := false;

      /*-*/
      /* Process the outbound group until stop requested
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

      /**/
      /* Exception trap
      /**/
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
                                        lics_constant.type_outbound,
                                        var_group,
                                        null,
                                        null,
                                        null,
                                        null,
                                        'OUTBOUND PROCESSOR FAILED - ' || substr(SQLERRM, 1, 1024));
         exception
            when others then
               raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Outbound Processor - ' || substr(SQLERRM, 1, 1024));
         end;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

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
      rcd_lics_header.hea_fil_name := rcd_lics_header_01.hea_fil_name;
      rcd_lics_header.hea_msg_name := rcd_lics_header_01.hea_msg_name;
      rcd_lics_header.hea_status := rcd_lics_header_01.hea_status;
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
      if rcd_lics_interface_01.int_type <> lics_constant.type_outbound then
         raise_application_error(-20000, 'Execute Single - Interface (' || rcd_lics_header_01.hea_interface || ') is not ' || lics_constant.type_outbound);
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
      rcd_lics_interface.int_lod_type := rcd_lics_interface_01.int_lod_type;

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
      /* Send the interface file
      /*-*/
      send_interface;

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
                                       lics_constant.type_outbound,
                                       null,
                                       null,
                                       rcd_lics_interface.int_interface,
                                       rcd_lics_header.hea_header,
                                       rcd_lics_hdr_trace.het_hdr_trace,
                                       'OUTBOUND PROCESSOR SUCCESS');
      else
         lics_notification.log_error('*SINGLE',
                                     null,
                                     lics_constant.type_outbound,
                                     null,
                                     null,
                                     rcd_lics_interface.int_interface,
                                     rcd_lics_header.hea_header,
                                     rcd_lics_hdr_trace.het_hdr_trace,
                                     'OUTBOUND PROCESSOR ERROR - see trace messages for more details',
                                     rcd_lics_interface.int_opr_alert,
                                     rcd_lics_interface.int_ema_group);
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
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
                                        lics_constant.type_outbound,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        'OUTBOUND PROCESSOR FAILED - ' || substr(SQLERRM, 1, 512));
         exception
            when others then
               raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Outbound Processor - ' || substr(SQLERRM, 1, 512));
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
                t01.int_procedure,
                t01.int_lod_type
           from lics_interface t01
          where t01.int_type = lics_constant.type_outbound
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
                t01.hea_fil_name,
                t01.hea_msg_name,
                t01.hea_status
           from lics_header t01
          where t01.hea_header = var_header
                for update nowait;
      rcd_lics_header_02 csr_lics_header_02%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the interfaces related to the process
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
         rcd_lics_interface.int_lod_type := rcd_lics_interface_01.int_lod_type;

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
                  rcd_lics_header.hea_fil_name := rcd_lics_header_02.hea_fil_name;
                  rcd_lics_header.hea_msg_name := rcd_lics_header_02.hea_msg_name;
                  rcd_lics_header.hea_status := rcd_lics_header_02.hea_status;
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
                  /* Send the interface file
                  /*-*/
                  send_interface;

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
                                                   lics_constant.type_outbound,
                                                   rcd_lics_interface.int_group,
                                                   null,
                                                   rcd_lics_interface.int_interface,
                                                   rcd_lics_header.hea_header,
                                                   rcd_lics_hdr_trace.het_hdr_trace,
                                                   'OUTBOUND PROCESSOR SUCCESS');
                  else
                     lics_notification.log_error(var_job,
                                                 var_execution,
                                                 lics_constant.type_outbound,
                                                 rcd_lics_interface.int_group,
                                                 null,
                                                 rcd_lics_interface.int_interface,
                                                 rcd_lics_header.hea_header,
                                                 rcd_lics_hdr_trace.het_hdr_trace,
                                                 'OUTBOUND PROCESSOR ERROR - see trace messages for more details',
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

   /******************************************************/
   /* This procedure performs the send interface routine */
   /******************************************************/
   procedure send_interface is

      /*-*/
      /* Local definitions
      /*-*/
      var_pth_name varchar2(256);
      var_fil_path varchar2(128);
      var_fil_name varchar2(64);
      var_msg_name varchar2(64);
      var_script varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the outbound path/file/message information
      /*-*/
      var_fil_path := lics_parameter.outbound_directory;
      var_fil_name := rcd_lics_header.hea_fil_name;
      var_msg_name := rcd_lics_header.hea_msg_name;
      if substr(var_fil_path, -1, 1) <> lics_parameter.ics_path_delimiter then
         var_fil_path := var_fil_path || lics_parameter.ics_path_delimiter;
      end if;
      var_pth_name := var_fil_path || var_fil_name;

      /*-*/
      /* Perform the path/file/message substitution as required
      /*-*/
      var_script := rcd_lics_interface.int_procedure;
      var_script := replace(var_script,'<PATH>',var_pth_name);
      var_script := replace(var_script,'<FILE>',var_fil_name);
      var_script := replace(var_script,'<MESG>',var_msg_name);
      var_script := replace(var_script,'<SCRIPT_PATH>',lics_parameter.ics_script_path);

      if upper(rcd_lics_interface.int_lod_type = '*EPA') then
         var_script := replace(var_script,'<AMI_PATH>',lics_parameter.ami_path);
      else
         var_script := replace(var_script,'<SCRIPT_PATH>',lics_parameter.ics_script_path||lics_parameter.ics_path_delimiter);
      end if;

      /*-*/
      /* Execute the outbound send script
      /* 1. Send the interface file
      /* 2. Archive the interface file (delete the source file and replace the target file)
      /*-*/
      begin
         lics_filesystem.execute_external_procedure(var_script);
         lics_filesystem.archive_file_gzip(lics_parameter.inbound_directory, var_fil_name, lics_parameter.archive_directory, var_fil_name||'.gz', '1', '1');
         when others then
            add_header_exception('EXTERNAL PROCESS ERROR - Send Interface - ' || substr(SQLERRM, 1, 3900));
      end;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap */
      /*-*/
      when others then
         add_header_exception('SQL ERROR - Send Interface - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end send_interface;

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
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end add_header_exception;

end lics_outbound_processor;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_outbound_processor for lics_app.lics_outbound_processor;
grant execute on lics_outbound_processor to public;