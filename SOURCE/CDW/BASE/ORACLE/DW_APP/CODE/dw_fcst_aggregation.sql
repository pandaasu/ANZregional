/******************/
/* Package Header */
/******************/
create or replace package dw_fcst_aggregation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_fcst_aggregation
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Forecast Aggregation

    This package contain the forecast aggregation procedures. The package exposes one
    procedure EXECUTE that performs the aggregation based on the following parameters:

    1. PAR_COMPANY (company code) (MANDATORY)

       The company for which the aggregation is to be performed. 

    **notes**
    1. A web log is produced under the search value DW_FCST_AGGREGATION where all errors are logged.

    2. All errors will raise an exception to the calling application so that an alert can
       be raised.

    3. All base tables will attempt to be aggregated and and errors logged.

    4. A deadly embrace with scheduled aggregation is avoided by all data warehouse components
       use the same process isolation locking string and sharing the same ICS stream code.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/08   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_company in varchar2);

end dw_fcst_aggregation;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_fcst_aggregation as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure purch_base_load(par_company_code in varchar2, par_company_currcy in varchar2, par_date in date);
   procedure order_base_load(par_company_code in varchar2, par_company_currcy in varchar2, par_date in date);
   procedure dlvry_base_load(par_company_code in varchar2, par_company_currcy in varchar2, par_date in date);
   procedure nzmkt_base_load(par_company_code in varchar2, par_company_currcy in varchar2, par_date in date);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_company in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_loc_string varchar2(128);
      var_alert varchar2(256);
      var_email varchar2(256);
      var_locked boolean;
      var_errors boolean;
      var_company_code company.company_code%type;
      var_company_currcy company.company_currcy%type;
      var_date date;
      var_test date;
      var_next date;
      var_process_date varchar2(8);
      var_process_code varchar2(32);

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DW Forecast Aggregation';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_company is
         select t01.*
           from company t01
          where t01.company_code = par_company;
      rcd_company csr_company%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'DW - FORECAST_AGGREGATION';
      var_log_search := 'DW_FORECAST_AGGREGATION' || '_' || lics_stream_processor.callback_event;
      var_loc_string := lics_stream_processor.callback_lock;
      var_alert := lics_stream_processor.callback_alert;
      var_email := lics_stream_processor.callback_email;
      var_errors := false;
      var_locked := false;
      if var_loc_string is null then
         raise_application_error(-20000, 'Stream lock not returned - must be executed from the ICS Stream Processor');
      end if;

      /*-*/
      /* Validate the parameters
      /*-*/
      if upper(par_company) is null then
         raise_application_error(-20000, 'Company parameter must be supplied');
      end if;
      open csr_company;
      fetch csr_company into rcd_company;
      if csr_company%notfound then
         raise_application_error(-20000, 'Company ' || par_company || ' not found on the company table');
      end if;
      close csr_company;
      var_company_code := rcd_company.company_code;
      var_company_currcy := rcd_company.company_currcy;

      /*-*/
      /* Aggregation date is always based on the previous day (converted using the company timezone)
      /*-*/
      var_date := trunc(sysdate);
      var_process_date := to_char(var_date-1,'yyyymmdd');
      var_process_code := 'FORECAST_AGGREGATION_'||var_company_code;
      if rcd_company.company_timezone_code != 'Australia/NSW' then
         var_date := dw_to_timezone(trunc(dw_to_timezone(sysdate,rcd_company.company_timezone_code,'Australia/NSW')),'Australia/NSW',rcd_company.company_timezone_code);
         var_process_date := to_char(dw_to_timezone(sysdate,rcd_company.company_timezone_code,'Australia/NSW')-1,'yyyymmdd');
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Forecast Aggregation - Parameters(' || var_company_code || ' + ' || to_char(var_date,'yyyy/mm/dd hh24:mi:ss') || ' + ' || to_char(to_date(var_process_date,'yyyymmdd'),'yyyy/mm/dd') || ')');

      /*-*/
      /* Request the lock on the aggregation
      /*-*/
      begin
         lics_locking.request(var_loc_string);
         var_locked := true;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log(substr(SQLERRM, 1, 1024));
      end;

      /*-*/
      /* Execute the requested procedures
      /* **note** these procedures must be executed in this exact sequence
      /*-*/
      if var_locked = true then

         /*-*/
         /* PURCH_BASE load
         /*-*/
         begin
            purch_base_load(var_company_code, var_company_currcy, var_date);
         exception
            when others then
               var_errors := true;
         end;

         /*-*/
         /* Release the lock on the aggregation
         /*-*/
         lics_locking.release(var_loc_string);

      end if;
      var_locked := false;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Forecast Aggregation');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

      /*-*/
      /* Errors
      /*-*/
      if var_errors = true then

         /*-*/
         /* Alert and email
         /*-*/
         if not(trim(var_alert) is null) and trim(upper(var_alert)) != '*NONE' then
            lics_notification.send_alert(var_alert);
         end if;
         if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
            lics_notification.send_email(dw_parameter.system_code,
                                         dw_parameter.system_unit,
                                         dw_parameter.system_environment,
                                         con_function,
                                         'DW_FORECAST_AGGREGATION',
                                         var_email,
                                         'One or more errors occurred during the Forecast Aggregation execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**LOGGED ERROR**');

      /*-*/
      /* Set processing trace when required
      /*-*/
      else

         /*-*/
         /* Set the forecast aggregation trace for the current company and date
         /*-*/
         lics_processing.set_trace(var_process_code, var_process_date);

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
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Log error
         /*-*/
         if lics_logging.is_created = true then
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         end if;

         /*-*/
         /* Release the lock when required
         /*-*/
         if var_locked = true then
            lics_locking.release(var_loc_string);
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - DW_FORECAST_AGGREGATION - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /****************************************************************/
   /* This procedure performs the purchase order base load routine */
   /****************************************************************/
   procedure purch_base_load(par_company_code in varchar2, par_company_currcy in varchar2, par_date in date) is

      /*-*/
      /* Local variables
      /*-*/
      rcd_purch_base dw_purch_base%rowtype;
      var_purch_max_seqn number;
      var_purch_order_type_factor number;
      var_gsv_value number;
      type typ_work is table of dw_temp%rowtype index by binary_integer;
      tbl_work typ_work;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_pur_base is
         select nvl(max(t01.purch_order_trace_seqn),0) as max_trace_seqn
           from dw_purch_base t01
          where t01.company_code = par_company_code;
      rcd_pur_base csr_pur_base%rowtype;

      cursor csr_work is
         select t01.purch_order_doc_num as doc_num,
                t01.purch_order_doc_line_num as doc_line_num
           from sap_sto_po_trace t01
          where t01.company_code = par_company_code
            and t01.trace_date <= par_date
            and t01.trace_seqn > var_purch_max_seqn
            and t01.purch_order_type_code = 'ZNB';
      rcd_work csr_work%rowtype;

      cursor csr_trace is
         select t01.*,
                t02.atwrt as mat_bus_sgmnt_code
           from sap_sto_po_trace t01,
                sap_cla_chr t02
          where t01.trace_seqn in (select max(t01.trace_seqn)
                                     from sap_sto_po_trace t01
                                    where t01.company_code = par_company_code
                                      and t01.trace_date <= par_date
                                      and t01.trace_seqn > var_purch_max_seqn
                                      and t01.purch_order_type_code = 'ZNB'
                                    group by t01.purch_order_doc_num)
            and t01.trace_status = '*ACTIVE'
            and t01.matl_code = t02.objek(+)
            and t02.obtab(+) = 'MARA'
            and t02.klart(+) = '001'
            and t02.atnam(+) = 'CLFFERT01';
      rcd_trace csr_trace%rowtype;

      cursor csr_purch_order_type is
         select decode(t01.purch_order_type_sign,'-',-1,1) as purch_order_type_factor
           from purch_order_type t01
          where t01.purch_order_type_code = rcd_purch_base.purch_order_type_code;
      rcd_purch_order_type csr_purch_order_type%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - PURCH_BASE Load');

      /*-*/
      /* PURCH_BASE maximum trace
      /*-*/
      var_purch_max_seqn := 0;
      open csr_pur_base;
      fetch csr_pur_base into rcd_pur_base;
      if csr_pur_base%found then
         var_purch_max_seqn := rcd_pur_base.max_trace_seqn;
      end if;
      close csr_pur_base;

      /* Trace work list
      /*-*/
      tbl_work.delete;
      open csr_work;
      fetch csr_work bulk collect into tbl_work;
      close csr_work;
      delete from dw_temp;
      forall idx in 1..tbl_work.count
         insert into dw_temp values tbl_work(idx);

      /*-*/
      /* STEP #1
      /*
      /* Delete any existing purchase order base rows 
      /* **notes** 1. Delete all purchase orders that have changed within the window
      /*              regardless of their eligibility for inclusion in this process.
      /*           2. This may result in *DELETED trace records being reprocessed during
      /*              the next execution of this routine where the *DELETED trace records
      /*              have a trace sequence number greater than the last *ACTIVE trace
      /*              record. This is because this routine uses trace records that have a
      /*              trace sequence that is greater than the highest trace sequence on the
      /*              related fact table and only *ACTIVE trace records are transferred to the
      /*              fact table. These reprocessed *DELETED trace records will not actually
      /*              perform any database activity as the fact table rows will not exist.
      /*-*/
      lics_logging.write_log('--> Deleting changed purchase order base data');
      delete from dw_purch_base
       where company_code = par_company_code
         and purch_order_doc_num in (select distinct(doc_num) from dw_temp);

      /*-*/
      /* STEP #2
      /*
      /* Load the purchase order base rows from the ODS trace data
      /* **notes** 1. Select all purchase orders that have changed within the window
      /*           2. Only inter-company business purchase orders (ZNB) are selected
      /*           3. Only valid purchase orders are selected (TRACE_STATUS = *ACTIVE)
      /*-*/
      lics_logging.write_log('--> Loading new and changed purchase order base data');
      open csr_trace;
      loop
         fetch csr_trace into rcd_trace;
         if csr_trace%notfound then
            exit;
         end if;

         /*---------------------------*/
         /* PURCH_BASE Initialisation */
         /*---------------------------*/

         /*-*/
         /* Initialise the purchase order base row
         /*-*/
         rcd_purch_base.purch_order_doc_num := rcd_trace.purch_order_doc_num;
         rcd_purch_base.purch_order_doc_line_num := rcd_trace.purch_order_doc_line_num;
         rcd_purch_base.purch_order_line_status := '*OPEN';
         rcd_purch_base.purch_order_trace_seqn := rcd_trace.trace_seqn;
         rcd_purch_base.creatn_date := rcd_trace.creatn_date;
         rcd_purch_base.creatn_yyyyppdd := rcd_trace.creatn_yyyyppdd;
         rcd_purch_base.creatn_yyyyppw := rcd_trace.creatn_yyyyppw;
         rcd_purch_base.creatn_yyyypp := rcd_trace.creatn_yyyypp;
         rcd_purch_base.creatn_yyyymm := rcd_trace.creatn_yyyymm;
         rcd_purch_base.purch_order_eff_date := rcd_trace.purch_order_eff_date;
         rcd_purch_base.purch_order_eff_yyyyppdd := rcd_trace.purch_order_eff_yyyyppdd;
         rcd_purch_base.purch_order_eff_yyyyppw := rcd_trace.purch_order_eff_yyyyppw;
         rcd_purch_base.purch_order_eff_yyyypp := rcd_trace.purch_order_eff_yyyypp;
         rcd_purch_base.purch_order_eff_yyyymm := rcd_trace.purch_order_eff_yyyymm;
         rcd_purch_base.confirmed_date := rcd_trace.confirmed_date;
         rcd_purch_base.confirmed_yyyyppdd := rcd_trace.confirmed_yyyyppdd;
         rcd_purch_base.confirmed_yyyyppw := rcd_trace.confirmed_yyyyppw;
         rcd_purch_base.confirmed_yyyypp := rcd_trace.confirmed_yyyypp;
         rcd_purch_base.confirmed_yyyymm := rcd_trace.confirmed_yyyymm;
         rcd_purch_base.company_code := rcd_trace.company_code;
         rcd_purch_base.sales_org_code := rcd_trace.sales_org_code;
         rcd_purch_base.distbn_chnl_code := rcd_trace.distbn_chnl_code;
         rcd_purch_base.division_code := rcd_trace.division_code;
         rcd_purch_base.doc_currcy_code := rcd_trace.currcy_code;
         rcd_purch_base.company_currcy_code := par_company_currcy;
         rcd_purch_base.exch_rate := rcd_trace.exch_rate;
         rcd_purch_base.purchg_company_code := rcd_trace.purchg_company_code;
         rcd_purch_base.purch_order_type_code := rcd_trace.purch_order_type_code;
         rcd_purch_base.purch_order_reasn_code := rcd_trace.purch_order_reasn_code;
         rcd_purch_base.purch_order_usage_code := rcd_trace.purch_order_usage_code;
         rcd_purch_base.vendor_code := rcd_trace.vendor_code;
         rcd_purch_base.cust_code := rcd_trace.cust_code;
         rcd_purch_base.matl_code := dw_trim_code(rcd_trace.matl_code);
         rcd_purch_base.ods_matl_code := rcd_trace.matl_code;
         rcd_purch_base.plant_code := rcd_trace.plant_code;
         rcd_purch_base.storage_locn_code := rcd_trace.storage_locn_code;
         rcd_purch_base.purch_order_weight_unit := rcd_trace.purch_order_weight_unit;
         rcd_purch_base.purch_order_gross_weight := rcd_trace.purch_order_gross_weight;
         rcd_purch_base.purch_order_net_weight := rcd_trace.purch_order_net_weight;
         rcd_purch_base.purch_order_uom_code := rcd_trace.purch_order_uom_code;
         rcd_purch_base.purch_order_base_uom_code := null;
         rcd_purch_base.ord_qty := 0;
         rcd_purch_base.ord_qty_base_uom := 0;
         rcd_purch_base.ord_qty_gross_tonnes := 0;
         rcd_purch_base.ord_qty_net_tonnes := 0;
         rcd_purch_base.ord_gsv := 0;
         rcd_purch_base.ord_gsv_xactn := 0;
         rcd_purch_base.ord_gsv_aud := 0;
         rcd_purch_base.ord_gsv_usd := 0;
         rcd_purch_base.ord_gsv_eur := 0;
         rcd_purch_base.con_qty := 0;
         rcd_purch_base.con_qty_base_uom := 0;
         rcd_purch_base.con_qty_gross_tonnes := 0;
         rcd_purch_base.con_qty_net_tonnes := 0;
         rcd_purch_base.con_gsv := 0;
         rcd_purch_base.con_gsv_xactn := 0;
         rcd_purch_base.con_gsv_aud := 0;
         rcd_purch_base.con_gsv_usd := 0;
         rcd_purch_base.con_gsv_eur := 0;
         rcd_purch_base.del_qty := 0;
         rcd_purch_base.del_qty_base_uom := 0;
         rcd_purch_base.del_qty_gross_tonnes := 0;
         rcd_purch_base.del_qty_net_tonnes := 0;
         rcd_purch_base.del_gsv := 0;
         rcd_purch_base.del_gsv_xactn := 0;
         rcd_purch_base.del_gsv_aud := 0;
         rcd_purch_base.del_gsv_usd := 0;
         rcd_purch_base.del_gsv_eur := 0;
         rcd_purch_base.inv_qty := 0;
         rcd_purch_base.inv_qty_base_uom := 0;
         rcd_purch_base.inv_qty_gross_tonnes := 0;
         rcd_purch_base.inv_qty_net_tonnes := 0;
         rcd_purch_base.inv_gsv := 0;
         rcd_purch_base.inv_gsv_xactn := 0;
         rcd_purch_base.inv_gsv_aud := 0;
         rcd_purch_base.inv_gsv_usd := 0;
         rcd_purch_base.inv_gsv_eur := 0;
         rcd_purch_base.out_qty := 0;
         rcd_purch_base.out_qty_base_uom := 0;
         rcd_purch_base.out_qty_gross_tonnes := 0;
         rcd_purch_base.out_qty_net_tonnes := 0;
         rcd_purch_base.out_gsv := 0;
         rcd_purch_base.out_gsv_xactn := 0;
         rcd_purch_base.out_gsv_aud := 0;
         rcd_purch_base.out_gsv_usd := 0;
         rcd_purch_base.out_gsv_eur := 0;
         rcd_purch_base.mfanz_icb_flag := 'N';
         rcd_purch_base.demand_plng_grp_division_code := rcd_trace.division_code;
         if (rcd_purch_base.sales_org_code = '149' and
             rcd_purch_base.distbn_chnl_code = '10') then
            if rcd_trace.mat_bus_sgmnt_code = '01' then
               rcd_purch_base.demand_plng_grp_division_code := '55';
            elsif rcd_trace.mat_bus_sgmnt_code = '02' then
               rcd_purch_base.demand_plng_grp_division_code := '57';
            elsif rcd_trace.mat_bus_sgmnt_code = '05' then
               rcd_purch_base.demand_plng_grp_division_code := '56';
            end if;
         else
            if rcd_purch_base.demand_plng_grp_division_code = '57' then
               if rcd_trace.mat_bus_sgmnt_code = '02' then
                  rcd_purch_base.demand_plng_grp_division_code := '57';
               elsif rcd_trace.mat_bus_sgmnt_code = '05' then
                  rcd_purch_base.demand_plng_grp_division_code := '56';
               end if;
            end if;
         end if;

         /*-*/
         /* Retrieve the purchase order type factor
         /*
         /* **note**
         /* 1. The purchase order type factor defaults to 1 for unrecognised purchase type codes
         /*    and will therefore be loaded into the purchase base table as a positive
         /*-*/
         var_purch_order_type_factor := 1;
         open csr_purch_order_type;
         fetch csr_purch_order_type into rcd_purch_order_type;
         if csr_purch_order_type%found then
            var_purch_order_type_factor := rcd_purch_order_type.purch_order_type_factor;
         end if;
         close csr_purch_order_type;

         /*-*/
         /* Set the ICB flag
         /*
         /* **note**
         /* 1. The ICB flag is set to 'Y' only when the company code is not equal
         /*    to the purchasing company code
         /*-*/
         if rcd_purch_base.company_code != rcd_purch_base.purchg_company_code then
            rcd_purch_base.mfanz_icb_flag := 'Y';
         end if;

         /*-------------------------*/
         /* PURCH_BASE Calculations */
         /*-------------------------*/

         /*-*/
         /* Calculate the purchase order quantity values from the material GRD data
         /* **notes** 1. Recalculation from the material GRD data allows the base tables to be rebuilt from the ODS when GRD data errors are corrected.
         /*           2. Ensures consistency when reducing outstanding quantity and weight from delivery and invoice.
         /*           3. Is the only way to reduce the order quantity with the delivery quantity (different material or UOM).
         /*-*/
         rcd_purch_base.ord_qty := var_purch_order_type_factor * rcd_trace.purch_order_qty;
         dw_utility.pkg_qty_fact.ods_matl_code := rcd_purch_base.ods_matl_code;
         dw_utility.pkg_qty_fact.uom_code := rcd_purch_base.purch_order_uom_code;
         dw_utility.pkg_qty_fact.uom_qty := rcd_purch_base.ord_qty;
         dw_utility.calculate_quantity;
         rcd_purch_base.purch_order_base_uom_code := dw_utility.pkg_qty_fact.base_uom_code;
         rcd_purch_base.ord_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
         rcd_purch_base.ord_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
         rcd_purch_base.ord_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

         /*-*/
         /* Calculate the purchase order GSV values
         /*-*/
         rcd_purch_base.ord_gsv_xactn := round(var_purch_order_type_factor * nvl(rcd_trace.purch_order_gsv,0), 2);
         var_gsv_value := var_purch_order_type_factor * rcd_trace.purch_order_gsv;
         rcd_purch_base.ord_gsv := round(
                                      ods_app.currcy_conv(
                                         var_gsv_value,
                                         rcd_purch_base.doc_currcy_code,
                                         rcd_purch_base.company_currcy_code,
                                         rcd_purch_base.creatn_date,
                                         'USDX'), 2);
         rcd_purch_base.ord_gsv_aud := round(
                                          ods_app.currcy_conv(
                                             ods_app.currcy_conv(
                                               var_gsv_value,
                                                rcd_purch_base.doc_currcy_code,
                                                rcd_purch_base.company_currcy_code,
                                                rcd_purch_base.creatn_date,
                                                'USDX'),
                                             rcd_purch_base.company_currcy_code,
                                             'AUD',
                                             rcd_purch_base.creatn_date,
                                             'MPPR'), 2);
         rcd_purch_base.ord_gsv_usd := round(
                                          ods_app.currcy_conv(
                                             ods_app.currcy_conv(
                                                var_gsv_value,
                                                rcd_purch_base.doc_currcy_code,
                                                rcd_purch_base.company_currcy_code,
                                                rcd_purch_base.creatn_date,
                                                'USDX'),
                                             rcd_purch_base.company_currcy_code,
                                             'USD',
                                             rcd_purch_base.creatn_date,
                                             'MPPR'), 2);
         rcd_purch_base.ord_gsv_eur := round(
                                          ods_app.currcy_conv(
                                             ods_app.currcy_conv(
                                                var_gsv_value,
                                                rcd_purch_base.doc_currcy_code,
                                                rcd_purch_base.company_currcy_code,
                                                rcd_purch_base.creatn_date,
                                                'USDX'),
                                             rcd_purch_base.company_currcy_code,
                                             'EUR',
                                             rcd_purch_base.creatn_date,
                                             'MPPR'), 2);

         /*-*/
         /* Calculate the confirmed values when required
         /*-*/
         if not(rcd_purch_base.confirmed_date is null) then

            /*-*/
            /* Calculate the confirmed quantity values
            /*-*/
            rcd_purch_base.con_qty := var_purch_order_type_factor * rcd_trace.confirmed_qty;
            dw_utility.pkg_qty_fact.ods_matl_code := rcd_purch_base.ods_matl_code;
            dw_utility.pkg_qty_fact.uom_code := rcd_purch_base.purch_order_uom_code;
            dw_utility.pkg_qty_fact.uom_qty := rcd_purch_base.con_qty;
            dw_utility.calculate_quantity;
            rcd_purch_base.con_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
            rcd_purch_base.con_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
            rcd_purch_base.con_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

            /*-*/
            /* Calculate the confirmed GSV values
            /*-*/
            if rcd_purch_base.ord_qty = 0 then
               rcd_purch_base.con_gsv := rcd_purch_base.ord_gsv;
               rcd_purch_base.con_gsv_xactn := rcd_purch_base.ord_gsv_xactn;
               rcd_purch_base.con_gsv_aud := rcd_purch_base.ord_gsv_aud;
               rcd_purch_base.con_gsv_usd := rcd_purch_base.ord_gsv_usd;
               rcd_purch_base.con_gsv_eur := rcd_purch_base.ord_gsv_eur;
            else
               rcd_purch_base.con_gsv := round((rcd_purch_base.ord_gsv / rcd_purch_base.ord_qty) * rcd_purch_base.con_qty, 2);
               rcd_purch_base.con_gsv_xactn := round((rcd_purch_base.ord_gsv_xactn / rcd_purch_base.ord_qty) * rcd_purch_base.con_qty, 2);
               rcd_purch_base.con_gsv_aud := round((rcd_purch_base.ord_gsv_aud / rcd_purch_base.ord_qty) * rcd_purch_base.con_qty, 2);
               rcd_purch_base.con_gsv_usd := round((rcd_purch_base.ord_gsv_usd / rcd_purch_base.ord_qty) * rcd_purch_base.con_qty, 2);
               rcd_purch_base.con_gsv_eur := round((rcd_purch_base.ord_gsv_eur / rcd_purch_base.ord_qty) * rcd_purch_base.con_qty, 2);
            end if;

         end if;

         /*---------------------*/
         /* PURCH_BASE Creation */
         /*---------------------*/

         /*-*/
         /* Insert the purchase base row
         /*-*/
         insert into dw_purch_base values rcd_purch_base;

      end loop;
      close csr_trace;

      /*-*/
      /* STEP #3
      /*
      /* Update the open purchase base row data
      /*-*/
      lics_logging.write_log('--> Updating open purchase base data');
      dw_alignment.purch_base_status(par_company_code);

      /*-*/
      /* STEP #4
      /*
      /* Remove the delivery base rows for purchase orders deleted in this procedure
      /*-*/
      lics_logging.write_log('--> Removing delivery base data orphaned by deleted purchase orders');
      delete from dw_dlvry_base
       where company_code = par_company_code
         and (purch_order_doc_num, purch_order_doc_line_num) in (select doc_num, doc_line_num
                                                                   from dw_temp,
                                                                        dw_purch_base
                                                                  where doc_num = purch_order_doc_num(+)
                                                                    and doc_line_num = purch_order_doc_line_num(+)
                                                                    and purch_order_doc_num is null);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - PURCH_BASE Load');

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
         /* Log error
         /*-*/
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - PURCH_BASE Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - PURCH_BASE Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purch_base_load;

end dw_fcst_aggregation;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_fcst_aggregation for dw_app.dw_fcst_aggregation;
grant execute on dw_fcst_aggregation to public;
