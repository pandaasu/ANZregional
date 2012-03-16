/******************/
/* Package Header */
/******************/
create or replace package qv_app.qvi_das_processor as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qvi_das_processor
    Owner   : qv_app

    DESCRIPTION
    -----------
    QlikView Interfacing - Dashboard Processor

    This package contain the dashboard processor functions.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2012/03   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2);

end qvi_das_processor;
/

/****************/
/* Package Body */
/****************/
create or replace package body qv_app.qvi_das_processor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_flg_string varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_loc_string varchar2(128);
      var_locked boolean;
      var_errors boolean;
      var_found boolean;
      var_instance number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fac_defn is
         select t01.*
           from qvi_fac_defn t01
          where t01.qfd_das_code = par_das_code
            and t01.qfd_fac_code = par_fac_code;
      rcd_fac_defn csr_fac_defn%rowtype;

      cursor csr_fac_time is 
         select t01.*
           from qvi_fac_time t01
          where t01.qft_das_code = par_das_code
            and t01.qft_fac_code = par_fac_code
            and t01.qft_tim_code = par_tim_code;
      rcd_fac_time csr_fac_time%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameters
      /*-*/
      if par_das_code is null then
         raise_application_error(-20000, 'Dashboard code must be supplied');
      end if;
      if par_fac_code is null then
         raise_application_error(-20000, 'Fact code must be supplied');
      end if;
      if par_tim_code is null then
         raise_application_error(-20000, 'Time code must be supplied');
      end if;

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'QVI - FACT BUILDER';
      var_log_search := 'QVI_FACT_BUILDER' || '_' || par_das_code || '_' || par_fac_code || '_' || par_tim_code;
      var_loc_string := 'QVI_FACT_BUILDER' || '_' || par_das_code || '_' || par_fac_code || '_' || par_tim_code;
      var_errors := false;
      var_locked := false;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - QVI Fact Builder - Parameters (' || par_das_code || ' + ' || par_fac_code || ' + ' || par_tim_code || ')');

      /*-*/
      /* Retrieve the fact definition
      /*-*/
      var_found := false;
      open csr_fac_defn;
      fetch csr_fac_defn into rcd_fac_defn;
      if csr_fac_defn%found then
         var_found := true;
      end if;
      close csr_fac_defn;
      if var_found = false then
         var_errors := true;
         lics_logging.write_log('Dashboard fact not found (' || par_das_code || '/' || par_fac_code || ')');
      elsif rcd_fac_defn.qfd_fac_status != '1' then
         var_errors := true;
         lics_logging.write_log('Dashboard fact is not active (' || par_das_code || '/' || par_fac_code || ')');
      end if;

      /*-*/
      /* Retrieve the fact time
      /*-*/
      var_found := false;
      open csr_fac_time;
      fetch csr_fac_time into rcd_fac_time;
      if csr_fac_time%found then
         var_found := true;
      end if;
      close csr_fac_time;
      if var_found = false then
         var_errors := true;
         lics_logging.write_log('Dashboard fact time not found (' || par_das_code || '/' || par_fac_code || '/' || par_tim_code || ')');
      elsif rcd_fac_time.qft_tim_code != '2' then
         var_errors := true;
         lics_logging.write_log('Dashboard fact time is not 2(submitted) (' || par_das_code || '/' || par_fac_code || '/' || par_tim_code || ')');
      end if;

      /*-*/
      /* Request the lock on the fact time when no errors
      /*-*/
      if var_errors = false then
        begin
           lics_locking.request(var_loc_string);
           var_locked := true;
         exception
            when others then
               var_errors := true;
               lics_logging.write_log(substr(sqlerrm, 1, 1024));
         end;
      end if;

      /*-*/
      /* Execute the fact builder when no errors and lock taken
      /*-*/
      if var_locked = true then

         /*-*/
         /* Process the fact builder procedure
         /* **notes**
         /* 1. Procedure should always perform own commit or rollback
         /*    (this processor will always perform commit/rollback for safety)
         /*-*/
         begin
            execute immediate 'begin '||rcd_fac_defn.qfd_fac_build||'('''||par_das_code||''','''||par_fac_code||''','''||par_tim_code||''');'||'; end;';
            commit;
         exception
            when others then
               rollback;
               var_errors := true;
               lics_logging.write_log(substr(sqlerrm, 1, 3000));
         end;

         /*-*/
         /* Process based on fact builder result
         /*-*/
         if var_errors = false then

            /*-*/
            /* Update the fact time status 3(completed) and commit
            /*-*/
            update qvi_fac_time
               set qft_tim_status = '3'
             where qft_das_code = par_das_code
               and qft_fac_code = par_fac_code
               and qft_tim_code = par_tim_code;
            commit;

            /*-*/
            /* Create the flag file interface - Qlikview
            /*-*/
            begin
               var_instance := lics_outbound_loader.create_interface(rcd_fac_defn.qfd_flg_iface,null,rcd_fac_defn.qfd_flg_mname);
               var_flg_string := par_das_code||','||par_fac_code||','||par_tim_code;
               var_flg_string := var_flg_string||',"'||rcd_fac_defn.qfd_fac_table||'('''||par_das_code||''','''||par_fac_code||''','''||par_tim_code||''')"';
               lics_outbound_loader.append_data(var_flg_string);
               lics_outbound_loader.finalise_interface;
            exception
               when others then
                  var_errors := true;
                  var_exception := substr(sqlerrm, 1, 1536);
                  lics_logging.write_log(var_exception);
                  if lics_outbound_loader.is_created = true then
                     lics_outbound_loader.add_exception(var_exception);
                     lics_outbound_loader.finalise_interface;
                  end if;
            end;

         end if;

         /*-*/
         /* Release the lock on the fact builder
         /*-*/
         lics_locking.release(var_loc_string);

      end if;
      var_locked := false;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - QVI Fact Builder');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

      /*-*/
      /* Errors
      /*-*/
      if var_errors = true then

         /*-*/
         /* Email
         /*-*/
         lics_notification.send_email(lics_parameter.system_code,
                                      lics_parameter.system_unit,
                                      lics_parameter.system_environment,
                                      'QVI Fact Builder',
                                      'QVI_FACT_BUILDER',
                                      rcd_fac_defn.qfd_ema_group,
                                      'One or more errors occurred during the Dashboard Builder execution - refer to web log - ' || lics_logging.callback_identifier);

      end if;

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
         raise_application_error(-20000, 'FATAL ERROR - QlikView Interfacing - Dashboard Processor - Execute - ' || substr(sqlerrm, 1, 1536));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end qvi_das_processor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym qvi_das_processor for qv_app.qvi_das_processor;
grant execute on qvi_das_processor to public;
