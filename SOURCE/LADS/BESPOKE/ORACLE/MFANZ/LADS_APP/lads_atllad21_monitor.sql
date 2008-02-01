/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad21_monitor
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad21 - Inbound Characteristic Master Monitor

 **Notes** 1. This package must NOT issue commit/rollback statements.
           2. This package must raise an exception on failure to exclude database activity from parent commit.


 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2006/11   Linden Glen    Included LADS FLATTENING callout

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad21_monitor as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_atnam in varchar2);

end lads_atllad21_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad21_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_atnam in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*---------------------------*/
      /* 1. LADS transaction logic */
      /*---------------------------*/

      /*-*/
      /* Transaction logic
      /* **note** - changes to the LADS data (eg. delivery deletion)
      /*-*/


      /*---------------------------*/
      /* 2. LADS flattening logic  */
      /*---------------------------*/

      /*-*/
      /* Flattening logic
      /* **note** - delete and replace
      /*-*/
      bds_atllad21_flatten.execute('*DOCUMENT',par_atnam);



      /*---------------------------*/
      /* 3. Triggered procedures   */
      /*---------------------------*/

      /*-*/
      /* Triggered procedures
      /* **note** - must be last (potentially use flattened data)
      /*-*/

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
         raise_application_error(-20000, 'LADS_ATLLAD21_MONITOR - EXECUTE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end lads_atllad21_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad21_monitor for lads_app.lads_atllad21_monitor;
grant execute on lads_atllad21_monitor to lics_app;
