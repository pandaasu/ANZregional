/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw29_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw29_extract
    Owner   : iface_app

    Description
    -----------
    Efex Call Type - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX call type data that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_market in number, par_history in number default 0);

end efxcdw29_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw29_extract as

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
         select to_char(t01.list_value_id) as list_value_id,
                t01.list_value_name,
                t01.status
           from list_values t01
          where t01.market_id = par_market
            and t01.list_type = 'CALL_TYPE'
            and trunc(t01.modified_date) >= trunc(sysdate) - var_history;
      rcd_extract csr_extract%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise procedure
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
         if var_start = true then
            var_instance := lics_outbound_loader.create_interface('EFXCDW29',null,'EFXCDW29.DAT');
            var_start := false;
         end if;

         /*-*/
         /* Append header line
         /*-*/
         lics_outbound_loader.append_data('HDR'||
                                          nvl(rcd_extract.list_value_id,'0')||rpad(' ',10-length(nvl(rcd_extract.list_value_id,'0')),' ') ||
                                          nvl(rcd_extract.list_value_name,' ')||rpad(' ',50-length(nvl(rcd_extract.list_value_name,' ')),' ') ||
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
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW29 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw29_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw29_extract for iface_app.efxcdw29_extract;
grant execute on efxcdw29_extract to public;
