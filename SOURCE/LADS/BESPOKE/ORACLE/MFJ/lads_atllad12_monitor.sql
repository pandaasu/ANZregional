/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad12_monitor
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad12 - Inbound Invoice Summary Monitor

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad12_monitor as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_fkdat in varchar2, par_bukrs in varchar2);

end lads_atllad12_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad12_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_function constant varchar2(128) := 'LADS Invoice Summary Monitor';
   con_rec_alt_group constant varchar2(32) := 'DW_ALERT';
   con_rec_alt_code constant varchar2(32) := 'SALES_RECONCILIATION';
   con_rec_ema_group constant varchar2(32) := 'DW_EMAIL_GROUP';
   con_rec_ema_code constant varchar2(32) := 'SALES_RECONCILIATION';
   con_sal_alt_group constant varchar2(32) := 'DW_ALERT';
   con_sal_alt_code constant varchar2(32) := 'SALES_AGGREGATION';
   con_sal_ema_group constant varchar2(32) := 'DW_EMAIL_GROUP';
   con_sal_ema_code constant varchar2(32) := 'SALES_AGGREGATION';
   con_sal_tri_group constant varchar2(32) := 'DW_JOB_GROUP';
   con_sal_tri_code constant varchar2(32) := 'SALES_AGGREGATION';

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_fkdat in varchar2, par_bukrs in varchar2) is

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
      var_rec_return := dw_app.dw_reconciliation.reconcile_sales(par_fkdat, par_bukrs, var_rec_message);
      if var_rec_return != '*OK' then
         if var_rec_return != '*VAR_ACCEPT' then
            if not(trim(var_alert) is null) and trim(upper(var_alert)) != '*NONE' then
               lics_notification.send_alert(var_alert);
            end if;
         end if;
         if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
            lics_notification.send_email(lads_parameter.system_code,
                                         lads_parameter.system_unit,
                                         lads_parameter.system_environment,
                                         con_function,
                                         'DW_RECONCILIATION',
                                         var_email,
                                         var_rec_message);
         end if;
      end if;

      /*-*/
      /* Trigger the sales aggregation when required
      /*-*/
      if var_rec_return = '*OK' or 
         var_rec_return = '*VAR_ACCEPT' then
         lics_trigger_loader.execute('DW Sales Aggregation',
                                     'dw_app.dw_sales_aggregation.execute(''*DATE'',''*ALL'',''' || par_fkdat || ''',''' || par_bukrs || ''')',
                                     lics_setting_configuration.retrieve_setting(con_sal_alt_group, con_sal_alt_code),
                                     lics_setting_configuration.retrieve_setting(con_sal_ema_group, con_sal_ema_code),
                                     lics_setting_configuration.retrieve_setting(con_sal_tri_group, con_sal_tri_code));
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
         raise_application_error(-20000, 'LADS_ATLLAD12_MONITOR - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end lads_atllad12_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad12_monitor for lads_app.lads_atllad12_monitor;
grant execute on lads_atllad12_monitor to lics_app;
