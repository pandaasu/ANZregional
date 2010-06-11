/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw15_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw15_extract
    Owner   : iface_app

    Description
    -----------
    Efex Timesheet Call Data - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_TIMESTAMP (MANDATORY)

       ## - Timestamp (YYYYMMDDHH24MISS) for the extract

    3. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX timesheet calls that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function execute(par_market in number, par_timestamp in varchar2, par_history in number default 0) return number;

end efxcdw15_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw15_extract as

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
         select to_char(t01.customer_id) as customer_id,
                to_char(t01.timesheet_date,'yyyymmddhh24miss') as timesheet_date,
                to_char(t01.user_id) as user_id,
                to_char(t03.sales_territory_id) as sales_territory_id,
                to_char(t06.segment_id) as segment_id,
                to_char(t07.business_unit_id) as business_unit_id,
                to_char(t01.calltime1_1) as calltime1_1,
                to_char(t01.calltime1_2) as calltime1_2,
                to_char(t01.calltime1_3) as calltime1_3,
                to_char(t01.calltime1_4) as calltime1_4,
                to_char(t01.calltime1_5) as calltime1_5,
                to_char(t01.calltime1_6) as calltime1_6,
                to_char(t01.traveltime1) as traveltime1,
                to_char(t01.travelkms1) as travelkms1,
                to_char(t01.calltime2_1) as calltime2_1,
                to_char(t01.calltime2_2) as calltime2_2,
                to_char(t01.calltime2_3) as calltime2_3,
                to_char(t01.calltime2_4) as calltime2_4,
                to_char(t01.calltime2_5) as calltime2_5,
                to_char(t01.calltime2_6) as calltime2_6,
                to_char(t01.traveltime2) as traveltime2,
                to_char(t01.travelkms2) as travelkms2,
                to_char(t01.calltime3_1) as calltime3_1,
                to_char(t01.calltime3_2) as calltime3_2,
                to_char(t01.calltime3_3) as calltime3_3,
                to_char(t01.calltime3_4) as calltime3_4,
                to_char(t01.calltime3_5) as calltime3_5,
                to_char(t01.calltime3_6) as calltime3_6,
                to_char(t01.traveltime3) as traveltime3,
                to_char(t01.travelkms3) as travelkms3,
                to_char(t01.calltime4_1) as calltime4_1,
                to_char(t01.calltime4_2) as calltime4_2,
                to_char(t01.calltime4_3) as calltime4_3,
                to_char(t01.calltime4_4) as calltime4_4,
                to_char(t01.calltime4_5) as calltime4_5,
                to_char(t01.calltime4_6) as calltime4_6,
                to_char(t01.traveltime4) as traveltime4,
                to_char(t01.travelkms4) as travelkms4,
                t01.status as status
           from timesheet_call t01,
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
            var_instance := lics_outbound_loader.create_interface('EFXCDW15',null,'EFXCDW15.DAT');
            lics_outbound_loader.append_data('CTL'||'EFXCDW15'||rpad(' ',32-length('EFXCDW15'),' ')||nvl(par_market,'0')||rpad(' ',10-length(nvl(par_market,'0')),' ')||nvl(par_timestamp,' ')||rpad(' ',14-length(nvl(par_timestamp,' ')),' '));
            var_count := 0;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         var_count := var_count + 1;
         var_return := var_return + 1;
         lics_outbound_loader.append_data('HDR' ||
                                          nvl(rcd_extract.customer_id,'0')||rpad(' ',10-length(nvl(rcd_extract.customer_id,'0')),' ') ||
                                          nvl(rcd_extract.timesheet_date,' ')||rpad(' ',14-length(nvl(rcd_extract.timesheet_date,' ')),' ') ||
                                          nvl(rcd_extract.user_id,'0')||rpad(' ',10-length(nvl(rcd_extract.user_id,'0')),' ') ||
                                          nvl(rcd_extract.sales_territory_id,'0')||rpad(' ',10-length(nvl(rcd_extract.sales_territory_id,'0')),' ') ||
                                          nvl(rcd_extract.segment_id,'0')||rpad(' ',10-length(nvl(rcd_extract.segment_id,'0')),' ') ||
                                          nvl(rcd_extract.business_unit_id,'0')||rpad(' ',10-length(nvl(rcd_extract.business_unit_id,'0')),' ') ||
                                          nvl(rcd_extract.calltime1_1,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime1_1,'0')),' ') ||
                                          nvl(rcd_extract.calltime1_2,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime1_2,'0')),' ') ||
                                          nvl(rcd_extract.calltime1_3,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime1_3,'0')),' ') ||
                                          nvl(rcd_extract.calltime1_4,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime1_4,'0')),' ') ||
                                          nvl(rcd_extract.calltime1_5,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime1_5,'0')),' ') ||
                                          nvl(rcd_extract.calltime1_6,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime1_6,'0')),' ') ||
                                          nvl(rcd_extract.traveltime1,'0')||rpad(' ',10-length(nvl(rcd_extract.traveltime1,'0')),' ') ||
                                          nvl(rcd_extract.travelkms1,'0')||rpad(' ',10-length(nvl(rcd_extract.travelkms1,'0')),' ') ||
                                          nvl(rcd_extract.calltime2_1,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime2_1,'0')),' ') ||
                                          nvl(rcd_extract.calltime2_2,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime2_2,'0')),' ') ||
                                          nvl(rcd_extract.calltime2_3,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime2_3,'0')),' ') ||
                                          nvl(rcd_extract.calltime2_4,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime2_4,'0')),' ') ||
                                          nvl(rcd_extract.calltime2_5,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime2_5,'0')),' ') ||
                                          nvl(rcd_extract.calltime2_6,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime2_6,'0')),' ') ||
                                          nvl(rcd_extract.traveltime2,'0')||rpad(' ',10-length(nvl(rcd_extract.traveltime2,'0')),' ') ||
                                          nvl(rcd_extract.travelkms2,'0')||rpad(' ',10-length(nvl(rcd_extract.travelkms2,'0')),' ') ||
                                          nvl(rcd_extract.calltime3_1,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime3_1,'0')),' ') ||
                                          nvl(rcd_extract.calltime3_2,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime3_2,'0')),' ') ||
                                          nvl(rcd_extract.calltime3_3,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime3_3,'0')),' ') ||
                                          nvl(rcd_extract.calltime3_4,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime3_4,'0')),' ') ||
                                          nvl(rcd_extract.calltime3_5,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime3_5,'0')),' ') ||
                                          nvl(rcd_extract.calltime3_6,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime3_6,'0')),' ') ||
                                          nvl(rcd_extract.traveltime3,'0')||rpad(' ',10-length(nvl(rcd_extract.traveltime3,'0')),' ') ||
                                          nvl(rcd_extract.travelkms3,'0')||rpad(' ',10-length(nvl(rcd_extract.travelkms3,'0')),' ') ||
                                          nvl(rcd_extract.calltime4_1,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime4_1,'0')),' ') ||
                                          nvl(rcd_extract.calltime4_2,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime4_2,'0')),' ') ||
                                          nvl(rcd_extract.calltime4_3,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime4_3,'0')),' ') ||
                                          nvl(rcd_extract.calltime4_4,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime4_4,'0')),' ') ||
                                          nvl(rcd_extract.calltime4_5,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime4_5,'0')),' ') ||
                                          nvl(rcd_extract.calltime4_6,'0')||rpad(' ',10-length(nvl(rcd_extract.calltime4_6,'0')),' ') ||
                                          nvl(rcd_extract.traveltime4,'0')||rpad(' ',10-length(nvl(rcd_extract.traveltime4,'0')),' ') ||
                                          nvl(rcd_extract.travelkms4,'0')||rpad(' ',10-length(nvl(rcd_extract.travelkms4,'0')),' ') ||
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
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW15 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw15_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw15_extract for iface_app.efxcdw15_extract;
grant execute on efxcdw15_extract to public;
