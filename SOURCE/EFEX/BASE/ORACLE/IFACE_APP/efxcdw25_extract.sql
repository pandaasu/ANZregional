/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw25_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw25_extract
    Owner   : iface_app

    Description
    -----------
    Efex Payment Data - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX payments that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_market in number, par_history in number default 0);

end efxcdw25_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw25_extract as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   con_group constant number := 500;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_market in number, par_history in number default 0) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_history number;
      var_instance number(15,0);
      var_start boolean;
      var_count integer;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_extract is
         select to_char(t01.payment_id) as payment_id,
                to_char(t01.customer_id) as customer_id,
                to_char(t03.sales_territory_id) as sales_territory_id,
                to_char(t06.segment_id) as segment_id,
                to_char(t07.business_unit_id) as business_unit_id,
                to_char(t01.user_id) as user_id,
                to_char(t01.payment_date,'yyyymmddhh24miss') as payment_date,
                t01.payment_method,
                to_char(t01.release_date,'yyyymmddhh24miss') as release_date,
                t01.processed_flg,
                t01.contra_payment_reference,
                t01.payment_notes,
                t01.contra_payment_status,
                to_char(t01.contra_processed_date,'yyyymmddhh24miss') as contra_processed_date,
                to_char(t01.contra_replicated_date,'yyyymmddhh24miss') as contra_replicated_date,
                to_char(t01.contra_deducted as contra_deducted,
                t01.status,
                t01.return_claim_code
           from payment t01,
                customer t02,
                cust_sales_territory t03,
                sales_territory t04,
                sales_area t05,
                sales_region t06,
                segment t07
          where t01.customer_id = t02.customer_id
            and t02.customer_id = t03.customer_id
            and t03.sales_territory_id = t04.sales_territory_id
            and t04.sales_area_id = t05.sales_area_id
            and t05.sales_region_id = t06.sales_region_id
            and t06.segment_id = t07.segment_id
            and t02.market_id = par_market
            and t03.primary_flg = 'Y'
            and (trunc(t01.modified_date) >= trunc(sysdate) - var_history or
                 exists (select 'x' from payment_deal where payment_id = t01.payment_id and trunc(modified_date) >= trunc(sysdate) - var_history) or
                 exists (select 'x' from payment_return where payment_id = t01.payment_id and trunc(modified_date) >= trunc(sysdate) - var_history));
      rcd_extract csr_extract%rowtype;

      cursor csr_deal is
         select to_char(t01.payment_id) as payment_id,
                to_char(t01.sequence_num) as sequence_num,
                to_char(t01.order_id) as order_id,
                t01.details,
                to_char(t01.deal_value) as deal_value,
                t01.status
           from payment_deal t01
          where t01.payment_id = rcd_extract.payment_id
          order by t01.sequence_num asc;
      rcd_deal csr_deal%rowtype;

      cursor csr_retn is
         select to_char(t01.payment_id) as payment_id,
                to_char(t01.sequence_num) as sequence_num,
                to_char(t01.item_id) as item_id,
                t01.return_reason,
                to_char(t01.return_qty) as return_qty,
                to_char(t01.return_value) as return_value,
                t01.status
           from payment_return t01
          where t01.payment_id = rcd_extract.payment_id
          order by t01.sequence_num asc;
      rcd_retn csr_retn%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise procedure
      /*-*/
      var_start := true;
      var_count := 0;

      /*-*/
      /* Define number of days to extract
      /*-*/
      if par_history = 0 then
         var_history := 99999;
      else
         var_history := par_history;
      end if;

      /*-*/
      /* Extract the order data
      /*-*/
      open csr_extract;
      loop
         fetch csr_extract into rcd_extract;
         if csr_extract%notfound then
            exit;
         end if;

         /*-*/
         /* Create outbound interface when required
         /*-*/
         if var_start = true or var_count = con_group then
            if var_start = false and lics_outbound_loader.is_created = true then
               lics_outbound_loader.finalise_interface;
            end if;
            var_instance := lics_outbound_loader.create_interface('EFXCDW25',null,'EFXCDW25.DAT');
            var_start := false;
            var_count := 0;
         end if;

         /*-*/
         /* Append header line
         /*-*/
         var_count := var_count + 1;
         lics_outbound_loader.append_data('HDR'||
                                          nvl(rcd_extract.payment_id,'0')||rpad(' ',10-length(nvl(rcd_extract.payment_id,'0')),' ') ||
                                          nvl(rcd_extract.customer_id,'0')||rpad(' ',10-length(nvl(rcd_extract.customer_id,'0')),' ') ||
                                          nvl(rcd_extract.sales_territory_id,'0')||rpad(' ',10-length(nvl(rcd_extract.sales_territory_id,'0')),' ') ||
                                          nvl(rcd_extract.segment_id,'0')||rpad(' ',10-length(nvl(rcd_extract.segment_id,'0')),' ') ||
                                          nvl(rcd_extract.business_unit_id,'0')||rpad(' ',10-length(nvl(rcd_extract.business_unit_id,'0')),' ') ||
                                          nvl(rcd_extract.user_id,'0')||rpad(' ',10-length(nvl(rcd_extract.user_id,'0')),' ') ||
                                          nvl(rcd_extract.payment_date,' ')||rpad(' ',14-length(nvl(rcd_extract.payment_date,' ')),' ') ||
                                          nvl(rcd_extract.payment_method,' ')||rpad(' ',50-length(nvl(rcd_extract.payment_method,' ')),' ') ||
                                          nvl(rcd_extract.release_date,' ')||rpad(' ',14-length(nvl(rcd_extract.release_date,' ')),' ') ||
                                          nvl(rcd_extract.processed_flg,' ')||rpad(' ',1-length(nvl(rcd_extract.processed_flg,' ')),' ') ||
                                          nvl(rcd_extract.contra_payment_reference,' ')||rpad(' ',50-length(nvl(rcd_extract.contra_payment_reference,' ')),' ') ||
                                          nvl(rcd_extract.contra_payment_status,' ')||rpad(' ',50-length(nvl(rcd_extract.contra_payment_status,' ')),' ') ||
                                          nvl(rcd_extract.contra_processed_date,' ')||rpad(' ',14-length(nvl(rcd_extract.contra_processed_date,' ')),' ') ||
                                          nvl(rcd_extract.contra_replicated_date,' ')||rpad(' ',14-length(nvl(rcd_extract.contra_replicated_date,' ')),' ') ||
                                          nvl(rcd_extract.contra_deducted,'0')||rpad(' ',15-length(nvl(rcd_extract.contra_deducted,'0')),' ') ||
                                          nvl(rcd_extract.return_claim_code,' ')||rpad(' ',50-length(nvl(rcd_extract.return_claim_code,' ')),' ') ||
                                          nvl(rcd_extract.status,' ')||rpad(' ',1-length(nvl(rcd_extract.status,' ')),' '));

         /*-*/
         /* Append note lines
         /*-*/
         lics_outbound_loader.append_data('NTE' || nvl(substr(rcd_extract.payment_notes,1,2000),' ')||rpad(' ',2000-length(nvl(substr(rcd_extract.payment_notes,1,2000),' ')),' '));
         if length(rcd_extract.order_notes) > 2000 then
            lics_outbound_loader.append_data('NTE' || nvl(substr(rcd_extract.payment_notes,2001),' ')||rpad(' ',2000-length(nvl(substr(rcd_extract.payment_notes,2001),' ')),' '));
         end if;

         /*-*/
         /* Append end line
         /*-*/
         lics_outbound_loader.append_data('END');

         /*-*/
         /* Extract the payment deals
         /*-*/
         open csr_deal;
         loop
            fetch csr_deal into rcd_deal;
            if csr_deal%notfound then
               exit;
            end if;
            lics_outbound_loader.append_data('DEH'||
                                             nvl(rcd_deal.payment_id,'0')||rpad(' ',10-length(nvl(rcd_deal.payment_id,'0')),' ') ||
                                             nvl(rcd_deal.sequence_num,'0')||rpad(' ',10-length(nvl(rcd_deal.sequence_num,'0')),' ') ||
                                             nvl(rcd_deal.order_id,'0')||rpad(' ',10-length(nvl(rcd_deal.order_id,'0')),' ') ||
                                             nvl(rcd_deal.deal_value,'0')||rpad(' ',15-length(nvl(rcd_deal.deal_value,'0')),' ') ||
                                             nvl(rcd_deal.status,' ')||rpad(' ',1-length(nvl(rcd_deal.status,' ')),' '));
            lics_outbound_loader.append_data('DED' || nvl(substr(rcd_deal.details,1,2000),' ')||rpad(' ',2000-length(nvl(substr(rcd_deal.details,1,2000),' ')),' '));
            if length(rcd_extract.order_notes) > 2000 then
               lics_outbound_loader.append_data('DED' || nvl(substr(rcd_deal.details,2001),' ')||rpad(' ',2000-length(nvl(substr(rcd_deal.details,2001),' ')),' '));
            end if;
            lics_outbound_loader.append_data('DET');
          end loop;
         close csr_deal;

         /*-*/
         /* Extract the payment returns
         /*-*/
         open csr_retn;
         loop
            fetch csr_retn into rcd_retn;
            if csr_retn%notfound then
               exit;
            end if;
            lics_outbound_loader.append_data('REH'||
                                             nvl(rcd_retn.payment_id,'0')||rpad(' ',10-length(nvl(rcd_retn.payment_id,'0')),' ') ||
                                             nvl(rcd_retn.sequence_num,'0')||rpad(' ',10-length(nvl(rcd_retn.sequence_num,'0')),' ') ||
                                             nvl(rcd_retn.item_id,'0')||rpad(' ',10-length(nvl(rcd_retn.item_id,'0')),' ') ||
                                             nvl(rcd_retn.return_reason,' ')||rpad(' ',50-length(nvl(rcd_retn.return_reason,' ')),' ') ||
                                             nvl(rcd_retn.return_qty,'0')||rpad(' ',15-length(nvl(rcd_retn.return_qty,'0')),' ') ||
                                             nvl(rcd_retn.return_value,'0')||rpad(' ',15-length(nvl(rcd_retn.return_value,'0')),' ') ||
                                             nvl(rcd_retn.status,' ')||rpad(' ',1-length(nvl(rcd_retn.status,' ')),' '));
          end loop;
         close csr_retn;

      end loop;
      close csr_extract;

      /*-*/
      /* Finalise interface when required
      /*-*/
      if var_start = false and lics_outbound_loader.is_created = true then
         lics_outbound_loader.finalise_interface;
      end if;

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
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 1024);

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
         if var_start = false and lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW25 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw25_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw25_extract for iface_app.efxcdw25_extract;
grant execute on efxcdw25_extract to public;
