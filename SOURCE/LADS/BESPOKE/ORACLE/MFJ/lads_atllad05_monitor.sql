/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad05_monitor
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad05 - Inbound Price List Monitor

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2005/05   Linden Glen    Added parameter par_knumh as a result of
                          HDR and DAT tables being flattened

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad05_monitor as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_vakey in varchar2, par_kschl in varchar2, par_datab in varchar2, par_knumh in varchar2);

end lads_atllad05_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad05_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_vakey in varchar2, par_kschl in varchar2, par_datab in varchar2, par_knumh in varchar2) is

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
         raise_application_error(-20000, 'LADS_ATLLAD05_MONITOR - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end lads_atllad05_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad05_monitor for lads_app.lads_atllad05_monitor;
grant execute on lads_atllad05_monitor to lics_app;
