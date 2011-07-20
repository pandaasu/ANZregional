--
-- LADS_ATLLAD31_MONITOR  (Package) 
--
CREATE OR REPLACE PACKAGE LADS_APP.LADS_ATLLAD31_monitor as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
   System  : lads
   Package : lads_atllad31_monitor
   Owner   : lads_app
   Author  : Ben Halicki

   Description
   -----------
   Local Atlas Data Store - atllad31 - Plant Maintenance Equipment Master

   **Notes** 1. This package must NOT issue commit/rollback statements.
             2. This package must raise an exception on failure to exclude database activity from parent commit.

   YYYY/MM   Author         Description
   -------   ------         -----------
   2010/10   Ben Halicki    Created this package

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute_before(par_equnr in varchar2);
   procedure execute_after(par_equnr in varchar2);

end LADS_ATLLAD31_monitor;
/


--
-- LADS_ATLLAD31_MONITOR  (Synonym) 
--
CREATE PUBLIC SYNONYM LADS_ATLLAD31_MONITOR FOR LADS_APP.LADS_ATLLAD31_MONITOR;


GRANT EXECUTE ON LADS_APP.LADS_ATLLAD31_MONITOR TO LICS_APP;


--
-- LADS_ATLLAD31_MONITOR  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY LADS_APP.lads_atllad31_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute_before(par_equnr in varchar2) is
    
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
      bds_atllad31_flatten.execute('*DOCUMENT',par_equnr);

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
         raise_application_error(-20000, 'LADS_ATLLAD31_MONITOR - EXECUTE_BEFORE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_before;
   
   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute_after(par_equnr in varchar2) is
    
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
         raise_application_error(-20000, 'LADS_ATLLAD31_MONITOR - EXECUTE_AFTER - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_after;   

end lads_atllad31_monitor;
/


--
-- LADS_ATLLAD31_MONITOR  (Synonym) 
--
CREATE PUBLIC SYNONYM LADS_ATLLAD31_MONITOR FOR LADS_APP.LADS_ATLLAD31_MONITOR;


GRANT EXECUTE ON LADS_APP.LADS_ATLLAD31_MONITOR TO LICS_APP;

