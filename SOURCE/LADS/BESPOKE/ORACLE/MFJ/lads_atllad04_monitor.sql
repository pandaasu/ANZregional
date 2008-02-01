/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad04_monitor
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad04 - Inbound Material Monitor

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad04_monitor as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_matnr in varchar2);

end lads_atllad04_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad04_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_matnr in varchar2) is

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
         raise_application_error(-20000, 'LADS_ATLLAD04_MONITOR - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end lads_atllad04_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad04_monitor for lads_app.lads_atllad04_monitor;
grant execute on lads_atllad04_monitor to lics_app;
