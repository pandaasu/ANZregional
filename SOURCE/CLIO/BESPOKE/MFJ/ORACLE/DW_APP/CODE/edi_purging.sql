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
      cursor csr_daily is
         select t01.*
           from whslr_dly_inv_hdr t01
          where t01.sap_creatn_date < to_char(sysdate-180,'yyyymmdd');
      rcd_daily csr_daily%rowtype;

      cursor csr_monthly is
         select t01.*
           from whslr_mly_inv_hdr t01
          where t01.edi_bilto_date < to_char(sysdate-180,'yyyymmdd');
      rcd_monthly csr_monthly%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Purge the daily data
      /*-*/
      var_count := 0;
      open csr_daily;
      loop
         if var_count >= cnt_process_count then
            if csr_daily%isopen then
               close csr_daily;
            end if;
            commit;
            open csr_daily;
            var_count := 0;
         end if;
         fetch csr_daily into rcd_daily;
         if csr_daily%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Delete the header and related data
         /*-*/
         delete from whslr_dly_inv_det where sap_invoice_number = rcd_daily.sap_invoice_number;
         delete from whslr_dly_inv_hdr where sap_invoice_number = rcd_daily.sap_invoice_number;

      end loop;
      close csr_daily;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Purge the monthly data
      /*-*/
      var_count := 0;
      open csr_monthly;
      loop
         if var_count >= cnt_process_count then
            if csr_monthly%isopen then
               close csr_monthly;
            end if;
            commit;
            open csr_monthly;
            var_count := 0;
         end if;
         fetch csr_monthly into rcd_monthly;
         if csr_monthly%notfound then
            exit;
         end if;

         /*-*/
         /* Increment the count
         /*-*/
         var_count := var_count + 1;

         /*-*/
         /* Delete the header and related data
         /*-*/
         delete from whslr_mly_inv_det where sap_company_code = rcd_monthly.sap_company_code and edi_sndto_code = rcd_monthly.edi_sndto_code and edi_bilto_date = rcd_monthly.edi_bilto_date;
         delete from whslr_mly_inv_bch where sap_company_code = rcd_monthly.sap_company_code and edi_sndto_code = rcd_monthly.edi_sndto_code and edi_bilto_date = rcd_monthly.edi_bilto_date;
         delete from whslr_mly_inv_hdr where sap_company_code = rcd_monthly.sap_company_code and edi_sndto_code = rcd_monthly.edi_sndto_code and edi_bilto_date = rcd_monthly.edi_bilto_date;

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