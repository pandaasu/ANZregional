/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_trigger_processor
 Owner   : lics_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Interface Control System - Trigger Processor

 The package implements the trigger functionality.

 1. This package executes triggered procedures in the sequence that they were created

 2. This package can be invoked either from a daemon processor or standalone

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2005/06   Steve Gregan   Added group to lics_triggered table

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lics_trigger_processor as

   /**/
   /* Public declarations
   /**/
   procedure execute_from_daemon;
   procedure execute_all;

end lics_trigger_processor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_trigger_processor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /**/
   /* Private declarations
   /**/
   procedure execute(par_execution in varchar2);

   /*-*/
   /* Private constants
   /*-*/
   con_from_daemon constant varchar2(32) := '*FROM_DAEMON';
   con_all constant varchar2(32) := '*ALL';

   /*-*/
   /* Private definitions
   /*-*/
   cnt_process_count constant number(5,0) := 50;
   type typ_process is table of number index by binary_integer;
   tbl_process typ_process;

   /***********************************************************/
   /* This procedure performs the execute from daemon routine */
   /***********************************************************/
   procedure execute_from_daemon is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Perform the execute routine with appropriate parameter
      /*-*/
      execute(con_from_daemon);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_from_daemon;

   /***************************************************/
   /* This procedure performs the execute all routine */
   /***************************************************/
   procedure execute_all is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Perform the execute routine with appropriate parameter
      /*-*/
      execute(con_all);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_all;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_execution in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;
      var_error varchar2(4000);
      var_procedure varchar2(4000);
      var_sequence lics_triggered.tri_sequence%type;
      var_job lics_job.job_job%type;
      var_execution lics_job_trace.jot_execution%type;
      var_group lics_job.job_int_group%type;
      var_search lics_job.job_int_group%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_triggered_01 is 
         select t01.tri_sequence
           from lics_triggered t01
          where t01.tri_group = var_search
             or var_search is null
       order by t01.tri_sequence asc;
      rcd_lics_triggered_01 csr_lics_triggered_01%rowtype;

      cursor csr_lics_triggered_02 is 
         select t01.tri_sequence,
                t01.tri_group,
                t01.tri_function,
                t01.tri_procedure,
                t01.tri_timestamp,
                t01.tri_ema_group,
                t01.tri_opr_alert
           from lics_triggered t01
          where t01.tri_sequence = var_sequence
                for update nowait;
      rcd_lics_triggered_02 csr_lics_triggered_02%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the control data
      /*-*/
      var_job := lics_constant.job_trigger;
      var_execution := null;
      var_group := null;
      var_search := null;

      /*-*/
      /* Retrieve the daemon processor control data when required
      /* ** callback to daemon processor only when execution from daemon **
      /* ** adjust the group **
      /*-*/
      if par_execution = con_from_daemon then
         var_job := lics_daemon_processor.callback_job;
         var_execution := lics_daemon_processor.callback_execution;
         var_group := lics_daemon_processor.callback_group;
         var_search := var_group;
         if instr(var_search,'#',1,1) <> 0 then
            var_search := substr(var_search,1,instr(var_search,'#',1,1)-1);
         end if;
      end if;

      /*-*/
      /* Process triggered procedures in batches
      /*
      /* **notes** based on process count constant
      /*-*/
      loop

         /*-*/
         /* Retrieve the triggered procedures
         /* notes - sorted by sequence ascending
         /*       - next processing count group
         /*-*/
         tbl_process.delete;
         open csr_lics_triggered_01;
         loop
            fetch csr_lics_triggered_01 into rcd_lics_triggered_01;
            if csr_lics_triggered_01%notfound then
               exit;
            end if;
            tbl_process(tbl_process.count + 1) := rcd_lics_triggered_01.tri_sequence;
            if tbl_process.count >= cnt_process_count then
               exit;
            end if;
         end loop;
         close csr_lics_triggered_01;

         /*-*/
         /* Break the processing loop when required
         /*-*/
         if tbl_process.count = 0 then
            exit;
         end if;

         /*-*/
         /* Process the current group of triggers
         /*-*/
         for idx in 1..tbl_process.count loop

            /*-*/
            /* Set the next trigger
            /*-*/
            var_sequence := tbl_process(idx);

            /*-*/
            /* Attempt to lock the triggered row
            /* notes - must still exist
            /*         must not be locked
            /*-*/
            var_available := true;
            begin
               open csr_lics_triggered_02;
               fetch csr_lics_triggered_02 into rcd_lics_triggered_02;
               if csr_lics_triggered_02%notfound then
                  var_available := false;
               end if;
            exception
               when others then
                  var_available := false;
            end;
            if csr_lics_triggered_02%isopen then
               close csr_lics_triggered_02;
            end if;

            /*-*/
            /* Release the trigger lock when not available
            /* 1. Cursor row locks are not released until commit or rollback
            /* 2. Cursor close does not release row locks
            /*-*/
            if var_available = false then

               /*-*/
               /* Rollback to release row locks
               /*-*/
               rollback;

            /*-*/
            /* Process the trigger when available
            /*-*/
            else

               /*-*/
               /* Delete the triggered data and commit
               /*-*/
               delete from lics_triggered where tri_sequence = var_sequence;
               commit;

               /*-*/
               /* Execute the triggered procedure
               /*
               /* **notes**
               /* 1. Triggered procedure should always perform own commit or rollback
               /*    (this processor will always perform commit/rollback for safety)
               /*-*/
               var_error := null;
               var_procedure := 'begin ' || rcd_lics_triggered_02.tri_procedure || '; end;';
               begin
                  execute immediate var_procedure;
                  commit;
               exception
                  when others then
                     rollback;
                     var_error := substr(SQLERRM, 1, 1024);
               end;
               if var_error is null then
                  lics_notification.log_success(var_job,
                                                var_execution,
                                                lics_constant.type_procedure,
                                                var_group,
                                                '(' || rcd_lics_triggered_02.tri_function || ') ' || rcd_lics_triggered_02.tri_procedure,
                                                null,
                                                null,
                                                null,
                                                'TRIGGER PROCESSOR SUCCESS');
               else
                  lics_notification.log_error(var_job,
                                              var_execution,
                                              lics_constant.type_procedure,
                                              var_group,
                                              '(' || rcd_lics_triggered_02.tri_function || ') ' || rcd_lics_triggered_02.tri_procedure,
                                              null,
                                              null,
                                              null,
                                              'TRIGGER PROCESSOR ERROR - ' || var_error,
                                              rcd_lics_triggered_02.tri_opr_alert,
                                              rcd_lics_triggered_02.tri_ema_group);
               end if;

            end if;

         end loop;

         /*-*/
         /* Check the daemon processor for stop request
         /* ** callback to daemon processor only when execution from daemon **
         /*-*/
         if par_execution = con_from_daemon then
            if lics_daemon_processor.callback_stop_requested = true then
               exit;
            end if;
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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Trigger Processor - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end lics_trigger_processor;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_trigger_processor for lics_app.lics_trigger_processor;
grant execute on lics_trigger_processor to public;