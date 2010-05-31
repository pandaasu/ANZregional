/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw13_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw13_extract
    Owner   : iface_app

    Description
    -----------
    Efex Route Plan Data - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX route plans that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_market in number, par_history in number default 0);

end efxcdw13_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw13_extract as

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
         select to_char(t02.user_id) as user_id,
                to_char(t02.route_plan_date,'yyyymmddhh24miss') as route_plan_date,
                to_char(t02.customer_id) as customer_id,
                to_char(t02.route_plan_order) as route_plan_order,
                to_char(t04.sales_territory_id) as sales_territory_id,
                to_char(t07.segment_id) as segment_id,
                to_char(t08.business_unit_id) as business_unit_id,
                t02.status as status
           from (select user_id,
                        route_plan_date,
                        customer_id,
                        max(route_plan_order) as route_plan_order
                   from route_plan
                  where trunc(modified_date) >= trunc(sysdate) - var_history
                 group by user_id,
                          route_plan_date,
                          customer_id) t01,
                route_plan t02,
                customer t03,
                cust_sales_territory t04,
                sales_territory t05,
                sales_area t06,
                sales_region t07,
                segment t08
          where t01.user_id = t02.user_id
            and t01.customer_id = t02.customer_id
            and t01.route_plan_date = t02.route_plan_date
            and t01.route_plan_order = t02.route_plan_order
            and t02.customer_id = t03.customer_id
            and t03.customer_id = t04.customer_id
            and t04.sales_territory_id = t05.sales_territory_id
            and t05.sales_area_id = t06.sales_area_id
            and t06.sales_region_id = t07.sales_region_id
            and t07.segment_id = t08.segment_id
            and t03.market_id = par_market
            and t04.primary_flg = 'Y'
            and trunc(t02.modified_date) >= trunc(sysdate) - var_history;
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
            var_instance := lics_outbound_loader.create_interface('EFXCDW13',null,'EFXCDW13.DAT');
            var_start := false;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         lics_outbound_loader.append_data('HDR' ||
                                          nvl(rcd_extract.user_id,'0')||rpad(' ',10-length(nvl(rcd_extract.user_id,'0')),' ') ||
                                          nvl(rcd_extract.route_plan_date,' ')||rpad(' ',14-length(nvl(rcd_extract.route_plan_date,' ')),' ') ||
                                          nvl(rcd_extract.customer_id,'0')||rpad(' ',10-length(nvl(rcd_extract.customer_id,'0')),' ') ||
                                          nvl(rcd_extract.route_plan_order,'0')||rpad(' ',15-length(nvl(rcd_extract.route_plan_order,'0')),' ') ||
                                          nvl(rcd_extract.sales_territory_id,'0')||rpad(' ',10-length(nvl(rcd_extract.sales_territory_id,'0')),' ') ||
                                          nvl(rcd_extract.segment_id,'0')||rpad(' ',10-length(nvl(rcd_extract.segment_id,'0')),' ') ||
                                          nvl(rcd_extract.business_unit_id,'0')||rpad(' ',10-length(nvl(rcd_extract.business_unit_id,'0')),' ') ||
                                          nvl(rcd_extract.status,' ')||rpad(' ',1-length(nvl(rcd_extract.status,' ')),' '));

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
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW13 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw13_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw13_extract for iface_app.efxcdw13_extract;
grant execute on efxcdw13_extract to public;
