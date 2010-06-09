/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw22_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw22_extract
    Owner   : iface_app

    Description
    -----------
    Efex Distribution Data - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX distributions that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_market in number, par_history in number default 0);

end efxcdw22_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw22_extract as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

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

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_extract is
         select to_char(t01.customer_id) as customer_id,
                to_char(t01.item_id) as item_id,
                to_char(t03.sales_territory_id) as sales_territory_id,
                to_char(t06.segment_id) as segment_id,
                to_char(t07.business_unit_id) as business_unit_id,
                to_char(t04.user_id) as user_id,
                to_char(t02.range_id) as range_id,
                to_char(t01.display_qty) as display_qty,
                to_char(t01.facing_qty) as facing_qty,
                t01.out_of_stock_flg as out_of_stock_flg,
                t01.out_of_date_flg as out_of_date_flg,
                t01.required_flg as required_flg,
                to_char(t01.inventory_qty) as inventory_qty,
                to_char(t01.sell_price) as sell_price,
                to_char(t01.in_store_date,'yyyymmddhh24miss') as in_store_date,
                t01.status as status,
                to_char(t01.modified_date,'yyyymmddhh24miss') as efex_lupdt
           from distribution t01,
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
            and (t01.facing_qty > 0 or t01.display_qty > 0 or t01.inventory_qty > 0 or t01.required_flg = 'Y')
            and t02.market_id = par_market
            and t03.primary_flg = 'Y'
            and trunc(t01.modified_date) >= trunc(sysdate) - var_history;
      rcd_extract csr_extract%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_start := true;

      /*-*/
      /* Define number of days to extract
      /*-*/
      if par_history = 0 then
         var_history := 99999;
      else
         var_history := par_history;
      end if;

      /*-*/
      /* Open cursor for output
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
         if var_start = true then
            var_instance := lics_outbound_loader.create_interface('EFXCDW22',null,'EFXCDW22.DAT');
            var_start := false;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         lics_outbound_loader.append_data('HDR' ||
                                          nvl(rcd_extract.customer_id,'0')||rpad(' ',10-length(nvl(rcd_extract.customer_id,'0')),' ') ||
                                          nvl(rcd_extract.item_id,'0')||rpad(' ',10-length(nvl(rcd_extract.item_id,'0')),' ') ||
                                          nvl(rcd_extract.sales_territory_id,'0')||rpad(' ',10-length(nvl(rcd_extract.sales_territory_id,'0')),' ') ||
                                          nvl(rcd_extract.segment_id,'0')||rpad(' ',10-length(nvl(rcd_extract.segment_id,'0')),' ') ||
                                          nvl(rcd_extract.business_unit_id,'0')||rpad(' ',10-length(nvl(rcd_extract.business_unit_id,'0')),' ') ||
                                          nvl(rcd_extract.user_id,'0')||rpad(' ',10-length(nvl(rcd_extract.user_id,'0')),' ') ||
                                          nvl(rcd_extract.range_id,'0')||rpad(' ',10-length(nvl(rcd_extract.range_id,'0')),' ') ||
                                          nvl(rcd_extract.display_qty,'0')||rpad(' ',15-length(nvl(rcd_extract.display_qty,'0')),' ') ||
                                          nvl(rcd_extract.facing_qty,'0')||rpad(' ',15-length(nvl(rcd_extract.facing_qty,'0')),' ') ||
                                          nvl(rcd_extract.out_of_stock_flg,' ')||rpad(' ',1-length(nvl(rcd_extract.out_of_stock_flg,' ')),' ') ||
                                          nvl(rcd_extract.out_of_date_flg,' ')||rpad(' ',1-length(nvl(rcd_extract.out_of_date_flg,' ')),' ') ||
                                          nvl(rcd_extract.required_flg,' ')||rpad(' ',1-length(nvl(rcd_extract.required_flg,' ')),' ') ||
                                          nvl(rcd_extract.inventory_qty,'0')||rpad(' ',15-length(nvl(rcd_extract.inventory_qty,'0')),' ') ||
                                          nvl(rcd_extract.sell_price,'0')||rpad(' ',15-length(nvl(rcd_extract.sell_price,'0')),' ') ||
                                          nvl(rcd_extract.in_store_date,' ')||rpad(' ',14-length(nvl(rcd_extract.in_store_date,' ')),' ') ||
                                          nvl(rcd_extract.status,' ')||rpad(' ',1-length(nvl(rcd_extract.status,' ')),' ') ||
                                          nvl(rcd_extract.efex_lupdt,' ')||rpad(' ',14-length(nvl(rcd_extract.efex_lupdt,' ')),' '));

      end loop;
      close csr_extract;

      /*-*/
      /* Finalise Interface
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
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW22 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw22_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw22_extract for iface_app.efxcdw22_extract;
grant execute on efxcdw22_extract to public;