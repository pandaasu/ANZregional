/******************/
/* Package Header */
/******************/
create or replace package edi_purging as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : edi_purging
    Owner   : dw_app

    Description
    -----------
    Electronic Data Interchange - EDI Purging

    This package contains the EDI purging logic.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end edi_purging;
/

/****************/
/* Package Body */
/****************/
create or replace package body edi_purging as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure purge_wholesaler;

   /*-*/
   /* Private constants
   /*-*/
   cnt_process_count constant number(5,0) := 100;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Purge the wholesaler data
      /*-*/
      purge_wholesaler;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise the exception
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - EDI - PURGING - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /********************************************************/
   /* This procedure performs the purge wholesaler routine */
   /********************************************************/
   procedure purge_wholesaler is

      /*-*/
      /* Local definitions
      /*-*/
      var_count number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_agency_daily is
         select t01.*
           from agency_dly_inv_hdr t01
          where t01.creatn_date < to_char(sysdate-90,'yyyymmdd');
      rcd_agency_daily csr_agency_daily%rowtype;

      cursor csr_whslr_daily is
         select t01.*
           from whslr_dly_inv_hdr t01
          where t01.sap_creatn_date < to_char(sysdate-90,'yyyymmdd');
      rcd_whslr_daily csr_whslr_daily%rowtype;

      cursor csr_whslr_monthly is
         select t01.*
           from whslr_mly_inv_hdr t01
          where t01.edi_bilto_date < to_char(sysdate-90,'yyyymmdd');
      rcd_whslr_monthly csr_whslr_monthly%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Purge the collection agency daily data
      /*-*/
      var_count := 0;
      open csr_agency_daily;
      loop
         if var_count >= cnt_process_count then
            if csr_agency_daily%isopen then
               close csr_agency_daily;
            end if;
            commit;
            open csr_agency_daily;
            var_count := 0;
         end if;
         fetch csr_agency_daily into rcd_agency_daily;
         if csr_agency_daily%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Delete the header and related data
         /*-*/
         delete from agency_dly_inv_det where gen_belnr = rcd_agency_daily.hdr_belnr;
         delete from agency_dly_inv_hdr where hdr_belnr = rcd_agency_daily.hdr_belnr;

      end loop;
      close csr_agency_daily;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Purge the wholesaler daily data
      /*-*/
      var_count := 0;
      open csr_whslr_daily;
      loop
         if var_count >= cnt_process_count then
            if csr_whslr_daily%isopen then
               close csr_whslr_daily;
            end if;
            commit;
            open csr_whslr_daily;
            var_count := 0;
         end if;
         fetch csr_whslr_daily into rcd_whslr_daily;
         if csr_whslr_daily%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Delete the header and related data
         /*-*/
         delete from whslr_dly_inv_det where sap_invoice_number = rcd_whslr_daily.sap_invoice_number;
         delete from whslr_dly_inv_hdr where sap_invoice_number = rcd_whslr_daily.sap_invoice_number;

      end loop;
      close csr_whslr_daily;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Purge the wholesaler monthly data
      /*-*/
      var_count := 0;
      open csr_whslr_monthly;
      loop
         if var_count >= cnt_process_count then
            if csr_whslr_monthly%isopen then
               close csr_whslr_monthly;
            end if;
            commit;
            open csr_whslr_monthly;
            var_count := 0;
         end if;
         fetch csr_whslr_monthly into rcd_whslr_monthly;
         if csr_whslr_monthly%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Delete the header and related data
         /*-*/
         delete from whslr_mly_inv_det where edi_sndto_code = rcd_whslr_monthly.edi_sndto_code and edi_bilto_date = rcd_whslr_monthly.edi_bilto_date;
         delete from whslr_mly_inv_bch where edi_sndto_code = rcd_whslr_monthly.edi_sndto_code and edi_bilto_date = rcd_whslr_monthly.edi_bilto_date;
         delete from whslr_mly_inv_hdr where edi_sndto_code = rcd_whslr_monthly.edi_sndto_code and edi_bilto_date = rcd_whslr_monthly.edi_bilto_date;

      end loop;
      close csr_monthly;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purge_wholesaler;

end edi_purging;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym edi_purging for dw_app.edi_purging;
grant execute on edi_purging to public;