/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw19_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw19_extract
    Owner   : iface_app

    Description
    -----------
    Efex Assessment Data - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX assessments that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_market in number, par_history in number default 0);

end efxcdw19_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw19_extract as

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
         select to_char(t01.comm_id) as comm_id,
                to_char(t01.customer_id) as customer_id,
                to_char(t01.response_date,'yyyymmddhh24miss') as response_date,
                to_char(t01.comm_answer_id) as comm_answer_id,
                t03.answer_text as answer_text,
                to_char(t01.user_id) as user_id,
                to_char(t05.sales_territory_id) as sales_territory_id,
                to_char(t09.segment_id) as segment_id,
                to_char(t09.business_unit_id) as business_unit_id,
                t01.status as status
           from comm_response t01,
                comm t02,
                comm_answer t03,
                customer t04,
                cust_sales_territory t05,
                sales_territory t06,
                sales_area t07,
                sales_region t08,
                segment t09
          where t01.comm_id = t02.comm_id
            and t01.comm_answer_id = t03.comm_answer_id
            and t01.customer_id = t04.customer_id
            and t04.customer_id = t05.customer_id
            and t05.sales_territory_id = t06.sales_territory_id
            and t06.sales_area_id = t07.sales_area_id
            and t07.sales_region_id = t08.sales_region_id
            and t09.segment_id = t09.segment_id
            and t02.comm_type = 'Assessment'
            and t04.market_id = par_market
            and t05.primary_flg = 'Y'
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
            var_instance := lics_outbound_loader.create_interface('EFXCDW19',null,'EFXCDW19.DAT');
            var_start := false;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         lics_outbound_loader.append_data('HDR' ||
                                          nvl(rcd_extract.comm_id,'0')||rpad(' ',10-length(nvl(rcd_extract.comm_id,'0')),' ') ||
                                          nvl(rcd_extract.customer_id,'0')||rpad(' ',10-length(nvl(rcd_extract.customer_id,'0')),' ') ||
                                          nvl(rcd_extract.response_date,' ')||rpad(' ',14-length(nvl(rcd_extract.response_date,' ')),' ') ||
                                          nvl(rcd_extract.comm_answer_id,'0')||rpad(' ',10-length(nvl(rcd_extract.comm_answer_id,'0')),' ') ||
                                          nvl(rcd_extract.answer_text,' ')||rpad(' ',50-length(nvl(rcd_extract.answer_text,' ')),' ') ||
                                          nvl(rcd_extract.user_id,'0')||rpad(' ',10-length(nvl(rcd_extract.user_id,'0')),' ') ||
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
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW19 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw19_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw19_extract for iface_app.efxcdw19_extract;
grant execute on efxcdw19_extract to public;
