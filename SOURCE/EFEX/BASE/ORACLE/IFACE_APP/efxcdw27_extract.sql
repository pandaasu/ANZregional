/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw27_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw27_extract
    Owner   : iface_app

    Description
    -----------
    Efex MRQ Task Data - EFEX to CDW

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_TIMESTAMP (MANDATORY)

       ## - Timestamp (YYYYMMDDHH24MISS) for the extract

    3. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    This package extracts the EFEX MRQ task data that have been modified within the last
    history number of days and sends the extract file to the CDW environment.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function execute(par_market in number, par_timestamp in varchar2, par_history in number default 0) return number;

end efxcdw27_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw27_extract as

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
      var_hr_rate varchar2(15);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_extract is
         select to_char(t01.mrq_task_id) as mrq_task_id,
                to_char(t01.mrq_id) as mrq_id,
                t01.mrq_task_name,
                t01.job_type,
                t01.display_type,
                to_char(t01.setup_mins) as setup_mins,
                to_char(t01.actual_mins) as actual_mins,
                to_char(0) as hr_rate,
                to_char(t01.actual_cases) as actual_cases,
                t01.compliance_result,
                t01.mrq_pricing,
                t01.mrq_task_notes,
                t01.status
           from mrq_task t01,
                deal t02,
                segment t03,
                business_unit t04
          where t01.deal_id = t02.deal_id
            and t02.segment_id = t03.segment_id
            and t03.business_unit_id = t04.business_unit_id
            and t01.mrq_id is null
            and not(t01.deal_id is null)
            and t04.market_id = par_market
            and (trunc(t01.modified_date) >= trunc(sysdate) - var_history or
                 exists (select 'x' from mrq_task_item where mrq_task_id = t01.mrq_task_id and trunc(modified_date) >= trunc(sysdate) - var_history))
          union
         select to_char(t01.mrq_task_id) as mrq_task_id,
                to_char(t01.mrq_id) as mrq_id,
                t01.mrq_task_name,
                t01.job_type,
                t01.display_type,
                to_char(t01.setup_mins) as setup_mins,
                to_char(t01.actual_mins) as actual_mins,
                to_char(0) as hr_rate,
                to_char(t01.actual_cases) as actual_cases,
                t01.compliance_result,
                t01.mrq_pricing,
                t01.mrq_task_notes,
                t01.status
           from mrq_task t01,
                mrq t02,
                customer t03
          where t01.mrq_id = t02.mrq_id
            and t02.customer_id = t03.customer_id
            and not(t01.mrq_id is null)
            and t01.deal_id is null
            and t03.market_id = par_market
            and (trunc(t01.modified_date) >= trunc(sysdate) - var_history or
                 exists (select 'x' from mrq_task_item where mrq_task_id = t01.mrq_task_id and trunc(modified_date) >= trunc(sysdate) - var_history));
      rcd_extract csr_extract%rowtype;

      cursor csr_item is
         select to_char(t01.mrq_task_id) as mrq_task_id,
                to_char(t01.item_id) as item_id,
                to_char(t01.item_qty) as item_qty,
                t01.supplier,
                t01.status
           from mrq_task_item t01
          where t01.mrq_task_id = rcd_extract.mrq_task_id
          order by t01.item_id asc;
      rcd_item csr_item%rowtype;

      cursor csr_setting is
         select default_value
           from setting
          where setting_name = 'MRQ_RATE';
      rcd_setting csr_setting%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise procedure
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
      /* Retrieve the hourly rate
      /*-*/
      var_hr_rate := '0';
      open csr_setting;
      fetch csr_setting into rcd_setting;
      if csr_setting%found then
         var_hr_rate := rcd_setting.default_value;
      end if;
      open csr_setting;

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
         if var_count = con_group then
            if var_instance != -1 then
               lics_outbound_loader.finalise_interface;
            end if;
            var_instance := lics_outbound_loader.create_interface('EFXCDW27',null,'EFXCDW27.DAT');
            lics_outbound_loader.append_data('CTL'||'EFXCDW27'||rpad(' ',32-length('EFXCDW27'),' ')||nvl(par_market,'0')||rpad(' ',10-length(nvl(par_market,'0')),' ')||nvl(par_timestamp,' ')||rpad(' ',14-length(nvl(par_timestamp,' ')),' '));
            var_count := 0;
         end if;

         /*-*/
         /* Append data lines
         /*-*/
         var_count := var_count + 1;
         var_return := var_return + 1;
         lics_outbound_loader.append_data('HDR'||
                                          nvl(rcd_extract.mrq_task_id,'0')||rpad(' ',10-length(nvl(rcd_extract.mrq_task_id,'0')),' ') ||
                                          nvl(rcd_extract.mrq_id,'0')||rpad(' ',10-length(nvl(rcd_extract.mrq_id,'0')),' ') ||
                                          nvl(rcd_extract.mrq_task_name,' ')||rpad(' ',50-length(nvl(rcd_extract.mrq_task_name,' ')),' ') ||
                                          nvl(rcd_extract.job_type,' ')||rpad(' ',50-length(nvl(rcd_extract.job_type,' ')),' ') ||
                                          nvl(rcd_extract.display_type,' ')||rpad(' ',50-length(nvl(rcd_extract.display_type,' ')),' ') ||
                                          nvl(rcd_extract.setup_mins,'0')||rpad(' ',15-length(nvl(rcd_extract.setup_mins,'0')),' ') ||
                                          nvl(rcd_extract.actual_mins,'0')||rpad(' ',15-length(nvl(rcd_extract.actual_mins,'0')),' ') ||
                                          nvl(var_hr_rate,'0')||rpad(' ',15-length(nvl(var_hr_rate,'0')),' ') ||
                                          nvl(rcd_extract.actual_cases,'0')||rpad(' ',15-length(nvl(rcd_extract.actual_cases,'0')),' ') ||
                                          nvl(rcd_extract.status,' ')||rpad(' ',1-length(nvl(rcd_extract.status,' ')),' '));

         /*-*/
         /* Append result lines
         /*-*/
         lics_outbound_loader.append_data('RES' || nvl(substr(rcd_extract.compliance_result,1,2000),' ')||rpad(' ',2000-length(nvl(substr(rcd_extract.compliance_result,1,2000),' ')),' '));
         if length(rcd_extract.compliance_result) > 2000 then
            lics_outbound_loader.append_data('RES' || nvl(substr(rcd_extract.compliance_result,2001),' ')||rpad(' ',2000-length(nvl(substr(rcd_extract.compliance_result,2001),' ')),' '));
         end if;

         /*-*/
         /* Append pricing lines
         /*-*/
         lics_outbound_loader.append_data('PRC' || nvl(substr(rcd_extract.mrq_pricing,1,2000),' ')||rpad(' ',2000-length(nvl(substr(rcd_extract.mrq_pricing,1,2000),' ')),' '));
         if length(rcd_extract.mrq_pricing) > 2000 then
            lics_outbound_loader.append_data('PRC' || nvl(substr(rcd_extract.mrq_pricing,2001),' ')||rpad(' ',2000-length(nvl(substr(rcd_extract.mrq_pricing,2001),' ')),' '));
         end if;

         /*-*/
         /* Append note lines
         /*-*/
         lics_outbound_loader.append_data('NTE' || nvl(substr(rcd_extract.mrq_task_notes,1,2000),' ')||rpad(' ',2000-length(nvl(substr(rcd_extract.mrq_task_notes,1,2000),' ')),' '));
         if length(rcd_extract.mrq_task_notes) > 2000 then
            lics_outbound_loader.append_data('NTE' || nvl(substr(rcd_extract.mrq_task_notes,2001),' ')||rpad(' ',2000-length(nvl(substr(rcd_extract.mrq_task_notes,2001),' ')),' '));
         end if;

         /*-*/
         /* Append end line
         /*-*/
         lics_outbound_loader.append_data('END');

         /*-*/
         /* Extract the MRQ task items
         /*-*/
         open csr_item;
         loop
            fetch csr_item into rcd_item;
            if csr_item%notfound then
               exit;
            end if;
            lics_outbound_loader.append_data('ITM'||
                                             nvl(rcd_item.mrq_task_id,'0')||rpad(' ',10-length(nvl(rcd_item.mrq_task_id,'0')),' ') ||
                                             nvl(rcd_item.item_id,'0')||rpad(' ',10-length(nvl(rcd_item.item_id,'0')),' ') ||
                                             nvl(rcd_item.item_qty,'0')||rpad(' ',15-length(nvl(rcd_item.item_qty,'0')),' ') ||
                                             nvl(rcd_item.supplier,' ')||rpad(' ',50-length(nvl(rcd_item.supplier,' ')),' ') ||
                                             nvl(rcd_item.status,' ')||rpad(' ',1-length(nvl(rcd_item.status,' ')),' '));
          end loop;
         close csr_item;

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
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW27 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw27_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw27_extract for iface_app.efxcdw27_extract;
grant execute on efxcdw27_extract to public;
