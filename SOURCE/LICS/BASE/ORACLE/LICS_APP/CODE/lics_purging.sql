/******************/
/* Package Header */
/******************/
create or replace package lics_purging as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_purging
    Owner   : lics_app
    Author  : Steve Gregan - January 2004

    DESCRIPTION
    -----------
    Local Interface Control System - Purging

    The package implements the purging functionality.

    **NOTES**
    ---------
    1. Only one instance of this package can execute at any one time to prevent
       database lock issues.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2004/01   Steve Gregan   Created
    2006/08   Steve Gregan   Added interface header search purging
    2007/01   Steve Gregan   Modified selection and processing logic
    2011/02   Steve Gregan   End point architecture version

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_commit_count in number default null);

end lics_purging;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_purging as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure purge_interfaces;
   procedure purge_executions;
   procedure purge_events;
   procedure purge_logs;
   procedure purge_os;

   /*-*/
   /* Private definitions
   /*-*/
   var_commit_count number;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_commit_count in number default null) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the commit count parameter
      /*-*/
      var_commit_count := 5000;
      if not(par_commit_count is null) then
         var_commit_count := par_commit_count;
      end if;

      /*-*/
      /* Purge the interfaces
      /*-*/
      purge_interfaces;

      /*-*/
      /* Purge the executions
      /*-*/
      purge_executions;

      /*-*/
      /* Purge the events
      /*-*/
      purge_events;

      /*-*/
      /* Purge the logs
      /*-*/
      purge_logs;

      /*-*/
      /* Purge the operating system
      /*-*/
      purge_os;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise the exception
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - Purging - ' || substr(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /********************************************************/
   /* This procedure performs the purge interfaces routine */
   /********************************************************/
   procedure purge_interfaces is

      /*-*/
      /* Local definitions
      /*-*/
      var_row_count number;
      type rcd_list is record(header number(15,0),
                              dta_flag varchar2(1),
                              hdr_flag varchar2(1));
      type typ_list is table of rcd_list index by binary_integer;
      tbl_list typ_list;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_header is 
         select t01.hea_header,
                t01.hea_crt_time,
                sysdate - t02.int_hdr_history as hdr_date,
                sysdate - t02.int_dta_history as dta_date
           from lics_header t01,
                lics_interface t02
          where t01.hea_interface = t02.int_interface(+)
            and (t01.hea_status = lics_constant.header_load_working or
                 t01.hea_status = lics_constant.header_load_working_error or
                 t01.hea_status = lics_constant.header_load_completed_error or
                 t01.hea_status = lics_constant.header_process_completed_error or
                 t01.hea_status = lics_constant.header_process_completed)
            and (t01.hea_crt_time < sysdate - t02.int_hdr_history or
                 t01.hea_crt_time < sysdate - t02.int_dta_history)
       order by t01.hea_header asc;
      rcd_lics_header csr_lics_header%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve and cache the interface headers to purge
      /*-*/
      tbl_list.delete;
      open csr_lics_header;
      loop
         fetch csr_lics_header into rcd_lics_header;
         if csr_lics_header%notfound then
            exit;
         end if;

         /*-*/
         /* Add the header to the purge list
         /*-*/
         tbl_list(tbl_list.count + 1).header := rcd_lics_header.hea_header;
         tbl_list(tbl_list.count).dta_flag := '0';
         tbl_list(tbl_list.count).hdr_flag := '0';

         /*-*/
         /* Purge the interface data when required
         /*-*/
         if rcd_lics_header.hea_crt_time < rcd_lics_header.dta_date then
            tbl_list(tbl_list.count).dta_flag := '1';
         end if;

         /*-*/
         /* Purge the interface header when required
         /*-*/
         if rcd_lics_header.hea_crt_time < rcd_lics_header.hdr_date and
            rcd_lics_header.hea_crt_time < rcd_lics_header.dta_date then
            tbl_list(tbl_list.count).hdr_flag := '1';
         end if;

      end loop;
      close csr_lics_header;

      /*-*/
      /* Process the purge list
      /*-*/
      var_row_count := 0;
      for idx in 1..tbl_list.count loop

         /*-*/
         /* Purge the interface data when required
         /*-*/
         if tbl_list(idx).dta_flag = '1' then

            /*-*/
            /* Purge the interface data messages
            /*-*/
            delete from lics_dta_message
             where dam_header = tbl_list(idx).header;
            var_row_count := var_row_count + sql%rowcount;

            /*-*/
            /* Purge the interface data
            /*-*/
            delete from lics_data
             where dat_header = tbl_list(idx).header;
            var_row_count := var_row_count + sql%rowcount;

         end if;

         /*-*/
         /* Purge the interface header when required
         /*-*/
         if tbl_list(idx).hdr_flag = '1' then

            /*-*/
            /* Purge the interface header search
            /*-*/
            delete from lics_hdr_search
             where hes_header = tbl_list(idx).header;
            var_row_count := var_row_count + sql%rowcount;

            /*-*/
            /* Purge the interface header messages
            /*-*/
            delete from lics_hdr_message
             where hem_header = tbl_list(idx).header;
            var_row_count := var_row_count + sql%rowcount;

            /*-*/
            /* Purge the interface header traces
            /*-*/
            delete from lics_hdr_trace
             where het_header = tbl_list(idx).header;
            var_row_count := var_row_count + sql%rowcount;

            /*-*/
            /* Purge the interface header
            /*-*/
            delete from lics_header
             where hea_header = tbl_list(idx).header;
            var_row_count := var_row_count + sql%rowcount;

         end if;

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_row_count >= var_commit_count then
            var_row_count := 0;
            commit;
         end if;

      end loop;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_interfaces;

   /********************************************************/
   /* This procedure performs the purge executions routine */
   /********************************************************/
   procedure purge_executions is

      /*-*/
      /* Local definitions
      /*-*/
      var_count number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lics_job_01 is 
         select t01.job_job,
                t01.job_exe_history
           from lics_job t01
       order by t01.job_job asc;
      rcd_lics_job_01 csr_lics_job_01%rowtype;

      cursor csr_lics_job_trace_01 is 
         select t01.jot_execution
           from lics_job_trace t01
          where t01.jot_job = rcd_lics_job_01.job_job
            and (t01.jot_status = lics_constant.job_completed or
                 t01.jot_status = lics_constant.job_aborted)
            and not exists (select 'x'
                              from lics_hdr_trace t02
                             where t02.het_execution = t01.jot_execution)
       order by t01.jot_execution desc;
      rcd_lics_job_trace_01 csr_lics_job_trace_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the jobs
      /*-*/
      open csr_lics_job_01;
      loop
         fetch csr_lics_job_01 into rcd_lics_job_01;
         if csr_lics_job_01%notfound then
            exit;
         end if;

         /*-*/
         /* Retrieve the job traces
         /*-*/
         var_count := 0;
         open csr_lics_job_trace_01;
         loop
            fetch csr_lics_job_trace_01 into rcd_lics_job_trace_01;
            if csr_lics_job_trace_01%notfound then
               exit;
            end if;

            /*-*/
            /* Purge the execution when required
            /*-*/
            var_count := var_count + 1;
            if var_count > rcd_lics_job_01.job_exe_history then
               delete from lics_job_trace
                where jot_execution = rcd_lics_job_trace_01.jot_execution;
            end if;

         end loop;
         close csr_lics_job_trace_01;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_lics_job_01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_executions;

   /****************************************************/
   /* This procedure performs the purge events routine */
   /****************************************************/
   procedure purge_events is

      /*-*/
      /* Local definitions
      /*-*/
      var_eve_date date;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the event purge date
      /* notes - system date - the number of event history days
      /*-*/
      var_eve_date := sysdate - lics_parameter.purge_event_history_days;

      /*-*/
      /* Purge the events
      /*-*/
      delete from lics_event
       where eve_time < var_eve_date;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_events;

   /**************************************************/
   /* This procedure performs the purge logs routine */
   /**************************************************/
   procedure purge_logs is

      /*-*/
      /* Local definitions
      /*-*/
      var_log_date date;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the log purge date
      /* notes - system date - the number of log history days
      /*-*/
      var_log_date := sysdate - lics_parameter.purge_log_history_days;

      /*-*/
      /* Purge the logs
      /*-*/
      delete from lics_log
       where log_time < var_log_date;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_logs;

   /**************************************************************/
   /* This procedure performs the purge operating system routine */
   /**************************************************************/
   procedure purge_os is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Execute the operating system purge script
      /*-*/
      lics_filesystem.execute_external_procedure(lics_parameter.purge_file_script);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_os;

end lics_purging;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_purging for lics_app.lics_purging;
grant execute on lics_purging to public;