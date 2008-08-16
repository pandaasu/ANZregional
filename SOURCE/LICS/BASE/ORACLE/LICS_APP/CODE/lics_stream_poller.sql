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
      cursor csr_list is
         select t01.sta_str_seqn,
                t01.sta_tsk_seqn,
                t01.sta_evt_seqn,
                t01.sta_status
           from (select t01.*,
                        rank() over (partition by t01.sta_evt_lock
                                         order by t01.sta_str_seqn asc,
                                                  t01.sta_tsk_seqn asc,
                                                  t01.sta_evt_seqn asc) as lckseq
                   from lics_str_action t01
                  where t01.sta_status = '*OPENED'
                    and t01.sta_completed = '0'
                    and t01.sta_failed = '0') t01
          where t01.lckseq = 1
            and t01.sta_selected = '0'
          order by t01.sta_str_seqn asc,
                   t01.sta_tsk_seqn asc,
                   t01.sta_evt_seqn asc;
      rcd_list csr_list%rowtype;

      cursor csr_action is 
         select t01.*
           from lics_str_action t01
          where t01.sta_str_seqn = rcd_list.sta_str_seqn
            and t01.sta_tsk_seqn = rcd_list.sta_tsk_seqn
            and t01.sta_evt_seqn = rcd_list.sta_evt_seqn
            for update nowait;
      rcd_action csr_action%rowtype;

      cursor csr_status is
         select t01.*
           from (select t01.sta_str_seqn,
                        t01.sta_tsk_code,
                        count(*) as evt_count,
                        sum(decode(t01.sta_selected,'1',1,0)) as sel_count,
                        sum(decode(t01.sta_completed,'1',1,0)) as com_count,
                        sum(decode(t01.sta_failed,'1',1,0)) as fal_count
                   from lics_str_action t01
                  where (t01.sta_status = '*OPENED')
                  group by t01.sta_str_seqn,
                           t01.sta_tsk_code) t01
          where t01.evt_count != 0
            and t01.evt_count = t01.sel_count
            and t01.evt_count = t01.com_count + t01.fal_count;
      rcd_status csr_status%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the completed stream task status
      /*-*/
      open csr_status;
      loop
         fetch csr_status into rcd_status;
         if csr_status%notfound then
            exit;
         end if;

         /*-*/
         /* Update the current task actions to *COMPLETED
         /*-*/
         update lics_str_action
            set sta_status = '*COMPLETED'
          where (sta_str_seqn, sta_tsk_seqn, sta_evt_seqn) in (select t01.sta_str_seqn, t01.sta_tsk_seqn, t01.sta_evt_seqn
                                                                 from lics_str_action t01
                                                                where t01.sta_str_seqn = rcd_status.sta_str_seqn
                                                                  and t01.sta_tsk_code = rcd_status.sta_tsk_code);

         /*-*/
         /* All events completed sucessfully
         /*-*/
         if rcd_status.fal_count = 0 then

            /*-*/
            /* Update the current task direct decendents to *OPENED when all related events are *COMPLETED
            /*-*/
            update lics_str_action
               set sta_status = '*OPENED'
             where (sta_str_seqn, sta_tsk_seqn, sta_evt_seqn) in (select t01.sta_str_seqn, t01.sta_tsk_seqn, t01.sta_evt_seqn
                                                                    from (select t01.sta_str_seqn, t01.sta_tsk_seqn, t01.sta_evt_seqn
                                                                            from lics_str_action t01
                                                                           where t01.sta_str_seqn = rcd_status.sta_str_seqn
                                                                             and level = 1
                                                                           start with t01.sta_tsk_pcde = rcd_status.sta_tsk_code
                                                                         connect by prior t01.sta_str_seqn = t01.sta_str_seqn
                                                                                 and prior t01.sta_tsk_code = t01.sta_tsk_pcde) t01
                                                                   group by t01.sta_str_seqn, t01.sta_tsk_seqn, t01.sta_evt_seqn);
         /*-*/
         /* Some events completed unsucessfully
         /*-*/
         else

            /*-*/
            /* Update the current action decendents to *CANCELLED
            /*-*/
            update lics_str_action
               set sta_status = '*CANCELLED'
             where (sta_str_seqn, sta_tsk_seqn, sta_evt_seqn) in (select t01.sta_str_seqn, t01.sta_tsk_seqn, t01.sta_evt_seqn
                                                                    from (select t01.sta_str_seqn, t01.sta_tsk_seqn, t01.sta_evt_seqn
                                                                            from lics_str_action t01
                                                                           where t01.sta_str_seqn = rcd_status.sta_str_seqn
                                                                           start with t01.sta_tsk_pcde = rcd_status.sta_tsk_code
                                                                         connect by prior t01.sta_str_seqn = t01.sta_str_seqn
                                                                                 and prior t01.sta_tsk_code = t01.sta_tsk_pcde) t01
                                                                   group by t01.sta_str_seqn, t01.sta_tsk_seqn, t01.sta_evt_seqn);

         end if;

      end loop;
      close csr_status;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Process the stream actions
      /*-*/
      open csr_list;
      loop
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;

         /*-*/
         /* Attempt to lock the stream action row
         /* notes - must still exist
         /*         must still be opened unselected status
         /*         must not be locked
         /*-*/
         var_available := true;
         begin
            open csr_action;
            fetch csr_action into rcd_action;
            if csr_action%notfound then
               var_available := false;
            else
               if rcd_action.sta_status != '*OPENED' or
                  rcd_action.sta_selected != '0' then
                  var_available := false;
               end if;
            end if;
         exception
            when others then
               var_available := false;
         end;
         if csr_action%isopen then
            close csr_action;
         end if;

         /*-*/
         /* Release the stream action lock when not available
         /* 1. Cursor row locks are not released until commit or rollback
         /* 2. Cursor close does not release row locks
         /*-*/
         if var_available = false then

            /*-*/
            /* Rollback to release row locks
            /*-*/
            rollback;

         /*-*/
         /* Process the stream action when available
         /*-*/
         else

            /*-*/
            /* Update the stream action and commit
            /*-*/
            Update lics_str_action
               set sta_selected = '1'
             where sta_str_seqn = rcd_action.sta_str_seqn
               and sta_tsk_seqn = rcd_action.sta_tsk_seqn
               and sta_evt_seqn = rcd_action.sta_evt_seqn;
            commit;

            /*-*/
            /* Trigger the stream action
            /*-*/
            lics_trigger_loader.execute('LICS Stream Processor',
                                        'lics_stream_processor.execute('||rcd_action.sta_str_seqn||','||rcd_action.sta_tsk_seqn||','||rcd_action.sta_evt_seqn||')',
                                        rcd_action.sta_opr_alert,
                                        rcd_action.sta_ema_group,
                                        rcd_action.sta_job_group);

         end if;

      end loop;
      close csr_list;

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
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Stream Poller - Execute - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end lics_stream_poller;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_stream_poller for lics_app.lics_stream_poller;
grant execute on lics_stream_poller to public;
