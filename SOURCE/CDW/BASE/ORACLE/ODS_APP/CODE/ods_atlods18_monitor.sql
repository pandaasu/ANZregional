/******************/
/* Package Header */
/******************/
create or replace package ods_atlods18_monitor as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ods
    Package : ods_atlods18_monitor
    Owner   : ods_app
    Author  : Steve Gregan

    Description
    -----------
    Operational Data Store - atlods18 - Inbound Invoice Monitor

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/02   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_belnr in varchar2);

end ods_atlods18_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_atlods18_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_function constant varchar2(128) := 'ODS Invoice Monitor';
   con_ema_group constant varchar2(64) := '"MFANZ CDW Group"@esosn1';
   con_ema_code constant varchar2(32) := 'ATLODS18';

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_belnr in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return - no monitoring
      /*-*/
      return;

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
         /* Send the notification
         /*-*/
         begin
            ods_notification.send_email(con_function,
                                        lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code),
                                        'Invoice (' || par_belnr || ')' || chr(13) || substr(SQLERRM, 1, 1024));
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'ODS_ATLODS18_MONITOR - ' || substr(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ods_atlods18_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ods_atlods18_monitor for ods_app.ods_atlods18_monitor;
grant execute on ods_atlods18_monitor to lics_app;

