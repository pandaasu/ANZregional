/******************/
/* Package Header */
/******************/
create or replace package dw_process_poller as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_process_poller
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Process Poller

    This package contain the process polling logic for the data warehouse streams

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/08   Steve Gregan   Created
    2011/04   Steve Gregan   Added new flag base triggers
    2011/04   Steve Gregan   Added new flattening trigger

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_company in varchar2, par_consolidated in varchar2);

end dw_process_poller;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_process_poller as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_company in varchar2, par_consolidated in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_company varchar2(32 char);
      var_polling_date date;
      var_today_date date;
      var_inv_count number;
      var_return boolean;
      type typ_company is table of varchar2(32 char) index by binary_integer;
      tbl_company typ_company;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_company is
         select t01.*
           from company t01
          where t01.company_code = var_company;
      rcd_company csr_company%rowtype;

      cursor csr_sap_inv_trace is 
         select count(*) as inv_count
           from sap_inv_trace t01
          where t01.company_code = var_company
            and trunc(t01.creatn_date) = trunc(var_polling_date);
      rcd_sap_inv_trace csr_sap_inv_trace%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the company parameter
      /*-*/
      if par_company is null then
         raise_application_error(-20000, 'Company parameter (' || par_company || ') must be specified');
      end if;
      tbl_company.delete;
      var_company := null;
      for idx in 1..length(par_company) loop
         if substr(par_company,idx,1) = ',' then
            if not(var_company is null) then
               if length(var_company) > 3 then
                  raise_application_error(-20000, 'Company code exceeds maximum length 3');
               end if;
               tbl_company(tbl_company.count+1) := var_company;
            end if;
            var_company := null;
         elsif substr(par_company,idx,1) != ' ' then
            var_company := var_company||substr(par_company,idx,1);
         end if;
      end loop;
      if not(var_company is null) then
         if length(var_company) > 3 then
            raise_application_error(-20000, 'Company code exceeds maximum length 3');
         end if;
         tbl_company(tbl_company.count+1) := var_company;
      end if;
      if tbl_company.count = 0 then
         raise_application_error(-20000, 'At least one company code must be supplied');
      end if;

      /*-*/
      /* Validate the consolidated parameter
      /*-*/
      if par_consolidated is null then
         raise_application_error(-20000, 'Consolidated parameter (' || par_consolidated || ') must be specified');
      end if;
      if par_consolidated != 'Y' and par_consolidated != 'N' then
         raise_application_error(-20000, 'Consolidated parameter (' || par_consolidated || ') must be Y or N');
      end if;

      /*-*/
      /* Loop through all polled companies
      /*-*/
      for idx in 1..tbl_company.count loop

         /*-*/
         /* Set the current company code
         /*-*/
         var_company := tbl_company(idx);

         /*-*/
         /* Retrieve the company information
         /*-*/
         open csr_company;
         fetch csr_company into rcd_company;
         if csr_company%notfound then
            raise_application_error(-20000, 'Company ' || var_company || ' not found on the company table');
         end if;
         close csr_company;

         /*-*/
         /* Polling date is always the previous day (converted using the company timezone)
         /*-*/
         var_polling_date := trunc(sysdate-1);
         if rcd_company.company_timezone_code != 'Australia/NSW' then
            var_polling_date := trunc(dw_to_timezone(sysdate,rcd_company.company_timezone_code,'Australia/NSW')-1);
         end if;

         /*-*/
         /* Today date is always the current day (converted using the company timezone)
         /*-*/
         var_today_date := sysdate;
         if rcd_company.company_timezone_code != 'Australia/NSW' then
            var_today_date := dw_to_timezone(sysdate,rcd_company.company_timezone_code,'Australia/NSW');
         end if;

         /*-*/
         /* Attempt to find invoices when required (01:00 today)
         /* **notes** If no invoices have been received for the polling date (ie. previous day)
         /*           then assume that there was no invoice activity for that date and set the
         /*           triggered aggregation trace so that any dependant processing can proceed 
         /*-*/
         if var_today_date > trunc(var_today_date) + (1/24) then
            var_inv_count := 0;
            open csr_sap_inv_trace;
            fetch csr_sap_inv_trace into rcd_sap_inv_trace;
            if csr_sap_inv_trace%found then
               var_inv_count := rcd_sap_inv_trace.inv_count;
            end if;
            close csr_sap_inv_trace;
            if var_inv_count = 0 then
               lics_processing.set_trace('TRIGGERED_AGGREGATION_'||var_company,to_char(var_polling_date,'yyyymmdd'));
            end if;
         end if;

         /*-*/
         /* Check and process the company data mart trigger and base flag file trigger
         /*-*/
         var_return := lics_processing.check_group('DATAMART_TRIGGER_'||var_company,
                                                   to_char(var_polling_date,'yyyymmdd'),
                                                   'DATAMART_'||var_company||'_FIRED');
         if var_return = true then
            lics_stream_loader.execute('DW_DATAMART_STREAM_'||var_company,null);
         end if;

         /*-*/
         /* Check the flag file triggers
         /* 1. Australian company works of server time
         /* 2. New Zealand company must wait until midnight Australian time as the BOXI
         /*    server uses sysdate-1 (australian time) as the processing date
         /*-*/
         if rcd_company.company_timezone_code = 'Australia/NSW' or
            trunc(sysdate) > var_polling_date then

            /*-*/
            /* Check and process the company flag base trigger
            /*-*/
            var_return := lics_processing.check_group('FLAGBASE_TRIGGER_'||var_company,
                                                      to_char(var_polling_date,'yyyymmdd'),
                                                      'FLAGBASE_'||var_company||'_FIRED');
            if var_return = true then
               lics_stream_loader.execute('DW_FLAGBASE_STREAM_'||var_company,null);
            end if

            /*-*/
            /* Check and process the company flag file trigger
            /*-*/
            var_return := lics_processing.check_group('FLAGFILE_TRIGGER_'||var_company,
                                                      to_char(var_polling_date,'yyyymmdd'),
                                                      'FLAGFILE_'||var_company||'_FIRED');
            if var_return = true then
               lics_stream_loader.execute('DW_FLAGFILE_STREAM_'||var_company,null);
            end if;

         end if;

         /*-*/
         /* Check and process the consolidated flag file trigger when required
         /*-*/
         if par_consolidated = 'Y' then

            /*-*/
            /* Check the consolidated flag file triggers
            /* 1. Australian company works of server time
            /* 2. New Zealand company must wait until midnight Australian time as the BOXI
            /*    server uses sysdate-1 (australian time) as the processing date
            /*-*/
            if rcd_company.company_timezone_code = 'Australia/NSW' or
               trunc(sysdate) > var_polling_date then

               /*-*/
               /* Check and process the consolidated flag base trigger
               /*-*/
               var_return := lics_processing.check_group('FLAGBASE_TRIGGER_CON',
                                                         to_char(var_polling_date,'yyyymmdd'),
                                                         'FLAGBASE_CON_FIRED');
               if var_return = true then
                  lics_stream_loader.execute('DW_FLAGBASE_STREAM_CON',null);
               end if;

               /*-*/
               /* Check and process the consolidated flag file trigger
               /*-*/
               var_return := lics_processing.check_group('FLAGFILE_TRIGGER_CON',
                                                         to_char(var_polling_date,'yyyymmdd'),
                                                         'FLAGFILE_CON_FIRED');
               if var_return = true then
                  lics_stream_loader.execute('DW_FLAGFILE_STREAM_CON',null);
               end if;

            end if;

         end if;

      end loop;

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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - DW_PROCESS_POLLER - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end dw_process_poller;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_process_poller for dw_app.dw_process_poller;
grant execute on dw_process_poller to public;
