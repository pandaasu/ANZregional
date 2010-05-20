/******************/
/* Package Header */
/******************/
create or replace package psa_app.psa_job_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : psa_smo_function
    Owner   : psa_app

    Description
    -----------
    Production Scheduling Application - Job Function

    This package contain the job functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure schedule_purge;

end psa_job_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body psa_app.psa_job_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);


   /******************************************************/
   /* This procedure performs the schedule purge routine */
   /******************************************************/
   procedure schedule_purge is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_count number;
      var_purge number;
      var_wek_code varchar2(7);

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'PSA Schedule Purging';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_week_now is
         select t01.mars_year,
                t01.mars_week
           from mars_date t01
          where trunc(t01.calendar_date) = trunc(sysdate);
      rcd_week_now csr_week_now%rowtype;

      cursor csr_pwek is
         select t01.*
           from psa_psc_week t01
          where t01.psw_psc_week < var_wek_code
          order by t01.psw_psc_week asc;
      rcd_pwek csr_pwek%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log variables
      /*-*/
      var_log_prefix := 'PSA - SCHEDULE PURGE';
      var_log_search := 'PSA_SCHEDULE_PURGE';
      var_purge := 0;
      begin
         var_purge := to_number(psa_sys_function.retrieve_system_value('SCHEDULE_WEEK_HISTORY'));
      exception
         when others then
            var_purge := 2;
      end;
      if var_purge < 2 then
         var_purge := 2;
      end if;

      /*-*/
      /* Retrieve the current MARS week
      /*-*/
      var_wek_code := null;
      open csr_week_now;
      fetch csr_week_now into rcd_week_now;
      if csr_week_now%found then
         var_wek_code := to_char((rcd_week_now.mars_year - var_purge),'fm0000')||substr(to_char(rcd_week_now.mars_week,'fm0000000'),5,3);
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - PSA Schedule Purge');

      /*-*/
      /* Purge the schedule weeks
      /*-*/
      var_count := 0;
      open csr_pwek;
      loop
         fetch csr_pwek into rcd_pwek;
         if csr_pwek%notfound then
            exit;
         end if;
         var_count := var_count + 1;
         delete from psa_psc_enty where pse_act_code in (select psa_act_code from psa_psc_actv where psa_psc_code = rcd_pwek.psw_psc_code and psa_psc_week = rcd_pwek.psw_psc_week);
         delete from psa_psc_invt where psi_act_code in (select psa_act_code from psa_psc_actv where psa_psc_code = rcd_pwek.psw_psc_code and psa_psc_week = rcd_pwek.psw_psc_week);
         delete from psa_psc_actv where psa_psc_code = rcd_pwek.psw_psc_code and psa_psc_week = rcd_pwek.psw_psc_week;
         delete from psa_psc_reso where psr_psc_code = rcd_pwek.psw_psc_code and psr_psc_week = rcd_pwek.psw_psc_week;
         delete from psa_psc_shft where pss_psc_code = rcd_pwek.psw_psc_code and pss_psc_week = rcd_pwek.psw_psc_week;
         delete from psa_psc_line where psl_psc_code = rcd_pwek.psw_psc_code and psl_psc_week = rcd_pwek.psw_psc_week;
         delete from psa_psc_prod where psp_psc_code = rcd_pwek.psw_psc_code and psp_psc_week = rcd_pwek.psw_psc_week;
         delete from psa_psc_date where psd_psc_code = rcd_pwek.psw_psc_code and psd_psc_week = rcd_pwek.psw_psc_week;
         delete from psa_psc_week where psw_psc_code = rcd_pwek.psw_psc_code and psw_psc_week = rcd_pwek.psw_psc_week;
         commit;
      end loop;
      close csr_pwek;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - PSA Schedule Purge - '||to_char(var_count)||' weeks purged');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

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
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Log error
         /*-*/
         if lics_logging.is_created = true then
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - PSA_JOB_FUNCTION - SCHEDULE_PURGE - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end schedule_purge;

end psa_job_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym psa_job_function for psa_app.psa_job_function;
grant execute on psa_app.psa_job_function to public;
