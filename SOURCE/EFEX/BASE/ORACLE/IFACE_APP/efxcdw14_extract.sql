/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw14_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw14_extract
    Owner   : iface_app

    Description
    -----------
    Efex Call Data - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX calls that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_market in number, par_history in number default 0);

end efxcdw14_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw14_extract as

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
                to_char(t01.call_date,'yyyymmddhh24miss') as call_date,
                to_char(t01.user_id) as call_user_id,
                to_char(t03.sales_territory_id) as sales_territory_id,
                to_char(t04.user_id) as sales_territory_user_id,
                to_char(t06.segment_id) as segment_id,
                to_char(t07.business_unit_id) as business_unit_id,
                to_char(t01.accomp_user_id) as accomp_user_id,
                t01.call_type as call_type,
                to_char(t01.end_date,'yyyymmddhh24miss') as end_date,
                t01.status as status
           from call t01,
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
            var_instance := lics_outbound_loader.create_interface('EFXCDW14',null,'EFXCDW14.DAT');
            var_start := false;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         lics_outbound_loader.append_data('HDR' ||
                                          nvl(rcd_extract.customer_id,'0')||rpad(' ',10-length(nvl(rcd_extract.customer_id,'0')),' ') ||
                                          nvl(rcd_extract.call_date,' ')||rpad(' ',14-length(nvl(rcd_extract.call_date,' ')),' ') ||
                                          nvl(rcd_extract.call_user_id,'0')||rpad(' ',10-length(nvl(rcd_extract.call_user_id,'0')),' ') ||
                                          nvl(rcd_extract.sales_territory_id,'0')||rpad(' ',10-length(nvl(rcd_extract.sales_territory_id,'0')),' ') ||
                                          nvl(rcd_extract.sales_territory_user_id,'0')||rpad(' ',10-length(nvl(rcd_extract.sales_territory_user_id,'0')),' ') ||
                                          nvl(rcd_extract.segment_id,'0')||rpad(' ',10-length(nvl(rcd_extract.segment_id,'0')),' ') ||
                                          nvl(rcd_extract.business_unit_id,'0')||rpad(' ',10-length(nvl(rcd_extract.business_unit_id,'0')),' ') ||
                                          nvl(rcd_extract.accomp_user_id,'0')||rpad(' ',10-length(nvl(rcd_extract.accomp_user_id,'0')),' ') ||
                                          nvl(rcd_extract.call_type,' ')||rpad(' ',50-length(nvl(rcd_extract.call_type,' ')),' ') ||
                                          nvl(rcd_extract.end_date,' ')||rpad(' ',14-length(nvl(rcd_extract.end_date,' ')),' ') ||
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
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW14 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw14_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw14_extract for iface_app.efxcdw14_extract;
grant execute on efxcdw14_extract to public;
