/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw18_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw18_extract
    Owner   : iface_app

    Description
    -----------
    Efex Assessment Assignment Data - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_TIMESTAMP (MANDATORY)

       ## - Timestamp (YYYYMMDDHH24MISS) for the extract

    3. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX assessment assignments that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function execute(par_market in number, par_timestamp in varchar2, par_history in number default 0) return number;

end efxcdw18_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw18_extract as

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
   function execute(par_market in number, par_timestamp in varchar2, par_history in number default 0) return number is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_history number;
      var_instance number(15,0);
      var_count integer;
      var_return number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_extract is
         select to_char(t01.comm_id) as comm_id,
                to_char(t03.customer_id) as customer_id,
                to_char(t03.cust_type_id) as cust_type_id,
                to_char(t03.affiliation_id) as affiliation_id,
                to_char(t03.sales_region_id) as sales_region_id,
                to_char(t03.segment_id) as segment_id,
                to_char(t03.sales_territory_id) as sales_territory_id,
                to_char(t03.business_unit_id) as business_unit_id,
                t01.status as status
           from comm_assignment t01,
                comm t02,
                (select t01.customer_id,
                        t01.cust_type_id,
                        t01.affiliation_id,
                        t01.state,
                        t02.sales_territory_id,
                        t03.sales_area_id,
                        t04.sales_region_id,
                        t05.segment_id,
                        t06.business_unit_id,
                        t02.status
                   from customer t01,
                        cust_sales_territory t02,
                        sales_territory t03,
                        sales_area t04,
                        sales_region t05,
                        segment t06
                  where t01.customer_id = t02.customer_id
                    and t02.sales_territory_id = t03.sales_territory_id
                    and t03.sales_area_id = t04.sales_area_id
                    and t04.sales_region_id = t05.sales_region_id
                    and t05.segment_id = t06.segment_id
                    and t01.market_id = par_market
                    and t01.status = 'A'
                    and t02.primary_flg = 'Y'
                    and t02.status = 'A') t03
          where t01.comm_id = t02.comm_id
            and t01.segment_id = t03.segment_id
            and (t01.cust_type_id = t03.cust_type_id or t01.cust_type_id is null)
            and (t01.affiliation_id = t03.affiliation_id or t01.affiliation_id is null)
            and (t01.sales_region_id = t03.sales_region_id or t01.sales_region_id is null)
            and (t01.state = t03.state or t01.state is null)
            and t02.comm_type = 'Assessment'
            and trunc(t01.modified_date) >= trunc(sysdate) - var_history;
      rcd_extract csr_extract%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_instance := -1;
      var_count := con_group;
      var_return := 0;

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
         if var_count = con_group then
            if var_instance != -1 then
               lics_outbound_loader.finalise_interface;
            end if;
            var_instance := lics_outbound_loader.create_interface('EFXCDW18',null,'EFXCDW18.DAT');
            lics_outbound_loader.append_data('CTL'||'EFXCDW18'||rpad(' ',32-length('EFXCDW18'),' ')||nvl(par_market,'0')||rpad(' ',10-length(nvl(par_market,'0')),' ')||nvl(par_timestamp,' ')||rpad(' ',14-length(nvl(par_timestamp,' ')),' '));
            var_count := 0;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         var_count := var_count + 1;
         var_return := var_return + 1;
         lics_outbound_loader.append_data('HDR' ||
                                          nvl(rcd_extract.comm_id,'0')||rpad(' ',10-length(nvl(rcd_extract.comm_id,'0')),' ') ||
                                          nvl(rcd_extract.customer_id,'0')||rpad(' ',10-length(nvl(rcd_extract.customer_id,'0')),' ') ||
                                          nvl(rcd_extract.cust_type_id,'0')||rpad(' ',10-length(nvl(rcd_extract.cust_type_id,'0')),' ') ||
                                          nvl(rcd_extract.affiliation_id,'0')||rpad(' ',10-length(nvl(rcd_extract.affiliation_id,'0')),' ') ||
                                          nvl(rcd_extract.sales_region_id,'0')||rpad(' ',10-length(nvl(rcd_extract.sales_region_id,'0')),' ') ||
                                          nvl(rcd_extract.segment_id,'0')||rpad(' ',10-length(nvl(rcd_extract.segment_id,'0')),' ') ||
                                          nvl(rcd_extract.sales_territory_id,'0')||rpad(' ',10-length(nvl(rcd_extract.sales_territory_id,'0')),' ') ||
                                          nvl(rcd_extract.business_unit_id,'0')||rpad(' ',10-length(nvl(rcd_extract.business_unit_id,'0')),' ') ||
                                          nvl(rcd_extract.status,' ')||rpad(' ',1-length(nvl(rcd_extract.status,' ')),' '));

      end loop;
      close csr_extract;

      /*-*/
      /* Finalise Interface
      /*-*/
      if var_instance != -1 then
         lics_outbound_loader.finalise_interface;
      end if;

      /*-*/
      /* Return the result
      /*-*/
      return var_return;

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
         if var_instance != -1 then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW18 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw18_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw18_extract for iface_app.efxcdw18_extract;
grant execute on efxcdw18_extract to public;
