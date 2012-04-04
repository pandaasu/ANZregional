/******************/
/* Package Header */
/******************/
create or replace package qv_app.qvi_das_poller as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qvi_das_poller
    Owner   : qv_app

    DESCRIPTION
    -----------
    QlikView Interfacing - Dashboard Poller

    This package contain the dashboard poller functions.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2012/03   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end qvi_das_poller;
/

/****************/
/* Package Body */
/****************/
create or replace package body qv_app.qvi_das_poller as

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
      var_fact_build boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_das_defn is
         select t01.qdd_das_code,
                t01.qdd_das_name,
                t02.qfd_fac_code,
                t02.qfd_fac_name,
                t02.qfd_job_group,
                t02.qfd_ema_group,
                t03.qft_tim_code
           from qvi_das_defn t01,
                qvi_fac_defn t02,
                qvi_fac_time t03
          where t01.qdd_das_code = t02.qfd_das_code
            and t02.qfd_das_code = t03.qft_das_code
            and t02.qfd_fac_code = t03.qft_fac_code
            and t01.qdd_das_status = '1'
            and t02.qfd_fac_status = '1'
            and t03.qft_tim_status = '1'
          order by t01.qdd_das_code asc,
                   t02.qfd_fac_code asc,
                   t03.qft_tim_code asc;
      rcd_das_defn csr_das_defn%rowtype;

      cursor csr_fac_part is
         select t01.*,
                nvl(t02.qsh_par_code, '*NONE') as src_flag
           from qvi_fac_part t01,
                (select t11.qsh_par_code
                   from qvi_src_hedr t11
                  where t11.qsh_das_code = rcd_das_defn.qdd_das_code
                    and t11.qsh_fac_code = rcd_das_defn.qfd_fac_code
                    and t11.qsh_tim_code = rcd_das_defn.qft_tim_code
                    and t11.qsh_lod_status = '2') t02
          where t01.qfp_par_code = t02.qsh_par_code(+)
            and t01.qfp_das_code = rcd_das_defn.qdd_das_code
            and t01.qfp_fac_code = rcd_das_defn.qfd_fac_code
            and t01.qfp_par_status = '1'
          order by t01.qfp_par_code asc;
      rcd_fac_part csr_fac_part%rowtype;

      cursor csr_submit is 
         select t01.*
           from qvi_fac_time t01
          where t01.qft_das_code = rcd_das_defn.qdd_das_code
            and t01.qft_fac_code = rcd_das_defn.qfd_fac_code
            and t01.qft_tim_code = rcd_das_defn.qft_tim_code
            for update nowait;
      rcd_submit csr_submit%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* The dashboard poller performs the following processing...
      /*
      /* 1. Retrieves all opened time dimensions for all active facts for all active dashboards
      /* 2. Checks that each opened time dimension has the loaded source data for each active fact part.
      /* 3. When all part source data has been loaded the fact build is submitted to the ICS trigger queue
      /*    for the related time dimension.
      /*-*/

      /*-*/
      /* Process open time dimensions for active dashboard/fact definitions
      /*-*/
      open csr_das_defn;
      loop
         fetch csr_das_defn into rcd_das_defn;
         if csr_das_defn%notfound then
            exit;
         end if;

         /*-*/
         /* Check that all active fact parts have source data for the current time dimension
         /*-*/
         var_fact_build := true;
         open csr_fac_part;
         loop
            fetch csr_fac_part into rcd_fac_part;
            if csr_fac_part%notfound then
               exit;
            end if;
            if rcd_fac_part.src_flag = '*NONE' then
               var_fact_build := false;
               exit;
            end if;
         end loop;
         close csr_fac_part;

         /*-*/
         /* Submit the fact builder when required
         /* **notes**
         /* 1. Processes fact time dimensions that are in an 1(opened) status and have all related part source data available.
         /* 2. Fact time dimension status changes to 2(submitted) until processing (fact builder) has completed or failed.
         /* 3. The submit architecture does not ensure that all submitted fact builders will execute in parallel. The number of
         /*    fact builders that will execute in parallel is determined by the number of jobs defined in the job groups
         /*-*/
         if var_fact_build = true then

            /*-*/
            /* Attempt to lock the stream event row
            /* notes - must still exist
            /*         must still be opened status
            /*         must not be locked
            /*-*/
            var_available := true;
            begin
               open csr_submit;
               fetch csr_submit into rcd_submit;
               if csr_submit%notfound then
                  var_available := false;
               else
                  if rcd_submit.qft_tim_status != '1' then
                     var_available := false;
                  end if;
               end if;
            exception
               when others then
                  var_available := false;
            end;
            if csr_submit%isopen then
               close csr_submit;
            end if;

            /*-*/
            /* Release the fact time lock when not available
            /* 1. Cursor row locks are not released until commit or rollback
            /* 2. Cursor close does not release row locks
            /*-*/
            if var_available = false then

               /*-*/
               /* Rollback to release row locks
               /*-*/
               rollback;

            /*-*/
            /* Process the fact time when available
            /*-*/
            else

               /*-*/
               /* Update the fact time status 2(submitted) and commit
               /*-*/
               update qvi_fac_time
                  set qft_tim_status = '2'
                where qft_das_code = rcd_submit.qft_das_code
                  and qft_fac_code = rcd_submit.qft_fac_code
                  and qft_tim_code = rcd_submit.qft_tim_code;
               commit;

               /*-*/
               /* Trigger the fact builder event
               /*-*/
               lics_trigger_loader.execute('QlikView Fact Builder',
                                           'qv_app.qvi_das_processor.execute('''||rcd_submit.qft_das_code||''','''||rcd_submit.qft_fac_code||''','''||rcd_submit.qft_tim_code||''')',
                                           null,
                                           rcd_das_defn.qfd_ema_group,
                                           rcd_das_defn.qfd_job_group);

            end if;

         end if;

      end loop;
      close csr_das_defn;

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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - QlikView Interfacing - Dashboard Poller - Execute - ' || substr(sqlerrm, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end qvi_das_poller;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym qvi_das_poller for qv_app.qvi_das_poller;
grant execute on qvi_das_poller to lics_app;
