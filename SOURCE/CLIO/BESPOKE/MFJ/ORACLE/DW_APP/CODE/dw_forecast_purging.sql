/******************/
/* Package Header */
/******************/
create or replace package dw_forecast_purging as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : dw_forecast_purging
 Owner   : dw_app

 Description
 -----------
 Dimensional Data Store - Forecast Purging

 This package contain the purging procedures for forecast data. The package exposes one
 procedure EXECUTE that performs the purging.

 **notes**
 1. A web log is produced under the search value DW_FORECAST_PURGING where all errors are logged.

 2. All errors will raise an exception to the calling application so that an alert can
    be raised.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/06   Steve Gregan   Created

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end dw_forecast_purging;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_forecast_purging as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure purge_loading;
   procedure purge_planning;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_loc_string varchar2(128);
      var_alert varchar2(256);
      var_email varchar2(256);
      var_locked boolean;
      var_errors boolean;

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DW Forecast Purging';
      con_alt_group constant varchar2(32) := 'DW_ALERT';
      con_alt_code constant varchar2(32) := 'FCST_PURGING';
      con_ema_group constant varchar2(32) := 'DW_EMAIL_GROUP';
      con_ema_code constant varchar2(32) := 'FCST_PURGING';

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'CLIO - DW_FORECAST_PURGING';
      var_log_search := 'DW_FORECAST_PURGING';
      var_loc_string := 'DW_FORECAST_PURGING';
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);
      var_errors := false;
      var_locked := false;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Forecast Purging');

      /*-*/
      /* Request the lock on the forecast purging
      /*-*/
      begin
         lics_locking.request(var_loc_string);
         var_locked := true;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log(substr(SQLERRM, 1, 1024));
      end;

      /*-*/
      /* Execute the requested procedures
      /*-*/
      if var_locked = true then

         /*-*/
         /* Execute the purge procedure
         /*
         /*-*/
         begin
            purge_loading;
         exception
            when others then
               var_errors := true;
         end;
         /*-*/
         begin
            purge_planning;
         exception
            when others then
               var_errors := true;
         end;

         /*-*/
         /* Release the lock on the forecast purging
         /*-*/
         lics_locking.release(var_loc_string);

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Forecast Purging');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

      /*-*/
      /* Errors
      /*-*/
      if var_errors = true then
         if not(trim(var_alert) is null) and trim(upper(var_alert)) != '*NONE' then
            lics_notification.send_alert(var_alert);
         end if;
         if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
            lics_notification.send_email(lads_parameter.system_code,
                                         lads_parameter.system_unit,
                                         lads_parameter.system_environment,
                                         con_function,
                                         'DW_FORECAST_PURGING',
                                         var_email,
                                         'One or more errors occurred during the Forecast Purging execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;
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
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 1024);

         /*-*/
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         exception
            when others then
               null;
         end;

         /*-*/
         /* Release the lock on the forecast purging
         /*-*/
         if var_locked = true then
            lics_locking.release(var_loc_string);
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_FORECAST_PURGING - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /*****************************************************/
   /* This procedure performs the purge loading routine */
   /*****************************************************/
   procedure purge_loading is

      /*-*/
      /* Local definitions
      /*-*/
      var_count number;
      var_available boolean;
      cnt_process_count constant number(5,0) := 10;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is 
         select t01.load_identifier
           from fcst_load_header t01
          where t01.fcst_cast_yyyynn < (select mars_period
                                          from mars_date t01
                                         where to_char(t01.calendar_date,'yyyymmdd') = to_char(sysdate,'yyyymmdd'));
      rcd_header csr_header%rowtype;

      cursor csr_lock is 
         select t01.load_identifier
           from fcst_load_header t01
          where t01.load_identifier = rcd_header.load_identifier
                for update nowait;
      rcd_lock csr_lock%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Purge Loading');

      /*-*/
      /* Retrieve the headers
      /*-*/
      var_count := 0;
      open csr_header;
      loop
         if var_count >= cnt_process_count then
            if csr_header%isopen then
               close csr_header;
            end if;
            commit;
            open csr_header;
            var_count := 0;
         end if;
         fetch csr_header into rcd_header;
         if csr_header%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Attempt to lock the header
         /*-*/
         var_available := true;
         begin
            open csr_lock;
            fetch csr_lock into rcd_lock;
            if csr_lock%notfound then
               var_available := false;
            end if;
         exception
            when others then
               var_available := false;
         end;
         if csr_lock%isopen then
            close csr_lock;
         end if;

         /*-*/
         /* Delete the header and related data when available
         /*-*/
         if var_available = true then
            delete from fcst_load_detail where load_identifier = rcd_lock.load_identifier;
            delete from fcst_load_header where load_identifier = rcd_lock.load_identifier;
         end if;

      end loop;
      close csr_header;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Purge Loading');

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
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**ERROR** - Purge Loading - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Purge Loading');
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_loading;

   /******************************************************/
   /* This procedure performs the purge planning routine */
   /******************************************************/
   procedure purge_planning is

      /*-*/
      /* Local definitions
      /*-*/
      var_history number;
      var_count number;
      cnt_process_count constant number(5,0) := 500;
      con_pur_group constant varchar2(32) := 'DW_PURGING';
      con_pur_code constant varchar2(32) := 'FCST_PLANNING';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_header is 
         select t01.*
           from fcst_plan_period t01
          where t01.fcst_yyyypp < var_history;
      rcd_header csr_header%rowtype;

      cursor csr_mars_date is
         select *
           from mars_date t01
          where to_char(t01.calendar_date,'yyyymmdd') = to_char(sysdate,'yyyymmdd');
      rcd_mars_date csr_mars_date%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Purge Planning');

      /*-*/
      /* Retrieve the current period
      /*-*/
      open csr_mars_date;
      fetch csr_mars_date into rcd_mars_date;
      if csr_mars_date%notfound then
         raise_application_error(-20000, 'Mars date (' || to_char(sysdate,'yyyy/mm/dd') || ') does not exist');
      end if;
      close csr_mars_date;

      /*-*/
      /* Retrieve the history years
      /*-*/
      var_history := to_number(lics_setting_configuration.retrieve_setting(con_pur_group, con_pur_code));
      if var_history = 0 then
         raise_application_error(-20000, 'Forecast planning purge history years is zero');
      end if;
      var_history := to_number(to_char(rcd_mars_date.mars_year-var_history,'fm0000')||substr(to_char(rcd_mars_date.mars_period,'fm000000'),5,2));

      /*-*/
      /* Retrieve the headers
      /*-*/
      var_count := 0;
      open csr_header;
      loop
         if var_count >= cnt_process_count then
            if csr_header%isopen then
               close csr_header;
            end if;
            commit;
            open csr_header;
            var_count := 0;
         end if;
         fetch csr_header into rcd_header;
         if csr_header%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Delete the header
         /*-*/
         delete from fcst_plan_period
          where sap_material_code = rcd_header.sap_material_code
            and sap_plant_code = rcd_header.sap_plant_code
            and casting_date = rcd_header.casting_date
            and asof_date = rcd_header.asof_date
            and fcst_date = rcd_header.fcst_date;

      end loop;
      close csr_header;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Purge Planning');

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
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**ERROR** - Purge Planning - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Purge Planning');
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_planning;

end dw_forecast_purging;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_forecast_purging for dw_app.dw_forecast_purging;
grant execute on dw_forecast_purging to public;
