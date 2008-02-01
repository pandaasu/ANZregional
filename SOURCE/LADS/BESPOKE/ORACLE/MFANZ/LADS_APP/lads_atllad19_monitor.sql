/******************/
/* Package Header */
/******************/
create or replace package lads_atllad19_monitor as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lads
    Package : lads_atllad19_monitor
    Owner   : lads_app
    Author  : Steve Gregan

    Description
    -----------
    Local Atlas Data Store - atllad19 - Inbound Vendor Monitor

    YYYY/MM   Author         Description
    -------   ------         -----------
    2004/01   Steve Gregan   Created
    2007/03   Steve Gregan   Included LADS FLATTENING callout
    2007/03   Steve Gregan   Removed MFGPRO trigger

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_lifnr in varchar2);

end lads_atllad19_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad19_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_lifnr in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ven_hdr is
         select *
           from lads_ven_hdr t01
          where t01.lifnr = par_lifnr;
      rcd_lads_ven_hdr csr_lads_ven_hdr%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the vendor header
      /* **note** - assumes that a lock is held in the calling procedure
      /*          - commit/rollback will be issued in the calling procedure
      /*-*/
      open csr_lads_ven_hdr;
      fetch csr_lads_ven_hdr into rcd_lads_ven_hdr;
      if csr_lads_ven_hdr%notfound then
         raise_application_error(-20000, 'Vendor (' || par_lifnr || ') not found');
      end if;
      close csr_lads_ven_hdr;

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
      bds_atllad19_flatten.execute('*DOCUMENT',par_lifnr);

      /*---------------------------*/
      /* 3. Triggered procedures   */
      /*---------------------------*/

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
         raise_application_error(-20000, 'LADS_ATLLAD19_MONITOR - EXECUTE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end lads_atllad19_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad19_monitor for lads_app.lads_atllad19_monitor;
grant execute on lads_atllad19_monitor to lics_app;
