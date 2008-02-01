/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad23_monitor
 Owner   : lads_app
 Author  : Megan Henderson

 Description
 -----------
 Local Atlas Data Store - atllad23 - Intransit Stock Monitor

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Megan Henderson   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad23_monitor as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_werks in varchar2);

end lads_atllad23_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad23_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_werks in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'LADS_ATLLAD23_MONITOR - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end lads_atllad23_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad23_monitor for lads_app.lads_atllad23_monitor;
grant execute on lads_atllad23_monitor to lics_app;
