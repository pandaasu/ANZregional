/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw05_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw05_extract
    Owner   : iface_app

    Description
    -----------
    Efex Customer Channel Data - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_TIMESTAMP (MANDATORY)

       ## - Timestamp (YYYYMMDDHH24MISS) for the extract

    3. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX customer channels that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function execute(par_market in number, par_timestamp in varchar2, par_history in number default 0) return number;

end efxcdw05_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw05_extract as

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
         select to_char(t01.cust_type_id) as cust_type_id,
                t01.cust_type_name as cust_type_name,
                t01.status as cust_type_status,
                to_char(t02.cust_trade_channel_id) as cust_trade_channel_id,
                t02.cust_trade_channel_name as cust_trade_channel_name,
                t02.status as cust_trade_channel_status,
                to_char(t03.cust_channel_id) as cust_channel_id,
                t03.cust_channel_name as cust_channel_name,
                t03.status as cust_channel_status
           from cust_type t01,
                cust_trade_channel t02,
                cust_channel t03
          where t01.cust_trade_channel_id = t02.cust_trade_channel_id
            and t02.cust_channel_id = t03.cust_channel_id
            and t03.market_id = par_market
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
            var_instance := lics_outbound_loader.create_interface('EFXCDW05',null,'EFXCDW05.DAT');
            lics_outbound_loader.append_data('CTL'||'EFXCDW05'||rpad(' ',32-length('EFXCDW05'),' ')||nvl(par_market,'0')||rpad(' ',10-length(nvl(par_market,'0')),' ')||nvl(par_timestamp,' ')||rpad(' ',14-length(nvl(par_timestamp,' ')),' '));
            var_count := 0;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         var_count := var_count + 1;
         var_return := var_return + 1;
         lics_outbound_loader.append_data('HDR' ||
                                          nvl(rcd_extract.cust_type_id,'0')||rpad(' ',10-length(nvl(rcd_extract.cust_type_id,'0')),' ') ||
                                          nvl(rcd_extract.cust_type_name,' ')||rpad(' ',50-length(nvl(rcd_extract.cust_type_name,' ')),' ') ||
                                          nvl(rcd_extract.cust_type_status,' ')||rpad(' ',1-length(nvl(rcd_extract.cust_type_status,' ')),' ') ||
                                          nvl(rcd_extract.cust_trade_channel_id,'0')||rpad(' ',10-length(nvl(rcd_extract.cust_trade_channel_id,'0')),' ') ||
                                          nvl(rcd_extract.cust_trade_channel_name,' ')||rpad(' ',50-length(nvl(rcd_extract.cust_trade_channel_name,' ')),' ') ||
                                          nvl(rcd_extract.cust_trade_channel_status,' ')||rpad(' ',1-length(nvl(rcd_extract.cust_trade_channel_status,' ')),' ') ||
                                          nvl(rcd_extract.cust_channel_id,'0')||rpad(' ',10-length(nvl(rcd_extract.cust_channel_id,'0')),' ') ||
                                          nvl(rcd_extract.cust_channel_name,' ')||rpad(' ',50-length(nvl(rcd_extract.cust_channel_name,' ')),' ') ||
                                          nvl(rcd_extract.cust_channel_status,' ')||rpad(' ',1-length(nvl(rcd_extract.cust_channel_status,' ')),' '));

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
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW05 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw05_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw05_extract for iface_app.efxcdw05_extract;
grant execute on efxcdw05_extract to public;
