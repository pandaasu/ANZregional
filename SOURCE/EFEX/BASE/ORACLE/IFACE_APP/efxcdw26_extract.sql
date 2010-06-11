/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw26_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw26_extract
    Owner   : iface_app

    Description
    -----------
    Efex MRQ Data - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_TIMESTAMP (MANDATORY)

       ## - Timestamp (YYYYMMDDHH24MISS) for the extract

    3. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX MRQ data that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function execute(par_market in number, par_timestamp in varchar2, par_history in number default 0) return number;

end efxcdw26_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw26_extract as

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
         select to_char(t01.mrq_id) as mrq_id,
                to_char(t01.customer_id) as customer_id,
                to_char(t03.sales_territory_id) as sales_territory_id,
                to_char(t06.segment_id) as segment_id,
                to_char(t07.business_unit_id) as business_unit_id,
                to_char(t01.user_id) as user_id,
                to_char(t01.created_datime,'yyyymmddhh24miss') as created_datime,
                to_char(t01.mrq_datime,'yyyymmddhh24miss') as mrq_datime,
                to_char(t01.alt_datime,'yyyymmddhh24miss') as alt_datime,
                to_char(t01.cust_contact_id) as cust_contact_id,
                t08.first_name||' '||t08.last_name as cust_contact_name,
                t01.merch_name,
                t01.merch_comments,
                to_char(t01.merch_travel_mins) as merch_travel_mins,
                to_char(t01.merch_travel_kms) as merch_travel_kms,
                to_char(t01.date_completed,'yyyymmddhh24miss') as date_completed,
                t01.complete_flg,
                t01.satisfactory_flg,
                t01.status
           from mrq t01,
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
            and t02.market_id = par_market
            and t03.primary_flg = 'Y'
            and trunc(t01.modified_date) >= trunc(sysdate) - var_history;
      rcd_extract csr_extract%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise procedure
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
         if var_count = con_group then
            if var_instance != -1 then
               lics_outbound_loader.finalise_interface;
            end if;
            var_instance := lics_outbound_loader.create_interface('EFXCDW26',null,'EFXCDW26.DAT');
            lics_outbound_loader.append_data('CTL'||'EFXCDW26'||rpad(' ',32-length('EFXCDW26'),' ')||nvl(par_market,'0')||rpad(' ',10-length(nvl(par_market,'0')),' ')||nvl(par_timestamp,' ')||rpad(' ',14-length(nvl(par_timestamp,' ')),' '));
            var_count := 0;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         var_count := var_count + 1;
         var_return := var_return + 1;
         lics_outbound_loader.append_data('HDR'||
                                          nvl(rcd_extract.mrq_id,'0')||rpad(' ',10-length(nvl(rcd_extract.mrq_id,'0')),' ') ||
                                          nvl(rcd_extract.customer_id,'0')||rpad(' ',10-length(nvl(rcd_extract.customer_id,'0')),' ') ||
                                          nvl(rcd_extract.sales_territory_id,'0')||rpad(' ',10-length(nvl(rcd_extract.sales_territory_id,'0')),' ') ||
                                          nvl(rcd_extract.segment_id,'0')||rpad(' ',10-length(nvl(rcd_extract.segment_id,'0')),' ') ||
                                          nvl(rcd_extract.business_unit_id,'0')||rpad(' ',10-length(nvl(rcd_extract.business_unit_id,'0')),' ') ||
                                          nvl(rcd_extract.user_id,'0')||rpad(' ',10-length(nvl(rcd_extract.user_id,'0')),' ') ||
                                          nvl(rcd_extract.created_datime,' ')||rpad(' ',14-length(nvl(rcd_extract.created_datime,' ')),' ') ||
                                          nvl(rcd_extract.mrq_datime,' ')||rpad(' ',14-length(nvl(rcd_extract.mrq_datime,' ')),' ') ||
                                          nvl(rcd_extract.alt_datime,' ')||rpad(' ',14-length(nvl(rcd_extract.alt_datime,' ')),' ') ||
                                          nvl(rcd_extract.cust_contact_id,'0')||rpad(' ',10-length(nvl(rcd_extract.cust_contact_id,'0')),' ') ||
                                          nvl(rcd_extract.cust_contact_name,' ')||rpad(' ',101-length(nvl(rcd_extract.cust_contact_name,' ')),' ') ||
                                          nvl(rcd_extract.merch_name,' ')||rpad(' ',50-length(nvl(rcd_extract.merch_name,' ')),' ') ||
                                          nvl(rcd_extract.merch_travel_mins,'0')||rpad(' ',15-length(nvl(rcd_extract.merch_travel_mins,'0')),' ') ||
                                          nvl(rcd_extract.merch_travel_kms,'0')||rpad(' ',15-length(nvl(rcd_extract.merch_travel_kms,'0')),' ') ||
                                          nvl(rcd_extract.date_completed,' ')||rpad(' ',14-length(nvl(rcd_extract.date_completed,' ')),' ') ||
                                          nvl(rcd_extract.complete_flg,' ')||rpad(' ',1-length(nvl(rcd_extract.complete_flg,' ')),' ') ||
                                          nvl(rcd_extract.satisfactory_flg,' ')||rpad(' ',1-length(nvl(rcd_extract.satisfactory_flg,' ')),' ') ||
                                          nvl(rcd_extract.status,' ')||rpad(' ',1-length(nvl(rcd_extract.status,' ')),' '));

         /*-*/
         /* Append comment lines
         /*-*/
         lics_outbound_loader.append_data('COM' || nvl(substr(rcd_extract.merch_comments,1,2000),' ')||rpad(' ',2000-length(nvl(substr(rcd_extract.merch_comments,1,2000),' ')),' '));
         if length(rcd_extract.merch_comments) > 2000 then
            lics_outbound_loader.append_data('COM' || nvl(substr(rcd_extract.merch_comments,2001),' ')||rpad(' ',2000-length(nvl(substr(rcd_extract.merch_comments,2001),' ')),' '));
         end if;

         /*-*/
         /* Append end line
         /*-*/
         lics_outbound_loader.append_data('END');

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
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW26 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw26_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw26_extract for iface_app.efxcdw26_extract;
grant execute on efxcdw26_extract to public;
