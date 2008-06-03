/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad15_monitor
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad15 - Inbound Address Monitor

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2008/05   Trevor Keon    Changed to use execute_before and execute_after

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad15_monitor as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute_before(par_obj_type in varchar2, par_obj_id in varchar2, par_context in number);
   procedure execute_after(par_obj_type in varchar2, par_obj_id in varchar2, par_context in number);

end lads_atllad15_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad15_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute_before(par_obj_type in varchar2, par_obj_id in varchar2, par_context in number) is

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
         raise_application_error(-20000, 'LADS_ATLLAD15_MONITOR - EXECUTE_BEFORE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_before;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute_after(par_obj_type in varchar2, par_obj_id in varchar2, par_context in number) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*---------------------------*/
      /* 1. Triggered procedures   */
      /*---------------------------*/

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
         raise_application_error(-20000, 'LADS_ATLLAD15_MONITOR - EXECUTE_AFTER - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_after;

end lads_atllad15_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad15_monitor for lads_app.lads_atllad15_monitor;
grant execute on lads_atllad15_monitor to lics_app;
