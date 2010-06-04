/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw30_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw30_extract
    Owner   : iface_app

    Description
    -----------
    Efex Customer Note - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX customer note data that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_market in number, par_history in number default 0);

end efxcdw30_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw30_extract as

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
         select to_char(t01.cust_note_id) as cust_note_id,
                to_char(t01.customer_id) as customer_id,
                to_char(t03.sales_territory_id) as sales_territory_id,
                to_char(t06.segment_id) as segment_id,
                to_char(t07.business_unit_id) as business_unit_id,
                t01.cust_note_title,
                t01.cust_note_body,
                t01.cust_note_author,
                t01.cust_note_created,
                t01.status
           from cust_note t01,
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
            and trunc(t01.modified_date) >= trunc(sysdate) - var_history
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
            var_instance := lics_outbound_loader.create_interface('EFXCDW30',null,'EFXCDW30.DAT');
            var_start := false;
            var_count := 0;
         end if;

         /*-*/
         /* Append header line
         /*-*/
         var_count := var_count + 1;
         lics_outbound_loader.append_data('HDR'||
                                          nvl(rcd_extract.cust_note_id,'0')||rpad(' ',10-length(nvl(rcd_extract.cust_note_id,'0')),' ') ||
                                          nvl(rcd_extract.customer_id,'0')||rpad(' ',10-length(nvl(rcd_extract.customer_id,'0')),' ') ||
                                          nvl(rcd_extract.sales_territory_id,'0')||rpad(' ',10-length(nvl(rcd_extract.sales_territory_id,'0')),' ') ||
                                          nvl(rcd_extract.segment_id,'0')||rpad(' ',10-length(nvl(rcd_extract.segment_id,'0')),' ') ||
                                          nvl(rcd_extract.business_unit_id,'0')||rpad(' ',10-length(nvl(rcd_extract.business_unit_id,'0')),' ') ||
                                          nvl(rcd_extract.cust_note_title,' ')||rpad(' ',50-length(nvl(rcd_extract.cust_note_title,' ')),' ') ||
                                          nvl(rcd_extract.cust_note_author,' ')||rpad(' ',10-length(nvl(rcd_extract.cust_note_author,' ')),' ') ||
                                          nvl(rcd_extract.note_created,' ')||rpad(' ',50-length(nvl(rcd_note.extract_created,' ')),' ') ||
                                          nvl(rcd_extract.status,' ')||rpad(' ',1-length(nvl(rcd_extract.status,' ')),' '));

         /*-*/
         /* Append note lines
         /*-*/
         lics_outbound_loader.append_data('NTE' || nvl(substr(rcd_note.note_body,1,2000),' ')||rpad(' ',2000-length(nvl(substr(rcd_note.note_body,1,2000),' ')),' '));
         if length(rcd_extract.order_notes) > 2000 then
            lics_outbound_loader.append_data('NTE' || nvl(substr(rcd_note.note_body,2001),' ')||rpad(' ',2000-length(nvl(substr(rcd_note.note_body,2001),' ')),' '));
         end if;

         /*-*/
         /* Append end line
         /*-*/
         lics_outbound_loader.append_data('END');

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
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW30 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw30_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw30_extract for iface_app.efxcdw30_extract;
grant execute on efxcdw30_extract to public;
