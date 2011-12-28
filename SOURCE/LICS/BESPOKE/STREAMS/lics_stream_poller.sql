/******************/
/* Package Header */
/******************/
create or replace package lics_stream_poller as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_stream_poller
    Owner   : lics_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Local Interface Control System - Stream Poller

    The package implements the stream poller functionality.

    1. The procedure is executed on an polling thread and supports the use of multiple
       parallel polling threads. With this model it is possible to have any combination
       of single to multiple threads executing any combination of parameters.

    2. The invocation interval is controlled by the polling thread.

    3. The polling threads provide load balancing and thread safety.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/08   Steve Gregan   Created
    2011/11   Steve Gregan   Added stream multiple dependency functionality

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end lics_stream_poller;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_stream_poller as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure stream_process(par_exe_seqn in number);
   procedure stream_open(par_exe_seqn in number);
   procedure stream_cancel(par_exe_seqn in number);
   procedure stream_pause(par_exe_seqn in number);
   procedure stream_resume(par_exe_seqn in number);
   procedure task_completed(par_exe_seqn in number, par_tsk_code in varchar2);
   procedure task_fail(par_exe_seqn in number, par_tsk_code in varchar2);
   procedure task_cancel(par_exe_seqn in number, par_tsk_code in varchar2);
   procedure gate_completed(par_exe_seqn in number, par_tsk_code in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   type ptyp_task is table of varchar2(32 char) index by varchar2(32);
   ptbl_task ptyp_task;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_stream_request is
         select t01.*
           from lics_str_exe_header t01
          where t01.sth_exe_status in ('*PENDING','*OPENED','*OPNPAUSED')
            and t01.sth_exe_request != '*NONE'
          order by t01.sth_exe_seqn asc;
      rcd_stream_request csr_stream_request%rowtype;

      cursor csr_stream_process is
         select t01.*
           from lics_str_exe_header t01
          where t01.sth_exe_status in ('*OPENED','*OPNCANCEL')
          order by t01.sth_exe_seqn asc;
      rcd_stream_process csr_stream_process%rowtype;

      cursor csr_stream_open is
         select t01.sth_exe_seqn
           from (select t01.sth_exe_seqn,
                        t01.sth_exe_status,
                        t01.sth_str_code,
                        rank() over (partition by t01.sth_str_code
                                         order by t01.sth_exe_seqn asc) as strseq
                   from lics_str_exe_header t01
                  where t01.sth_exe_status = '*PENDING') t01
          where t01.strseq = 1
            and not(t01.sth_str_code in (select sth_str_code
                                           from lics_str_exe_header
                                          where sth_str_code = t01.sth_str_code
                                            and sth_exe_status in ('*OPENED','*OPNCANCEL','*OPNPAUSED')))
          order by t01.sth_exe_seqn asc;
      rcd_stream_open csr_stream_open%rowtype;

      cursor csr_submit_event is
         select t01.ste_exe_seqn,
                t01.ste_tsk_code,
                t01.ste_evt_code
           from (select t01.*,
                        t02.stt_tsk_seqn,
                        rank() over (partition by t01.ste_evt_lock
                                         order by t01.ste_exe_seqn asc,
                                                  t02.stt_tsk_seqn asc,
                                                  t01.ste_evt_seqn asc) as lckseq
                   from lics_str_exe_event t01,
                        lics_str_exe_task t02
                  where t01.ste_exe_seqn = t02.stt_exe_seqn
                    and t01.ste_tsk_code = t02.stt_tsk_code
                    and t01.ste_exe_status = '*QUEUED') t01
          where t01.lckseq = 1
            and not(t01.ste_evt_lock in (select ste_evt_lock
                                           from lics_str_exe_event
                                          where ste_evt_lock = t01.ste_evt_lock
                                            and ste_exe_status in ('*OPENED','*WORKING')))
          order by t01.ste_exe_seqn asc,
                   t01.stt_tsk_seqn asc,
                   t01.ste_evt_seqn asc;
      rcd_submit_event csr_submit_event%rowtype;

      cursor csr_event is 
         select t01.*
           from lics_str_exe_event t01
          where t01.ste_exe_seqn = rcd_submit_event.ste_exe_seqn
            and t01.ste_tsk_code = rcd_submit_event.ste_tsk_code
            and t01.ste_evt_code = rcd_submit_event.ste_evt_code
            for update nowait;
      rcd_event csr_event%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process stream requests
      /* **notes**
      /* 1. Outstanding requests on pending and opened streams are processed here
      /*-*/
      open csr_stream_request;
      loop
         fetch csr_stream_request into rcd_stream_request;
         if csr_stream_request%notfound then
            exit;
         end if;
         if rcd_stream_request.sth_exe_request = '*CANCEL' then
            stream_cancel(rcd_stream_request.sth_exe_seqn);
         elsif rcd_stream_request.sth_exe_request = '*PAUSE' then
            stream_pause(rcd_stream_request.sth_exe_seqn);
         elsif rcd_stream_request.sth_exe_request = '*RESUME' then
            stream_resume(rcd_stream_request.sth_exe_seqn);
         end if;
      end loop;
      close csr_stream_request;

      /*-*/
      /* Process open streams
      /*-*/
      open csr_stream_process;
      loop
         fetch csr_stream_process into rcd_stream_process;
         if csr_stream_process%notfound then
            exit;
         end if;
         stream_process(rcd_stream_process.sth_exe_seqn);
      end loop;
      close csr_stream_process;

      /*-*/
      /* Open pending streams
      /* **notes**
      /* 1. Execution instances of the same stream are serialized
      /*-*/
      open csr_stream_open;
      loop
         fetch csr_stream_open into rcd_stream_open;
         if csr_stream_open%notfound then
            exit;
         end if;
         stream_open(rcd_stream_open.sth_exe_seqn);
      end loop;
      close csr_stream_open;

      /*-*/
      /* Submit the stream events
      /* **notes**
      /* 1. Processes all open stream *QUEUED events by event lock that have an available lock (no *OPENED event for the lock)
      /* 2. Event status changes to *OPENED until processing has completed or failed so as to block the selection of the next *QUEUED event
      /* 3. The SQL only pops the first event in the stack so that subsequent events are held until the lock is available
      /* 4. The locks are implemented across all streams to prevent deadlocks and data corruption
      /* 5. The submit architecture does not ensure that all submitted events will execute in parallel. The number of events that will
      /*    execute in parallel is determined by the number of jobs defined in the event job groups
      /*-*/
      open csr_submit_event;
      loop
         fetch csr_submit_event into rcd_submit_event;
         if csr_submit_event%notfound then
            exit;
         end if;

         /*-*/
         /* Attempt to lock the stream event row
         /* notes - must still exist
         /*         must still be opened status
         /*         must not be locked
         /*-*/
         var_available := true;
         begin
            open csr_event;
            fetch csr_event into rcd_event;
            if csr_event%notfound then
               var_available := false;
            else
               if rcd_event.ste_exe_status != '*QUEUED' then
                  var_available := false;
               end if;
            end if;
         exception
            when others then
               var_available := false;
         end;
         if csr_event%isopen then
            close csr_event;
         end if;

         /*-*/
         /* Release the stream event lock when not available
         /* 1. Cursor row locks are not released until commit or rollback
         /* 2. Cursor close does not release row locks
         /*-*/
         if var_available = false then

            /*-*/
            /* Rollback to release row locks
            /*-*/
            rollback;

         /*-*/
         /* Process the stream event when available
         /*-*/
         else

            /*-*/
            /* Update the stream event and commit
            /*-*/
            update lics_str_exe_event
               set ste_exe_status = '*OPENED',
                   ste_exe_open = sysdate
             where ste_exe_seqn = rcd_event.ste_exe_seqn
               and ste_tsk_code = rcd_event.ste_tsk_code
               and ste_evt_code = rcd_event.ste_evt_code;
            commit;

            /*-*/
            /* Trigger the stream event
            /*-*/
            lics_trigger_loader.execute('LICS Stream Processor',
                                        'lics_stream_processor.execute('||rcd_event.ste_exe_seqn||','''||rcd_event.ste_tsk_code||''','''||rcd_event.ste_evt_code||''')',
                                        rcd_event.ste_opr_alert,
                                        rcd_event.ste_ema_group,
                                        rcd_event.ste_job_group);

         end if;

      end loop;
      close csr_submit_event;

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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Stream Poller - EXECUTE - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /******************************************************/
   /* This procedure performs the stream process routine */
   /******************************************************/
   procedure stream_process(par_exe_seqn in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_stream is
         select t01.*
           from lics_str_exe_header t01
          where t01.sth_exe_seqn = par_exe_seqn
            for update nowait;
      rcd_stream csr_stream%rowtype;

      cursor csr_open_task is
         select t01.*,
                (select count(*)
                   from lics_str_exe_event t11
                  where t11.ste_exe_seqn = t01.stt_exe_seqn
                    and t11.ste_tsk_code = t01.stt_tsk_code) as tot_count,
                (select sum(decode(t11.ste_exe_status,'*COMPLETED',1,'*FAILED',1,'*CANCELLED',1,0))
                   from lics_str_exe_event t11
                  where t11.ste_exe_seqn = t01.stt_exe_seqn
                    and t11.ste_tsk_code = t01.stt_tsk_code) as pro_count,
                (select sum(decode(t11.ste_exe_status,'*COMPLETED',1,0))
                   from lics_str_exe_event t11
                  where t11.ste_exe_seqn = t01.stt_exe_seqn
                    and t11.ste_tsk_code = t01.stt_tsk_code) as com_count,
                (select sum(decode(t11.ste_exe_status,'*FAILED',1,0))
                   from lics_str_exe_event t11
                  where t11.ste_exe_seqn = t01.stt_exe_seqn
                    and t11.ste_tsk_code = t01.stt_tsk_code) as fal_count,
                (select sum(decode(t11.ste_exe_status,'*CANCELLED',1,0))
                   from lics_str_exe_event t11
                  where t11.ste_exe_seqn = t01.stt_exe_seqn
                    and t11.ste_tsk_code = t01.stt_tsk_code) as can_count
           from lics_str_exe_task t01
          where t01.stt_exe_seqn = rcd_stream.sth_exe_seqn
            and t01.stt_tsk_type = '*EXEC'
            and t01.stt_exe_status = '*OPENED'
          order by t01.stt_tsk_seqn asc;
      rcd_open_task csr_open_task%rowtype;

      cursor csr_gate_test is
         select t01.*,
                (select count(*)
                   from lics_str_exe_depend t11,
                        lics_str_exe_task t12
                  where t11.std_exe_seqn = t12.stt_exe_seqn
                    and t11.std_dep_code = t12.stt_tsk_code
                    and t11.std_exe_seqn = t01.stt_exe_seqn
                    and t11.std_tsk_code = t01.stt_tsk_code) as tot_count,
                (select sum(decode(t12.stt_exe_status,'*COMPLETED',1,0))
                   from lics_str_exe_depend t11,
                        lics_str_exe_task t12
                  where t11.std_exe_seqn = t12.stt_exe_seqn
                    and t11.std_dep_code = t12.stt_tsk_code
                    and t11.std_exe_seqn = t01.stt_exe_seqn
                    and t11.std_tsk_code = t01.stt_tsk_code) as com_count
           from lics_str_exe_task t01
          where t01.stt_exe_seqn = rcd_stream.sth_exe_seqn
            and t01.stt_tsk_type = '*GATE'
            and t01.stt_exe_status = '*PENDING'
          order by t01.stt_tsk_seqn asc;
      rcd_gate_test csr_gate_test%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Attempt to lock the stream
      /* notes - must still exist
      /*         must still be opened or opened cancel status
      /*         must not be locked
      /*-*/
      var_available := true;
      begin
         open csr_stream;
         fetch csr_stream into rcd_stream;
         if csr_stream%notfound then
            var_available := false;
         else
            if (rcd_stream.sth_exe_status != '*OPENED' and rcd_stream.sth_exe_status != '*OPNCANCEL') then
               var_available := false;
            end if;
         end if;
      exception
         when others then
            var_available := false;
      end;
      if csr_stream%isopen then
         close csr_stream;
      end if;

      /*-*/
      /* Release the stream row lock when not available
      /* 1. Cursor row locks are not released until commit or rollback
      /* 2. Cursor close does not release row locks
      /*-*/
      if var_available = false then

         /*-*/
         /* Rollback to release row locks
         /*-*/
         rollback;

      /*-*/
      /* Process the stream when available
      /*-*/
      else

         /*-*/
         /* Perform the open task processing
         /* **notes**
         /* 1. Retrieve stream open tasks where all events have been processed
         /* 2. The task is closed when all events have completed successfully
         /* 3. The task is cancelled when any events have failed
         /*-*/
         open csr_open_task;
         loop
            fetch csr_open_task into rcd_open_task;
            if csr_open_task%notfound then
               exit;
            end if;

            /*-*/
            /* All events processed
            /*-*/
            if rcd_open_task.tot_count = rcd_open_task.pro_count then

               /*-*/
               /* Opened task
               /*-*/
               if rcd_stream.sth_exe_status = '*OPENED' then

                  /*-*/
                  /* All events completed successfully
                  /*-*/
                  if rcd_open_task.tot_count = rcd_open_task.com_count then

                     /*-*/
                     /* Complete the current task and open direct decendent tasks
                     /*-*/
                     task_completed(rcd_open_task.stt_exe_seqn, rcd_open_task.stt_tsk_code);

                  /*-*/
                  /* Some events failed
                  /*-*/
                  else

                     /*-*/
                     /* Fail the current task and all decendent tasks
                     /*-*/
                     ptbl_task.delete;
                     task_fail(rcd_open_task.stt_exe_seqn, rcd_open_task.stt_tsk_code);

                  end if;

               end if;

               /*-*/
               /* Opened cancelling task
               /*-*/
               if rcd_stream.sth_exe_status = '*OPNCANCEL' then

                  /*-*/
                  /* All events completed successfully
                  /*-*/
                  if rcd_open_task.tot_count = rcd_open_task.com_count then

                     /*-*/
                     /* Set the task to *COMPLETED
                     /*-*/
                     update lics_str_exe_task
                        set stt_exe_status = '*COMPLETED',
                            stt_exe_end = sysdate
                      where stt_exe_seqn = rcd_open_task.stt_exe_seqn
                        and stt_tsk_code = rcd_open_task.stt_tsk_code;

                  /*-*/
                  /* Some events failed/cancelled
                  /*-*/
                  else

                     /*-*/
                     /* Set the task to *CANCELLED
                     /*-*/
                     update lics_str_exe_task
                        set stt_exe_status = '*CANCELLED',
                            stt_exe_end = sysdate
                      where stt_exe_seqn = rcd_open_task.stt_exe_seqn
                        and stt_tsk_code = rcd_open_task.stt_tsk_code;

                  end if;

               end if;

            end if;

         end loop;
         close csr_open_task;

         /*-*/
         /* Perform the gate test processing for opened streams
         /* **notes**
         /* 1. Opened cancelling streams are ignored (all remaining gates and tasks already cancelled)
         /* 2. Pending gate dependency status are retrieved
         /* 3. Gate is opened (*COMPLETED) when all dependencies have completed successfully
         /*-*/
         if rcd_stream.sth_exe_status = '*OPENED' then
            open csr_gate_test;
            loop
               fetch csr_gate_test into rcd_gate_test;
               if csr_gate_test%notfound then
                  exit;
               end if;

               /*-*/
               /* All dependencies completed successfully
               /*-*/
               if rcd_gate_test.tot_count = rcd_gate_test.com_count then

                  /*-*/
                  /* Complete the current gate and open direct decendent tasks
                  /*-*/
                  gate_completed(rcd_gate_test.stt_exe_seqn, rcd_gate_test.stt_tsk_code);

               end if;

            end loop;
            close csr_gate_test;
         end if;

         /*-*/
         /* Set the opened stream to *COMPLETED when all tasks processed
         /*-*/
         if rcd_stream.sth_exe_status = '*OPENED' then
            update lics_str_exe_header
               set sth_exe_status = '*COMPLETED',
                   sth_exe_end = sysdate
             where sth_exe_seqn = (select t01.sth_exe_seqn
                                     from (select t01.sth_exe_seqn,
                                                  (select count(*)
                                                     from lics_str_exe_task t11
                                                    where t11.stt_exe_seqn = t01.sth_exe_seqn) as tot_count,
                                                  (select sum(decode(t11.stt_exe_status,'*COMPLETED',1,'*FAILED',1,'*CANCELLED',1,0))
                                                     from lics_str_exe_task t11
                                                    where t11.stt_exe_seqn = t01.sth_exe_seqn) as com_count
                                             from lics_str_exe_header t01
                                            where t01.sth_exe_seqn = rcd_stream.sth_exe_seqn) t01
                                    where t01.tot_count = t01.com_count);
         end if;

         /*-*/
         /* Set the opened cancelling stream to *CANCELLED when all tasks processed
         /*-*/
         if rcd_stream.sth_exe_status = '*OPNCANCEL' then
            update lics_str_exe_header
               set sth_exe_status = '*CANCELLED',
                   sth_exe_end = sysdate
             where sth_exe_seqn = (select t01.sth_exe_seqn
                                     from (select t01.sth_exe_seqn,
                                                  (select count(*)
                                                     from lics_str_exe_task t11
                                                    where t11.stt_exe_seqn = t01.sth_exe_seqn) as tot_count,
                                                  (select sum(decode(t11.stt_exe_status,'*COMPLETED',1,'*FAILED',1,'*CANCELLED',1,0))
                                                     from lics_str_exe_task t11
                                                    where t11.stt_exe_seqn = t01.sth_exe_seqn) as com_count
                                             from lics_str_exe_header t01
                                            where t01.sth_exe_seqn = rcd_stream.sth_exe_seqn) t01
                                    where t01.tot_count = t01.com_count);
         end if;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Stream Poller - STREAM_PROCESS - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end stream_process;

   /***************************************************/
   /* This procedure performs the stream open routine */
   /***************************************************/
   procedure stream_open(par_exe_seqn in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_stream is
         select t01.*
           from lics_str_exe_header t01
          where t01.sth_exe_seqn = par_exe_seqn
            for update nowait;
      rcd_stream csr_stream%rowtype;

      cursor csr_task_open is
         select t01.*
           from lics_str_exe_task t01
          where t01.stt_exe_seqn = par_exe_seqn
            and t01.stt_tsk_pcde = '*TOP'
            and t01.stt_tsk_type = '*EXEC'
          order by t01.stt_tsk_seqn asc;
      rcd_task_open csr_task_open%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Attempt to lock the stream
      /* notes - must still exist
      /*         must still be pending status
      /*         must still be *NONE request
      /*         must not be locked
      /*-*/
      var_available := true;
      begin
         open csr_stream;
         fetch csr_stream into rcd_stream;
         if csr_stream%notfound then
            var_available := false;
         else
            if rcd_stream.sth_exe_status != '*PENDING' or
               rcd_stream.sth_exe_request != '*NONE' then
               var_available := false;
            end if;
         end if;
      exception
         when others then
            var_available := false;
      end;
      if csr_stream%isopen then
         close csr_stream;
      end if;

      /*-*/
      /* Release the stream row lock when not available
      /* 1. Cursor row locks are not released until commit or rollback
      /* 2. Cursor close does not release row locks
      /*-*/
      if var_available = false then

         /*-*/
         /* Rollback to release row locks
         /*-*/
         rollback;

      /*-*/
      /* Process the stream when available
      /*-*/
      else

         /*-*/
         /* Set the stream to *OPENED
         /*-*/
         update lics_str_exe_header
            set sth_exe_status = '*OPENED',
                sth_exe_start = sysdate
          where sth_exe_seqn = par_exe_seqn;

         /*-*/
         /* Perform the child task open processing
         /* **notes**
         /* 1. Execution tasks for the parent *TOP are retrieved and opened (direct decendents only)
         /* 2. Execution events for each child task are opened
         /*-*/
         open csr_task_open;
         loop
            fetch csr_task_open into rcd_task_open;
            if csr_task_open%notfound then
               exit;
            end if;

            /*-*/
            /* Set the child task to *OPENED
            /*-*/
            update lics_str_exe_task
               set stt_exe_status = '*OPENED',
                   stt_exe_start = sysdate
             where stt_exe_seqn = rcd_task_open.stt_exe_seqn
               and stt_tsk_code = rcd_task_open.stt_tsk_code;

            /*-*/
            /* Set the child task events to *QUEUED
            /*-*/
            update lics_str_exe_event
               set ste_exe_status = '*QUEUED',
                   ste_exe_queued = sysdate
             where ste_exe_seqn = rcd_task_open.stt_exe_seqn
               and ste_tsk_code = rcd_task_open.stt_tsk_code;

         end loop;
         close csr_task_open;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Stream Poller - STREAM_OPEN - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end stream_open;

   /*****************************************************/
   /* This procedure performs the stream cancel routine */
   /*****************************************************/
   procedure stream_cancel(par_exe_seqn in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_stream is
         select t01.*
           from lics_str_exe_header t01
          where t01.sth_exe_seqn = par_exe_seqn
            for update nowait;
      rcd_stream csr_stream%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Attempt to lock the stream
      /* notes - must still exist
      /*         must still be pending or opened status
      /*         must still be cancel request
      /*         must not be locked
      /*-*/
      var_available := true;
      begin
         open csr_stream;
         fetch csr_stream into rcd_stream;
         if csr_stream%notfound then
            var_available := false;
         else
            if (rcd_stream.sth_exe_status != '*PENDING' and rcd_stream.sth_exe_status != '*OPENED') or
               rcd_stream.sth_exe_request != '*CANCEL' then
               var_available := false;
            end if;
         end if;
      exception
         when others then
            var_available := false;
      end;
      if csr_stream%isopen then
         close csr_stream;
      end if;

      /*-*/
      /* Release the stream row lock when not available
      /* 1. Cursor row locks are not released until commit or rollback
      /* 2. Cursor close does not release row locks
      /*-*/
      if var_available = false then

         /*-*/
         /* Rollback to release row locks
         /*-*/
         rollback;

      /*-*/
      /* Process the stream when available
      /*-*/
      else

         /*-*/
         /* Set the stream to *CANCELLED
         /*-*/
         if rcd_stream.sth_exe_status = '*PENDING' then

            /*-*/
            /* Set the stream to *CANCELLED
            /*-*/
            update lics_str_exe_header
               set sth_exe_status = '*CANCELLED',
                   sth_exe_request = '*NONE',
                   sth_exe_end = sysdate
             where sth_exe_seqn = par_exe_seqn;

            /*-*/
            /* Set the tasks to *CANCELLED
            /*-*/
            update lics_str_exe_task
               set stt_exe_status = '*CANCELLED',
                   stt_exe_end = sysdate
             where stt_exe_seqn = par_exe_seqn;

            /*-*/
            /* Set the events to *CANCELLED
            /*-*/
            update lics_str_exe_event
               set ste_exe_status = '*CANCELLED',
                   ste_exe_end = sysdate
             where ste_exe_seqn = par_exe_seqn;

         else

            /*-*/
            /* Set the stream to *OPNCANCEL
            /*-*/
            update lics_str_exe_header
               set sth_exe_status = '*OPNCANCEL',
                   sth_exe_request = '*NONE',
                   sth_exe_end = sysdate
             where sth_exe_seqn = par_exe_seqn;

            /*-*/
            /* Set the pending tasks to *CANCELLED
            /*-*/
            update lics_str_exe_task
               set stt_exe_status = '*CANCELLED',
                   stt_exe_end = sysdate
             where stt_exe_seqn = par_exe_seqn
               and stt_exe_status = '*PENDING';

            /*-*/
            /* Set the pending/queued events to *CANCELLED
            /*-*/
            update lics_str_exe_event
               set ste_exe_status = '*CANCELLED',
                   ste_exe_end = sysdate
             where ste_exe_seqn = par_exe_seqn
               and (ste_exe_status = '*PENDING' or ste_exe_status = '*QUEUED');

         end if;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Stream Poller - STREAM_CANCEL - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end stream_cancel;

   /****************************************************/
   /* This procedure performs the stream pause routine */
   /****************************************************/
   procedure stream_pause(par_exe_seqn in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_stream is
         select t01.*
           from lics_str_exe_header t01
          where t01.sth_exe_seqn = par_exe_seqn
            for update nowait;
      rcd_stream csr_stream%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Attempt to lock the stream
      /* notes - must still exist
      /*         must still be opened status
      /*         must still be pause request
      /*         must not be locked
      /*-*/
      var_available := true;
      begin
         open csr_stream;
         fetch csr_stream into rcd_stream;
         if csr_stream%notfound then
            var_available := false;
         else
            if rcd_stream.sth_exe_status != '*OPENED' or
               rcd_stream.sth_exe_request != '*PAUSE' then
               var_available := false;
            end if;
         end if;
      exception
         when others then
            var_available := false;
      end;
      if csr_stream%isopen then
         close csr_stream;
      end if;

      /*-*/
      /* Release the stream row lock when not available
      /* 1. Cursor row locks are not released until commit or rollback
      /* 2. Cursor close does not release row locks
      /*-*/
      if var_available = false then

         /*-*/
         /* Rollback to release row locks
         /*-*/
         rollback;

      /*-*/
      /* Process the stream when available
      /*-*/
      else

         /*-*/
         /* Set the stream to *OPNPAUSED
         /*-*/
         update lics_str_exe_header
            set sth_exe_status = '*OPNPAUSED',
                sth_exe_request = '*NONE',
                sth_exe_end = sysdate
          where sth_exe_seqn = par_exe_seqn;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Stream Poller - STREAM_PAUSE - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end stream_pause;

   /*****************************************************/
   /* This procedure performs the stream resume routine */
   /*****************************************************/
   procedure stream_resume(par_exe_seqn in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_stream is
         select t01.*
           from lics_str_exe_header t01
          where t01.sth_exe_seqn = par_exe_seqn
            for update nowait;
      rcd_stream csr_stream%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Attempt to lock the stream
      /* notes - must still exist
      /*         must still be open paused status
      /*         must still be resume request
      /*         must not be locked
      /*-*/
      var_available := true;
      begin
         open csr_stream;
         fetch csr_stream into rcd_stream;
         if csr_stream%notfound then
            var_available := false;
         else
            if rcd_stream.sth_exe_status != '*OPNPAUSED' or
               rcd_stream.sth_exe_request != '*RESUME' then
               var_available := false;
            end if;
         end if;
      exception
         when others then
            var_available := false;
      end;
      if csr_stream%isopen then
         close csr_stream;
      end if;

      /*-*/
      /* Release the stream row lock when not available
      /* 1. Cursor row locks are not released until commit or rollback
      /* 2. Cursor close does not release row locks
      /*-*/
      if var_available = false then

         /*-*/
         /* Rollback to release row locks
         /*-*/
         rollback;

      /*-*/
      /* Process the stream when available
      /*-*/
      else

         /*-*/
         /* Set the stream to *OPENED
         /*-*/
         update lics_str_exe_header
            set sth_exe_status = '*OPENED',
                sth_exe_request = '*NONE',
                sth_exe_end = sysdate
          where sth_exe_seqn = par_exe_seqn;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Stream Poller - STREAM_RESUME - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end stream_resume;

   /******************************************************/
   /* This procedure performs the task completed routine */
   /******************************************************/
   procedure task_completed(par_exe_seqn in number, par_tsk_code in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_task_open is
         select t01.*
           from lics_str_exe_task t01
          where t01.stt_exe_seqn = par_exe_seqn
            and t01.stt_tsk_pcde = par_tsk_code
            and t01.stt_tsk_type = '*EXEC'
          order by t01.stt_tsk_seqn asc;
      rcd_task_open csr_task_open%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the task to *COMPLETED
      /*-*/
      update lics_str_exe_task
         set stt_exe_status = '*COMPLETED',
             stt_exe_end = sysdate
       where stt_exe_seqn = par_exe_seqn
         and stt_tsk_code = par_tsk_code;

      /*-*/
      /* Perform the child task open processing
      /* **notes**
      /* 1. Execution tasks for the parent task are retrieved and opened (direct decendents only)
      /* 2. Execution events for each child task are opened
      /*-*/
      open csr_task_open;
      loop
         fetch csr_task_open into rcd_task_open;
         if csr_task_open%notfound then
            exit;
         end if;

         /*-*/
         /* Set the child task to *OPENED
         /*-*/
         update lics_str_exe_task
            set stt_exe_status = '*OPENED',
                stt_exe_start = sysdate
          where stt_exe_seqn = rcd_task_open.stt_exe_seqn
            and stt_tsk_code = rcd_task_open.stt_tsk_code;

         /*-*/
         /* Set the child task events to *QUEUED
         /*-*/
         update lics_str_exe_event
            set ste_exe_status = '*QUEUED',
                ste_exe_queued = sysdate
          where ste_exe_seqn = rcd_task_open.stt_exe_seqn
            and ste_tsk_code = rcd_task_open.stt_tsk_code;

      end loop;
      close csr_task_open;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end task_completed;

   /*************************************************/
   /* This procedure performs the task fail routine */
   /*************************************************/
   procedure task_fail(par_exe_seqn in number, par_tsk_code in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_gate_cancel is
         select t01.*
           from lics_str_exe_depend t01,
                lics_str_exe_task t02
          where t01.std_exe_seqn = t02.stt_exe_seqn
            and t01.std_tsk_code = t02.stt_tsk_code
            and t01.std_exe_seqn = par_exe_seqn
            and t01.std_dep_code = par_tsk_code
            and t02.stt_exe_status != '*CANCELLED'
          order by t01.std_tsk_code;
      rcd_gate_cancel csr_gate_cancel%rowtype;

      cursor csr_child_cancel is
         select t01.*
           from lics_str_exe_task t01
          where t01.stt_exe_seqn = par_exe_seqn
            and t01.stt_tsk_pcde = par_tsk_code
            and t01.stt_tsk_type = '*EXEC'
          order by t01.stt_tsk_seqn asc;
      rcd_child_cancel csr_child_cancel%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Check for the the task code in the task tree
      /* **note** recursion is not supported in the task hierarchy
      /*-*/
      if ptbl_task.exists(par_tsk_code) then
         raise_application_error(-20000, 'The task hierarchy does not support recursion - stream execution ('||to_char(par_exe_seqn)||') task ('||par_tsk_code||'}');
      end if;
      ptbl_task(par_tsk_code) := par_tsk_code;

      /*-*/
      /* Set the task to *FAILED
      /*-*/
      update lics_str_exe_task
         set stt_exe_status = '*FAILED',
             stt_exe_end = sysdate
       where stt_exe_seqn = par_exe_seqn
         and stt_tsk_code = par_tsk_code;

      /*-*/
      /* Retrieve the task gate dependencies
      /*-*/
      open csr_gate_cancel;
      loop
         fetch csr_gate_cancel into rcd_gate_cancel;
         if csr_gate_cancel%notfound then
            exit;
         end if;

         /*-*/
         /* Cancel the dependent gate task
         /*-*/
         task_cancel(rcd_gate_cancel.std_exe_seqn, rcd_gate_cancel.std_tsk_code);

      end loop;
      close csr_gate_cancel;

      /*-*/
      /* Retrieve the child tasks
      /*-*/
      open csr_child_cancel;
      loop
         fetch csr_child_cancel into rcd_child_cancel;
         if csr_child_cancel%notfound then
            exit;
         end if;

         /*-*/
         /* Cancel the child task
         /*-*/
         task_cancel(rcd_child_cancel.stt_exe_seqn, rcd_child_cancel.stt_tsk_code);

      end loop;
      close csr_child_cancel;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end task_fail;

   /***************************************************/
   /* This procedure performs the task cancel routine */
   /***************************************************/
   procedure task_cancel(par_exe_seqn in number, par_tsk_code in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_gate_cancel is
         select t01.*
           from lics_str_exe_depend t01,
                lics_str_exe_task t02
          where t01.std_exe_seqn = t02.stt_exe_seqn
            and t01.std_tsk_code = t02.stt_tsk_code
            and t01.std_exe_seqn = par_exe_seqn
            and t01.std_dep_code = par_tsk_code
            and t02.stt_exe_status != '*CANCELLED'
          order by t01.std_tsk_code;
      rcd_gate_cancel csr_gate_cancel%rowtype;

      cursor csr_child_cancel is
         select t01.*
           from lics_str_exe_task t01
          where t01.stt_exe_seqn = par_exe_seqn
            and t01.stt_tsk_pcde = par_tsk_code
            and t01.stt_tsk_type = '*EXEC'
          order by t01.stt_tsk_seqn asc;
      rcd_child_cancel csr_child_cancel%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Check for the the task code in the task tree
      /* **note** recursion is not supported in the task hierarchy
      /*-*/
      if ptbl_task.exists(par_tsk_code) then
         raise_application_error(-20000, 'The task hierarchy does not support recursion - stream execution ('||to_char(par_exe_seqn)||') task ('||par_tsk_code||'}');
      end if;
      ptbl_task(par_tsk_code) := par_tsk_code;

      /*-*/
      /* Set the task to *CANCELLED
      /*-*/
      update lics_str_exe_task
         set stt_exe_status = '*CANCELLED',
             stt_exe_end = sysdate
       where stt_exe_seqn = par_exe_seqn
         and stt_tsk_code = par_tsk_code;

      /*-*/
      /* Set the task events to *CANCELLED
      /*-*/
      update lics_str_exe_event
         set ste_exe_status = '*CANCELLED',
             ste_exe_end = sysdate
       where ste_exe_seqn = par_exe_seqn
         and ste_tsk_code = par_tsk_code;

      /*-*/
      /* Retrieve the task gate dependencies
      /*-*/
      open csr_gate_cancel;
      loop
         fetch csr_gate_cancel into rcd_gate_cancel;
         if csr_gate_cancel%notfound then
            exit;
         end if;

         /*-*/
         /* Cancel the dependent gate task
         /*-*/
         task_cancel(rcd_gate_cancel.std_exe_seqn, rcd_gate_cancel.std_tsk_code);

      end loop;
      close csr_gate_cancel;

      /*-*/
      /* Retrieve the child tasks
      /*-*/
      open csr_child_cancel;
      loop
         fetch csr_child_cancel into rcd_child_cancel;
         if csr_child_cancel%notfound then
            exit;
         end if;

         /*-*/
         /* Cancel the child task
         /*-*/
         task_cancel(rcd_child_cancel.stt_exe_seqn, rcd_child_cancel.stt_tsk_code);

      end loop;
      close csr_child_cancel;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end task_cancel;

   /******************************************************/
   /* This procedure performs the gate completed routine */
   /******************************************************/
   procedure gate_completed(par_exe_seqn in number, par_tsk_code in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_task_open is
         select t01.*
           from lics_str_exe_task t01
          where t01.stt_exe_seqn = par_exe_seqn
            and t01.stt_tsk_pcde = par_tsk_code
            and t01.stt_tsk_type = '*EXEC'
          order by t01.stt_tsk_seqn asc;
      rcd_task_open csr_task_open%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the gate to *COMPLETED
      /*-*/
      update lics_str_exe_task
         set stt_exe_status = '*COMPLETED',
             stt_exe_start = sysdate,
             stt_exe_end = sysdate
       where stt_exe_seqn = par_exe_seqn
         and stt_tsk_code = par_tsk_code;

      /*-*/
      /* Perform the child task open processing
      /* **notes**
      /* 1. Execution tasks for the parent gate are retrieved and opened (direct decendents only)
      /* 2. Execution events for each child task are opened
      /*-*/
      open csr_task_open;
      loop
         fetch csr_task_open into rcd_task_open;
         if csr_task_open%notfound then
            exit;
         end if;

         /*-*/
         /* Set the child task to *OPENED
         /*-*/
         update lics_str_exe_task
            set stt_exe_status = '*OPENED',
                stt_exe_start = sysdate
          where stt_exe_seqn = rcd_task_open.stt_exe_seqn
            and stt_tsk_code = rcd_task_open.stt_tsk_code;

         /*-*/
         /* Set the child task events to *QUEUED
         /*-*/
         update lics_str_exe_event
            set ste_exe_status = '*QUEUED',
                ste_exe_queued = sysdate
          where ste_exe_seqn = rcd_task_open.stt_exe_seqn
            and ste_tsk_code = rcd_task_open.stt_tsk_code;

      end loop;
      close csr_task_open;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end gate_completed;

end lics_stream_poller;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_stream_poller for lics_app.lics_stream_poller;
grant execute on lics_stream_poller to public;
