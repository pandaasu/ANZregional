/******************/
/* Package Header */
/******************/
create or replace package ods_atlods05_monitor as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ods
    Package : ods_atlods05_monitor
    Owner   : ods_app
    Author  : Steve Gregan

    Description
    -----------
    Operational Data Store - atlods05 - Inbound Price List Monitor

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/11   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_vakey in varchar2, par_kschl in varchar2, par_datab in varchar2, par_knumh in varchar2);

end ods_atlods05_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_atlods05_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_function constant varchar2(128) := 'ODS Price List Monitor';
   con_ema_group constant varchar2(64) := '"MFANZ CDW Group"@esosn1';
   con_ema_code constant varchar2(32) := 'ATLODS05';

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_vakey in varchar2, par_kschl in varchar2, par_datab in varchar2, par_knumh in varchar2) is

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
                                        con_ema_group,
                                        'Price List (' || par_vakey || '/' || par_kschl || '/' || par_datab || '/' || par_knumh || ')' || chr(13) || substr(SQLERRM, 1, 1024));
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'ODS_ATLODS05_MONITOR - ' || substr(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end ods_atlods05_monitor;
/
