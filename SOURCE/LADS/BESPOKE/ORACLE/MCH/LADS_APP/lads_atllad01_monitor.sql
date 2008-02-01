/******************/
/* Package Header */
/******************/
create or replace package lads_atllad01_monitor as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lads
    Package : lads_atllad01_monitor
    Owner   : lads_app
    Author  : Steve Gregan

    Description
    -----------
    Local Atlas Data Store - atllad01 - Inbound Control Recipe Monitor

    YYYY/MM   Author         Description
    -------   ------         -----------
    2004/01   Steve Gregan   Created
    2007/04   Steve Gregan   Included LADS FLATTENING callout

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_cntl_rec_id in number);

end lads_atllad01_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad01_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_cntl_rec_id in number) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ctl_rec_hpi is
         select *
           from lads_ctl_rec_hpi t01
          where t01.cntl_rec_id = par_cntl_rec_id;
      rcd_lads_ctl_rec_hpi csr_lads_ctl_rec_hpi%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the control recipe header
      /* **note** - assumes that a lock is held in the calling procedure
      /*          - commit/rollback will be issued in the calling procedure
      /*-*/
      open csr_lads_ctl_rec_hpi;
      fetch csr_lads_ctl_rec_hpi into rcd_lads_ctl_rec_hpi;
      if csr_lads_ctl_rec_hpi%notfound then
         raise_application_error(-20000, 'Control Recipe (' || par_cntl_rec_id || ') not found');
      end if;
      close csr_lads_ctl_rec_hpi;

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
      bds_atllad01_flatten.execute('*DOCUMENT',par_cntl_rec_id);

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
         raise_application_error(-20000, 'LADS_ATLLAD01_MONITOR - EXECUTE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end lads_atllad01_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad01_monitor for lads_app.lads_atllad01_monitor;
grant execute on lads_atllad01_monitor to lics_app;
