/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw12_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw12_extract
    Owner   : iface_app

    Description
    -----------
    Efex Route Scheduler Data - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX route schedulers that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_market in number, par_history in number default 0);

end efxcdw12_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw12_extract as

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
         select to_char(t01.user_id) as user_id,
                to_char(t01.route_scheduler_date,'yyyymmddhh24miss') as route_scheduler_date,
                to_char(t01.total_scanned) as total_scanned,
                to_char(t01.total_scheduled) as total_scheduled,
                to_char(t01.total_skipped) as total_skipped,
                to_char(t01.total_errors) as total_errors,
                to_char(t01.total_calls) as total_calls,
                t01.status as status
           from route_scheduler t01,
                users t02
          where t01.user_id = t02.user_id
            and t02.market_id = par_market
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
            var_instance := lics_outbound_loader.create_interface('EFXCDW12',null,'EFXCDW12.DAT');
            var_start := false;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         lics_outbound_loader.append_data('HDR' ||
                                          nvl(rcd_extract.user_id,'0')||rpad(' ',10-length(nvl(rcd_extract.user_id,'0')),' ') ||
                                          nvl(rcd_extract.route_scheduler_date,' ')||rpad(' ',14-length(nvl(rcd_extract.route_scheduler_date,' ')),' ') ||
                                          nvl(rcd_extract.total_scanned,'0')||rpad(' ',15-length(nvl(rcd_extract.total_scanned,'0')),' ') ||
                                          nvl(rcd_extract.total_scheduled,'0')||rpad(' ',15-length(nvl(rcd_extract.total_scheduled,'0')),' ') ||
                                          nvl(rcd_extract.total_skipped,'0')||rpad(' ',15-length(nvl(rcd_extract.total_skipped,'0')),' ') ||
                                          nvl(rcd_extract.total_errors,'0')||rpad(' ',15-length(nvl(rcd_extract.total_errors,'0')),' ') ||
                                          nvl(rcd_extract.total_calls,'0')||rpad(' ',15-length(nvl(rcd_extract.total_calls,'0')),' ') ||
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
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW12 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw12_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw12_extract for iface_app.efxcdw12_extract;
grant execute on efxcdw12_extract to public;