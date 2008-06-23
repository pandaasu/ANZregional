/******************/
/* Package Header */
/******************/
create or replace package ods_atlods12_monitor as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ods
    Package : ods_atlods12_monitor
    Owner   : ods_app
    Author  : Steve Gregan

    Description
    -----------
    Operational Data Store - atlods12 - Inbound Invoice Summary Monitor

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/10   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_fkdat in varchar2, par_bukrs in varchar2, par_hdrseq in number);

end ods_atlods12_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_atlods12_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_function constant varchar2(128) := 'ODS Invoice Summary Monitor';
   con_rec_alt_group constant varchar2(32) := 'DW_ALERT';
   con_rec_alt_code constant varchar2(32) := 'RECONCILIATION';
   con_rec_ema_group constant varchar2(32) := 'DW_EMAIL_GROUP';
   con_rec_ema_code constant varchar2(32) := 'RECONCILIATION';

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_fkdat in varchar2, par_bukrs in varchar2, par_hdrseq in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_alert varchar2(256);
      var_email varchar2(256);
      var_rec_return varchar2(256);
      var_rec_message varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*----------------------*/
      /* Triggered procedures */
      /*----------------------*/

      /*-*/
      /* Perform the sales reconciliation for the control record
      /*-*/
      var_alert := lics_setting_configuration.retrieve_setting(con_rec_alt_group, con_rec_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_rec_ema_group, con_rec_ema_code);
      var_rec_return := dw_app.dw_reconciliation.reconcile_sales(par_fkdat, par_bukrs, par_hdrseq, var_rec_message);
      if var_rec_return != '*OK' then
         if var_rec_return != '*VAR_ACCEPT' then
            if not(trim(var_alert) is null) and trim(upper(var_alert)) != '*NONE' then
               lics_notification.send_alert(var_alert);
            end if;
         end if;
         if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
            lics_notification.send_email(dw_parameter.system_code,
                                         dw_parameter.system_unit,
                                         dw_parameter.system_environment,
                                         con_function,
                                         'DW_RECONCILIATION',
                                         var_email,
                                         var_rec_message);
         end if;
      end if;

      /*-*/
      /* Stream the triggered aggregation when required
      /*-*/
      if var_rec_return = '*OK' or 
         var_rec_return = '*VAR_ACCEPT' then
         lics_stream_loader.execute('DW_TRIGGERED_STREAM_'||par_bukrs,
                                    'dw_app.dw_triggered_aggregation.execute(''*DATE'',''*ALL'','''||par_fkdat||''','''||par_bukrs||''')');
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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'ODS_ATLODS12_MONITOR - EXECUTE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ods_atlods12_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ods_atlods12_monitor for ods_app.ods_atlods12_monitor;
grant execute on ods_atlods12_monitor to lics_app;
