/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_job_control
 Owner   : lics_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Interface Control System - Job Control

 The package implements the job control functionality.

 **note** This package must be owned by LICS_APP to ensure that all job
          execution is performed by this user.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2005/11   Steve Gregan   Added poller functionality
 2007/07   Steve Gregan   Added exception override for missing oracle jobs

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lics_job_control as

   /*-*/
   /* Public declarations
   /*-*/
   procedure restart_jobs;
   procedure stop_jobs;
   procedure start_jobs;
   procedure suspend_processes(par_group in varchar2);
   procedure release_processes(par_group in varchar2);

end lics_job_control;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_job_control as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure stop_processes;

   /****************************************************/
   /* This procedure performs the restart jobs routine */
   /****************************************************/
   procedure restart_jobs is

      /*-*/
      /* Local definitions
      /*-*/
      var_date date;
      var_job_number binary_integer;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_user_jobs_01 is 
         select t01.job
           from user_jobs t01;
      rcd_user_jobs_01 csr_user_jobs_01%rowtype;

      cursor csr_lics_job_01 is 
         select t01.job_job,
                t01.job_opr_alert,
                t01.job_ema_group,
                t01.job_type,
                t01.job_next,
                t01.job_interval
           from lics_job t01
          where t01.job_status = lics_constant.status_active;
      rcd_lics_job_01 csr_lics_job_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Alter the session language to english so that day functions work
      /*-*/
      execute immediate 'alter session set nls_language = english';

      /*-*/
      /* Remove all jobs owned by LICS_APP (this is the schema owner of this package)
      /*-*/
      open csr_user_jobs_01;
      loop
         fetch csr_user_jobs_01 into rcd_user_jobs_01;
         if csr_user_jobs_01%notfound then
            exit;
         end if;
         begin
            dbms_job.remove(rcd_user_jobs_01.job);
         exception
            when others then
               null;
         end;
      end loop;
      close csr_user_jobs_01;
      commit;

      /*-*/
      /* Stop the current processes
      /*-*/
      stop_processes;

      /*-*/
      /* Retrieve all active jobs from LICS_JOB
      /*-*/
      open csr_lics_job_01;
      loop
         fetch csr_lics_job_01 into rcd_lics_job_01;
         if csr_lics_job_01%notfound then
            exit;
         end if;

         /*-*/
         /* Calculate the next date
         /*-*/
         begin
            execute immediate 'select ' || rcd_lics_job_01.job_next || ' from dual' into var_date;
         exception
            when others then
               var_date := null;
         end;

         /*-*/
         /* Clear the job_interval when *POLLER
         /*-*/
         if rcd_lics_job_01.job_type = lics_constant.type_poller then
            rcd_lics_job_01.job_interval := null;
         end if;

         /*-*/
         /* Submit the job
         /*-*/
         begin
            dbms_job.submit(var_job_number, 
                            'lics_job_processor.execute(''' || rcd_lics_job_01.job_job || ''');',
                            var_date,
                            rcd_lics_job_01.job_interval);
            commit;
            lics_notification.log_success(rcd_lics_job_01.job_job,
                                          null,
                                          null,
                                          null,
                                          null,
                                          null,
                                          null,
                                          null,
                                          'JOB SUBMIT SUCCESS');
         exception
            when others then
               lics_notification.log_error(rcd_lics_job_01.job_job,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null,
                                           'JOB SUBMIT ABNORMAL END - ' || substr(SQLERRM, 1, 512),
                                           rcd_lics_job_01.job_opr_alert,
                                           rcd_lics_job_01.job_ema_group);
         end;

      end loop;
      close csr_lics_job_01;

      /*-*/
      /* Log the event
      /*-*/
      lics_notification.log_success(lics_constant.job_startup,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null,
                                    'RESTART JOBS SUCCESS');

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Log the fatal event
         /*-*/
         begin
            lics_notification.log_fatal(lics_constant.job_startup,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        'JOB CONTROL FATAL ERROR - Restart Jobs - ' || substr(SQLERRM, 1, 512));
         exception
            when others then
               raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Job Control - ' || substr(SQLERRM, 1, 512));
         end;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end restart_jobs;

   /*************************************************/
   /* This procedure performs the stop jobs routine */
   /*************************************************/
   procedure stop_jobs is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_user_jobs_01 is 
         select t01.job
           from user_jobs t01;
      rcd_user_jobs_01 csr_user_jobs_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Remove all jobs owned by LICS_APP (this is the schema owner of this package)
      /*-*/
      open csr_user_jobs_01;
      loop
         fetch csr_user_jobs_01 into rcd_user_jobs_01;
         if csr_user_jobs_01%notfound then
            exit;
         end if;
         begin
            dbms_job.remove(rcd_user_jobs_01.job);
         exception
            when others then
               null;
         end;
      end loop;
      close csr_user_jobs_01;
      commit;

      /*-*/
      /* Stop the current processes
      /*-*/
      stop_processes;

      /*-*/
      /* Log the event
      /*-*/
      lics_notification.log_success(lics_constant.job_shutdown,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null,
                                    'STOP JOBS SUCCESS');

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Log the fatal event
         /*-*/
         begin
            lics_notification.log_fatal(lics_constant.job_shutdown,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        'JOB CONTROL FATAL ERROR - Stop Jobs - ' || substr(SQLERRM, 1, 512));
         exception
            when others then
               raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Job Control - ' || substr(SQLERRM, 1, 512));
         end;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end stop_jobs;

   /**************************************************/
   /* This procedure performs the start jobs routine */
   /**************************************************/
   procedure start_jobs is

      /*-*/
      /* Local definitions
      /*-*/
      var_job_count number;
      var_date date;
      var_job_number binary_integer;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_user_jobs_01 is 
         select count(*) as job_count
           from user_jobs t01;
      rcd_user_jobs_01 csr_user_jobs_01%rowtype;

      cursor csr_lics_job_01 is 
         select t01.job_job,
                t01.job_opr_alert,
                t01.job_ema_group,
                t01.job_type,
                t01.job_next,
                t01.job_interval
           from lics_job t01
          where t01.job_status = lics_constant.status_active;
      rcd_lics_job_01 csr_lics_job_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Alter the session language to english so that day functions work
      /*-*/
      execute immediate 'alter session set nls_language = english';

      /*-*/
      /* Check for jobs owned by LICS_APP (this is the schema owner of this package)
      /*
      /* **note** Return when jobs already active
      /*-*/
      var_job_count := 0;
      open csr_user_jobs_01;
      fetch csr_user_jobs_01 into rcd_user_jobs_01;
      if csr_user_jobs_01%found then
         var_job_count := rcd_user_jobs_01.job_count;
      end if;
      close csr_user_jobs_01;
      if var_job_count <> 0 then
         return;
      end if;

      /*-*/
      /* Retrieve all active jobs from LICS_JOB
      /*-*/
      open csr_lics_job_01;
      loop
         fetch csr_lics_job_01 into rcd_lics_job_01;
         if csr_lics_job_01%notfound then
            exit;
         end if;

         /*-*/
         /* Calculate the next date
         /*-*/
         begin
            execute immediate 'select ' || rcd_lics_job_01.job_next || ' from dual' into var_date;
         exception
            when others then
               var_date := null;
         end;

         /*-*/
         /* Clear the job_interval when *POLLER
         /*-*/
         if rcd_lics_job_01.job_type = lics_constant.type_poller then
            rcd_lics_job_01.job_interval := null;
         end if;

         /*-*/
         /* Submit the job
         /*-*/
         begin
            dbms_job.submit(var_job_number, 
                            'lics_job_processor.execute(''' || rcd_lics_job_01.job_job || ''');',
                            var_date,
                            rcd_lics_job_01.job_interval);
            commit;
            lics_notification.log_success(rcd_lics_job_01.job_job,
                                          null,
                                          null,
                                          null,
                                          null,
                                          null,
                                          null,
                                          null,
                                          'JOB SUBMIT SUCCESS');
         exception
            when others then
               lics_notification.log_error(rcd_lics_job_01.job_job,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null,
                                           null,
                                           'JOB SUBMIT ABNORMAL END - ' || substr(SQLERRM, 1, 512),
                                           rcd_lics_job_01.job_opr_alert,
                                           rcd_lics_job_01.job_ema_group);
         end;

      end loop;
      close csr_lics_job_01;

      /*-*/
      /* Log the event
      /*-*/
      lics_notification.log_success(lics_constant.job_startup,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null,
                                    null,
                                    'START JOBS SUCCESS');

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Log the fatal event
         /*-*/
         begin
            lics_notification.log_fatal(lics_constant.job_startup,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        'JOB CONTROL FATAL ERROR - Start Jobs - ' || substr(SQLERRM, 1, 512));
         exception
            when others then
               raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Job Control - ' || substr(SQLERRM, 1, 512));
         end;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end start_jobs;

   /*********************************************************/
   /* This procedure performs the suspend processes routine */
   /*********************************************************/
   procedure suspend_processes(par_group in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_work varchar2(1);
      var_client_info varchar2(64);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_job_trace_01 is 
         select t01.jot_execution,
                t01.jot_type,
                t01.jot_int_group,
                t01.jot_status
           from lics_job_trace t01
          where t01.jot_type <> lics_constant.type_procedure
            and (t01.jot_status = lics_constant.job_working or
                 t01.jot_status = lics_constant.job_idle);
      rcd_lics_job_trace_01 csr_lics_job_trace_01%rowtype;

      cursor csr_v$session_01 is 
         select 'x'
            from v$session t01
           where t01.client_info = var_client_info;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve requested job executions
      /*-*/
      open csr_lics_job_trace_01;
      loop
         fetch csr_lics_job_trace_01 into rcd_lics_job_trace_01;
         if csr_lics_job_trace_01%notfound then
            exit;
         end if;

         /*-*/
         /* Check for an active session for the current execution
         /* note - client info was set in job processor
         /*-*/
         if par_group is null or
            rcd_lics_job_trace_01.jot_int_group = par_group then

            /*-*/
            /* Check for an active session for the current execution
            /* note - client info was set in job processor
            /*-*/
            var_client_info := 'ICSJOB:' || to_char(rcd_lics_job_trace_01.jot_execution,'FM999999999999990');
            open csr_v$session_01;
            fetch csr_v$session_01 into var_work;
            if csr_v$session_01%found then

               /*-*/
               /* Send the suspend message via the pipe when required
               /*-*/
               case rcd_lics_job_trace_01.jot_type
                  when lics_constant.type_inbound then
                     lics_pipe.send(lics_constant.queue_inbound || rcd_lics_job_trace_01.jot_int_group, lics_constant.pipe_suspend);
                  when lics_constant.type_outbound then
                     lics_pipe.send(lics_constant.queue_outbound || rcd_lics_job_trace_01.jot_int_group, lics_constant.pipe_suspend);
                  when lics_constant.type_passthru then
                     lics_pipe.send(lics_constant.queue_passthru || rcd_lics_job_trace_01.jot_int_group, lics_constant.pipe_suspend);
                  when lics_constant.type_daemon then
                     lics_pipe.send(lics_constant.queue_daemon || rcd_lics_job_trace_01.jot_int_group, lics_constant.pipe_suspend);
                  when lics_constant.type_poller then
                     lics_pipe.send(lics_constant.queue_poller || rcd_lics_job_trace_01.jot_int_group, lics_constant.pipe_suspend);
                  else
                     raise_application_error(-20000, 'Suspend Processes - Invalid interface type (' || rcd_lics_job_trace_01.jot_type || ')');
               end case;

            end if;
            close csr_v$session_01;

         end if;

      end loop;
      close csr_lics_job_trace_01;

      /*-*/
      /* Log the event
      /*-*/
      lics_notification.log_success(lics_constant.job_suspend,
                                    null,
                                    null,
                                    par_group,
                                    null,
                                    null,
                                    null,
                                    null,
                                    'SUSPEND PROCESSES SUCCESS');

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Log the fatal event
         /*-*/
         begin
            lics_notification.log_fatal(lics_constant.job_suspend,
                                        null,
                                        null,
                                        par_group,
                                        null,
                                        null,
                                        null,
                                        null,
                                        'JOB CONTROL FATAL ERROR - Suspend Processes - ' || substr(SQLERRM, 1, 512));
         exception
            when others then
               raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Job Control - ' || substr(SQLERRM, 1, 512));
         end;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end suspend_processes;

   /*********************************************************/
   /* This procedure performs the release processes routine */
   /*********************************************************/
   procedure release_processes(par_group in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_work varchar2(1);
      var_client_info varchar2(64);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_job_trace_01 is 
         select t01.jot_execution,
                t01.jot_type,
                t01.jot_int_group,
                t01.jot_status
           from lics_job_trace t01
          where t01.jot_type <> lics_constant.type_procedure
            and t01.jot_status = lics_constant.job_suspended;
      rcd_lics_job_trace_01 csr_lics_job_trace_01%rowtype;

      cursor csr_v$session_01 is 
         select 'x'
            from v$session t01
           where t01.client_info = var_client_info;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve requested job executions
      /*-*/
      open csr_lics_job_trace_01;
      loop
         fetch csr_lics_job_trace_01 into rcd_lics_job_trace_01;
         if csr_lics_job_trace_01%notfound then
            exit;
         end if;

         /*-*/
         /* Check for an active session for the current execution
         /* note - client info was set in job processor
         /*-*/
         if par_group is null or
            rcd_lics_job_trace_01.jot_int_group = par_group then

            /*-*/
            /* Check for an active session for the current execution
            /* note - client info was set in job processor
            /*-*/
            var_client_info := 'ICSJOB:' || to_char(rcd_lics_job_trace_01.jot_execution,'FM999999999999990');
            open csr_v$session_01;
            fetch csr_v$session_01 into var_work;
            if csr_v$session_01%found then

               /*-*/
               /* Send the release message via the pipe when required
               /*-*/
               case rcd_lics_job_trace_01.jot_type
                  when lics_constant.type_inbound then
                     lics_pipe.send(lics_constant.queue_inbound || rcd_lics_job_trace_01.jot_int_group, lics_constant.pipe_release);
                  when lics_constant.type_outbound then
                     lics_pipe.send(lics_constant.queue_outbound || rcd_lics_job_trace_01.jot_int_group, lics_constant.pipe_release);
                  when lics_constant.type_passthru then
                     lics_pipe.send(lics_constant.queue_passthru || rcd_lics_job_trace_01.jot_int_group, lics_constant.pipe_release);
                  when lics_constant.type_daemon then
                     lics_pipe.send(lics_constant.queue_daemon || rcd_lics_job_trace_01.jot_int_group, lics_constant.pipe_release);
                  when lics_constant.type_poller then
                     lics_pipe.send(lics_constant.queue_poller || rcd_lics_job_trace_01.jot_int_group, lics_constant.pipe_release);
                  else
                     raise_application_error(-20000, 'Release Processes - Invalid interface type (' || rcd_lics_job_trace_01.jot_type || ')');
               end case;

            end if;
            close csr_v$session_01;

         end if;

      end loop;
      close csr_lics_job_trace_01;

      /*-*/
      /* Log the event
      /*-*/
      lics_notification.log_success(lics_constant.job_release,
                                    null,
                                    null,
                                    par_group,
                                    null,
                                    null,
                                    null,
                                    null,
                                    'RELEASE PROCESSES SUCCESS');

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Log the fatal event
         /*-*/
         begin
            lics_notification.log_fatal(lics_constant.job_release,
                                        null,
                                        null,
                                        par_group,
                                        null,
                                        null,
                                        null,
                                        null,
                                        'JOB CONTROL FATAL ERROR - Release Processes - ' || substr(SQLERRM, 1, 512));
         exception
            when others then
               raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Job Control - ' || substr(SQLERRM, 1, 512));
         end;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end release_processes;

   /******************************************************/
   /* This procedure performs the stop processes routine */
   /******************************************************/
   procedure stop_processes is

      /*-*/
      /* Local definitions
      /*-*/
      var_work varchar2(1);
      var_client_info varchar2(64);
      rcd_lics_job_trace lics_job_trace%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_job_trace_01 is 
         select t01.jot_execution,
                t01.jot_type,
                t01.jot_int_group,
                t01.jot_message
           from lics_job_trace t01
          where t01.jot_type <> lics_constant.type_procedure
            and (t01.jot_status = lics_constant.job_working or
                 t01.jot_status = lics_constant.job_idle or
                 t01.jot_status = lics_constant.job_suspended);
      rcd_lics_job_trace_01 csr_lics_job_trace_01%rowtype;

      cursor csr_v$session_01 is 
         select 'x'
            from v$session t01
           where t01.client_info = var_client_info;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve all active background jobs from LICS_JOB_TRACE
      /*-*/
      open csr_lics_job_trace_01;
      loop
         fetch csr_lics_job_trace_01 into rcd_lics_job_trace_01;
         if csr_lics_job_trace_01%notfound then
            exit;
         end if;

         /*-*/
         /* Check for an active session for the current execution
         /* note - client info was set in job processor
         /*-*/
         var_client_info := 'ICSJOB:' || to_char(rcd_lics_job_trace_01.jot_execution,'FM999999999999990');
         open csr_v$session_01;
         fetch csr_v$session_01 into var_work;
         if csr_v$session_01%found then

            /*-*/
            /* Send the stop message via the pipe when required
            /*-*/
            case rcd_lics_job_trace_01.jot_type
               when lics_constant.type_inbound then
                  lics_pipe.send(lics_constant.queue_inbound || rcd_lics_job_trace_01.jot_int_group, lics_constant.pipe_stop);
               when lics_constant.type_outbound then
                  lics_pipe.send(lics_constant.queue_outbound || rcd_lics_job_trace_01.jot_int_group, lics_constant.pipe_stop);
               when lics_constant.type_passthru then
                  lics_pipe.send(lics_constant.queue_passthru || rcd_lics_job_trace_01.jot_int_group, lics_constant.pipe_stop);
               when lics_constant.type_daemon then
                  lics_pipe.send(lics_constant.queue_daemon || rcd_lics_job_trace_01.jot_int_group, lics_constant.pipe_stop);
               when lics_constant.type_poller then
                  lics_pipe.send(lics_constant.queue_poller || rcd_lics_job_trace_01.jot_int_group, lics_constant.pipe_stop);
               else
                  raise_application_error(-20000, 'Stop Processes - Invalid interface type (' || rcd_lics_job_trace_01.jot_type || ')');
            end case;

         else

            /*-*/
            /* Update the job trace end time and status
            /* note - Job must have aborted before status could be updated
            /*-*/
            rcd_lics_job_trace.jot_execution := rcd_lics_job_trace_01.jot_execution;
            rcd_lics_job_trace.jot_end_time := sysdate;
            if rcd_lics_job_trace_01.jot_message is null then
               rcd_lics_job_trace.jot_status := lics_constant.job_completed;
            else
               rcd_lics_job_trace.jot_status := lics_constant.job_aborted;
            end if;
            update lics_job_trace
               set jot_end_time = rcd_lics_job_trace.jot_end_time,
                   jot_status = rcd_lics_job_trace.jot_status
            where jot_execution = rcd_lics_job_trace.jot_execution;

            /*-*/
            /* Commit the database
            /*-*/
            commit;

         end if;
         close csr_v$session_01;

      end loop;
      close csr_lics_job_trace_01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end stop_processes;

end lics_job_control;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_job_control for lics_app.lics_job_control;
grant execute on lics_job_control to public;