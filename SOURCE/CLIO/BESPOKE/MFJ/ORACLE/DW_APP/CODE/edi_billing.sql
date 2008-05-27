/******************/
/* Package Header */
/******************/
create or replace package edi_billing as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : edi_billing
    Owner   : dw_app

    Description
    -----------
    Electronic Data Interchange - EDI Billing

    This package contains the EDI billing functions.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function whslr_monthly(par_date in varchar2) return edi_billing_table pipelined;
   function whslr_cycle return edi_cycle_table pipelined;

end edi_billing;
/

/****************/
/* Package Body */
/****************/
create or replace package body edi_billing as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*****************************************************************/
   /* This function performs the wholesaler monthly billing routine */
   /*****************************************************************/
   function whslr_monthly(par_date in varchar2) return edi_billing_table pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      var_current_month varchar2(6);
      var_billing_month varchar2(6);
      var_bilto_date varchar2(8);
      var_bilto_str_date varchar2(8);
      var_bilto_end_date varchar2(8);
      var_sndon_date varchar2(8);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_whslr is 
         select *
           from whslr t01
          order by t01.edi_sndto_code;
      rcd_whslr csr_whslr%rowtype;

      cursor csr_whslr_cycle_hdr is 
         select *
           from whslr_cycle_hdr t01
          where t01.edi_sndto_code = rcd_whslr.edi_sndto_code
            and t01.edi_effat_month <= var_current_month
          order by t01.edi_effat_month desc;
      rcd_whslr_cycle_hdr csr_whslr_cycle_hdr%rowtype;

      cursor csr_whslr_cycle_det is 
         select *
           from whslr_cycle_det t01
          where t01.edi_sndto_code = rcd_whslr_cycle_hdr.edi_sndto_code
            and t01.edi_effat_month = rcd_whslr_cycle_hdr.edi_effat_month
          order by t01.edi_endon_day desc;
      rcd_whslr_cycle_det csr_whslr_cycle_det%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve all wholesalers
      /*-*/
      open csr_whslr;
      loop
         fetch csr_whslr into rcd_whslr;
         if csr_whslr%notfound then
            exit;
         end if;

         /*-*/
         /* Search for billing events until current monthly cycle date has past
         /*-*/
         var_current_month := substr(par_date,1,6);
         var_billing_month := to_char(add_months(to_date(par_date,'yyyymmdd'),-1),'yyyymm');
         loop

            /*-*/
            /* Look for a cycle effective month that satisfies the current billing month
            /* **notes** 1. Less than or equal to the current month
            /*-*/
            open csr_whslr_cycle_hdr;
            fetch csr_whslr_cycle_hdr into rcd_whslr_cycle_hdr;
            if csr_whslr_cycle_hdr%found then

               /*-*/
               /* Generate billing events that satisfy the current month from the related cycle details
               /* **notes** 1. The send on date must be equal to the current monthly cycle date
               /*           2. The end on day is always assumed to be in the current period
               /*-*/
               open csr_whslr_cycle_det;
               loop
                  fetch csr_whslr_cycle_det into rcd_whslr_cycle_det;
                  if csr_whslr_cycle_det%notfound then
                     exit;
                  end if;
                  if upper(rcd_whslr_cycle_det.edi_stron_month) = 'P' then
                     var_bilto_str_date := substr(to_char(add_months(to_date(var_current_month||'01','yyyymmdd'),-1),'yyyymmdd'),1,6)||rcd_whslr_cycle_det.edi_stron_day;
                  else
                     var_bilto_str_date := var_current_month||rcd_whslr_cycle_det.edi_stron_day;
                  end if;
                  if rcd_whslr_cycle_det.edi_endon_day = '99' then
                     var_bilto_end_date := to_char(last_day(to_date(var_current_month||'01','yyyymmdd')),'yyyymmdd');
                  else
                     var_bilto_end_date := var_current_month||rcd_whslr_cycle_det.edi_endon_day;
                  end if;
                  var_bilto_date := var_bilto_end_date;
                  var_sndon_date := to_char(to_date(var_bilto_end_date,'yyyymmdd')+rcd_whslr_cycle_hdr.edi_sndon_delay,'yyyymmdd');
                  if var_sndon_date = par_date then
                     pipe row(edi_billing_object(rcd_whslr.edi_sndto_code,
                                                 var_bilto_date,
                                                 var_bilto_str_date,
                                                 var_bilto_end_date,
                                                 var_sndon_date));
                  end if;
               end loop;
               close csr_whslr_cycle_det;

            end if;
            close csr_whslr_cycle_hdr;

            /*-*/
            /* Decrement the current month and exit when required
            /*-*/
            var_current_month := to_char(add_months(to_date(var_current_month||'01','yyyymmdd'),-1),'yyyymm');
            if var_current_month < var_billing_month then
               exit;
            end if;

         end loop;

      end loop;
      close csr_whslr;

      /*-*/
      /* Return
      /*-*/  
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
         raise_application_error(-20000, 'FATAL ERROR - EDI_BILLING - WHSLR_MONTHLY - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end whslr_monthly;

   /*******************************************************/
   /* This function performs the wholesaler cycle routine */
   /*******************************************************/
   function whslr_cycle return edi_cycle_table pipelined is

      /*-*/
      /* Local definitions
      /*-*/
      sav_sndto_code whslr_cycle_det.edi_sndto_code%type;
      sav_effat_month whslr_cycle_det.edi_effat_month%type;
      var_cycle_text varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_whslr_cycle_det is 
         select t01.edi_sndto_code,
                t01.edi_effat_month,
                decode(edi_stron_month,'P','Previous ','C','Current ',edi_stron_month)||edi_stron_day||
                ' - Current '||decode(edi_endon_day,'99','*LAST',edi_endon_day) as cycle_text
           from whslr_cycle_det t01
          order by t01.edi_sndto_code asc,
                   t01.edi_effat_month asc,
                   t01.edi_endon_day asc;
      rcd_whslr_cycle_det csr_whslr_cycle_det%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve all wholesaler cycle details
      /*-*/
      sav_sndto_code := null;
      sav_effat_month := null;
      open csr_whslr_cycle_det;
      loop
         fetch csr_whslr_cycle_det into rcd_whslr_cycle_det;
         if csr_whslr_cycle_det%notfound then
            exit;
         end if;
         if sav_sndto_code is null or
            sav_sndto_code != rcd_whslr_cycle_det.edi_sndto_code or
            sav_effat_month != rcd_whslr_cycle_det.edi_effat_month then
            if not(sav_sndto_code is null) then
               pipe row(edi_cycle_object(sav_sndto_code,
                                         sav_effat_month,
                                         var_cycle_text));
            end if;
            sav_sndto_code := rcd_whslr_cycle_det.edi_sndto_code;
            sav_effat_month := rcd_whslr_cycle_det.edi_effat_month;
            var_cycle_text := null;
         end if;
         if not(var_cycle_text is null) then
            var_cycle_text := var_cycle_text || '; ';
         end if;
         var_cycle_text := var_cycle_text || rcd_whslr_cycle_det.cycle_text;
      end loop;
      close csr_whslr_cycle_det;
      if not(sav_sndto_code is null) then
         pipe row(edi_cycle_object(sav_sndto_code,
                                   sav_effat_month,
                                   var_cycle_text));
      end if;

      /*-*/
      /* Return
      /*-*/  
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
         raise_application_error(-20000, 'FATAL ERROR - EDI_BILLING - WHSLR_CYCLE - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end whslr_cycle;

end edi_billing;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym edi_billing for dw_app.edi_billing;
grant execute on edi_billing to public;
