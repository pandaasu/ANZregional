/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw17_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw17_extract
    Owner   : iface_app

    Description
    -----------
    Efex Assessment Question Data - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX assessment questions that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_market in number, par_history in number default 0);

end efxcdw17_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw17_extract as

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
                t01.comm_text as comm_text,
                t01.comm_type as comm_type,
                to_char(t01.comm_group_id) as comm_group_id,
                t02.comm_group_name as comm_group_name,
                to_char(t02.segment_id) as segment_id,
                to_char(t03.business_unit_id) as business_unit_id,
                to_char(t01.active_date,'yyyymmddhh24miss') as active_date,
                to_char(t01.inactive_date,'yyyymmddhh24miss') as inactive_date,
                to_char(t01.due_date,'yyyymmddhh24miss') as due_date,
                t01.status as status
           from comm t01,
                comm_group t02,
                segment t03,
                business_unit t04
          where t01.comm_group_id = t02.comm_group_id
            and t01.segment_id = t03.segment_id
            and t03.business_unit_id = t04.business_unit_id
            and t01.comm_type = 'Assessment'
            and t04.market_id = par_market
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
            var_instance := lics_outbound_loader.create_interface('EFXCDW17',null,'EFXCDW17.DAT');
            var_start := false;
         end if;

         /*-*/
         /* Append header line
         /*-*/
         lics_outbound_loader.append_data('HDR' ||
                                          nvl(rcd_extract.comm_id,'0')||rpad(' ',10-length(nvl(rcd_extract.comm_id,'0')),' ') ||
                                          nvl(rcd_extract.comm_type,' ')||rpad(' ',50-length(nvl(rcd_extract.comm_type,' ')),' ') ||
                                          nvl(rcd_extract.comm_group_id,'0')||rpad(' ',10-length(nvl(rcd_extract.comm_group_id,'0')),' ') ||
                                          nvl(rcd_extract.comm_group_name,' ')||rpad(' ',50-length(nvl(rcd_extract.comm_group_name,' ')),' ') ||
                                          nvl(rcd_extract.segment_id,'0')||rpad(' ',10-length(nvl(rcd_extract.segment_id,'0')),' ') ||
                                          nvl(rcd_extract.business_unit_id,'0')||rpad(' ',10-length(nvl(rcd_extract.business_unit_id,'0')),' ') ||
                                          nvl(rcd_extract.active_date,' ')||rpad(' ',14-length(nvl(rcd_extract.active_date,' ')),' ') ||
                                          nvl(rcd_extract.inactive_date,' ')||rpad(' ',14-length(nvl(rcd_extract.inactive_date,' ')),' ') ||
                                          nvl(rcd_extract.due_date,' ')||rpad(' ',14-length(nvl(rcd_extract.due_date,' ')),' ') ||
                                          nvl(rcd_extract.status,' ')||rpad(' ',1-length(nvl(rcd_extract.status,' ')),' '));

         /*-*/
         /* Append text lines
         /*-*/
         lics_outbound_loader.append_data('TXT' || nvl(substr(rcd_extract.comm_text,1,2000),' ')||rpad(' ',2000-length(nvl(substr(rcd_extract.comm_text,1,2000),' ')),' '));
         if length(rcd_extract.comm_text) > 2000 then
            lics_outbound_loader.append_data('TXT' || nvl(substr(rcd_extract.comm_text,2001),' ')||rpad(' ',2000-length(nvl(substr(rcd_extract.comm_text,2001),' ')),' '));
         end if;

         /*-*/
         /* Append end line
         /*-*/
         lics_outbound_loader.append_data('END');

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
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW17 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw17_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw17_extract for iface_app.efxcdw17_extract;
grant execute on efxcdw17_extract to public;