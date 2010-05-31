/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw24_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw24_extract
    Owner   : iface_app

    Description
    -----------
    Efex Order Data - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX orders that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_market in number, par_history in number default 0);

end efxcdw24_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw24_extract as

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
      var_str_time date;
      var_end_time date;
      var_start boolean;
      var_count integer;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_extract is
         select to_char(t01.order_id) as order_id,
                t01.purchase_order as purchase_order,
                t01.order_notes as order_notes,
                to_char(t01.order_date,'yyyymmddhh24miss') as order_date,
                t01.order_code as order_code,
                to_char(t01.customer_id) as customer_id,
                to_char(t03.sales_territory_id) as sales_territory_id,
                to_char(t07.segment_id) as segment_id,
                to_char(t07.business_unit_id) as business_unit_id,
                to_char(t01.cust_contact_id) as cust_contact_id,
                t08.first_name||' '||t08.last_name as cust_contact,
                to_char(t01.distributor_id) as distributor_id,
                to_char(t01.user_id) as user_id,
                to_char(t01.deliver_date,'yyyymmddhh24miss') as deliver_date,
                to_char(t01.total_items) as total_items,
                to_char(t01.total_price) as total_price,
                t01.confirm_flg as confirm_flg,
                t01.order_status as order_status,
                to_char(t01.tp_amount) as tp_amount,
                t01.tp_paid_flg as tp_paid_flg,
                t01.delivered_flg as delivered_flg,
                t01.status as status
           from orders t01,
                customer t02,
                cust_sales_territory t03,
                sales_territory t04,
                sales_area t05,
                sales_region t06,
                segment t07,
                cust_contact t08
          where t01.customer_id = t02.customer_id
            and t02.customer_id = t03.customer_id
            and t03.sales_territory_id = t04.sales_territory_id
            and t04.sales_area_id = t05.sales_area_id
            and t05.sales_region_id = t06.sales_region_id
            and t06.segment_id = t07.segment_id
            and t01.cust_contact_id = t08.cust_contact_id(+)
            and not(t01.distributor_id is null)
            and t02.market_id = par_market
            and t03.primary_flg = 'Y'
            and (trunc(t01.modified_date) >= trunc(sysdate) - var_history or
                 exists (select 'x' from order_item where order_id = t01.order_id and trunc(modified_date) >= trunc(sysdate) - var_history))
          union
         select to_char(t01.order_id) as order_id,
                t01.purchase_order as purchase_order,
                t01.order_notes as order_notes,
                to_char(t01.order_date,'yyyymmddhh24miss') as order_date,
                t01.order_code as order_code,
                to_char(t01.customer_id) as customer_id,
                to_char(t03.sales_territory_id) as sales_territory_id,
                to_char(t07.segment_id) as segment_id,
                to_char(t07.business_unit_id) as business_unit_id,
                to_char(t01.cust_contact_id) as cust_contact_id,
                t08.first_name||' '||t08.last_name as cust_contact,
                to_char(t01.distributor_id) as distributor_id,
                to_char(t01.user_id) as user_id,
                to_char(t01.deliver_date,'yyyymmddhh24miss') as deliver_date,
                to_char(t01.total_items) as total_items,
                to_char(t01.total_price) as total_price,
                t01.confirm_flg as confirm_flg,
                t01.order_status as order_status,
                to_char(t01.tp_amount) as tp_amount,
                t01.tp_paid_flg as tp_paid_flg,
                t01.delivered_flg as delivered_flg,
                t01.status as status
           from orders t01,
                customer t02,
                cust_sales_territory t03,
                sales_territory t04,
                sales_area t05,
                sales_region t06,
                segment t07,
                cust_contact t08
          where t01.customer_id = t02.customer_id
            and t02.customer_id = t03.customer_id
            and t03.sales_territory_id = t04.sales_territory_id
            and t04.sales_area_id = t05.sales_area_id
            and t05.sales_region_id = t06.sales_region_id
            and t06.segment_id = t07.segment_id
            and t01.cust_contact_id = t08.cust_contact_id(+)
            and t01.distributor_id is null
            and t02.market_id = par_market
            and t03.primary_flg = 'Y'
            and exists (select 'x' from order_source where order_id = t01.order_id and not(distributor_id is null))
            and (trunc(t01.modified_date) >= trunc(sysdate) - var_history or
                 exists (select 'x' from order_item where order_id = t01.order_id and trunc(modified_date) >= trunc(sysdate) - var_history));
      rcd_extract csr_extract%rowtype;

      cursor csr_item01 is
         select to_char(t01.order_id) as order_id,
                to_char(t01.item_id) as item_id,
                to_char(t01.order_qty) as order_qty,
                to_char(t01.alloc_qty) as alloc_qty,
                t01.uom as uom,
                t01.status as status
           from order_item t01
          where t01.order_id = rcd_extract.order_id;
      rcd_item01 csr_item01%rowtype;

      cursor csr_item02 is
         select to_char(t01.order_id) as order_id,
                to_char(t01.item_id) as item_id,
                to_char(t01.order_qty) as order_qty,
                to_char(t01.alloc_qty) as alloc_qty,
                to_char(t03.distributor_id) as distributor_id,
                t01.uom as uom,
                t01.status as status
           from order_item t01,
                item t02,
                order_source t03
          where t01.item_id = t02.item_id
            and t01.order_id = t03.order_id
            and t02.item_source_id = t03.item_source_id
            and t01.order_id = rcd_extract.order_id
            and not(t03.distributor_id is null);
      rcd_item02 csr_item02%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise procedure
      /*-*/
      var_str_time := sysdate;
      var_end_time := sysdate;
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
            var_instance := lics_outbound_loader.create_interface('EFXCDW24',null,'EFXCDW24.DAT');
            var_start := false;
            var_count := 0;
         end if;

         /*-*/
         /* Append header line
         /*-*/
         var_count := var_count + 1;
         lics_outbound_loader.append_data('HDR'||
                                          nvl(to_char(rcd_extract.order_id),'0')||rpad(' ',10-length(nvl(to_char(rcd_extract.order_id),'0')),' ') ||
                                          nvl(rcd_extract.purchase_order,' ')||rpad(' ',50-length(nvl(rcd_extract.purchase_order,' ')),' ') ||
                                          nvl(rcd_extract.order_date,' ')||rpad(' ',14-length(nvl(rcd_extract.order_date,' ')),' ') ||
                                          nvl(rcd_extract.order_code,' ')||rpad(' ',50-length(nvl(rcd_extract.order_code,' ')),' ') ||
                                          nvl(rcd_extract.customer_id,'0')||rpad(' ',10-length(nvl(rcd_extract.customer_id,'0')),' ') ||
                                          nvl(rcd_extract.sales_territory_id,'0')||rpad(' ',10-length(nvl(rcd_extract.sales_territory_id,'0')),' ') ||
                                          nvl(rcd_extract.segment_id,'0')||rpad(' ',10-length(nvl(rcd_extract.segment_id,'0')),' ') ||
                                          nvl(rcd_extract.business_unit_id,'0')||rpad(' ',10-length(nvl(rcd_extract.business_unit_id,'0')),' ') ||
                                          nvl(rcd_extract.cust_contact_id,'0')||rpad(' ',10-length(nvl(rcd_extract.cust_contact_id,'0')),' ') ||
                                          nvl(rcd_extract.cust_contact,' ')||rpad(' ',101-length(nvl(rcd_extract.cust_contact,' ')),' ') ||
                                          nvl(rcd_extract.distributor_id,'0')||rpad(' ',10-length(nvl(rcd_extract.distributor_id,'0')),' ') ||
                                          nvl(rcd_extract.user_id,'0')||rpad(' ',10-length(nvl(rcd_extract.user_id,'0')),' ') ||
                                          nvl(rcd_extract.deliver_date,' ')||rpad(' ',14-length(nvl(rcd_extract.deliver_date,' ')),' ') ||
                                          nvl(rcd_extract.total_items,'0')||rpad(' ',15-length(nvl(rcd_extract.total_items,'0')),' ') ||
                                          nvl(rcd_extract.total_price,'0')||rpad(' ',15-length(nvl(rcd_extract.total_price,'0')),' ') ||
                                          nvl(rcd_extract.confirm_flg,' ')||rpad(' ',1-length(nvl(rcd_extract.confirm_flg,' ')),' ') ||
                                          nvl(rcd_extract.order_status,' ')||rpad(' ',50-length(nvl(rcd_extract.order_status,' ')),' ') ||
                                          nvl(rcd_extract.tp_amount,'0')||rpad(' ',15-length(nvl(rcd_extract.tp_amount,'0')),' ') ||
                                          nvl(rcd_extract.tp_paid_flg,' ')||rpad(' ',1-length(nvl(rcd_extract.tp_paid_flg,' ')),' ') ||
                                          nvl(rcd_extract.delivered_flg,' ')||rpad(' ',1-length(nvl(rcd_extract.delivered_flg,' ')),' ') ||
                                          nvl(rcd_extract.status,' ')||rpad(' ',1-length(nvl(rcd_extract.status,' ')),' '));

         /*-*/
         /* Append note lines
         /*-*/
         lics_outbound_loader.append_data('NTE' || nvl(substr(rcd_extract.order_notes,1,2000),' ')||rpad(' ',2000-length(nvl(substr(rcd_extract.order_notes,1,2000),' ')),' '));
         if length(rcd_extract.order_notes) > 2000 then
            lics_outbound_loader.append_data('NTE' || nvl(substr(rcd_extract.order_notes,2001),' ')||rpad(' ',2000-length(nvl(substr(rcd_extract.order_notes,2001),' ')),' '));
         end if;

         /*-*/
         /* Extract the order items based on the order distributor
         /* **notes**
         /* 1. Assumption that the order customer market is the same as all related order item markets
         /*-*/
         if not(rcd_extract.distributor_id is null) then
            open csr_item01;
            loop
               fetch csr_item01 into rcd_item01;
               if csr_item01%notfound then
                  exit;
               end if;
               lics_outbound_loader.append_data('ITM'||
                                                nvl(to_char(rcd_item01.order_id),'0')||rpad(' ',10-length(nvl(to_char(rcd_item01.order_id),'0')),' ') ||
                                                nvl(to_char(rcd_item01.item_id),'0')||rpad(' ',10-length(nvl(to_char(rcd_item01.item_id),'0')),' ') ||
                                                nvl(to_char(rcd_item01.order_qty),'0')||rpad(' ',15-length(nvl(to_char(rcd_item01.order_qty),'0')),' ') ||
                                                nvl(to_char(rcd_item01.alloc_qty),'0')||rpad(' ',15-length(nvl(to_char(rcd_item01.alloc_qty),'0')),' ') ||
                                                nvl(to_char(rcd_extract.distributor_id),'0')||rpad(' ',10-length(nvl(to_char(rcd_extract.distributor_id),'0')),' ') ||
                                                nvl(rcd_item01.uom,' ')||rpad(' ',10-length(nvl(rcd_item01.uom,' ')),' ') ||
                                                nvl(rcd_item01.status,' ')||rpad(' ',1-length(nvl(rcd_item01.status,' ')),' '));
            end loop;
            close csr_item01;
         else
            open csr_item02;
            loop
               fetch csr_item02 into rcd_item02;
               if csr_item02%notfound then
                  exit;
               end if;
               lics_outbound_loader.append_data('ITM'||
                                                nvl(to_char(rcd_item02.order_id),'0')||rpad(' ',10-length(nvl(to_char(rcd_item02.order_id),'0')),' ') ||
                                                nvl(to_char(rcd_item02.item_id),'0')||rpad(' ',10-length(nvl(to_char(rcd_item02.item_id),'0')),' ') ||
                                                nvl(to_char(rcd_item02.order_qty),'0')||rpad(' ',15-length(nvl(to_char(rcd_item02.order_qty),'0')),' ') ||
                                                nvl(to_char(rcd_item02.alloc_qty),'0')||rpad(' ',15-length(nvl(to_char(rcd_item02.alloc_qty),'0')),' ') ||
                                                nvl(to_char(rcd_item02.distributor_id),'0')||rpad(' ',10-length(nvl(to_char(rcd_item02.distributor_id),'0')),' ') ||
                                                nvl(rcd_item02.uom,' ')||rpad(' ',10-length(nvl(rcd_item02.uom,' ')),' ') ||
                                                nvl(rcd_item02.status,' ')||rpad(' ',1-length(nvl(rcd_item02.status,' ')),' '));
            end loop;
            close csr_item02;
         end if;

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
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW24 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw24_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw24_extract for iface_app.efxcdw24_extract;
grant execute on efxcdw24_extract to public;
