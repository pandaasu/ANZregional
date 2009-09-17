/******************/
/* Package Header */
/******************/
create or replace package sms_app.sms_rep_poller as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : sms_rep_poller
    Owner   : sms_app

    Description
    -----------
    SMS Reporting System - Report poller

    This package contain the report poller logic.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/09   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end sms_rep_poller;
/

/****************/
/* Package Body */
/****************/
create or replace package body sms_app.sms_rep_poller as

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
      var_bcst_time varchar2(256);
      var_work_time varchar2(8);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*
           from sms_rpt_header t01
          where t01.rhe_status = '1'
            and t01.rhe_crt_date = to_char(sysdate,'yyyymmdd')
          order by t01.rhe_qry_date asc;
      rcd_list csr_list%rowtype;

      cursor csr_report is
         select t01.*
           from sms_rpt_header t01
          where t01.rhe_qry_code = rcd_list.rhe_qry_code
            and t01.rhe_qry_date = rcd_list.rhe_qry_date
            for update nowait;
      rcd_report csr_report%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Exit the poller when the system is not active
      /*-*/
      if sms_gen_function.retrieve_system_value('SYSTEM_PROCESS') != '*ACTIVE' then
         return;
      end if;

      /*-*/
      /* Retrieve broadcast time value and exit the poller when not reached or not set
      /*-*/
      var_bcst_time := sms_gen_function.retrieve_system_value('SMS_BROADCAST_TIME');
      begin
         var_work_time := to_char(to_date(to_char(sysdate,'yyyymmdd')||var_bcst_time,'yyyymmddhh24miss'),'hh24miss');
      exception
         when others then
            var_work_time := '000000';
      end;
      if to_char(sysdate,'hh24miss') < var_work_time then
         return;
      end if;

      /*-*/
      /* Process the report list
      /*-*/
      open csr_list;
      loop
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;

         /*-*/
         /* Attempt to lock the report header row
         /* notes - must still exist
         /*         must still be loaded
         /*         must not be locked
         /*-*/
         var_available := true;
         begin
            open csr_report;
            fetch csr_report into rcd_report;
            if csr_report%notfound then
               var_available := false;
            else
               if rcd_report.rhe_status != '1' then
                  var_available := false;
               end if;
            end if;
         exception
            when others then
               var_available := false;
         end;
         if csr_report%isopen then
            close csr_report;
         end if;

         /*-*/
         /* Release the report lock when not available
         /* 1. Cursor row locks are not released until commit or rollback
         /* 2. Cursor close does not release row locks
         /*-*/
         if var_available = false then

            /*-*/
            /* Rollback to release row locks
            /*-*/
            rollback;

         /*-*/
         /* Process the report when available
         /*-*/
         else

            /*-*/
            /* Generate the report messages
            /*-*/
            begin
               sms_rep_function.generate(rcd_report.rhe_qry_code,rcd_report.rhe_qry_date,rcd_report.rhe_crt_user);
            exception
               when others then
                  null;
            end;

            /*-*/
            /* Commit to release row locks
            /*-*/
            commit;

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
         raise_application_error(-20000, 'FATAL ERROR - SMS_REP_POLLER - EXECUTE - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end sms_rep_poller;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym sms_rep_poller for sms_app.sms_rep_poller;
grant execute on sms_rep_poller to public;
