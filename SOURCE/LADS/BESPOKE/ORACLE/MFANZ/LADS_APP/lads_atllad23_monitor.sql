
/******************/
/* Package Header */
/******************/
create or replace package lads_atllad23_monitor as

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

    YYYY/MM   Author            Description
    -------   ------            -----------
    2004/11   Megan Henderson   Created
    2007/03   Steve Gregan      Included LADS FLATTENING callout
    2008/05   Trevor Keon       Changed to use execute_before and execute_after

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute_before(par_werks in varchar2);
   procedure execute_after(par_werks in varchar2);

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
   procedure execute_before(par_werks in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_int_stk_hdr is
         select *
           from lads_int_stk_hdr t01
          where t01.werks = par_werks;
      rcd_lads_int_stk_hdr csr_lads_int_stk_hdr%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the intransit stock header
      /* **note** - assumes that a lock is held in the calling procedure
      /*          - commit/rollback will be issued in the calling procedure
      /*-*/
      open csr_lads_int_stk_hdr;
      fetch csr_lads_int_stk_hdr into rcd_lads_int_stk_hdr;
      if csr_lads_int_stk_hdr%notfound then
         raise_application_error(-20000, 'Intransit Stock (' || par_werks || ') not found');
      end if;
      close csr_lads_int_stk_hdr;

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
      bds_atllad23_flatten.execute('*DOCUMENT',par_werks);   

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
         raise_application_error(-20000, 'LADS_ATLLAD23_MONITOR - EXECUTE_BEFORE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_before;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute_after(par_werks in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*---------------------------*/
      /* 1. Triggered procedures   */
      /*---------------------------*/
      lics_trigger_loader.execute('MFANZ Plant In-Transit Data Inteface',
                            'plant_intransit_extract.execute(''*PLANT'',''' || par_werks || ''',''*REL'')',
                            lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','PLANT_INTERFACE'),
                            lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','PLANT_INTERFACE'),
                            lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','PLANT_INTERFACE'));      

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
         raise_application_error(-20000, 'LADS_ATLLAD23_MONITOR - EXECUTE_AFTER - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_after;

end lads_atllad23_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad23_monitor for lads_app.lads_atllad23_monitor;
grant execute on lads_atllad23_monitor to lics_app;
