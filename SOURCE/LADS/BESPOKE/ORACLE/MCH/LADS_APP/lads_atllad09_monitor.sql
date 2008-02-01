/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad09_monitor
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad09 - Inbound Stock Transfer and Purchase Order Monitor

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2005/04   Linden Glen    Added Trident Global Triggering

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad09_monitor as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_belnr in varchar2);

end lads_atllad09_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad09_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_belnr in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*----------------------*/
      /* Triggered procedures */
      /*----------------------*/

      /*-*/
      /* Trigger the TRIDENT interface
      /*-*/
      lics_trigger_loader.execute('TRIDENT Interface',
                                  'site_app.trident_extract_pkg.idoc_monitor(''ORD_PO'',''' || par_belnr || ''')',
                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','TRIDENT_LADTRI01'),
                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','TRIDENT_LADTRI01'),
                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','TRIDENT_LADTRI01'));

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
         raise_application_error(-20000, 'LADS_ATLLAD09_MONITOR - EXECUTE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end lads_atllad09_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad09_monitor for lads_app.lads_atllad09_monitor;
grant execute on lads_atllad09_monitor to lics_app;
