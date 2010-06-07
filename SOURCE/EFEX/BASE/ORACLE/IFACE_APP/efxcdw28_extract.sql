/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw28_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw28_extract
    Owner   : iface_app

    Description
    -----------
    Efex Target Data - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX target data that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_market in number, par_history in number default 0);

end efxcdw28_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw28_extract as

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
      var_start boolean;
      var_count integer;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_extract is
         select to_char(t02.sales_territory_id) as sales_territory_id,
                to_char(t01.target_id) as target_id,
                to_char(t02.period) as period,
                to_char(t01.business_unit_id) as business_unit_id,
                t01.target_name,
                to_char(t02.target_value) as target_value,
                to_char(t02.actual_value) as actual_value,
                t01.status
           from target t01,
                target_territory_value t02,
                business_unit t03
          where t01.target_id = t02.target_id
            and t01.business_unit_id = t03.business_unit_id
            and t03.market_id = par_market
            and (trunc(t01.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t02.modified_date) >= trunc(sysdate) - var_history);
      rcd_extract csr_extract%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise procedure
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
            var_instance := lics_outbound_loader.create_interface('EFXCDW28',null,'EFXCDW28.DAT');
            var_start := false;
            var_count := 0;
         end if;

         /*-*/
         /* Append header line
         /*-*/
         var_count := var_count + 1;
         lics_outbound_loader.append_data('HDR'||
                                          nvl(rcd_extract.sales_territory_id,'0')||rpad(' ',10-length(nvl(rcd_extract.sales_territory_id,'0')),' ') ||
                                          nvl(rcd_extract.target_id,'0')||rpad(' ',10-length(nvl(rcd_extract.target_id,'0')),' ') ||
                                          nvl(rcd_extract.period,'0')||rpad(' ',10-length(nvl(rcd_extract.period,'0')),' ') ||
                                          nvl(rcd_extract.business_unit_id,'0')||rpad(' ',10-length(nvl(rcd_extract.business_unit_id,'0')),' ') ||
                                          nvl(rcd_extract.target_name,' ')||rpad(' ',50-length(nvl(rcd_extract.target_name,' ')),' ') ||
                                          nvl(rcd_extract.target_value,'0')||rpad(' ',15-length(nvl(rcd_extract.target_value,'0')),' ') ||
                                          nvl(rcd_extract.actual_value,'0')||rpad(' ',15-length(nvl(rcd_extract.actual_value,'0')),' ') ||
                                          nvl(rcd_extract.status,' ')||rpad(' ',1-length(nvl(rcd_extract.status,' ')),' '));

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
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW28 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw28_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw28_extract for iface_app.efxcdw28_extract;
grant execute on efxcdw28_extract to public;
