/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_daemon_processor
 Owner   : lics_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Interface Control System - Daemon Processor

 The package implements the daemon processor functionality.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lics_daemon_processor as

   /**/
   /* Public declarations
   /**/
   procedure execute(par_group in varchar2,
                     par_procedure in varchar2,
                     par_job in varchar2,
                     par_execution in number);
   function callback_job return varchar2;
   function callback_execution return number;
   function callback_group return varchar2;
   function callback_stop_requested return boolean;

end lics_daemon_processor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_daemon_processor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   var_ctl_pipe varchar2(128);
   var_ctl_wake boolean;
   var_ctl_suspend boolean;
   var_ctl_stop boolean;
   var_group lics_job.job_int_group%type;
   var_procedure lics_job.job_procedure%type;
   var_job lics_job.job_job%type;
   var_execution lics_job_trace.jot_execution%type;

   /*******************************************************/
   /* This procedure performs the execute process routine */
   /*******************************************************/
   procedure execute(par_group in varchar2,
                     par_procedure in varchar2,
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
      var_procedure := par_procedure;
      var_job := par_job;
      var_execution := par_execution;

      /*-*/
      /* Set the controls
      /*-*/
      var_ctl_pipe := lics_constant.queue_daemon || var_group;
      var_ctl_wake := false;
      var_ctl_suspend := false;
      var_ctl_stop := false;
      var_suspended := false;

      /*-*/
      /* Process the daemon group until stop requested
      /*-*/
      loop

         /*-*/
         /* Process the procedure when requested
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
            /* Process the procedure until exhausted
            /*-*/
            loop
               var_ctl_wake := false;
               var_ctl_suspend := false;
               var_ctl_stop := false;
               execute immediate 'begin ' || var_procedure || '; end;';
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
                                        lics_constant.type_daemon,
                                        var_group,
                                        par_procedure,
                                        null,
                                        null,
                                        null,
                                        'DAEMON PROCESSOR FAILED - ' || substr(SQLERRM, 1, 1024));
         exception
            when others then
               raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Daemon Processor - ' || substr(SQLERRM, 1, 1024));
         end;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /***************************************************/
   /* This function performs the callback job routine */
   /***************************************************/
   function callback_job return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the processor job
      /*-*/
      return var_job;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end callback_job;

   /*********************************************************/
   /* This function performs the callback execution routine */
   /*********************************************************/
   function callback_execution return number is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the processor execution
      /*-*/
      return var_execution;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end callback_execution;

   /*****************************************************/
   /* This function performs the callback group routine */
   /*****************************************************/
   function callback_group return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the processor group
      /*-*/
      return var_group;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end callback_group;

   /**************************************************************/
   /* This function performs the callback stop requested routine */
   /**************************************************************/
   function callback_stop_requested return boolean is

      /*-*/
      /* Local definitions
      /*-*/
      var_return boolean;
      var_check varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Check the pipe for new message when available
      /*
      /* **notes**
      /* 1. Wake - continue and remember the state
      /* 2. Suspend - break the processing and suspend the processor
      /* 3. Release - continue and reset the suspend control
      /* 4. Stop - break the processing and stop the processor
      /* 5. Default - continue and ignore the instruction
      /*-*/
      if not(var_ctl_pipe is null) then
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
      end if;

      /*-*/
      /* Set the stop requested value as required
      /*-*/
      var_return := false;
      if var_ctl_suspend = true or
         var_ctl_stop = true then
         var_return := true;
      end if;

      /*-*/
      /* Return the stop requested value
      /*-*/
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end callback_stop_requested;

end lics_daemon_processor;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_daemon_processor for lics_app.lics_daemon_processor;
grant execute on lics_daemon_processor to public;