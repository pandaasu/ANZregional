/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw07_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw07_extract
    Owner   : iface_app

    Description
    -----------
    Efex Customer Data - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX customers that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_market in number, par_history in number default 0);

end efxcdw07_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw07_extract as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   con_group constant number := 1000;

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
         select to_char(t01.customer_id) as customer_id,
                t01.customer_code as customer_code,
                t01.customer_name as customer_name,
                t01.status as status,
                to_char(t01.market_id) as market_id,
                t01.address_1 as address_1,
                t01.address_2 as address_2,
                t01.postal_address as postal_address,
                t01.city as city,
                substr(t01.state,1,3) as state,
                t01.postcode as postcode,
                t01.phone_number as phone_number,
                t01.distributor_flg as distributor_flg,
                t01.outlet_flg as outlet_flg,
                t01.active_flg as active_flg,
                to_char(t02.sales_territory_id) as sales_territory_id,
                to_char(t01.range_id) as range_id,
                to_char(t01.cust_visit_freq_id) as cust_visit_freq_id,
                to_char(t04.reporting_measure) as reporting_measure,
                to_char(t01.cust_type_id) as cust_type_id,
                to_char(t01.affiliation_id) as affiliation_id,
                to_char(t01.distributor_id) as distributor_id,
                to_char(t01.cust_grade_id) as cust_grade_id,
                t03.cust_grade_name as cust_grade_name,
                t01.payee_name as payee_name,
                t01.merch_name as merch_name,
                t01.merch_code as merch_code,
                t01.vendor_code as vendor_code,
                t01.vat_reg_num as vat_reg_num,
                to_char(t01.meals_day) as meals_day,
                to_char(t01.lead_time) as lead_time,
                to_char(t01.discount_pct) as discount_pct,
                t01.corporate_flg as corporate_flg,
                case when (t01.modified_date > t02.modified_date) then to_char(t01.modified_date,'yyyymmddhh24miss') else to_char(t02.modified_date,'yyyymmddhh24miss') end as efex_lupdt
           from customer t01,
                cust_sales_territory t02,
                cust_grade t03,
                cust_visit_freq t04
          where t01.customer_id = t02.customer_id
            and t01.cust_grade_id = t03.cust_grade_id(+)
            and t01.cust_visit_freq_id = t04.cust_visit_freq_id(+)
            and t01.market_id = par_market
            and t02.primary_flg = 'Y'
            and (trunc(t01.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t02.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t03.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t04.modified_date) >= trunc(sysdate) - var_history)
          union
         select to_char(t01.customer_id) as customer_id,
                t01.customer_code as customer_code,
                t01.customer_name as customer_name,
                t01.status as status,
                to_char(t01.market_id) as market_id,
                t01.address_1 as address_1,
                t01.address_2 as address_2,
                t01.postal_address as postal_address,
                t01.city as city,
                substr(t01.state,1,3) as state,
                t01.postcode as postcode,
                t01.phone_number as phone_number,
                t01.distributor_flg as distributor_flg,
                t01.outlet_flg as outlet_flg,
                t01.active_flg as active_flg,
                null as sales_territory_id,
                to_char(t01.range_id) as range_id,
                to_char(t01.cust_visit_freq_id) as cust_visit_freq_id,
                to_char(t03.reporting_measure) as reporting_measure,
                to_char(t01.cust_type_id) as cust_type_id,
                to_char(t01.affiliation_id) as affiliation_id,
                to_char(t01.distributor_id) as distributor_id,
                to_char(t01.cust_grade_id) as cust_grade_id,
                t02.cust_grade_name as cust_grade_name,
                t01.payee_name as payee_name,
                t01.merch_name as merch_name,
                t01.merch_code as merch_code,
                t01.vendor_code as vendor_code,
                t01.vat_reg_num as vat_reg_num,
                to_char(t01.meals_day) as meals_day,
                to_char(t01.lead_time) as lead_time,
                to_char(t01.discount_pct) as discount_pct,
                t01.corporate_flg as corporate_flg,
                to_char(t01.modified_date,'yyyymmddhh24miss') as efex_lupdt
           from customer t01,
                cust_grade t02,
                cust_visit_freq t03
          where t01.cust_grade_id = t02.cust_grade_id(+)
            and t01.cust_visit_freq_id = t03.cust_visit_freq_id(+)
            and t01.market_id = par_market
            and t01.distributor_flg = 'Y'
            and not exists (select customer_id
                              from cust_sales_territory
                             where customer_id = t01.customer_id
                               and primary_flg = 'Y')
            and (trunc(t01.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t02.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t03.modified_date) >= trunc(sysdate) - var_history);
      rcd_extract csr_extract%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
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
         if var_start = true or var_count = con_group then
            if var_start = false and lics_outbound_loader.is_created = true then
               lics_outbound_loader.finalise_interface;
            end if;
            var_instance := lics_outbound_loader.create_interface('EFXCDW07',null,'EFXCDW07.DAT');
            var_start := false;
            var_count := 0;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         var_count := var_count + 1;
         lics_outbound_loader.append_data('HDR' ||
                                          nvl(rcd_extract.customer_id,'0')||rpad(' ',10-length(nvl(rcd_extract.customer_id,'0')),' ') ||
                                          nvl(rcd_extract.customer_code,' ')||rpad(' ',50-length(nvl(rcd_extract.customer_code,' ')),' ') ||
                                          nvl(rcd_extract.customer_name,' ')||rpad(' ',100-length(nvl(rcd_extract.customer_name,' ')),' ') ||
                                          nvl(rcd_extract.status,' ')||rpad(' ',1-length(nvl(rcd_extract.status,' ')),' ') ||
                                          nvl(rcd_extract.market_id,'0')||rpad(' ',10-length(nvl(rcd_extract.market_id,'0')),' ') ||
                                          nvl(rcd_extract.address_1,' ')||rpad(' ',100-length(nvl(rcd_extract.address_1,' ')),' ') ||
                                          nvl(rcd_extract.address_2,' ')||rpad(' ',100-length(nvl(rcd_extract.address_2,' ')),' ') ||
                                          nvl(rcd_extract.postal_address,' ')||rpad(' ',50-length(nvl(rcd_extract.postal_address,' ')),' ') ||
                                          nvl(rcd_extract.city,' ')||rpad(' ',50-length(nvl(rcd_extract.city,' ')),' ') ||
                                          nvl(rcd_extract.state,' ')||rpad(' ',50-length(nvl(rcd_extract.state,' ')),' ') ||
                                          nvl(rcd_extract.postcode,' ')||rpad(' ',50-length(nvl(rcd_extract.postcode,' ')),' ') ||
                                          nvl(rcd_extract.phone_number,' ')||rpad(' ',50-length(nvl(rcd_extract.phone_number,' ')),' ') ||
                                          nvl(rcd_extract.distributor_flg,' ')||rpad(' ',1-length(nvl(rcd_extract.distributor_flg,' ')),' ') ||
                                          nvl(rcd_extract.outlet_flg,' ')||rpad(' ',1-length(nvl(rcd_extract.outlet_flg,' ')),' ') ||
                                          nvl(rcd_extract.active_flg,' ')||rpad(' ',1-length(nvl(rcd_extract.active_flg,' ')),' ') ||
                                          nvl(rcd_extract.sales_territory_id,'0')||rpad(' ',10-length(nvl(rcd_extract.sales_territory_id,'0')),' ') ||
                                          nvl(rcd_extract.range_id,'0')||rpad(' ',10-length(nvl(rcd_extract.range_id,'0')),' ') ||
                                          nvl(rcd_extract.cust_visit_freq_id,'0')||rpad(' ',10-length(nvl(rcd_extract.cust_visit_freq_id,'0')),' ') ||
                                          nvl(rcd_extract.reporting_measure,'0')||rpad(' ',15-length(nvl(rcd_extract.reporting_measure,'0')),' ') ||
                                          nvl(rcd_extract.cust_type_id,'0')||rpad(' ',10-length(nvl(rcd_extract.cust_type_id,'0')),' ') ||
                                          nvl(rcd_extract.affiliation_id,'0')||rpad(' ',10-length(nvl(rcd_extract.affiliation_id,'0')),' ') ||
                                          nvl(rcd_extract.distributor_id,'0')||rpad(' ',10-length(nvl(rcd_extract.distributor_id,'0')),' ') ||
                                          nvl(rcd_extract.cust_grade_id,'0')||rpad(' ',10-length(nvl(rcd_extract.cust_grade_id,'0')),' ') ||
                                          nvl(rcd_extract.cust_grade_name,' ')||rpad(' ',50-length(nvl(rcd_extract.cust_grade_name,' ')),' ') ||
                                          nvl(rcd_extract.payee_name,' ')||rpad(' ',50-length(nvl(rcd_extract.payee_name,' ')),' ') ||
                                          nvl(rcd_extract.merch_name,' ')||rpad(' ',50-length(nvl(rcd_extract.merch_name,' ')),' ') ||
                                          nvl(rcd_extract.merch_code,' ')||rpad(' ',50-length(nvl(rcd_extract.merch_code,' ')),' ') ||
                                          nvl(rcd_extract.vendor_code,' ')||rpad(' ',50-length(nvl(rcd_extract.vendor_code,' ')),' ') ||
                                          nvl(rcd_extract.vat_reg_num,' ')||rpad(' ',50-length(nvl(rcd_extract.vat_reg_num,' ')),' ') ||
                                          nvl(rcd_extract.meals_day,'0')||rpad(' ',15-length(nvl(rcd_extract.meals_day,'0')),' ') ||
                                          nvl(rcd_extract.lead_time,'0')||rpad(' ',15-length(nvl(rcd_extract.lead_time,'0')),' ') ||
                                          nvl(rcd_extract.discount_pct,'0')||rpad(' ',15-length(nvl(rcd_extract.discount_pct,'0')),' ') ||
                                          nvl(rcd_extract.corporate_flg,' ')||rpad(' ',1-length(nvl(rcd_extract.corporate_flg,' ')),' ') ||
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
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW07 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw07_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw07_extract for iface_app.efxcdw07_extract;
grant execute on efxcdw07_extract to public;
