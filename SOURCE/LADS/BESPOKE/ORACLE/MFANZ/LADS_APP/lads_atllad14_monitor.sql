/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad14_monitor
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad14 - Inbound Shipment Monitor

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2008/05   Trevor Keon    Changed to use execute_before and execute_after

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad14_monitor as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute_before(par_tknum in varchar2);
   procedure execute_after(par_tknum in varchar2);

end lads_atllad14_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad14_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute_before(par_tknum in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*---------------------------*/
      /* 1. LADS transaction logic */
      /*---------------------------*/
      /*-*/
      /* Transaction logic
      /* **note** - changes to the LADS data
      /*-*/

      /*---------------------------*/
      /* 2. LADS flattening logic  */
      /*---------------------------*/
      /*-*/
      /* Flattening logic
      /* **note** - delete and replace
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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'LADS_ATLLAD14_MONITOR - EXECUTE_BEFORE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_before;

   procedure execute_after(par_tknum in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*---------------------------*/
      /* 1. Triggered procedures   */
      /*---------------------------*/
--      lics_trigger_loader.execute('TRIDENT Interface',
--                                  'site_app.trident_extract_pkg.idoc_monitor(''SHP'',''' || par_tknum || ''')',
--                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','TRIDENT_LADTRI01'),
--                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','TRIDENT_LADTRI01'),
--                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','TRIDENT_LADTRI01'));

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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'LADS_ATLLAD14_MONITOR - EXECUTE_AFTER - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_after;

end lads_atllad14_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad14_monitor for lads_app.lads_atllad14_monitor;
grant execute on lads_atllad14_monitor to lics_app;
