/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw04_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw04_extract
    Owner   : iface_app

    Description
    -----------
    Efex Affiliation Data - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX affiliations that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_market in number, par_history in number default 0);

end efxcdw04_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw04_extract as

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
         select to_char(t01.affiliation_id) as affiliation_id,
                t01.affiliation_name as affiliation_name,
                to_char(t02.affiliation_group_id) as affiliation_group_id,
                t02.affiliation_group_name as affiliation_group_name,
                to_char(t02.market_id) as market_id,
                t01.status as status
           from affiliation t01,
                affiliation_group t02
          where t01.affiliation_group_id = t02.affiliation_group_id
            and t02.market_id = par_market
            and (trunc(t01.modified_date) >= trunc(sysdate) - var_history or
                 trunc(t02.modified_date) >= trunc(sysdate) - var_history);
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
            var_instance := lics_outbound_loader.create_interface('EFXCDW04',null,'EFXCDW04.DAT');
            var_start := false;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         lics_outbound_loader.append_data('HDR' ||
                                          nvl(rcd_extract.affiliation_id,'0')||rpad(' ',10-length(nvl(rcd_extract.affiliation_id,'0')),' ') ||
                                          nvl(rcd_extract.affiliation_name,' ')||rpad(' ',50-length(nvl(rcd_extract.affiliation_name,' ')),' ') ||
                                          nvl(rcd_extract.affiliation_group_id,'0')||rpad(' ',10-length(nvl(rcd_extract.affiliation_group_id,'0')),' ') ||
                                          nvl(rcd_extract.affiliation_group_name,' ')||rpad(' ',50-length(nvl(rcd_extract.affiliation_group_name,' ')),' ') ||
                                          nvl(rcd_extract.market_id,'0')||rpad(' ',10-length(nvl(rcd_extract.market_id,'0')),' ') ||
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
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW04 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw04_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw04_extract for iface_app.efxcdw04_extract;
grant execute on efxcdw04_extract to public;
