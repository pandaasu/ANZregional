/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad20_monitor
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad20 - Inbound Hierarchy Customer Monitor

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad20_monitor as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_hdrdat in varchar2, par_hdrseq in number);

end lads_atllad20_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad20_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_hdrdat in varchar2, par_hdrseq in number) is

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
         raise_application_error(-20000, 'LADS_ATLLAD20_MONITOR - EXECUTE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end lads_atllad20_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad20_monitor for lads_app.lads_atllad20_monitor;
grant execute on lads_atllad20_monitor to lics_app;
