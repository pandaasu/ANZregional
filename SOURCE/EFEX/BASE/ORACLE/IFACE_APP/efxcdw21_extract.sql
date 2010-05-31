/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw21_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw21_extract
    Owner   : iface_app

    Description
    -----------
    Efex Range Item Data - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX range items that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_market in number, par_history in number default 0);

end efxcdw21_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw21_extract as

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
         select to_char(t01.range_id) as range_id,
                to_char(t01.item_id) as item_id,
                t01.ref_code as ref_code,
                t01.grade as grade,
                t01.required_flg as required_flg,
                to_char(t01.start_date,'yyyymmddhh24miss') as start_date,
                to_char(t01.target_date,'yyyymmddhh24miss') as target_date,
                t01.status as status
           from range_item t01,
                range t02
          where t01.range_id = t02.range_id
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
            var_instance := lics_outbound_loader.create_interface('EFXCDW21',null,'EFXCDW21.DAT');
            var_start := false;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         lics_outbound_loader.append_data('HDR' ||
                                          nvl(rcd_extract.range_id,'0')||rpad(' ',10-length(nvl(rcd_extract.range_id,'0')),' ') ||
                                          nvl(rcd_extract.item_id,'0')||rpad(' ',10-length(nvl(rcd_extract.item_id,'0')),' ') ||
                                          nvl(rcd_extract.ref_code,' ')||rpad(' ',50-length(nvl(rcd_extract.ref_code,' ')),' ') ||
                                          nvl(rcd_extract.grade,' ')||rpad(' ',50-length(nvl(rcd_extract.grade,' ')),' ') ||
                                          nvl(rcd_extract.required_flg,' ')||rpad(' ',1-length(nvl(rcd_extract.required_flg,' ')),' ') ||
                                          nvl(rcd_extract.start_date,' ')||rpad(' ',14-length(nvl(rcd_extract.start_date,' ')),' ') ||
                                          nvl(rcd_extract.target_date,' ')||rpad(' ',14-length(nvl(rcd_extract.target_date,' ')),' ') ||
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
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW21 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw21_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw21_extract for iface_app.efxcdw21_extract;
grant execute on efxcdw21_extract to public;
