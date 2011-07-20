--
-- LADS_ATLLAD32_MONITOR  (Package) 
--
CREATE OR REPLACE PACKAGE LADS_APP.lads_atllad32_monitor as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad32_monitor
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad32 - Plant maintenance functional location monitor

 **Notes** 1. This package must NOT issue commit/rollback statements.
           2. This package must raise an exception on failure to exclude database activity from parent commit.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2010/10   Ben Halicki    Created this package

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute_before(par_tplnr in varchar2);
   procedure execute_after(par_tplnr in varchar2);

end lads_atllad32_monitor;
/


--
-- LADS_ATLLAD32_MONITOR  (Synonym) 
--
CREATE PUBLIC SYNONYM LADS_ATLLAD32_MONITOR FOR LADS_APP.LADS_ATLLAD32_MONITOR;


GRANT EXECUTE ON LADS_APP.LADS_ATLLAD32_MONITOR TO LICS_APP;


--
-- LADS_ATLLAD32_MONITOR  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY LADS_APP.lads_atllad32_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute_before(par_tplnr in varchar2) is
    
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
      bds_atllad32_flatten.execute('*DOCUMENT',par_tplnr);

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
         raise_application_error(-20000, 'LADS_ATLLAD32_MONITOR - EXECUTE_BEFORE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_before;
   
   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute_after(par_tplnr in varchar2) is
    
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
         raise_application_error(-20000, 'LADS_ATLLAD32_MONITOR - EXECUTE_AFTER - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_after;   

end lads_atllad32_monitor;
/


--
-- LADS_ATLLAD32_MONITOR  (Synonym) 
--
CREATE PUBLIC SYNONYM LADS_ATLLAD32_MONITOR FOR LADS_APP.LADS_ATLLAD32_MONITOR;


GRANT EXECUTE ON LADS_APP.LADS_ATLLAD32_MONITOR TO LICS_APP;

