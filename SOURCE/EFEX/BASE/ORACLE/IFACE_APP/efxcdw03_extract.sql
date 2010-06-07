/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw03_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw03_extract
    Owner   : iface_app

    Description
    -----------
    Efex User Data - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX users that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_market in number, par_history in number default 0);

end efxcdw03_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw03_extract as

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
                t01.firstname as firstname,
                t01.lastname as lastname,
                t01.email_address as email_address,
                t01.phone_number as phone_number,
                to_char(t01.market_id) as market_id,
                t01.status as status
           from users t01
          where t01.market_id = par_market
            and (trunc(t01.modified_date) >= trunc(sysdate) - var_history or
                 exists (select 'x' from user_segment where user_id = t01.user_id and trunc(modified_date) >= trunc(sysdate) - var_history));
      rcd_extract csr_extract%rowtype;

      cursor csr_segment is
         select to_char(t01.user_id) as user_id,
                to_char(t02.segment_id) as segment_id,
                to_char(t03.business_unit_id) as business_unit_id,
                t01.status
           from user_segment t01,
                segment t02,
                business_unit t03
          where t01.segment_id = t02.segment_id
            and t02.business_unit_id = t03.business_unit_id
            and t01.user_id = rcd_extract.user_id
          order by t01.segment_id asc;
      rcd_segment csr_segment%rowtype;

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
            var_instance := lics_outbound_loader.create_interface('EFXCDW03',null,'EFXCDW03.DAT');
            var_start := false;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         lics_outbound_loader.append_data('HDR' ||
                                          nvl(rcd_extract.user_id,'0')||rpad(' ',10-length(nvl(rcd_extract.user_id,'0')),' ') ||
                                          nvl(rcd_extract.firstname,' ')||rpad(' ',50-length(nvl(rcd_extract.firstname,' ')),' ') ||
                                          nvl(rcd_extract.lastname,' ')||rpad(' ',50-length(nvl(rcd_extract.lastname,' ')),' ') ||
                                          nvl(rcd_extract.email_address,' ')||rpad(' ',50-length(nvl(rcd_extract.email_address,' ')),' ') ||
                                          nvl(rcd_extract.phone_number,' ')||rpad(' ',50-length(nvl(rcd_extract.phone_number,' ')),' ') ||
                                          nvl(rcd_extract.market_id,'0')||rpad(' ',10-length(nvl(rcd_extract.market_id,'0')),' ') ||
                                          nvl(rcd_extract.status,' ')||rpad(' ',1-length(nvl(rcd_extract.status,' ')),' '));

         /*-*/
         /* Extract the user segments
         /*-*/
         open csr_segment;
         loop
            fetch csr_segment into rcd_segment;
            if csr_segment%notfound then
               exit;
            end if;
            lics_outbound_loader.append_data('SEG'||
                                             nvl(rcd_segment.user_id,'0')||rpad(' ',10-length(nvl(rcd_segment.user_id,'0')),' ') ||
                                             nvl(rcd_segment.segment_id,'0')||rpad(' ',10-length(nvl(rcd_segment.segment_id,'0')),' ') ||
                                             nvl(rcd_segment.business_unit_id,'0')||rpad(' ',10-length(nvl(rcd_segment.business_unit_id,'0')),' ') ||
                                             nvl(rcd_segment.status,' ')||rpad(' ',1-length(nvl(rcd_segment.status,' ')),' '));
          end loop;
         close csr_segment;

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
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW03 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw03_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw03_extract for iface_app.efxcdw03_extract;
grant execute on efxcdw03_extract to public;
