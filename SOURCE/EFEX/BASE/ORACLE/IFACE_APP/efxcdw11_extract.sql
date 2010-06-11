/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw11_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw11_extract
    Owner   : iface_app

    Description
    -----------
    Efex Item Item Sub Group Data - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_TIMESTAMP (MANDATORY)

       ## - Timestamp (YYYYMMDDHH24MISS) for the extract

    3. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX item item sub groups that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function execute(par_market in number, par_timestamp in varchar2, par_history in number default 0) return number;

end efxcdw11_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw11_extract as

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
         select to_char(t01.item_id) as item_id,
                to_char(t01.item_subgroup_id) as item_subgroup_id,
                to_char(t03.segment_id) as segment_id,
                to_char(t02.item_group_id) as item_group_id,
                to_char(t04.business_unit_id) as business_unit_id,
                t01.distribution_flg as distribution_flg,
                case when (t03.status = 'X') then 'X'
                     when (t02.status = 'X') then 'X'
                     else t01.status end as status,
                case when (t02.modified_date > t01.modified_date and t02.modified_date > t03.modified_date) then to_char(t02.modified_date,'yyyymmddhh24miss')
                     when (t03.modified_date > t01.modified_date and t03.modified_date > t02.modified_date) then to_char(t03.modified_date,'yyyymmddhh24miss')
                     else to_char(t01.modified_date,'yyyymmddhh24miss') end as efex_lupdt
           from item_item_subgroup t01,
                item_subgroup t02,
                item_group t03,
                segment t04,
                business_unit t05
          where t01.item_subgroup_id = t02.item_subgroup_id
            and t02.item_group_id = t03.item_group_id
            and t03.segment_id = t04.segment_id
            and t04.business_unit_id = t05.business_unit_id
            and t05.market_id = par_market
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
            var_instance := lics_outbound_loader.create_interface('EFXCDW11',null,'EFXCDW11.DAT');
            lics_outbound_loader.append_data('CTL'||'EFXCDW11'||rpad(' ',32-length('EFXCDW11'),' ')||nvl(par_market,'0')||rpad(' ',10-length(nvl(par_market,'0')),' ')||nvl(par_timestamp,' ')||rpad(' ',14-length(nvl(par_timestamp,' ')),' '));
            var_count := 0;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         var_count := var_count + 1;
         var_return := var_return + 1;
         lics_outbound_loader.append_data('HDR' ||
                                          nvl(rcd_extract.item_id,'0')||rpad(' ',10-length(nvl(rcd_extract.item_id,'0')),' ') ||
                                          nvl(rcd_extract.item_subgroup_id,'0')||rpad(' ',10-length(nvl(rcd_extract.item_subgroup_id,'0')),' ') ||
                                          nvl(rcd_extract.segment_id,'0')||rpad(' ',10-length(nvl(rcd_extract.segment_id,'0')),' ') ||
                                          nvl(rcd_extract.item_group_id,'0')||rpad(' ',10-length(nvl(rcd_extract.item_group_id,'0')),' ') ||
                                          nvl(rcd_extract.business_unit_id,'0')||rpad(' ',10-length(nvl(rcd_extract.business_unit_id,'0')),' ') ||
                                          nvl(rcd_extract.distribution_flg,' ')||rpad(' ',1-length(nvl(rcd_extract.distribution_flg,' ')),' ') ||
                                          nvl(rcd_extract.status,' ')||rpad(' ',1-length(nvl(rcd_extract.status,' ')),' ') ||
                                          nvl(rcd_extract.efex_lupdt,' ')||rpad(' ',14-length(nvl(rcd_extract.efex_lupdt,' ')),' '));

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
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW11 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw11_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw11_extract for iface_app.efxcdw11_extract;
grant execute on efxcdw11_extract to public;
