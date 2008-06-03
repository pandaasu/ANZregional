/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad16_monitor
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad16 - Inbound Delivery Monitor

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2006/06   Steve Gregan   Modified order line rejection logic to ignore reason ZA
 2008/05   Trevor Keon    Changed to use execute_before and execute_after

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad16_monitor as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute_before(par_vbeln in varchar2);
   procedure execute_after(par_vbeln in varchar2);

end lads_atllad16_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad16_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute_before(par_vbeln in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_so_deleted boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_del_hdr_01 is
         select *
           from lads_del_hdr t01
          where t01.vbeln = par_vbeln;
      rcd_lads_del_hdr_01 csr_lads_del_hdr_01%rowtype;

      cursor csr_lads_del_irf_01 is
         select t01.belnr,
                t01.posnr
           from lads_del_irf t01
          where t01.vbeln = rcd_lads_del_hdr_01.vbeln
            and t01.qualf in ('C','H','I','K','L')
            and not(t01.datum is null);
      rcd_lads_del_irf_01 csr_lads_del_irf_01%rowtype;

      cursor csr_lads_del_irf_02 is
         select t02.vbeln,
                t02.idoc_timestamp
           from lads_del_irf t01,
                lads_del_hdr t02
          where t01.vbeln = t02.vbeln(+)
            and t01.vbeln <> rcd_lads_del_hdr_01.vbeln
            and t01.belnr = rcd_lads_del_irf_01.belnr
            and t01.posnr = rcd_lads_del_irf_01.posnr
            and t01.qualf in ('C','H','I','K','L')
            and not(t01.datum is null)
            and t02.lads_status <> '4';
      rcd_lads_del_irf_02 csr_lads_del_irf_02%rowtype;

      cursor csr_lads_sal_ord_gen_01 is
         select 'x'
           from lads_sal_ord_gen t01,
                lads_sal_ord_hdr t02
          where t01.belnr = t02.belnr(+)
            and t01.belnr = rcd_lads_del_irf_01.belnr
            and t01.posex = rcd_lads_del_irf_01.posnr
            and ((not(t01.abgru is null) and t01.abgru != 'ZA') or
                 ((t01.abgru is null or t01.abgru = 'ZA') and t01.menge is null and t01.menee is null) or
                 t02.lads_status = '4');
      rcd_lads_sal_ord_gen_01 csr_lads_sal_ord_gen_01%rowtype;

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
      
      /*-*/
      /* Retrieve the delivery
      /*-*/
      open csr_lads_del_hdr_01;
      fetch csr_lads_del_hdr_01 into rcd_lads_del_hdr_01;
      if csr_lads_del_hdr_01%notfound then
         raise_application_error(-20000, 'Delivery (' || par_vbeln || ') not found');
      end if;
      close csr_lads_del_hdr_01;

      /*-------------------*/
      /* Delivery Deletion */
      /*-------------------*/
      /*
      /* 1. Deliveries related to deleted sales orders or rejected sales order lines are flagged as deleted
      /* 2. Older deliveries referencing the same sales order line are flagged as deleted
      /*-*/

      /*-*/
      /* Retrieve the delivery detail internal reference data
      /*-*/
      open csr_lads_del_irf_01;
      loop
         fetch csr_lads_del_irf_01 into rcd_lads_del_irf_01;
         if csr_lads_del_irf_01%notfound then
            exit;
         end if;

         /*-*/
         /* Update the delivery status (deleted) when sales order or sales order line deleted
         /*-*/
         var_so_deleted := false;
         open csr_lads_sal_ord_gen_01;
         fetch csr_lads_sal_ord_gen_01 into rcd_lads_sal_ord_gen_01;
         if csr_lads_sal_ord_gen_01%found then
            var_so_deleted := true;
            update lads_del_hdr
               set lads_date = sysdate,
                   lads_status = '4'
             where vbeln = rcd_lads_del_hdr_01.vbeln;
         end if;
         close csr_lads_sal_ord_gen_01;

         /*-*/
         /* Retrieve any related delivery detail internal reference data
         /* ** note ** the relationship is based on sales order and sales order line
         /*-*/
         open csr_lads_del_irf_02;
         loop
            fetch csr_lads_del_irf_02 into rcd_lads_del_irf_02;
            if csr_lads_del_irf_02%notfound then
               exit;
            end if;

            /*-*/
            /* Update the relevant delivery status (deleted) based on the idoc timestamp
            /* ** notes **
            /* 1. The older delivery is flagged as deleted
            /* 2. Any one delivery line will cause the deletion of the whole delivery
            /*-*/
            if rcd_lads_del_hdr_01.idoc_timestamp >= rcd_lads_del_irf_02.idoc_timestamp then
               update lads_del_hdr
                  set lads_date = sysdate,
                      lads_status = '4'
                where vbeln = rcd_lads_del_irf_02.vbeln;
            else
               update lads_del_hdr
                  set lads_date = sysdate,
                      lads_status = '4'
                where vbeln = rcd_lads_del_hdr_01.vbeln;
            end if;

            /*-*/
            /* Update the related delivery status (deleted) when sales order or sales order line deleted
            /*-*/
            if var_so_deleted = true then
               update lads_del_hdr
                  set lads_date = sysdate,
                      lads_status = '4'
                where vbeln = rcd_lads_del_irf_02.vbeln;
            end if;

         end loop;
         close csr_lads_del_irf_02;

      end loop;
      close csr_lads_del_irf_01;

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
         raise_application_error(-20000, 'LADS_ATLLAD16_MONITOR - EXECUTE_BEFORE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_before;
   
   procedure execute_after(par_vbeln in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*---------------------------*/
      /* 1. Triggered procedures   */
      /*---------------------------*/
--      lics_trigger_loader.execute('TRIDENT Interface',
--                                  'site_app.trident_extract_pkg.idoc_monitor(''DLV'',''' || rcd_lads_del_hdr_01.vbeln || ''')',
--                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','TRIDENT_LADTRI01'),
--                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','TRIDENT_LADTRI01'),
--                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','TRIDENT_LADTRI01'));

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
         raise_application_error(-20000, 'LADS_ATLLAD16_MONITOR - EXECUTE_AFTER - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_after;   

end lads_atllad16_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad16_monitor for lads_app.lads_atllad16_monitor;
grant execute on lads_atllad16_monitor to lics_app;
