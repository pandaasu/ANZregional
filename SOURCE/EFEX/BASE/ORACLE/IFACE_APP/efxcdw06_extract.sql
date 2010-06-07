/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw06_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw06_extract
    Owner   : iface_app

    Description
    -----------
    Efex Sales Territory Data - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX sales territories that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_market in number, par_history in number default 0);

end efxcdw06_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw06_extract as

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
         select to_char(t01.sales_territory_id) as sales_territory_id,
                t01.sales_territory_name as sales_territory_name,
                t01.status as sales_territory_status,
                to_char(t01.user_id) as sales_territory_user_id,
                to_char(t02.sales_area_id) as sales_area_id,
                t02.sales_area_name as sales_area_name,
                t02.status as sales_area_status,
                to_char(t02.user_id) as sales_area_user_id,
                nvl(t06.firstname,'Unknown')||' '||t06.lastname as sales_area_user_name,
                to_char(t03.sales_region_id) as sales_region_id,
                t03.sales_region_name as sales_region_name,
                t03.status as sales_region_status,
                to_char(t03.user_id) as sales_region_user_id,
                nvl(t07.firstname,'Unknown')||' '||t07.lastname as sales_region_user_name,
                to_char(t04.segment_id) as segment_id,
                t04.status as segment_status,
                to_char(t05.business_unit_id) as business_unit_id,
                case when (t01.modified_date > t02.modified_date) then to_char(t01.modified_date,'yyyymmddhh24miss') else to_char(t02.modified_date,'yyyymmddhh24miss') end efex_lupdt
           from sales_territory t01,
                sales_area t02,
                sales_region t03,
                segment t04,
                business_unit t05,
                users t06,
                users t07
          where t01.sales_area_id = t02.sales_area_id
            and t02.sales_region_id = t03.sales_region_id
            and t02.user_id = t06.user_id
            and t03.segment_id = t04.segment_id
            and t03.user_id = t07.user_id
            and t04.business_unit_id = t05.business_unit_id
            and t05.market_id = par_market
            and (trunc(t01.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t02.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t03.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t04.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t05.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t06.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t07.modified_date) >= trunc(sysdate) - var_history);
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
            var_instance := lics_outbound_loader.create_interface('EFXCDW06',null,'EFXCDW06.DAT');
            var_start := false;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         lics_outbound_loader.append_data('HDR' ||
                                          nvl(rcd_extract.sales_territory_id,'0')||rpad(' ',10-length(nvl(rcd_extract.sales_territory_id,'0')),' ') ||
                                          nvl(rcd_extract.sales_territory_name,' ')||rpad(' ',50-length(nvl(rcd_extract.sales_territory_name,' ')),' ') ||
                                          nvl(rcd_extract.sales_territory_status,' ')||rpad(' ',1-length(nvl(rcd_extract.sales_territory_status,' ')),' ') ||
                                          nvl(rcd_extract.sales_territory_user_id,'0')||rpad(' ',10-length(nvl(rcd_extract.sales_territory_user_id,'0')),' ') ||
                                          nvl(rcd_extract.sales_area_id,'0')||rpad(' ',10-length(nvl(rcd_extract.sales_area_id,'0')),' ') ||
                                          nvl(rcd_extract.sales_area_name,' ')||rpad(' ',50-length(nvl(rcd_extract.sales_area_name,' ')),' ') ||
                                          nvl(rcd_extract.sales_area_status,' ')||rpad(' ',1-length(nvl(rcd_extract.sales_area_status,' ')),' ') ||
                                          nvl(rcd_extract.sales_area_user_id,'0')||rpad(' ',10-length(nvl(rcd_extract.sales_area_user_id,'0')),' ') ||
                                          nvl(rcd_extract.sales_area_user_name,' ')||rpad(' ',120-length(nvl(rcd_extract.sales_area_user_name,' ')),' ') ||
                                          nvl(rcd_extract.sales_region_id,'0')||rpad(' ',10-length(nvl(rcd_extract.sales_region_id,'0')),' ') ||
                                          nvl(rcd_extract.sales_region_name,' ')||rpad(' ',50-length(nvl(rcd_extract.sales_region_name,' ')),' ') ||
                                          nvl(rcd_extract.sales_region_status,' ')||rpad(' ',1-length(nvl(rcd_extract.sales_region_status,' ')),' ') ||
                                          nvl(rcd_extract.sales_region_user_id,'0')||rpad(' ',10-length(nvl(rcd_extract.sales_region_user_id,'0')),' ') ||
                                          nvl(rcd_extract.sales_region_user_name,' ')||rpad(' ',120-length(nvl(rcd_extract.sales_region_user_name,' ')),' ') ||
                                          nvl(rcd_extract.segment_id,'0')||rpad(' ',10-length(nvl(rcd_extract.segment_id,'0')),' ') ||
                                          nvl(rcd_extract.segment_status,' ')||rpad(' ',1-length(nvl(rcd_extract.segment_status,' ')),' ') ||
                                          nvl(rcd_extract.business_unit_id,'0')||rpad(' ',10-length(nvl(rcd_extract.business_unit_id,'0')),' ') ||
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
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW06 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw06_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw06_extract for iface_app.efxcdw06_extract;
grant execute on efxcdw06_extract to public;
