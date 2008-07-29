/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad18_monitor
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad18 - Inbound Invoice Monitor

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2008/05   Trevor Keon    Changed to use execute_before and execute_after

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad18_monitor as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute_before(par_belnr in varchar2);
   procedure execute_after(par_belnr in varchar2);

end lads_atllad18_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad18_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute_before(par_belnr in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_orgid lads_inv_org.orgid%type;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_inv_hdr_01 is
         select *
           from lads_inv_hdr t01
          where t01.belnr = par_belnr;
      rcd_lads_inv_hdr_01 csr_lads_inv_hdr_01%rowtype;

      cursor csr_lads_inv_org_01 is
         select t01.orgid
           from lads_inv_org t01
          where t01.belnr = rcd_lads_inv_hdr_01.belnr
            and t01.qualf = '015';
      rcd_lads_inv_org_01 csr_lads_inv_org_01%rowtype;

      cursor csr_lads_inv_ref_01 is
         select 'x' as rcd_found
           from lads_inv_ref t01,
                lads_inv_org t02
          where t01.belnr = t02.belnr
            and t01.qualf = '031'
            and t01.refnr = rcd_lads_inv_hdr_01.belnr
            and t02.qualf = '015'
            and t02.orgid = var_orgid;
      rcd_lads_inv_ref_01 csr_lads_inv_ref_01%rowtype;

      cursor csr_lads_inv_ref_02 is
         select t01.refnr
           from lads_inv_ref t01
          where t01.belnr = rcd_lads_inv_hdr_01.belnr
            and t01.qualf = '031';
      rcd_lads_inv_ref_02 csr_lads_inv_ref_02%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the invoice
      /*-*/
      open csr_lads_inv_hdr_01;
      fetch csr_lads_inv_hdr_01 into rcd_lads_inv_hdr_01;
      if csr_lads_inv_hdr_01%notfound then
         raise_application_error(-20000, 'Invoice (' || par_belnr || ') not found');
      end if;
      close csr_lads_inv_hdr_01;

      /*---------------------------*/
      /* 1. LADS transaction logic */
      /*---------------------------*/
      /*-*/
      /* Transaction logic
      /* **note** - changes to the LADS data
      /*-*/

      /*----------------------*/
      /* Invoice Cancellation */
      /*----------------------*/

      /*-*/
      /* Retrieve the invoice organisational data
      /* ** note ** Ignore when no organisational data found
      /*-*/
      open csr_lads_inv_org_01;
      fetch csr_lads_inv_org_01 into rcd_lads_inv_org_01;
      if csr_lads_inv_org_01%found then 
				
         /*-*/
         /* Process normal invoice (that can be cancelled)
         /*
         /* 1. Check for a cancelling invoice for the current invoice
         /* 2. Set the cancelled status for the current invoice when found
         /*-*/
         if rcd_lads_inv_org_01.orgid = 'BV' or
            rcd_lads_inv_org_01.orgid = 'F2' or
            rcd_lads_inv_org_01.orgid = 'FAZ' or
            rcd_lads_inv_org_01.orgid = 'HR' or
            rcd_lads_inv_org_01.orgid = 'IGA' or
            rcd_lads_inv_org_01.orgid = 'IVA' or
            rcd_lads_inv_org_01.orgid = 'LG' or
            rcd_lads_inv_org_01.orgid = 'LR' or
            rcd_lads_inv_org_01.orgid = 'ZF2' or
            rcd_lads_inv_org_01.orgid = 'ZF2I' or
            rcd_lads_inv_org_01.orgid = 'ZG2' or
            rcd_lads_inv_org_01.orgid = 'ZIV' or
            rcd_lads_inv_org_01.orgid = 'ZIV1' or
            rcd_lads_inv_org_01.orgid = 'ZIVJ' or
            rcd_lads_inv_org_01.orgid = 'ZLG' or
            rcd_lads_inv_org_01.orgid = 'ZLR' or
            rcd_lads_inv_org_01.orgid = 'ZLR2' then

            if rcd_lads_inv_org_01.orgid = 'BV' then
               var_orgid := 'SV';
            elsif rcd_lads_inv_org_01.orgid = 'F2' then
               var_orgid := 'S1';
            elsif rcd_lads_inv_org_01.orgid = 'FAZ' then
               var_orgid := 'FAS';
            elsif rcd_lads_inv_org_01.orgid = 'HR' then
               var_orgid := 'SHR';
            elsif rcd_lads_inv_org_01.orgid = 'IGA' then
               var_orgid := 'IGS';
            elsif rcd_lads_inv_org_01.orgid = 'IVA' then
               var_orgid := 'IVS';
            elsif rcd_lads_inv_org_01.orgid = 'LG' then
               var_orgid := 'LGS';
            elsif rcd_lads_inv_org_01.orgid = 'LR' then
               var_orgid := 'LRS';
            elsif rcd_lads_inv_org_01.orgid = 'ZF2' then
               var_orgid := 'ZS1';
            elsif rcd_lads_inv_org_01.orgid = 'ZF2I' then
               var_orgid := 'ZIS1';
            elsif rcd_lads_inv_org_01.orgid = 'ZG2' then
               var_orgid := 'ZS2';
            elsif rcd_lads_inv_org_01.orgid = 'ZIV' then
               var_orgid := 'ZIVS';
            elsif rcd_lads_inv_org_01.orgid = 'ZIV1' then
               var_orgid := 'ZI1S';
            elsif rcd_lads_inv_org_01.orgid = 'ZIVJ' then
               var_orgid := 'ZIS2';
            elsif rcd_lads_inv_org_01.orgid = 'ZLG' then
               var_orgid := 'ZLGS';
            elsif rcd_lads_inv_org_01.orgid = 'ZLR' then
               var_orgid := 'ZLRS';
            elsif rcd_lads_inv_org_01.orgid = 'ZLR2' then
               var_orgid := 'ZLRS';
            end if;

            open csr_lads_inv_ref_01;
            fetch csr_lads_inv_ref_01 into rcd_lads_inv_ref_01;
            if csr_lads_inv_ref_01%found then
               update lads_inv_hdr set lads_status = '4'
                where belnr = rcd_lads_inv_hdr_01.belnr;
            end if;
            close csr_lads_inv_ref_01;

         end if;

         /*-*/
         /* Process canceling invoice
         /*
         /* 1. Set the cancelled status for the current invoice
         /* 2. Set the cancelled status for the reference invoice
         /*-*/
         if rcd_lads_inv_org_01.orgid = 'FAS' or
            rcd_lads_inv_org_01.orgid = 'IGS' or
            rcd_lads_inv_org_01.orgid = 'IVS' or
            rcd_lads_inv_org_01.orgid = 'LGS' or
            rcd_lads_inv_org_01.orgid = 'LRS' or
            rcd_lads_inv_org_01.orgid = 'S1' or
            rcd_lads_inv_org_01.orgid = 'SHR' or
            rcd_lads_inv_org_01.orgid = 'SV' or
            rcd_lads_inv_org_01.orgid = 'ZI1S' or
            rcd_lads_inv_org_01.orgid = 'ZIS1' or
            rcd_lads_inv_org_01.orgid = 'ZIS2' or
            rcd_lads_inv_org_01.orgid = 'ZIVS' or
            rcd_lads_inv_org_01.orgid = 'ZLGS' or
            rcd_lads_inv_org_01.orgid = 'ZLRS' or
            rcd_lads_inv_org_01.orgid = 'ZS1' or
            rcd_lads_inv_org_01.orgid = 'ZS2' then

            update lads_inv_hdr set lads_status = '4'
             where belnr = rcd_lads_inv_hdr_01.belnr;

            open csr_lads_inv_ref_02;
            fetch csr_lads_inv_ref_02 into rcd_lads_inv_ref_02;
            if csr_lads_inv_ref_02%found then
               update lads_inv_hdr set lads_status = '4'
                where belnr = rcd_lads_inv_ref_02.refnr;
            end if;
            close csr_lads_inv_ref_02;

         end if;

      end if;
      close csr_lads_inv_org_01;

      /*---------------------------*/
      /* 2. LADS flattening logic  */
      /*---------------------------*/
      /*-*/
      /* Flattening logic
      /* **note** - delete and replace
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
         raise_application_error(-20000, 'LADS_ATLLAD18_MONITOR - EXECUTE_BEFORE - Invoice (' || par_belnr || ')' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_before;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute_after(par_belnr in varchar2) is

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
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'LADS_ATLLAD18_MONITOR - EXECUTE_AFTER - Invoice (' || par_belnr || ')' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_after;

end lads_atllad18_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad18_monitor for lads_app.lads_atllad18_monitor;
grant execute on lads_atllad18_monitor to lics_app;
