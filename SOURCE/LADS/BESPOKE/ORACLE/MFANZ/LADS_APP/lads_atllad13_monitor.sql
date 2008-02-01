/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad13_monitor
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad13 - Inbound Sales Order Monitor

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2005/04   Linden Glen    Added Trident Global Triggering
 2006/06   Steve Gregan   Modified order line rejection logic to ignore reason ZA

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad13_monitor as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_belnr in varchar2);

end lads_atllad13_monitor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad13_monitor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_belnr in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_rejected boolean;
      var_open boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_sal_ord_hdr_01 is
         select *
           from lads_sal_ord_hdr t01
          where t01.belnr = par_belnr;
      rcd_lads_sal_ord_hdr_01 csr_lads_sal_ord_hdr_01%rowtype;

      cursor csr_lads_sal_ord_gen_01 is
         select t01.belnr,
                t01.posex,
                t01.abgru,
                t01.menge,
                t01.menee
           from lads_sal_ord_gen t01
          where t01.belnr = rcd_lads_sal_ord_hdr_01.belnr;
      rcd_lads_sal_ord_gen_01 csr_lads_sal_ord_gen_01%rowtype;

      cursor csr_lads_del_irf_01 is
         select t01.vbeln
           from lads_del_irf t01,
                lads_del_hdr t02
          where t01.vbeln = t02.vbeln(+)
            and t01.belnr = rcd_lads_sal_ord_gen_01.belnr
            and t01.posnr = rcd_lads_sal_ord_gen_01.posex
            and t01.qualf in ('C','H','I','K','L')
            and not(t01.datum is null)
            and t02.lads_status <> '4';
      rcd_lads_del_irf_01 csr_lads_del_irf_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the sales order
      /*-*/
      open csr_lads_sal_ord_hdr_01;
      fetch csr_lads_sal_ord_hdr_01 into rcd_lads_sal_ord_hdr_01;
      if csr_lads_sal_ord_hdr_01%notfound then
         raise_application_error(-20000, 'Sales order (' || par_belnr || ') not found');
      end if;
      close csr_lads_sal_ord_hdr_01;

      /*-----------------------------------*/
      /* Sales Order and Delivery Deletion */
      /*-----------------------------------*/
      /*
      /* 1. Rejected sales order lines flag related deliveries as deleted
      /* 2. Sales orders with no open lines are flagged as deleted
      /*-*/

      /*-*/
      /* Retrieve the sales order lines
      /*-*/
      var_open := false;
      open csr_lads_sal_ord_gen_01;
      loop
         fetch csr_lads_sal_ord_gen_01 into rcd_lads_sal_ord_gen_01;
         if csr_lads_sal_ord_gen_01%notfound then
            exit;
         end if;

         /*-*/
         /* Rejected sales order line
         /* ** notes reason code is not null
         /*          reason code is not equal 'ZA'
         /*             OR
         /*          quantity ordered is null
         /*          quantity uom is null
         /*-*/
         var_rejected := false;
         if (not(rcd_lads_sal_ord_gen_01.abgru is null) and
             rcd_lads_sal_ord_gen_01.abgru != 'ZA') then
            var_rejected := true;
         else
            if rcd_lads_sal_ord_gen_01.menge is null then
               if rcd_lads_sal_ord_gen_01.menee is null then
                  var_rejected := true;
               end if;
            end if;
         end if;

         /*-*/
         /* Rejected sales order line
         /*-*/
         if var_rejected = true then

            /*-*/
            /* Retrieve any related delivery detail internal reference data
            /* ** note ** the relationship is based on sales order and sales order line
            /*-*/
            open csr_lads_del_irf_01;
            loop
               fetch csr_lads_del_irf_01 into rcd_lads_del_irf_01;
               if csr_lads_del_irf_01%notfound then
                  exit;
               end if;

               /*-*/
               /* Update the related delivery status (deleted)
               /* ** notes **
               /* 1. Any one delivery line will cause the deletion of the whole delivery
               /*-*/
               update lads_del_hdr
                  set lads_date = sysdate,
                      lads_status = '4'
                where vbeln = rcd_lads_del_irf_01.vbeln;

            end loop;
            close csr_lads_del_irf_01;

         /*-*/
         /* Open sales order line
         /*-*/
         else
            var_open := true;
         end if;

      end loop;
      close csr_lads_sal_ord_gen_01;

      /*-*/
      /* Set the sales order status to deleted when no open lines
      /*-*/
      if var_open = false then
         update lads_sal_ord_hdr
            set lads_date = sysdate,
                lads_status = '4'
          where belnr = rcd_lads_sal_ord_hdr_01.belnr;
      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*------------*/
      /* Triggering */
      /*------------*/

      /*-*/
      /* Trigger the TRIDENT interface
      /*-*/
      lics_trigger_loader.execute('TRIDENT Interface',
                                  'site_app.trident_extract_pkg.idoc_monitor(''ORD_SO'',''' || rcd_lads_sal_ord_hdr_01.belnr || ''')',
                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','TRIDENT_LADTRI01'),
                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','TRIDENT_LADTRI01'),
                                  lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','TRIDENT_LADTRI01'));

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
         raise_application_error(-20000, 'LADS_ATLLAD13_MONITOR - EXECUTE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end lads_atllad13_monitor;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad13_monitor for lads_app.lads_atllad13_monitor;
grant execute on lads_atllad13_monitor to lics_app;
