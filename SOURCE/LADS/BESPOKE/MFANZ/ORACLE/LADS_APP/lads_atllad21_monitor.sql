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
 2008/05   Trevor Keon    Changed to use execute_before and execute_after

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad21_monitor as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute_before(par_atnam in varchar2);
   procedure execute_after(par_atnam in varchar2);

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
   procedure execute_before(par_atnam in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_chr_mas_hdr is
         select *
           from lads_chr_mas_hdr t01
          where t01.atnam = par_atnam;
      rcd_lads_chr_mas_hdr csr_lads_chr_mas_hdr%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the characteristic master header
      /* **note** - assumes that a lock is held in the calling procedure
      /*          - commit/rollback will be issued in the calling procedure
      /*-*/
      open csr_lads_chr_mas_hdr;
      fetch csr_lads_chr_mas_hdr into rcd_lads_chr_mas_hdr;
      if csr_lads_chr_mas_hdr%notfound then
         raise_application_error(-20000, 'Characteristic Master (' || par_atnam || ') not found');
      end if;
      close csr_lads_chr_mas_hdr;

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
         raise_application_error(-20000, 'LADS_ATLLAD21_MONITOR - EXECUTE_BEFORE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_before;
   
   procedure execute_after(par_atnam in varchar2) is

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
         raise_application_error(-20000, 'LADS_ATLLAD21_MONITOR - EXECUTE_AFTER - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_after;   

end lads_atllad21_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad21_monitor for lads_app.lads_atllad21_monitor;
grant execute on lads_atllad21_monitor to lics_app;
