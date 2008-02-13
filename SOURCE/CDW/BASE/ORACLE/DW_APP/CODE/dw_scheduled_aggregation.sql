/******************/
/* Package Header */
/******************/
create or replace package dw_scheduled_aggregation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_scheduled_aggregation
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Scheduled Aggregation

    This package contain the scheduled aggregation procedures. The package exposes one
    procedure EXECUTE that performs the aggregation based on the following parameters:

    1. PAR_COMPANY (company code) (MANDATORY)

       The company for which the aggregation is to be performed. 

    **notes**
    1. A web log is produced under the search value DW_SCHEDULED_AGGREGATION where all errors are logged.

    2. All errors will raise an exception to the calling application so that an alert can
       be raised.

    3. All base tables will attempt to be aggregated and and errors logged.

    4. This package shares the same lock string as the triggered aggregation package. This is required
       to prevent a deadly embrace as both packages call the same base status routines.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/08   Steve Gregan   Created
    2008/02   Steve Gregan   Added NZ market sales aggregation

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_company in varchar2);

end dw_scheduled_aggregation;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_scheduled_aggregation as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure purch_base_load;
   procedure order_base_load;
   procedure dlvry_base_load;
   procedure nzmkt_base_load;

   /*-*/
   /* Private definitions
   /*-*/
   pkg_company_code company.company_code%type;
   pkg_company_currcy company.company_currcy%type;
   pkg_date date;
   pkg_purch_max_seqn number;
   pkg_order_max_seqn number;
   pkg_dlvry_max_seqn number;
   pkg_nzmkt_max_seqn number;

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

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DW Scheduled Aggregation';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_company is
         select t01.*
           from company t01
          where t01.company_code = par_company;
      rcd_company csr_company%rowtype;

      cursor csr_pur_base is
         select nvl(max(t01.purch_order_trace_seqn),0) as max_trace_seqn
           from dw_purch_base t01
          where t01.company_code = par_company;
      rcd_pur_base csr_pur_base%rowtype;

      cursor csr_ord_base is
         select nvl(max(t01.order_trace_seqn),0) as max_trace_seqn
           from dw_order_base t01
          where t01.company_code = par_company;
      rcd_ord_base csr_ord_base%rowtype;

      cursor csr_del_base is
         select nvl(max(t01.dlvry_trace_seqn),0) as max_trace_seqn
           from dw_dlvry_base t01
          where t01.company_code = par_company;
      rcd_del_base csr_del_base%rowtype;

      cursor csr_nzm_base is
         select nvl(max(t01.purch_order_trace_seqn),0) as max_trace_seqn
           from dw_nzmkt_base t01
          where t01.company_code = par_company;
      rcd_nzm_base csr_nzm_base%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'DW - SCHEDULED_AGGREGATION';
      var_log_search := 'DW_SCHEDULED_AGGREGATION' || '_' || lics_stream_processor.callback_event;
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
      pkg_company_code := rcd_company.company_code;
      pkg_company_currcy := rcd_company.company_currcy;

      /*-*/
      /* Aggregation date is always based on the previous day (converted using the company timezone)
      /*-*/
      pkg_date := dw_to_timezone(trunc(sysdate),'Australia/NSW',rcd_company.company_timezone_code);

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Scheduled Aggregation - Parameters(' || par_company || ')');

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
         /* PURCH_BASE maximum trace
         /*-*/
         pkg_purch_max_seqn := 0;
         open csr_pur_base;
         fetch csr_pur_base into rcd_pur_base;
         if csr_pur_base%found then
            pkg_purch_max_seqn := rcd_pur_base.max_trace_seqn;
         end if;
         close csr_pur_base;

         /*-*/
         /* ORDER_BASE maximum trace
         /*-*/
         pkg_order_max_seqn := 0;
         open csr_ord_base;
         fetch csr_ord_base into rcd_ord_base;
         if csr_ord_base%found then
            pkg_order_max_seqn := rcd_ord_base.max_trace_seqn;
         end if;
         close csr_ord_base;

         /*-*/
         /* DLVRY_BASE maximum trace
         /*-*/
         pkg_dlvry_max_seqn := 0;
         open csr_del_base;
         fetch csr_del_base into rcd_del_base;
         if csr_del_base%found then
            pkg_dlvry_max_seqn := rcd_del_base.max_trace_seqn;
         end if;
         close csr_del_base;

         /*-*/
         /* NZMKT_BASE maximum trace
         /*-*/
         pkg_nzmkt_max_seqn := 0;
         open csr_nzm_base;
         fetch csr_nzm_base into rcd_nzm_base;
         if csr_nzm_base%found then
            pkg_nzmkt_max_seqn := rcd_nzm_base.max_trace_seqn;
         end if;
         close csr_nzm_base;

         /*-*/
         /* PURCH_BASE load
         /*-*/
     --    begin
     --       purch_base_load;
     --    exception
     --       when others then
     --          var_errors := true;
     --    end;

         /*-*/
         /* ORDER_BASE load
         /*-*/
     --    begin
     --       order_base_load;
     --    exception
     --       when others then
     --          var_errors := true;
     --    end;

         /*-*/
         /* DLVRY_BASE load
         /*-*/
     --    begin
     --       dlvry_base_load;
     --    exception
     --       when others then
     --          var_errors := true;
     --    end;

         /*-*/
         /* NZMKT_BASE load
         /*-*/
         begin
            nzmkt_base_load;
         exception
            when others then
               var_errors := true;
         end;

         /*-*/
         /* Release the lock on the aggregation
         /*-*/
         lics_locking.release(var_loc_string);

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Scheduled Aggregation');

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
                                         'DW_SCHEDULED_AGGREGATION',
                                         var_email,
                                         'One or more errors occurred during the Scheduled Aggregation execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;

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
         raise_application_error(-20000, 'FATAL ERROR - DW_SCHEDULED_AGGREGATION - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /****************************************************************/
   /* This procedure performs the purchase order base load routine */
   /****************************************************************/
   procedure purch_base_load is

      /*-*/
      /* Local variables
      /*-*/
      rcd_purch_base dw_purch_base%rowtype;
      var_purch_order_type_factor number;
      var_gsv_value number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_trace is
         select t01.*,
                t02.atwrt as mat_bus_sgmnt_code
           from sap_sto_po_trace t01,
                sap_cla_chr t02
          where t01.trace_seqn in (select max(t01.trace_seqn)
                                     from sap_sto_po_trace t01
                                    where t01.company_code = pkg_company_code
                                      and trunc(t01.trace_date) <= trunc(pkg_date)
                                      and t01.trace_seqn > pkg_purch_max_seqn
                                    group by t01.purch_order_doc_num)
            and t01.purch_order_type_code = 'ZNB'
            and t01.trace_status = '*ACTIVE'
            and t01.matl_code = t02.objek(+)
            and t02.obtab(+) = 'MARA'
            and t02.klart(+) = '001'
            and t02.atnam(+) = 'CLFFERT01'
          order by t01.purch_order_doc_num asc,
                   t01.purch_order_doc_line_num asc;
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
      /* STEP #1
      /*
      /* Delete any existing purchase order base rows 
      /* **notes** 1. Delete all purchase orders that have changed within the window
      /*              regardless of their eligibility for inclusion in this process
      /*-*/
      delete from dw_purch_base
       where (purch_order_doc_num) in (select distinct(t01.purch_order_doc_num)
                                         from sap_sto_po_trace t01
                                        where t01.company_code = pkg_company_code
                                          and trunc(t01.trace_date) <= trunc(pkg_date)
                                          and t01.trace_seqn > pkg_purch_max_seqn);

      /*-*/
      /* STEP #2
      /*
      /* Load the purchase order base rows from the ODS trace data
      /* **notes** 1. Select all purchase orders that have changed within the window
      /*           2. Only inter-company business purchase orders (ZNB) are selected
      /*           3. Only valid purchase orders are selected (TRACE_STATUS = *ACTIVE)
      /*-*/
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
         rcd_purch_base.purch_order_line_status := '*OUTSTANDING';
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
         rcd_purch_base.company_currcy_code := pkg_company_currcy;
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
         rcd_purch_base.req_qty := 0;
         rcd_purch_base.req_qty_base_uom := 0;
         rcd_purch_base.req_qty_gross_tonnes := 0;
         rcd_purch_base.req_qty_net_tonnes := 0;
         rcd_purch_base.req_gsv := 0;
         rcd_purch_base.req_gsv_xactn := 0;
         rcd_purch_base.req_gsv_aud := 0;
         rcd_purch_base.req_gsv_usd := 0;
         rcd_purch_base.req_gsv_eur := 0;
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
         if rcd_purch_base.demand_plng_grp_division_code = '57' then
            if rcd_trace.mat_bus_sgmnt_code = '05' then
               rcd_purch_base.demand_plng_grp_division_code := '56';
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
         rcd_purch_base.ord_gsv_xactn := round(var_purch_order_type_factor * rcd_trace.purch_order_gsv, 2);
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

         /*---------------------*/
         /* PURCH_BASE Creation */
         /*---------------------*/

         /*-*/
         /* Insert the purchase base row
         /*-*/
         insert into dw_purch_base values rcd_purch_base;

         /*-------------------*/
         /* PURCH_BASE Status */
         /*-------------------*/

         /*-*/
         /* Update the purchase base status
         /*-*/
         dw_utility.purch_base_status(rcd_purch_base.purch_order_doc_num, rcd_purch_base.purch_order_doc_line_num);

      end loop;
      close csr_trace;

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

   /*******************************************************/
   /* This procedure performs the order base load routine */
   /*******************************************************/
   procedure order_base_load is

      /*-*/
      /* Local variables
      /*-*/
      rcd_order_base dw_order_base%rowtype;
      var_order_type_gsv_flag order_type.order_type_gsv_flag%type;
      var_order_type_factor number;
      var_gsv_value number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_trace is
         select t01.*,
                t02.atwrt as mat_bus_sgmnt_code
           from sap_sal_ord_trace t01,
                sap_cla_chr t02
          where t01.trace_seqn in (select max(t01.trace_seqn)
                                     from sap_sal_ord_trace t01
                                    where t01.company_code = pkg_company_code
                                      and trunc(t01.trace_date) <= trunc(pkg_date)
                                      and t01.trace_seqn > pkg_order_max_seqn
                                    group by t01.order_doc_num)
            and t01.trace_status = '*ACTIVE'
            and t01.matl_code = t02.objek(+)
            and t02.obtab(+) = 'MARA'
            and t02.klart(+) = '001'
            and t02.atnam(+) = 'CLFFERT01'
          order by t01.order_doc_num asc,
                   t01.order_doc_line_num asc;
      rcd_trace csr_trace%rowtype;

      cursor csr_order_type is
         select decode(t01.order_type_sign,'-',-1,1) as order_type_factor,
                t01.order_type_gsv_flag
           from order_type t01
          where t01.order_type_code = rcd_order_base.order_type_code;
      rcd_order_type csr_order_type%rowtype;

      cursor csr_icb_flag is
         select 'Y' as icb_flag
           from table(lics_datastore.retrieve_value('CDW','ICB_FLAG',rcd_order_base.company_code)) t01
          where t01.dsv_value = rcd_order_base.ship_to_cust_code;
      rcd_icb_flag csr_icb_flag%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - ORDER_BASE Load');

      /*-*/
      /* STEP #1
      /*
      /* Delete any existing order base rows 
      /* **notes** 1. Delete all orders that have changed within the window.
      /*-*/
      delete from dw_order_base
       where (order_doc_num) in (select distinct(t01.order_doc_num)
                                   from sap_sal_ord_trace t01
                                  where t01.company_code = pkg_company_code
                                    and trunc(t01.trace_date) <= trunc(pkg_date)
                                    and t01.trace_seqn > pkg_order_max_seqn);

      /*-*/
      /* STEP #2
      /*
      /* Load the order base rows from the ODS trace data
      /* **notes** 1. Select all orders that have changed within the window
      /*           2. Only valid order lines are selected (TRACE_STATUS = *ACTIVE)
      /*-*/
      open csr_trace;
      loop
         fetch csr_trace into rcd_trace;
         if csr_trace%notfound then
            exit;
         end if;

         /*---------------------------*/
         /* ORDER_BASE Initialisation */
         /*---------------------------*/

         /*-*/
         /* Initialise the order base row
         /*-*/
         rcd_order_base.order_doc_num := rcd_trace.order_doc_num;
         rcd_order_base.order_doc_line_num := rcd_trace.order_doc_line_num;
         rcd_order_base.order_line_status := '*OUTSTANDING';
         rcd_order_base.order_trace_seqn := rcd_trace.trace_seqn;
         rcd_order_base.creatn_date := rcd_trace.creatn_date;
         rcd_order_base.creatn_yyyyppdd := rcd_trace.creatn_yyyyppdd;
         rcd_order_base.creatn_yyyyppw := rcd_trace.creatn_yyyyppw;
         rcd_order_base.creatn_yyyypp := rcd_trace.creatn_yyyypp;
         rcd_order_base.creatn_yyyymm := rcd_trace.creatn_yyyymm;
         rcd_order_base.order_eff_date := nvl(rcd_trace.confirmed_date, rcd_trace.order_eff_date);
         rcd_order_base.order_eff_yyyyppdd := nvl(rcd_trace.confirmed_yyyyppdd, rcd_trace.order_eff_yyyyppdd);
         rcd_order_base.order_eff_yyyyppw := nvl(rcd_trace.confirmed_yyyyppw, rcd_trace.order_eff_yyyyppw);
         rcd_order_base.order_eff_yyyypp := nvl(rcd_trace.confirmed_yyyypp, rcd_trace.order_eff_yyyypp);
         rcd_order_base.order_eff_yyyymm := nvl(rcd_trace.confirmed_yyyymm, rcd_trace.order_eff_yyyymm);
         rcd_order_base.confirmed_date := rcd_trace.confirmed_date;
         rcd_order_base.confirmed_yyyyppdd := rcd_trace.confirmed_yyyyppdd;
         rcd_order_base.confirmed_yyyyppw := rcd_trace.confirmed_yyyyppw;
         rcd_order_base.confirmed_yyyypp := rcd_trace.confirmed_yyyypp;
         rcd_order_base.confirmed_yyyymm := rcd_trace.confirmed_yyyymm;
         rcd_order_base.company_code := rcd_trace.company_code;
         rcd_order_base.cust_order_doc_num := rcd_trace.cust_order_doc_num;
         rcd_order_base.cust_order_doc_line_num := rcd_trace.cust_order_doc_line_num;
         rcd_order_base.cust_order_due_date := rcd_trace.cust_order_due_date;
         rcd_order_base.sales_org_code := rcd_trace.sales_org_code;
         rcd_order_base.distbn_chnl_code := rcd_trace.distbn_chnl_code;
         rcd_order_base.division_code := rcd_trace.division_code;
         rcd_order_base.doc_currcy_code := rcd_trace.currcy_code;
         rcd_order_base.company_currcy_code := pkg_company_currcy;
         rcd_order_base.exch_rate := rcd_trace.exch_rate;
         rcd_order_base.order_type_code := rcd_trace.order_type_code;
         rcd_order_base.order_reasn_code := rcd_trace.order_reasn_code;
         rcd_order_base.order_usage_code := rcd_trace.order_usage_code;
         rcd_order_base.sold_to_cust_code := nvl(rcd_trace.gen_sold_to_cust_code, rcd_trace.hdr_sold_to_cust_code);
         rcd_order_base.bill_to_cust_code := nvl(rcd_trace.gen_bill_to_cust_code, rcd_trace.hdr_bill_to_cust_code);
         rcd_order_base.payer_cust_code := nvl(rcd_trace.gen_payer_cust_code, rcd_trace.hdr_payer_cust_code);
         rcd_order_base.ship_to_cust_code := nvl(rcd_trace.gen_ship_to_cust_code, rcd_trace.hdr_ship_to_cust_code);
         rcd_order_base.matl_code := dw_trim_code(rcd_trace.matl_code);
         rcd_order_base.ods_matl_code := rcd_trace.matl_code;
         rcd_order_base.matl_entd := dw_trim_code(rcd_trace.matl_entd);
         rcd_order_base.plant_code := rcd_trace.plant_code;
         rcd_order_base.storage_locn_code := rcd_trace.storage_locn_code;
         rcd_order_base.order_line_rejectn_code := rcd_trace.order_line_rejectn_code;
         rcd_order_base.order_weight_unit := rcd_trace.order_weight_unit;
         rcd_order_base.order_gross_weight := rcd_trace.order_gross_weight;
         rcd_order_base.order_net_weight := rcd_trace.order_net_weight;
         rcd_order_base.order_uom_code := rcd_trace.order_uom_code;
         rcd_order_base.order_base_uom_code := null;
         rcd_order_base.ord_qty := 0;
         rcd_order_base.ord_qty_base_uom := 0;
         rcd_order_base.ord_qty_gross_tonnes := 0;
         rcd_order_base.ord_qty_net_tonnes := 0;
         rcd_order_base.ord_gsv := 0;
         rcd_order_base.ord_gsv_xactn := 0;
         rcd_order_base.ord_gsv_aud := 0;
         rcd_order_base.ord_gsv_usd := 0;
         rcd_order_base.ord_gsv_eur := 0;
         rcd_order_base.con_qty := 0;
         rcd_order_base.con_qty_base_uom := 0;
         rcd_order_base.con_qty_gross_tonnes := 0;
         rcd_order_base.con_qty_net_tonnes := 0;
         rcd_order_base.con_gsv := 0;
         rcd_order_base.con_gsv_xactn := 0;
         rcd_order_base.con_gsv_aud := 0;
         rcd_order_base.con_gsv_usd := 0;
         rcd_order_base.con_gsv_eur := 0;
         rcd_order_base.req_qty := 0;
         rcd_order_base.req_qty_base_uom := 0;
         rcd_order_base.req_qty_gross_tonnes := 0;
         rcd_order_base.req_qty_net_tonnes := 0;
         rcd_order_base.req_gsv := 0;
         rcd_order_base.req_gsv_xactn := 0;
         rcd_order_base.req_gsv_aud := 0;
         rcd_order_base.req_gsv_usd := 0;
         rcd_order_base.req_gsv_eur := 0;
         rcd_order_base.del_qty := 0;
         rcd_order_base.del_qty_base_uom := 0;
         rcd_order_base.del_qty_gross_tonnes := 0;
         rcd_order_base.del_qty_net_tonnes := 0;
         rcd_order_base.del_gsv := 0;
         rcd_order_base.del_gsv_xactn := 0;
         rcd_order_base.del_gsv_aud := 0;
         rcd_order_base.del_gsv_usd := 0;
         rcd_order_base.del_gsv_eur := 0;
         rcd_order_base.inv_qty := 0;
         rcd_order_base.inv_qty_base_uom := 0;
         rcd_order_base.inv_qty_gross_tonnes := 0;
         rcd_order_base.inv_qty_net_tonnes := 0;
         rcd_order_base.inv_gsv := 0;
         rcd_order_base.inv_gsv_xactn := 0;
         rcd_order_base.inv_gsv_aud := 0;
         rcd_order_base.inv_gsv_usd := 0;
         rcd_order_base.inv_gsv_eur := 0;
         rcd_order_base.out_qty := 0;
         rcd_order_base.out_qty_base_uom := 0;
         rcd_order_base.out_qty_gross_tonnes := 0;
         rcd_order_base.out_qty_net_tonnes := 0;
         rcd_order_base.out_gsv := 0;
         rcd_order_base.out_gsv_xactn := 0;
         rcd_order_base.out_gsv_aud := 0;
         rcd_order_base.out_gsv_usd := 0;
         rcd_order_base.out_gsv_eur := 0;
         rcd_order_base.mfanz_icb_flag := 'N';
         rcd_order_base.demand_plng_grp_division_code := rcd_trace.division_code;
         if rcd_order_base.demand_plng_grp_division_code = '57' then
            if rcd_trace.mat_bus_sgmnt_code = '05' then
               rcd_order_base.demand_plng_grp_division_code := '56';
            end if;
         end if;

--=============
-- QUESTIONS ==
--=============
-- 1. ORDER_TYPE_GSV_FLAG is used in order aggregation and only selects equal to GSV, whereas, ORDER_USAGE_GSV_FLAG is used in sales aggregation and selects
--    equal to NULL or GSV. Which method is correct?
--=============

         /*-*/
         /* Retrieve the order type factor
         /*
         /* **note**
         /* 1. The order type factor defaults to 1 for unrecognised type codes
         /*    and will therefore be loaded into the order base table as a positive
         /* 2. The order usage GSV flag defaults to 'GSV' for unrecognised order usage codes
         /*    and will therefore always be loaded into the order base table
         /*-*/
         var_order_type_factor := 1;
         var_order_type_gsv_flag := 'XXX';
         open csr_order_type;
         fetch csr_order_type into rcd_order_type;
         if csr_order_type%found then
            var_order_type_factor := rcd_order_type.order_type_factor;
            var_order_type_gsv_flag := rcd_order_type.order_type_gsv_flag;
         end if;
         close csr_order_type;

         /*-*/
         /* Retrieve the ICB flag
         /*
         /* **note**
         /* 1. The ICB flag is set to 'Y' only when the ship to customer
         /*    exists in the LICS data store with 'CDW' - 'ICB_FLAG' - company code
         /*-*/
         open csr_icb_flag;
         fetch csr_icb_flag into rcd_icb_flag;
         if csr_icb_flag%found then
            rcd_order_base.mfanz_icb_flag := 'Y';
         end if;
         close csr_icb_flag;

         /*-*/
         /* Only load the order base row when order type 'GSV'
         /*-*/
         if var_order_type_gsv_flag = 'GSV' then

            /*-------------------------*/
            /* ORDER_BASE Calculations */
            /*-------------------------*/

            /*-*/
            /* Calculate the order quantity values
            /* **notes** 1. Recalculation from the material GRD data allows the base tables to be rebuilt from the ODS when GRD data errors are corrected.
            /*           2. Ensures consistency when reducing outstanding quantity and weight from delivery and invoice.
            /*           3. Is the only way to reduce the order quantity with the delivery quantity (different material or UOM).
            /*-*/
            rcd_order_base.ord_qty := var_order_type_factor * rcd_trace.order_qty;
            dw_utility.pkg_qty_fact.ods_matl_code := rcd_order_base.ods_matl_code;
            dw_utility.pkg_qty_fact.uom_code := rcd_order_base.order_uom_code;
            dw_utility.pkg_qty_fact.uom_qty := rcd_order_base.ord_qty;
            dw_utility.calculate_quantity;
            rcd_order_base.order_base_uom_code := dw_utility.pkg_qty_fact.base_uom_code;
            rcd_order_base.ord_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
            rcd_order_base.ord_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
            rcd_order_base.ord_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

            /*-*/
            /* Calculate the order GSV values
            /*-*/
            rcd_order_base.ord_gsv_xactn := round(var_order_type_factor * rcd_trace.order_gsv, 2);
            var_gsv_value := (var_order_type_factor / ods_app.exch_rate_factor('ICB',
                                                                               rcd_order_base.doc_currcy_code,
                                                                               rcd_order_base.company_currcy_code,
                                                                               rcd_order_base.creatn_date))
                             * (rcd_trace.order_gsv * rcd_order_base.exch_rate);
            rcd_order_base.ord_gsv := round(var_gsv_value, 2);
            rcd_order_base.ord_gsv_aud := round(
                                             ods_app.currcy_conv(
                                                var_gsv_value,
                                                rcd_order_base.company_currcy_code,
                                                'AUD',
                                                rcd_order_base.creatn_date,
                                                'MPPR'), 2);
            rcd_order_base.ord_gsv_usd := round(
                                             ods_app.currcy_conv(
                                                var_gsv_value,
                                                rcd_order_base.company_currcy_code,
                                                'USD',
                                                rcd_order_base.creatn_date,
                                                'MPPR'), 2);
            rcd_order_base.ord_gsv_eur := round(
                                             ods_app.currcy_conv(
                                                var_gsv_value,
                                                rcd_order_base.company_currcy_code,
                                                'EUR',
                                                rcd_order_base.creatn_date,
                                                'MPPR'), 2);

            /*-*/
            /* Calculate the confirmed quantity values
            /*-*/
            rcd_order_base.con_qty := var_order_type_factor * rcd_trace.confirmed_qty;
            dw_utility.pkg_qty_fact.ods_matl_code := rcd_order_base.ods_matl_code;
            dw_utility.pkg_qty_fact.uom_code := rcd_order_base.order_uom_code;
            dw_utility.pkg_qty_fact.uom_qty := rcd_order_base.con_qty;
            dw_utility.calculate_quantity;
            rcd_order_base.con_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
            rcd_order_base.con_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
            rcd_order_base.con_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

            /*-*/
            /* Calculate the confirmed GSV values
            /*-*/
            if rcd_order_base.ord_qty = 0 then
               rcd_order_base.con_gsv := rcd_order_base.ord_gsv;
               rcd_order_base.con_gsv_xactn := rcd_order_base.ord_gsv_xactn;
               rcd_order_base.con_gsv_aud := rcd_order_base.ord_gsv_aud;
               rcd_order_base.con_gsv_usd := rcd_order_base.ord_gsv_usd;
               rcd_order_base.con_gsv_eur := rcd_order_base.ord_gsv_eur;
            else
               rcd_order_base.con_gsv := round((rcd_order_base.ord_gsv / rcd_order_base.ord_qty) * rcd_order_base.con_qty, 2);
               rcd_order_base.con_gsv_xactn := round((rcd_order_base.ord_gsv_xactn / rcd_order_base.ord_qty) * rcd_order_base.con_qty, 2);
               rcd_order_base.con_gsv_aud := round((rcd_order_base.ord_gsv_aud / rcd_order_base.ord_qty) * rcd_order_base.con_qty, 2);
               rcd_order_base.con_gsv_usd := round((rcd_order_base.ord_gsv_usd / rcd_order_base.ord_qty) * rcd_order_base.con_qty, 2);
               rcd_order_base.con_gsv_eur := round((rcd_order_base.ord_gsv_eur / rcd_order_base.ord_qty) * rcd_order_base.con_qty, 2);
            end if;

            /*---------------------*/
            /* ORDER_BASE Creation */
            /*---------------------*/

            /*-*/
            /* Insert the order base row
            /*-*/
            insert into dw_order_base values rcd_order_base;

            /*-------------------*/
            /* ORDER_BASE Status */
            /*-------------------*/

            /*-*/
            /* Update the order base status
            /*-*/
            dw_utility.order_base_status(rcd_order_base.order_doc_num, rcd_order_base.order_doc_line_num);

         end if;

      end loop;
      close csr_trace;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - ORDER_BASE Load');

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
            lics_logging.write_log('**ERROR** - ORDER_BASE Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - ORDER_BASE Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end order_base_load;

   /**********************************************************/
   /* This procedure performs the delivery base load routine */
   /**********************************************************/
   procedure dlvry_base_load is

      /*-*/
      /* Local variables
      /*-*/
      rcd_dlvry_base dw_dlvry_base%rowtype;
      var_dlvry_type_factor number;
      var_gsv_value number;
      var_process boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_trace is
         select t01.*,
                t02.atwrt as mat_bus_sgmnt_code
           from sap_del_trace t01,
                sap_cla_chr t02
          where (t01.trace_seqn in (select max(t01.trace_seqn)
                                      from sap_del_trace t01
                                     where t01.company_code = pkg_company_code
                                       and trunc(t01.trace_date) <= trunc(pkg_date)
                                       and t01.trace_seqn > pkg_dlvry_max_seqn
                                     group by t01.dlvry_doc_num) or
                 t01.trace_seqn in (select max(t01.trace_seqn)
                                      from sap_del_trace t01
                                     where t01.company_code = pkg_company_code
                                       and trunc(t01.trace_date) <= trunc(pkg_date)
                                       and (t01.order_doc_num) in (select distinct(t01.order_doc_num)
                                                                     from sap_sal_ord_trace t01
                                                                    where t01.company_code = pkg_company_code
                                                                      and trunc(t01.trace_date) <= trunc(pkg_date)
                                                                      and t01.trace_seqn > pkg_order_max_seqn)
                                     group by t01.dlvry_doc_num) or
                 t01.trace_seqn in (select max(t01.trace_seqn)
                                      from sap_del_trace t01
                                     where t01.company_code = pkg_company_code
                                       and trunc(t01.trace_date) <= trunc(pkg_date)
                                       and (t01.purch_order_doc_num) in (select distinct(t01.purch_order_doc_num)
                                                                           from sap_sto_po_trace t01
                                                                          where t01.company_code = pkg_company_code
                                                                            and trunc(t01.trace_date) <= trunc(pkg_date)
                                                                            and t01.trace_seqn > pkg_purch_max_seqn)
                                     group by t01.dlvry_doc_num))
            and t01.trace_status = '*ACTIVE'
            and t01.matl_code = t02.objek(+)
            and t02.obtab(+) = 'MARA'
            and t02.klart(+) = '001'
            and t02.atnam(+) = 'CLFFERT01'
          order by t01.dlvry_doc_num asc,
                   t01.dlvry_doc_line_num asc;
      rcd_trace csr_trace%rowtype;

      cursor csr_order_base is
         select t01.*,
                decode(t02.order_type_sign,'-',-1,1) as order_type_factor
           from dw_order_base t01,
                order_type t02
          where t01.order_type_code = t02.order_type_code(+)
            and t01.order_doc_num = rcd_trace.order_doc_line_num
            and t01.order_doc_line_num = rcd_trace.order_doc_line_num;
      rcd_order_base csr_order_base%rowtype;

      cursor csr_purch_base is
         select t01.*,
                decode(t02.purch_order_type_sign,'-',-1,1) as purch_order_type_factor
           from dw_purch_base t01,
                purch_order_type t02
          where t01.purch_order_type_code = t02.purch_order_type_code(+)
            and t01.purch_order_doc_num = rcd_trace.purch_order_doc_line_num
            and t01.purch_order_doc_line_num = rcd_trace.purch_order_doc_line_num;
      rcd_purch_base csr_purch_base%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - DLVRY_BASE Load');

      /*-*/
      /* STEP #1
      /*
      /* Delete any existing delivery base rows 
      /* **notes** 1. Delete all deliveries that have changed within the window.
      /*           2. Delete all deliveries that are related to sales orders changed
      /*              within the window as these may no longer be selected for aggregation
      /*              and therefore the delivery will need to be removed.
      /*           3. Delete all deliveries that are related to purchase orders changed
      /*              within the window as these may no longer be selected for aggregation
      /*              and therefore the delivery will need to be removed.
      /*-*/
      delete from dw_dlvry_base
       where (dlvry_doc_num) in (select distinct(t01.dlvry_doc_num)
                                   from sap_del_trace t01
                                  where t01.company_code = pkg_company_code
                                    and trunc(t01.trace_date) <= trunc(pkg_date)
                                    and t01.trace_seqn > pkg_dlvry_max_seqn)
          or (order_doc_num) in (select distinct(t01.order_doc_num)
                                   from sap_sal_ord_trace t01
                                  where t01.company_code = pkg_company_code
                                    and trunc(t01.trace_date) <= trunc(pkg_date)
                                    and t01.trace_seqn > pkg_order_max_seqn)
          or (purch_order_doc_num) in (select distinct(t01.purch_order_doc_num)
                                         from sap_sto_po_trace t01
                                        where t01.company_code = pkg_company_code
                                          and trunc(t01.trace_date) <= trunc(pkg_date)
                                          and t01.trace_seqn > pkg_purch_max_seqn);

      /*-*/
      /* STEP #2
      /*
      /* Load the delivery base rows from the ODS trace data
      /* **notes** 1. Select all deliveries that have changed within the window.
      /*           2. Select all deliveries that are related to sales orders changed within the window.
      /*           3. Select all deliveries that are related to purchase orders changed within the window.
      /*           4. Only valid deliveries are selected (TRACE_STATUS = *ACTIVE)
      /*-*/
      open csr_trace;
      loop
         fetch csr_trace into rcd_trace;
         if csr_trace%notfound then
            exit;
         end if;

         /*-*/
         /* Only process required delivery documents
         /*
         /* **notes**
         /* 1. Reset the process indicator
         /* 2. Retrieve the related ORDER_BASE row when required
         /* 3. Retrieve the related PURCH_BASE row when required
         /* 4. This will ensure the removal of any DLVRY_BASE rows that
         /*    pointed to deleted ORDER_BASE or PURCH_BASE rows
         /*-*/
         var_process := false;
         if not(rcd_trace.order_doc_num is null) then
            open csr_order_base;
            fetch csr_order_base into rcd_order_base;
            if csr_order_base%found then
               var_process := true;
               var_dlvry_type_factor := rcd_order_base.order_type_factor;
            end if;
            close csr_order_base;
         elsif not(rcd_trace.purch_order_doc_num is null) then
            open csr_purch_base;
            fetch csr_purch_base into rcd_purch_base;
            if csr_purch_base%found then
               var_process := true;
               var_dlvry_type_factor := rcd_purch_base.purch_order_type_factor;
            end if;
            close csr_purch_base;
         end if;
 
         /*-*/
         /* Process the ODS data when required
         /*-*/
         if var_process = true then

            /*---------------------------*/
            /* DLVRY_BASE Initialisation */
            /*---------------------------*/

            /*-*/
            /* Initialise the delivery base row
            /*-*/
            rcd_dlvry_base.dlvry_doc_num := rcd_trace.dlvry_doc_num;
            rcd_dlvry_base.dlvry_doc_line_num := rcd_trace.dlvry_doc_line_num;
            rcd_dlvry_base.dlvry_line_status := '*OUTSTANDING';
            rcd_dlvry_base.dlvry_trace_seqn := rcd_trace.trace_seqn;
            rcd_dlvry_base.creatn_date := rcd_trace.creatn_date;
            rcd_dlvry_base.creatn_yyyyppdd := rcd_trace.creatn_yyyyppdd;
            rcd_dlvry_base.creatn_yyyyppw := rcd_trace.creatn_yyyyppw;
            rcd_dlvry_base.creatn_yyyypp := rcd_trace.creatn_yyyypp;
            rcd_dlvry_base.creatn_yyyymm := rcd_trace.creatn_yyyymm;
            rcd_dlvry_base.dlvry_eff_date := rcd_trace.dlvry_eff_date;
            rcd_dlvry_base.dlvry_eff_yyyyppdd := rcd_trace.dlvry_eff_yyyyppdd;
            rcd_dlvry_base.dlvry_eff_yyyyppw := rcd_trace.dlvry_eff_yyyyppw;
            rcd_dlvry_base.dlvry_eff_yyyypp := rcd_trace.dlvry_eff_yyyypp;
            rcd_dlvry_base.dlvry_eff_yyyymm := rcd_trace.dlvry_eff_yyyymm;
            rcd_dlvry_base.goods_issue_date := rcd_trace.goods_issue_date;
            rcd_dlvry_base.goods_issue_yyyyppdd := rcd_trace.goods_issue_yyyyppdd;
            rcd_dlvry_base.goods_issue_yyyyppw := rcd_trace.goods_issue_yyyyppw;
            rcd_dlvry_base.goods_issue_yyyypp := rcd_trace.goods_issue_yyyypp;
            rcd_dlvry_base.goods_issue_yyyymm := rcd_trace.goods_issue_yyyymm;
            rcd_dlvry_base.order_doc_num := rcd_trace.order_doc_num;
            rcd_dlvry_base.order_doc_line_num := rcd_trace.order_doc_line_num;
            rcd_dlvry_base.purch_order_doc_num := rcd_trace.purch_order_doc_num;
            rcd_dlvry_base.purch_order_doc_line_num := rcd_trace.purch_order_doc_line_num;
            rcd_dlvry_base.company_code := rcd_trace.company_code;
            rcd_dlvry_base.sales_org_code := rcd_trace.sales_org_code;
            rcd_dlvry_base.distbn_chnl_code := rcd_trace.distbn_chnl_code;
            rcd_dlvry_base.division_code := null;
            rcd_dlvry_base.doc_currcy_code := null;
            rcd_dlvry_base.company_currcy_code := pkg_company_currcy;
            rcd_dlvry_base.exch_rate := null;
            rcd_dlvry_base.dlvry_type_code := rcd_trace.dlvry_type_code;
            rcd_dlvry_base.dlvry_procg_stage := rcd_trace.dlvry_procg_stage;
            rcd_dlvry_base.sold_to_cust_code := rcd_trace.sold_to_cust_code;
            rcd_dlvry_base.bill_to_cust_code := rcd_trace.bill_to_cust_code;
            rcd_dlvry_base.payer_cust_code := rcd_trace.payer_cust_code;
            rcd_dlvry_base.ship_to_cust_code := rcd_trace.ship_to_cust_code;
            rcd_dlvry_base.matl_code := dw_trim_code(rcd_trace.matl_code);
            rcd_dlvry_base.ods_matl_code := rcd_trace.matl_code;
            rcd_dlvry_base.matl_entd := dw_trim_code(rcd_trace.matl_entd);
            rcd_dlvry_base.plant_code := rcd_trace.plant_code;
            rcd_dlvry_base.storage_locn_code := rcd_trace.storage_locn_code;
            rcd_dlvry_base.dlvry_weight_unit := rcd_trace.dlvry_weight_unit;
            rcd_dlvry_base.dlvry_gross_weight := rcd_trace.dlvry_gross_weight;
            rcd_dlvry_base.dlvry_net_weight := rcd_trace.dlvry_net_weight;
            rcd_dlvry_base.dlvry_uom_code := rcd_trace.dlvry_uom_code;
            rcd_dlvry_base.dlvry_base_uom_code := rcd_trace.dlvry_base_uom_code;
            rcd_dlvry_base.req_qty := 0;
            rcd_dlvry_base.req_qty_base_uom := 0;
            rcd_dlvry_base.req_qty_gross_tonnes := 0;
            rcd_dlvry_base.req_qty_net_tonnes := 0;
            rcd_dlvry_base.req_gsv := 0;
            rcd_dlvry_base.req_gsv_xactn := 0;
            rcd_dlvry_base.req_gsv_aud := 0;
            rcd_dlvry_base.req_gsv_usd := 0;
            rcd_dlvry_base.req_gsv_eur := 0;
            rcd_dlvry_base.del_qty := 0;
            rcd_dlvry_base.del_qty_base_uom := 0;
            rcd_dlvry_base.del_qty_gross_tonnes := 0;
            rcd_dlvry_base.del_qty_net_tonnes := 0;
            rcd_dlvry_base.del_gsv := 0;
            rcd_dlvry_base.del_gsv_xactn := 0;
            rcd_dlvry_base.del_gsv_aud := 0;
            rcd_dlvry_base.del_gsv_usd := 0;
            rcd_dlvry_base.del_gsv_eur := 0;
            rcd_dlvry_base.inv_qty := 0;
            rcd_dlvry_base.inv_qty_base_uom := 0;
            rcd_dlvry_base.inv_qty_gross_tonnes := 0;
            rcd_dlvry_base.inv_qty_net_tonnes := 0;
            rcd_dlvry_base.inv_gsv := 0;
            rcd_dlvry_base.inv_gsv_xactn := 0;
            rcd_dlvry_base.inv_gsv_aud := 0;
            rcd_dlvry_base.inv_gsv_usd := 0;
            rcd_dlvry_base.inv_gsv_eur := 0;
            rcd_dlvry_base.out_qty := 0;
            rcd_dlvry_base.out_qty_base_uom := 0;
            rcd_dlvry_base.out_qty_gross_tonnes := 0;
            rcd_dlvry_base.out_qty_net_tonnes := 0;
            rcd_dlvry_base.out_gsv := 0;
            rcd_dlvry_base.out_gsv_xactn := 0;
            rcd_dlvry_base.out_gsv_aud := 0;
            rcd_dlvry_base.out_gsv_usd := 0;
            rcd_dlvry_base.out_gsv_eur := 0;
            rcd_dlvry_base.mfanz_icb_flag := null;
            rcd_dlvry_base.demand_plng_grp_division_code := null;

            /*-*/
            /* Set the related data ORDER_BASE or PURCH_BASE
            /*-*/
            if not(rcd_dlvry_base.order_doc_num is null) then
               rcd_dlvry_base.division_code := rcd_order_base.division_code;
               rcd_dlvry_base.doc_currcy_code := rcd_order_base.doc_currcy_code;
               rcd_dlvry_base.exch_rate := rcd_order_base.exch_rate;
               rcd_dlvry_base.mfanz_icb_flag := rcd_order_base.mfanz_icb_flag;
               rcd_dlvry_base.demand_plng_grp_division_code := rcd_order_base.demand_plng_grp_division_code;
            end if;
            if not(rcd_dlvry_base.purch_order_doc_num is null) then
               rcd_dlvry_base.division_code := rcd_purch_base.division_code;
               rcd_dlvry_base.doc_currcy_code := rcd_purch_base.doc_currcy_code;
               rcd_dlvry_base.exch_rate := rcd_purch_base.exch_rate;
               rcd_dlvry_base.mfanz_icb_flag := rcd_purch_base.mfanz_icb_flag;
               rcd_dlvry_base.demand_plng_grp_division_code := rcd_purch_base.demand_plng_grp_division_code;
            end if;

            /*-------------------------*/
            /* DLVRY_BASE Calculations */
            /*-------------------------*/

            /*-*/
            /* Calculate the requested quantity values
            /* **notes** 1. Recalculation from the material GRD data allows the base tables to be rebuilt from the ODS when GRD data errors are corrected.
            /*           2. Ensures consistency when reducing outstanding quantity and weight from invoice.
            /*-*/
            rcd_dlvry_base.req_qty := var_dlvry_type_factor * rcd_trace.allocated_qty;
            dw_utility.pkg_qty_fact.ods_matl_code := rcd_dlvry_base.ods_matl_code;
            dw_utility.pkg_qty_fact.uom_code := rcd_dlvry_base.dlvry_uom_code;
            dw_utility.pkg_qty_fact.uom_qty := rcd_dlvry_base.req_qty;
            dw_utility.calculate_quantity;
            rcd_dlvry_base.dlvry_base_uom_code := dw_utility.pkg_qty_fact.base_uom_code;
            rcd_dlvry_base.req_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
            rcd_dlvry_base.req_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
            rcd_dlvry_base.req_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

            /*-*/
            /* Calculate the requested GSV values
            /*-*/
            if not(rcd_dlvry_base.order_doc_num is null) then
               if rcd_order_base.ord_qty != 0 then
                  rcd_dlvry_base.req_gsv_xactn := round(var_dlvry_type_factor * ((rcd_order_base.ord_gsv_xactn / rcd_order_base.ord_qty) * rcd_trace.allocated_qty), 2);
                  rcd_dlvry_base.req_gsv := round(var_dlvry_type_factor * ((rcd_order_base.ord_gsv / rcd_order_base.ord_qty) * rcd_trace.allocated_qty), 2);
                  rcd_dlvry_base.req_gsv_aud := round(var_dlvry_type_factor * ((rcd_order_base.ord_gsv_aud / rcd_order_base.ord_qty) * rcd_trace.allocated_qty), 2);
                  rcd_dlvry_base.req_gsv_usd := round(var_dlvry_type_factor * ((rcd_order_base.ord_gsv_usd / rcd_order_base.ord_qty) * rcd_trace.allocated_qty), 2);
                  rcd_dlvry_base.req_gsv_eur := round(var_dlvry_type_factor * ((rcd_order_base.ord_gsv_eur / rcd_order_base.ord_qty) * rcd_trace.allocated_qty), 2);
               end if;
            end if;
            if not(rcd_dlvry_base.purch_order_doc_num is null) then
               if rcd_purch_base.ord_qty != 0 then
                  rcd_dlvry_base.req_gsv_xactn := round(var_dlvry_type_factor * ((rcd_purch_base.ord_gsv_xactn / rcd_purch_base.ord_qty) * rcd_trace.allocated_qty), 2);
                  rcd_dlvry_base.req_gsv := round(var_dlvry_type_factor * ((rcd_purch_base.ord_gsv / rcd_purch_base.ord_qty) * rcd_trace.allocated_qty), 2);
                  rcd_dlvry_base.req_gsv_aud := round(var_dlvry_type_factor * ((rcd_purch_base.ord_gsv_aud / rcd_purch_base.ord_qty) * rcd_trace.allocated_qty), 2);
                  rcd_dlvry_base.req_gsv_usd := round(var_dlvry_type_factor * ((rcd_purch_base.ord_gsv_usd / rcd_purch_base.ord_qty) * rcd_trace.allocated_qty), 2);
                  rcd_dlvry_base.req_gsv_eur := round(var_dlvry_type_factor * ((rcd_purch_base.ord_gsv_eur / rcd_purch_base.ord_qty) * rcd_trace.allocated_qty), 2);
               end if;
            end if;

            /*-*/
            /* Calculate the delivered quantity values
            /* **notes** 1. Recalculation from the material GRD data allows the base tables to be rebuilt from the ODS when GRD data errors are corrected.
            /*           2. Ensures consistency when reducing outstanding quantity and weight from  invoice.
            /*-*/
            rcd_dlvry_base.del_qty := var_dlvry_type_factor * rcd_trace.dlvry_qty;
            dw_utility.pkg_qty_fact.ods_matl_code := rcd_dlvry_base.ods_matl_code;
            dw_utility.pkg_qty_fact.uom_code := rcd_dlvry_base.dlvry_uom_code;
            dw_utility.pkg_qty_fact.uom_qty := rcd_dlvry_base.del_qty;
            dw_utility.calculate_quantity;
            rcd_dlvry_base.dlvry_base_uom_code := dw_utility.pkg_qty_fact.base_uom_code;
            rcd_dlvry_base.del_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
            rcd_dlvry_base.del_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
            rcd_dlvry_base.del_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

            /*-*/
            /* Calculate the delivered GSV values
            /*-*/
            if not(rcd_dlvry_base.order_doc_num is null) then
               if rcd_order_base.ord_qty != 0 then
                  rcd_dlvry_base.del_gsv_xactn := round(var_dlvry_type_factor * ((rcd_order_base.ord_gsv_xactn / rcd_order_base.ord_qty) * rcd_trace.dlvry_qty), 2);
                  rcd_dlvry_base.del_gsv := round(var_dlvry_type_factor * ((rcd_order_base.ord_gsv / rcd_order_base.ord_qty) * rcd_trace.dlvry_qty), 2);
                  rcd_dlvry_base.del_gsv_aud := round(var_dlvry_type_factor * ((rcd_order_base.ord_gsv_aud / rcd_order_base.ord_qty) * rcd_trace.dlvry_qty), 2);
                  rcd_dlvry_base.del_gsv_usd := round(var_dlvry_type_factor * ((rcd_order_base.ord_gsv_usd / rcd_order_base.ord_qty) * rcd_trace.dlvry_qty), 2);
                  rcd_dlvry_base.del_gsv_eur := round(var_dlvry_type_factor * ((rcd_order_base.ord_gsv_eur / rcd_order_base.ord_qty) * rcd_trace.dlvry_qty), 2);
               end if;
            end if;
            if not(rcd_dlvry_base.purch_order_doc_num is null) then
               if rcd_purch_base.ord_qty != 0 then
                  rcd_dlvry_base.del_gsv_xactn := round(var_dlvry_type_factor * ((rcd_purch_base.ord_gsv_xactn / rcd_purch_base.ord_qty) * rcd_trace.dlvry_qty), 2);
                  rcd_dlvry_base.del_gsv := round(var_dlvry_type_factor * ((rcd_purch_base.ord_gsv / rcd_purch_base.ord_qty) * rcd_trace.dlvry_qty), 2);
                  rcd_dlvry_base.del_gsv_aud := round(var_dlvry_type_factor * ((rcd_purch_base.ord_gsv_aud / rcd_purch_base.ord_qty) * rcd_trace.dlvry_qty), 2);
                  rcd_dlvry_base.del_gsv_usd := round(var_dlvry_type_factor * ((rcd_purch_base.ord_gsv_usd / rcd_purch_base.ord_qty) * rcd_trace.dlvry_qty), 2);
                  rcd_dlvry_base.del_gsv_eur := round(var_dlvry_type_factor * ((rcd_purch_base.ord_gsv_eur / rcd_purch_base.ord_qty) * rcd_trace.dlvry_qty), 2);
               end if;
            end if;

            /*---------------------*/
            /* DLVRY_BASE Creation */
            /*---------------------*/

            /*-*/
            /* Insert the delivery base row
            /*-*/
            insert into dw_dlvry_base values rcd_dlvry_base;

            /*-------------------*/
            /* DLVRY_BASE Status */
            /*-------------------*/

            /*-*/
            /* Update the delivery base status
            /*-*/
            dw_utility.dlvry_base_status(rcd_dlvry_base.dlvry_doc_num, rcd_dlvry_base.dlvry_doc_line_num);

            /*-------------------*/
            /* ORDER_BASE Status */
            /*-------------------*/

            /*-*/
            /* Update the order base status when required
            /* **notes**
            /* 1. A deadly embrace with triggered aggregation is avoided by both
            /*    triggered and scheduled aggregation using the same process isolation locking
            /*    string and sharing the same ICS stream code
            /*-*/
            if not(rcd_dlvry_base.order_doc_num is null) then
               dw_utility.order_base_status(rcd_dlvry_base.order_doc_num, rcd_dlvry_base.order_doc_line_num);
            end if;

            /*-------------------*/
            /* PURCH_BASE Status */
            /*-------------------*/

            /*-*/
            /* Update the purchase base status when required
            /* **notes**
            /* 1. A deadly embrace with triggered aggregation is avoided by both
            /*    triggered and scheduled aggregation using the same process isolation locking
            /*    string and sharing the same ICS stream code
            /*-*/
            if not(rcd_dlvry_base.purch_order_doc_num is null) then
               dw_utility.purch_base_status(rcd_dlvry_base.purch_order_doc_num, rcd_dlvry_base.purch_order_doc_line_num);
            end if;

         end if;

      end loop;
      close csr_trace;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - DLVRY_BASE Load');

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
            lics_logging.write_log('**ERROR** - DLVRY_BASE Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - DLVRY_BASE Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end dlvry_base_load;

   /***********************************************************/
   /* This procedure performs the NZ market base load routine */
   /***********************************************************/
   procedure nzmkt_base_load is

      /*-*/
      /* Local variables
      /*-*/
      rcd_nzmkt_base dw_nzmkt_base%rowtype;
      var_nzmkt_vendor_code varchar2(64);
      var_nzmkt_cust_code varchar2(64);
      var_nzmkt_matl_group varchar2(64);
      var_nzmkt_factor number;
      var_nzmkt_price number;
      var_gsv_value number;
      var_process boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_trace is
         select t01.*,
                t02.mtart as mat_type_code,
                t03.atwrt as mat_bus_sgmnt_code,
                t04.atwrt as mat_cnsmr_pack_frmt_code
           from sap_sto_po_trace t01,
                sap_mat_hdr t02,
                sap_cla_chr t03,
                sap_cla_chr t04
          where t01.trace_seqn in (select max(t01.trace_seqn)
                                     from sap_sto_po_trace t01
                                    where t01.company_code = pkg_company_code
                                      and trunc(t01.trace_date) <= trunc(pkg_date)
                                      and t01.trace_seqn > pkg_nzmkt_max_seqn
                                    group by t01.purch_order_doc_num)
            and t01.purch_order_type_code = 'ZUB'
            and t01.trace_status = '*ACTIVE'
            and t01.matl_code = t02.matnr(+)
            and t01.matl_code = t03.objek(+)
            and t03.obtab(+) = 'MARA'
            and t03.klart(+) = '001'
            and t03.atnam(+) = 'CLFFERT01'
            and t01.matl_code = t04.objek(+)
            and t04.obtab(+) = 'MARA'
            and t04.klart(+) = '001'
            and t04.atnam(+) = 'CLFFERT25'
          order by t01.purch_order_doc_num asc,
                   t01.purch_order_doc_line_num asc;
      rcd_trace csr_trace%rowtype;

      cursor csr_pricing is
         select t02.kbetr
           from sap_prc_lst_hdr t01,
                sap_prc_lst_det t02
          where t01.vakey = t02.vakey
            and t01.kschl = t02.kschl
            and t01.datab = t02.datab
            and t01.knumh = t02.knumh
            and t01.kschl = 'ZV01'
            and t01.kotabnr = '969'
            and t01.vakey = lpad(nvl('0000010882','0'),10,'0')||rpad(rcd_nzmkt_base.ods_matl_code,18,' ')||'0'
            and (t01.datab <= to_char(rcd_nzmkt_base.purch_order_eff_date,'yyyymmdd') and
                 t01.datbi >= to_char(rcd_nzmkt_base.purch_order_eff_date,'yyyymmdd'))
            and t02.detseq = 1
            and t02.loevm_ko is null;
      rcd_pricing csr_pricing%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - NZMKT_BASE Load');

      /*-*/
      /* Retrieve the NZ market vendor and customer codes
      /*-*/
      var_nzmkt_vendor_code := lics_setting_configuration.retrieve_setting('NVMKT_SALES', 'VENDOR_CODE');
      var_nzmkt_cust_code := lics_setting_configuration.retrieve_setting('NVMKT_SALES', 'CUSTOMER_CODE');

      /*-*/
      /* STEP #1
      /*
      /* Delete any existing NZ market transfer rows 
      /* **notes** 1. Delete all NZ market transfers that have changed within the window
      /*              regardless of their eligibility for inclusion in this process
      /*-*/
      delete from dw_nzmkt_base
       where (purch_order_doc_num) in (select distinct(t01.purch_order_doc_num)
                                         from sap_sto_po_trace t01
                                        where t01.company_code = pkg_company_code
                                          and trunc(t01.trace_date) <= trunc(pkg_date)
                                          and t01.trace_seqn > pkg_nzmkt_max_seqn);

      /*-*/
      /* STEP #2
      /*
      /* Load the NZ market transfer rows from the ODS trace data
      /* **notes** 1. Select all stock transfers that have changed within the window
      /*           2. Only stock transfers (ZUB) are selected
      /*           3. Only valid stock transfers are selected (TRACE_STATUS = *ACTIVE)
      /*-*/
      open csr_trace;
      loop
         fetch csr_trace into rcd_trace;
         if csr_trace%notfound then
            exit;
         end if;

         /* Only process required NZ market stock transfers
         /*
         /* **notes**
         /* 1. Reset the process indicator
         /* 2. Retrieve the required stock transfers to record as sales
         /*    (ie. where stock ownership has changed within the same company)
         /*-*/
         var_process := false;
         if (rcd_trace.source_plant_code = 'NZ01' and
             rcd_trace.plant_code = 'NZ11' and
             rcd_trace.mat_type_code = 'FERT' and
             rcd_trace.mat_bus_sgmnt_code = '05' and
             rcd_trace.mat_cnsmr_pack_frmt_code = '51') then
            var_nzmkt_matl_group := 'DOG_ROLL';
            var_nzmkt_factor := 1;
            var_process := true;
         end if;
         if (rcd_trace.source_plant_code = 'NZ11' and
             rcd_trace.plant_code = 'NZ01' and
             rcd_trace.mat_type_code = 'FERT' and
             rcd_trace.mat_bus_sgmnt_code = '05' and
             rcd_trace.mat_cnsmr_pack_frmt_code = '51') then
            var_nzmkt_matl_group := 'DOG_ROLL';
            var_nzmkt_factor := -1;
            var_process := true;
         end if;
         if (rcd_trace.source_plant_code in ('NZ01','NZ11') and
             rcd_trace.plant_code in ('NZ13','NZ14') and
             rcd_trace.mat_type_code = 'FERT' and
             rcd_trace.mat_bus_sgmnt_code = '05' and
             rcd_trace.mat_cnsmr_pack_frmt_code = '45') then
            var_nzmkt_matl_group := 'POUCH';
            var_nzmkt_factor := 1;
            var_process := true;
         end if;
         if (rcd_trace.source_plant_code in ('NZ13','NZ14') and
             rcd_trace.plant_code in ('NZ01','NZ11') and
             rcd_trace.mat_type_code = 'FERT' and
             rcd_trace.mat_bus_sgmnt_code = '05' and
             rcd_trace.mat_cnsmr_pack_frmt_code = '45') then
            var_nzmkt_matl_group := 'POUCH';
            var_nzmkt_factor := -1;
            var_process := true;
         end if;

         /*-*/
         /* Process the ODS data when required
         /*-*/
         if var_process = true then

            /*---------------------------*/
            /* NZMKT_BASE Initialisation */
            /*---------------------------*/

            /*-*/
            /* Initialise the NZ market base row
            /*-*/
            rcd_nzmkt_base.purch_order_doc_num := rcd_trace.purch_order_doc_num;
            rcd_nzmkt_base.purch_order_doc_line_num := rcd_trace.purch_order_doc_line_num;
            rcd_nzmkt_base.purch_order_trace_seqn := rcd_trace.trace_seqn;
            rcd_nzmkt_base.nzmkt_vendor_code := var_nzmkt_vendor_code;
            rcd_nzmkt_base.nzmkt_cust_code := var_nzmkt_cust_code;
            rcd_nzmkt_base.nzmkt_matl_group := var_nzmkt_matl_group;
            rcd_nzmkt_base.creatn_date := rcd_trace.creatn_date;
            rcd_nzmkt_base.creatn_yyyyppdd := rcd_trace.creatn_yyyyppdd;
            rcd_nzmkt_base.creatn_yyyyppw := rcd_trace.creatn_yyyyppw;
            rcd_nzmkt_base.creatn_yyyypp := rcd_trace.creatn_yyyypp;
            rcd_nzmkt_base.creatn_yyyymm := rcd_trace.creatn_yyyymm;
            rcd_nzmkt_base.purch_order_eff_date := rcd_trace.purch_order_eff_date;
            rcd_nzmkt_base.purch_order_eff_yyyyppdd := rcd_trace.purch_order_eff_yyyyppdd;
            rcd_nzmkt_base.purch_order_eff_yyyyppw := rcd_trace.purch_order_eff_yyyyppw;
            rcd_nzmkt_base.purch_order_eff_yyyypp := rcd_trace.purch_order_eff_yyyypp;
            rcd_nzmkt_base.purch_order_eff_yyyymm := rcd_trace.purch_order_eff_yyyymm;
            rcd_nzmkt_base.confirmed_date := rcd_trace.confirmed_date;
            rcd_nzmkt_base.confirmed_yyyyppdd := rcd_trace.confirmed_yyyyppdd;
            rcd_nzmkt_base.confirmed_yyyyppw := rcd_trace.confirmed_yyyyppw;
            rcd_nzmkt_base.confirmed_yyyypp := rcd_trace.confirmed_yyyypp;
            rcd_nzmkt_base.confirmed_yyyymm := rcd_trace.confirmed_yyyymm;
            rcd_nzmkt_base.company_code := rcd_trace.company_code;
            rcd_nzmkt_base.sales_org_code := rcd_trace.sales_org_code;
            rcd_nzmkt_base.distbn_chnl_code := rcd_trace.distbn_chnl_code;
            rcd_nzmkt_base.division_code := rcd_trace.division_code;
            rcd_nzmkt_base.doc_currcy_code := rcd_trace.currcy_code;
            rcd_nzmkt_base.company_currcy_code := pkg_company_currcy;
            rcd_nzmkt_base.exch_rate := rcd_trace.exch_rate;
            rcd_nzmkt_base.purchg_company_code := rcd_trace.purchg_company_code;
            rcd_nzmkt_base.purch_order_type_code := rcd_trace.purch_order_type_code;
            rcd_nzmkt_base.purch_order_reasn_code := rcd_trace.purch_order_reasn_code;
            rcd_nzmkt_base.purch_order_usage_code := rcd_trace.purch_order_usage_code;
            rcd_nzmkt_base.vendor_code := rcd_trace.vendor_code;
            rcd_nzmkt_base.cust_code := rcd_trace.cust_code;
            rcd_nzmkt_base.matl_code := dw_trim_code(rcd_trace.matl_code);
            rcd_nzmkt_base.ods_matl_code := rcd_trace.matl_code;
            rcd_nzmkt_base.plant_code := rcd_trace.plant_code;
            rcd_nzmkt_base.storage_locn_code := rcd_trace.storage_locn_code;
            rcd_nzmkt_base.purch_order_weight_unit := rcd_trace.purch_order_weight_unit;
            rcd_nzmkt_base.purch_order_gross_weight := rcd_trace.purch_order_gross_weight;
            rcd_nzmkt_base.purch_order_net_weight := rcd_trace.purch_order_net_weight;
            rcd_nzmkt_base.purch_order_uom_code := rcd_trace.purch_order_uom_code;
            rcd_nzmkt_base.purch_order_base_uom_code := null;
            rcd_nzmkt_base.ord_qty := 0;
            rcd_nzmkt_base.ord_qty_base_uom := 0;
            rcd_nzmkt_base.ord_qty_gross_tonnes := 0;
            rcd_nzmkt_base.ord_qty_net_tonnes := 0;
            rcd_nzmkt_base.ord_gsv := 0;
            rcd_nzmkt_base.ord_gsv_xactn := 0;
            rcd_nzmkt_base.ord_gsv_aud := 0;
            rcd_nzmkt_base.ord_gsv_usd := 0;
            rcd_nzmkt_base.ord_gsv_eur := 0;
            rcd_nzmkt_base.con_qty := 0;
            rcd_nzmkt_base.con_qty_base_uom := 0;
            rcd_nzmkt_base.con_qty_gross_tonnes := 0;
            rcd_nzmkt_base.con_qty_net_tonnes := 0;
            rcd_nzmkt_base.con_gsv := 0;
            rcd_nzmkt_base.con_gsv_xactn := 0;
            rcd_nzmkt_base.con_gsv_aud := 0;
            rcd_nzmkt_base.con_gsv_usd := 0;
            rcd_nzmkt_base.con_gsv_eur := 0;
            rcd_nzmkt_base.mfanz_icb_flag := 'N';
            rcd_nzmkt_base.demand_plng_grp_division_code := rcd_trace.division_code;
            if rcd_nzmkt_base.demand_plng_grp_division_code = '57' then
               if rcd_trace.mat_bus_sgmnt_code = '05' then
                  rcd_nzmkt_base.demand_plng_grp_division_code := '56';
               end if;
            end if;

            /*-*/
            /* Retrieve the NZ market stock transfer pricing data
            /*-*/
            var_nzmkt_price := 0;
            open csr_pricing;
            fetch csr_pricing into rcd_pricing;
            if csr_pricing%found then
               var_nzmkt_price := rcd_pricing.kbetr;
            end if;
            close csr_pricing;

            /*-------------------------*/
            /* NZMKT_BASE Calculations */
            /*-------------------------*/

            /*-*/
            /* Calculate the NZ market stock transfer quantity values from the material GRD data
            /* **notes** 1. Recalculation from the material GRD data allows the base tables to be rebuilt from the ODS when GRD data errors are corrected.
            /*           2. Ensures consistency when reducing outstanding quantity and weight from delivery and invoice.
            /*           3. Is the only way to reduce the order quantity with the delivery quantity (different material or UOM).
            /*-*/
            rcd_nzmkt_base.ord_qty := var_nzmkt_factor * rcd_trace.purch_order_qty;
            dw_utility.pkg_qty_fact.ods_matl_code := rcd_nzmkt_base.ods_matl_code;
            dw_utility.pkg_qty_fact.uom_code := rcd_nzmkt_base.purch_order_uom_code;
            dw_utility.pkg_qty_fact.uom_qty := rcd_nzmkt_base.ord_qty;
            dw_utility.calculate_quantity;
            rcd_nzmkt_base.purch_order_base_uom_code := dw_utility.pkg_qty_fact.base_uom_code;
            rcd_nzmkt_base.ord_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
            rcd_nzmkt_base.ord_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
            rcd_nzmkt_base.ord_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

            /*-*/
            /* Calculate the NZ market stock transfer GSV values
            /*-*/
            rcd_nzmkt_base.ord_gsv_xactn := round(var_nzmkt_factor * rcd_trace.purch_order_qty * var_nzmkt_price, 2);
            var_gsv_value := var_nzmkt_factor * rcd_trace.purch_order_qty * var_nzmkt_price;
            rcd_nzmkt_base.ord_gsv := round(
                                         ods_app.currcy_conv(
                                            var_gsv_value,
                                            rcd_nzmkt_base.doc_currcy_code,
                                            rcd_nzmkt_base.company_currcy_code,
                                            rcd_nzmkt_base.creatn_date,
                                            'USDX'), 2);
            rcd_nzmkt_base.ord_gsv_aud := round(
                                             ods_app.currcy_conv(
                                                ods_app.currcy_conv(
                                                   var_gsv_value,
                                                   rcd_nzmkt_base.doc_currcy_code,
                                                   rcd_nzmkt_base.company_currcy_code,
                                                   rcd_nzmkt_base.creatn_date,
                                                   'USDX'),
                                                rcd_nzmkt_base.company_currcy_code,
                                                'AUD',
                                                rcd_nzmkt_base.creatn_date,
                                                'MPPR'), 2);
            rcd_nzmkt_base.ord_gsv_usd := round(
                                             ods_app.currcy_conv(
                                                ods_app.currcy_conv(
                                                   var_gsv_value,
                                                   rcd_nzmkt_base.doc_currcy_code,
                                                   rcd_nzmkt_base.company_currcy_code,
                                                   rcd_nzmkt_base.creatn_date,
                                                   'USDX'),
                                                rcd_nzmkt_base.company_currcy_code,
                                                'USD',
                                                rcd_nzmkt_base.creatn_date,
                                                'MPPR'), 2);
            rcd_nzmkt_base.ord_gsv_eur := round(
                                             ods_app.currcy_conv(
                                                ods_app.currcy_conv(
                                                   var_gsv_value,
                                                   rcd_nzmkt_base.doc_currcy_code,
                                                   rcd_nzmkt_base.company_currcy_code,
                                                   rcd_nzmkt_base.creatn_date,
                                                   'USDX'),
                                                rcd_nzmkt_base.company_currcy_code,
                                                'EUR',
                                                rcd_nzmkt_base.creatn_date,
                                                'MPPR'), 2);

         /*-*/
         /* Calculate the confirmed quantity values
         /*-*/
         rcd_nzmkt_base.con_qty := var_nzmkt_factor * rcd_trace.confirmed_qty;
         dw_utility.pkg_qty_fact.ods_matl_code := rcd_nzmkt_base.ods_matl_code;
         dw_utility.pkg_qty_fact.uom_code := rcd_nzmkt_base.purch_order_uom_code;
         dw_utility.pkg_qty_fact.uom_qty := rcd_nzmkt_base.con_qty;
         dw_utility.calculate_quantity;
         rcd_nzmkt_base.con_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
         rcd_nzmkt_base.con_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
         rcd_nzmkt_base.con_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

         /*-*/
         /* Calculate the confirmed GSV values
         /*-*/
         if rcd_nzmkt_base.ord_qty = 0 then
            rcd_nzmkt_base.con_gsv := rcd_nzmkt_base.ord_gsv;
            rcd_nzmkt_base.con_gsv_xactn := rcd_nzmkt_base.ord_gsv_xactn;
            rcd_nzmkt_base.con_gsv_aud := rcd_nzmkt_base.ord_gsv_aud;
            rcd_nzmkt_base.con_gsv_usd := rcd_nzmkt_base.ord_gsv_usd;
            rcd_nzmkt_base.con_gsv_eur := rcd_nzmkt_base.ord_gsv_eur;
         else
            rcd_nzmkt_base.con_gsv := round((rcd_nzmkt_base.ord_gsv / rcd_nzmkt_base.ord_qty) * rcd_nzmkt_base.con_qty, 2);
            rcd_nzmkt_base.con_gsv_xactn := round((rcd_nzmkt_base.ord_gsv_xactn / rcd_nzmkt_base.ord_qty) * rcd_nzmkt_base.con_qty, 2);
            rcd_nzmkt_base.con_gsv_aud := round((rcd_nzmkt_base.ord_gsv_aud / rcd_nzmkt_base.ord_qty) * rcd_nzmkt_base.con_qty, 2);
            rcd_nzmkt_base.con_gsv_usd := round((rcd_nzmkt_base.ord_gsv_usd / rcd_nzmkt_base.ord_qty) * rcd_nzmkt_base.con_qty, 2);
            rcd_nzmkt_base.con_gsv_eur := round((rcd_nzmkt_base.ord_gsv_eur / rcd_nzmkt_base.ord_qty) * rcd_nzmkt_base.con_qty, 2);
         end if;

            /*---------------------*/
            /* NZMKT_BASE Creation */
            /*---------------------*/

            /*-*/
            /* Insert the NZ market base row
            /*-*/
            insert into dw_nzmkt_base values rcd_nzmkt_base;

         end if;

      end loop;
      close csr_trace;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - NZMKT_BASE Load');

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
            lics_logging.write_log('**ERROR** - NZMKT_BASE Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - NZMKT_BASE Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end nzmkt_base_load;

end dw_scheduled_aggregation;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_scheduled_aggregation for dw_app.dw_scheduled_aggregation;
grant execute on dw_scheduled_aggregation to public;
