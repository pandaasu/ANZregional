/******************/
/* Package Header */
/******************/
create or replace package lads_atllad08_monitor as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lads
    Package : lads_atllad08_monitor
    Owner   : lads_app
    Author  : Steve Gregan

    Description
    -----------
    Local Atlas Data Store - atllad08 - Inbound Material BOM Monitor

    **Notes** 1. This package must NOT issue commit/rollback statements.
              2. This package must raise an exception on failure to exclude
              database activity from parent commit.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2004/01   Steve Gregan   Created
    2006/12   Steve Gregan   Included LADS FLATTENING callout
    2008/05   Trevor Keon    Changed to use execute_before and execute_after

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute_before(par_stlnr in varchar2, par_stlal in varchar2);
   procedure execute_after(par_stlnr in varchar2, par_stlal in varchar2);

end lads_atllad08_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad08_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute_before(par_stlnr in varchar2, par_stlal in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_mat_bom_hdr is
         select *
           from lads_mat_bom_hdr t01
           where stlnr = par_stlnr
             and stlal = par_stlal;
      rcd_lads_mat_bom_hdr csr_lads_mat_bom_hdr%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the material BOM header
      /* **note** - assumes that a lock is held in the calling procedure
      /*          - commit/rollback will be issued in the calling procedure
      /*-*/
      open csr_lads_mat_bom_hdr;
      fetch csr_lads_mat_bom_hdr into rcd_lads_mat_bom_hdr;
      if csr_lads_mat_bom_hdr%notfound then
         raise_application_error(-20000, 'Material BOM (' || par_stlnr || ' / ' || par_stlal || ') not found');
      end if;
      close csr_lads_mat_bom_hdr;

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
      bds_atllad08_flatten.execute('*DOCUMENT', par_stlnr, par_stlal);

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
         raise_application_error(-20000, 'LADS_ATLLAD08_MONITOR - EXECUTE_BEFORE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_before;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute_after(par_stlnr in varchar2, par_stlal in varchar2) is

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
         raise_application_error(-20000, 'LADS_ATLLAD08_MONITOR - EXECUTE_AFTER - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_after;

end lads_atllad08_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad08_monitor for lads_app.lads_atllad08_monitor;
grant execute on lads_atllad08_monitor to lics_app;
