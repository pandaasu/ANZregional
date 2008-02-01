/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_job_processor
 Owner   : lics_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Interface Control System - Job Processor

 The package implements the job processor functionality.

 1. The job processor executes a submitted job.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2005/11   Steve Gregan   Added poller processor
 2007/06   Steve Gregan   Changed duplicate background job behaviour

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lics_job_processor as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_job in varchar2);

end lics_job_processor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_job_processor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure process_job;
   procedure add_exception(par_exception in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   rcd_lics_job lics_job%rowtype;
   rcd_lics_job_trace lics_job_trace%rowtype;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_job in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_current_consumer_group varchar2(32);
      var_work varchar2(1);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_job_01 is 
         select t01.job_job,
                t01.job_description,
                t01.job_res_group,
                t01.job_opr_alert,
                t01.job_ema_group,
                t01.job_type,
                t01.job_int_group,
                t01.job_procedure,
                t01.job_interval,
                t01.job_status
           from lics_job t01
          where t01.job_job = rcd_lics_job.job_job;
      rcd_lics_job_01 csr_lics_job_01%rowtype;

      cursor csr_lics_job_trace_01 is 
         select 'x'
           from lics_job_trace t01
          where t01.jot_type = rcd_lics_job.job_type
            and t01.jot_int_group = rcd_lics_job.job_int_group
            and (t01.jot_status = lics_constant.job_working or
                 t01.jot_status = lics_constant.job_idle or
                 t01.jot_status = lics_constant.job_suspended);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the job variable
      /*-*/
      rcd_lics_job.job_job := par_job;

      /*-*/
      /* Retrieve the requested job
      /*-*/
      open csr_lics_job_01;
      fetch csr_lics_job_01 into rcd_lics_job_01;
      if csr_lics_job_01%notfound then
         raise_application_error(-20000, 'Execute - Job (' || rcd_lics_job.job_job || ') does not exist');
      end if;
      close csr_lics_job_01;

      /*-*/
      /* Set the private job variables
      /*-*/
      rcd_lics_job.job_job := rcd_lics_job_01.job_job;
      rcd_lics_job.job_description := rcd_lics_job_01.job_description;
      rcd_lics_job.job_res_group := rcd_lics_job_01.job_res_group;
      rcd_lics_job.job_opr_alert := rcd_lics_job_01.job_opr_alert;
      rcd_lics_job.job_ema_group := rcd_lics_job_01.job_ema_group;
      rcd_lics_job.job_type := rcd_lics_job_01.job_type;
      rcd_lics_job.job_int_group := rcd_lics_job_01.job_int_group;
      rcd_lics_job.job_procedure := rcd_lics_job_01.job_procedure;
      rcd_lics_job.job_interval := rcd_lics_job_01.job_interval;
      rcd_lics_job.job_status := rcd_lics_job_01.job_status;

      /*-*/
      /* Inactive job - return immediately
      /* - allows a job to be inactivated for a period of time
      /*-*/
      if rcd_lics_job.job_status <> lics_constant.status_active then
         return;
      end if;

      /*-*/
      /* Background process
      /*    - must have a group
      /*    - must not be already running for the current group
      /*-*/
      if rcd_lics_job.job_type <> lics_constant.type_procedure then
         if rcd_lics_job.job_int_group is null then
            raise_application_error(-20000, 'Execute - Background job (' || rcd_lics_job.job_job || ') must have a group specified');
         end if;
         open csr_lics_job_trace_01;
         fetch csr_lics_job_trace_01 into var_work;
         if csr_lics_job_trace_01%found then
            return;
         end if;
         close csr_lics_job_trace_01;
      end if;

      /*-*/
      /* Switch the consumer group based on the job property when required
      /*-*/
      if not(rcd_lics_job.job_res_group is null) then
         begin
            dbms_session.switch_current_consumer_group(rcd_lics_job.job_res_group, var_current_consumer_group, false);
         exception
            when others then
               raise_application_error(-20000, 'Execute - Switch Database Consumer Group - ' || substr(SQLERRM, 1, 512));
         end;
      end if;

      /*-*/
      /* Create the new job trace
      /* notes - execution = current execution
      /*         status = job_working
      /*-*/
      select lics_execution_sequence.nextval into rcd_lics_job_trace.jot_execution from dual;
      rcd_lics_job_trace.jot_job := rcd_lics_job.job_job;
      rcd_lics_job_trace.jot_type := rcd_lics_job.job_type;
      rcd_lics_job_trace.jot_int_group := rcd_lics_job.job_int_group;
      rcd_lics_job_trace.jot_procedure := rcd_lics_job.job_procedure;
      rcd_lics_job_trace.jot_user := user;
      rcd_lics_job_trace.jot_str_time := sysdate;
      rcd_lics_job_trace.jot_end_time := sysdate;
      rcd_lics_job_trace.jot_status := lics_constant.job_working;
      rcd_lics_job_trace.jot_message := null;
      insert into lics_job_trace
         (jot_execution,
          jot_job,
          jot_type,
          jot_int_group,
          jot_procedure,
          jot_user,
          jot_str_time,
          jot_end_time,
          jot_status,
          jot_message)
            values(rcd_lics_job_trace.jot_execution,
                   rcd_lics_job_trace.jot_job,
                   rcd_lics_job_trace.jot_type,
                   rcd_lics_job_trace.jot_int_group,
                   rcd_lics_job_trace.jot_procedure,
                   rcd_lics_job_trace.jot_user,
                   rcd_lics_job_trace.jot_str_time,
                   rcd_lics_job_trace.jot_end_time,
                   rcd_lics_job_trace.jot_status,
                   rcd_lics_job_trace.jot_message);

      /*-*/
      /* Commit the database (job trace)
      /*-*/
      commit;

      /*-*/
      /* Set the client info
      /*-*/
      dbms_application_info.set_client_info('ICSJOB:' || to_char(rcd_lics_job_trace.jot_execution,'FM999999999999990'));

      /*-*/
      /* Process the job
      /*-*/
      process_job;

      /*-*/
      /* Job completed successfully
      /*-*/
      if rcd_lics_job_trace.jot_status <> lics_constant.job_aborted then

         /*-*/
         /* Update the job trace end time and status
         /* note - job_completed
         /*-*/
         rcd_lics_job_trace.jot_end_time := sysdate;
         rcd_lics_job_trace.jot_status := lics_constant.job_completed;
         update lics_job_trace
            set jot_end_time = rcd_lics_job_trace.jot_end_time,
                jot_status = rcd_lics_job_trace.jot_status
          where jot_execution = rcd_lics_job_trace.jot_execution;
         if sql%notfound then
            raise_application_error(-20000, 'Execute - Job trace (' || to_char(rcd_lics_job_trace.jot_execution,'FM999999999999990') || ') does not exist');
         end if;

         /*-*/
         /* Commit the database (trace)
         /*-*/
         commit;

      end if;

      /*-*/
      /* Log the job trace event
      /*-*/
      if rcd_lics_job_trace.jot_status = lics_constant.job_completed then
         lics_notification.log_success(rcd_lics_job.job_job,
                                       rcd_lics_job_trace.jot_execution,
                                       rcd_lics_job.job_type,
                                       rcd_lics_job.job_int_group,
                                       rcd_lics_job.job_procedure,
                                       null,
                                       null,
                                       null,
                                       'JOB PROCESSOR SUCCESS');
      else
         lics_notification.log_error(rcd_lics_job.job_job,
                                     rcd_lics_job_trace.jot_execution,
                                     rcd_lics_job.job_type,
                                     rcd_lics_job.job_int_group,
                                     rcd_lics_job.job_procedure,
                                     null,
                                     null,
                                     null,
                                     'JOB PROCESSOR ABNORMAL END - see trace message for more details',
                                     rcd_lics_job.job_opr_alert,
                                     rcd_lics_job.job_ema_group);
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
         /* Log the fatal event
         /*-*/
         begin
            lics_notification.log_fatal(rcd_lics_job.job_job,
                                        rcd_lics_job_trace.jot_execution,
                                        rcd_lics_job.job_type,
                                        rcd_lics_job.job_int_group,
                                        rcd_lics_job.job_procedure,
                                        null,
                                        null,
                                        null,
                                        'JOB PROCESSOR FATAL ERROR - ' || substr(SQLERRM, 1, 512));
         exception
            when others then
               raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Job Processor - ' || substr(SQLERRM, 1, 512));
         end;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /***************************************************/
   /* This procedure performs the process job routine */
   /***************************************************/
   procedure process_job is

      /*-*/
      /* Local definitions
      /*-*/
      var_interval number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the job
      /*-*/
      case rcd_lics_job.job_type

         when lics_constant.type_inbound then
            if rcd_lics_job.job_int_group is null then
               raise_application_error(-20000, 'Process Job - *INBOUND job must have a job group specified');
            end if;
            begin
               lics_inbound_processor.execute(rcd_lics_job.job_int_group,
                                              rcd_lics_job_trace.jot_job,
                                              rcd_lics_job_trace.jot_execution);
            exception
               when others then
                  add_exception(substr(SQLERRM, 1, 512));
            end;

         when lics_constant.type_outbound then
            if rcd_lics_job.job_int_group is null then
               raise_application_error(-20000, 'Process Job - *OUTBOUND job must have a job group specified');
            end if;
            begin
               lics_outbound_processor.execute(rcd_lics_job.job_int_group,
                                               rcd_lics_job_trace.jot_job,
                                               rcd_lics_job_trace.jot_execution);
            exception
               when others then
                  add_exception(substr(SQLERRM, 1, 512));
            end;

         when lics_constant.type_passthru then
            if rcd_lics_job.job_int_group is null then
               raise_application_error(-20000, 'Process Job - *PASSTHRU job must have a job group specified');
            end if;
            begin
               lics_passthru_processor.execute(rcd_lics_job.job_int_group,
                                               rcd_lics_job_trace.jot_job,
                                               rcd_lics_job_trace.jot_execution);
            exception
               when others then
                  add_exception(substr(SQLERRM, 1, 512));
            end;

         when lics_constant.type_daemon then
            if rcd_lics_job.job_int_group is null then
               raise_application_error(-20000, 'Process Job - *DAEMON job must have a job group specified');
            end if;
            if rcd_lics_job.job_procedure is null then
               raise_application_error(-20000, 'Process Job - *DAEMON job must have a job procedure specified');
            end if;
            begin
               lics_daemon_processor.execute(rcd_lics_job.job_int_group,
                                             rcd_lics_job.job_procedure,
                                             rcd_lics_job_trace.jot_job,
                                             rcd_lics_job_trace.jot_execution);
            exception
               when others then
                  add_exception(substr(SQLERRM, 1, 512));
            end;

         when lics_constant.type_poller then
            if rcd_lics_job.job_int_group is null then
               raise_application_error(-20000, 'Process Job - *POLLER job must have a job group specified');
            end if;
            if rcd_lics_job.job_procedure is null then
               raise_application_error(-20000, 'Process Job - *POLLER job must have a job procedure specified');
            end if;
            if rcd_lics_job.job_interval is null then
               raise_application_error(-20000, 'Process Job - *POLLER job must have a job interval specified');
            end if;
            begin
               var_interval := to_number(trim(rcd_lics_job.job_interval));
            exception
               when others then
                  raise_application_error(-20000, 'Process Job - *POLLER job must have a numeric job interval');
            end;
            begin
               lics_poller_processor.execute(rcd_lics_job.job_int_group,
                                             rcd_lics_job.job_procedure,
                                             rcd_lics_job_trace.jot_job,
                                             rcd_lics_job_trace.jot_execution,
                                             var_interval);
            exception
               when others then
                  add_exception(substr(SQLERRM, 1, 512));
            end;

         when lics_constant.type_procedure then
            if rcd_lics_job.job_procedure is null then
               raise_application_error(-20000, 'Process Job - *PROCEDURE job must have a job procedure specified');
            end if;
            begin
               execute immediate 'begin ' || rcd_lics_job.job_procedure || '; end;';
            exception
               when others then
                  add_exception(substr(SQLERRM, 1, 512));
            end;

         else raise_application_error(-20000, 'Process Job - Invalid job type (' || rcd_lics_job.job_type || ')');

      end case;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Application exception
      /**/
      when application_exception then
         add_exception('APPLICATION ERROR - ' || substr(SQLERRM, 1, 512));

      /*-*/
      /* Exception trap */
      /*-*/
      when others then
         add_exception('SQL ERROR - Process Job - ' || substr(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_job;

   /*****************************************************/
   /* This procedure performs the add exception routine */
   /*****************************************************/
   procedure add_exception(par_exception in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Update the job trace status when required
      /* note - job_aborted
      /*-*/
      rcd_lics_job_trace.jot_end_time := sysdate;
      rcd_lics_job_trace.jot_status := lics_constant.job_aborted;
      rcd_lics_job_trace.jot_message := par_exception;
      update lics_job_trace
         set jot_end_time = rcd_lics_job_trace.jot_end_time,
             jot_status = rcd_lics_job_trace.jot_status,
             jot_message = rcd_lics_job_trace.jot_message
       where jot_execution = rcd_lics_job_trace.jot_execution;
      if sql%notfound then
         raise_application_error(-20000, 'Add Exception - Job trace (' || to_char(rcd_lics_job_trace.jot_execution,'FM999999999999990') || ') does not exist');
      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end add_exception;

end lics_job_processor;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_job_processor for lics_app.lics_job_processor;
grant execute on lics_job_processor to public;