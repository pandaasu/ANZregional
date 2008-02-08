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

    This package contain the aggregation procedures for sales orders and deliveries. The package exposes
    one procedure EXECUTE that performs the aggregation based on the following parameters:

    1. PAR_COMPANY (company code) (MANDATORY)

       The company for which the aggregation is to be performed. 

    **notes**
    1. A web log is produced under the search value DW_SCHEDULED_AGGREGATION where all errors are logged.

    2. All errors will raise an exception to the calling application so that an alert can
       be raised.

    3. All fact tables will attempt to be aggregated and and errors logged.

    4. This package shares the same lock string as the triggered aggregation package. This is required
       to prevent a deadly embrace as both packages call the same fact status routines.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/08   Steve Gregan   Created
    2008/02   Steve Gregan   Added stock sales aggregation

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
   procedure purch_order_fact_load;
   procedure stock_base_load;
   procedure order_fact_load;
   procedure dlvry_fact_load;

   /*-*/
   /* Private definitions
   /*-*/
   pkg_company_code company.company_code%type;
   pkg_company_currcy company.company_currcy%type;
   pkg_date date;
   pkg_pur_fact_max_seqn number;
   pkg_stk_fact_max_seqn number;
   pkg_ord_fact_max_seqn number;
   pkg_del_fact_max_seqn number;

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

      cursor csr_pur_fact is
         select nvl(max(t01.purch_order_trace_seqn),0) as max_trace_seqn
           from dw_purch_base t01
          where t01.company_code = par_company;
      rcd_pur_fact csr_pur_fact%rowtype;

      cursor csr_stk_fact is
         select nvl(max(t01.purch_order_trace_seqn),0) as max_trace_seqn
           from dw_stock_base t01
          where t01.company_code = par_company;
      rcd_stk_fact csr_stk_fact%rowtype;

      cursor csr_ord_fact is
         select nvl(max(t01.order_trace_seqn),0) as max_trace_seqn
           from dw_order_base t01
          where t01.company_code = par_company;
      rcd_ord_fact csr_ord_fact%rowtype;

      cursor csr_del_fact is
         select nvl(max(t01.dlvry_trace_seqn),0) as max_trace_seqn
           from dw_dlvry_base t01
          where t01.company_code = par_company;
      rcd_del_fact csr_del_fact%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'DW - SCHEDULED_AGGREGATION';
      var_log_search := lics_stream_processor.callback_event;
      var_loc_string := lics_stream_processor.callback_lock;
      var_alert := lics_stream_processor.callback_alert;
      var_email := lics_stream_processor.callback_email;
      var_errors := false;
      var_locked := false;
      if var_loc_string is null then
         raise_application_error(-20000, 'Stream code not returned - must be executed from the ICS Stream Processor');
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
      /* Aggregation date is always based on the previous day
      /*-*/
      pkg_date := trunc(sysdate-1);

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
         /* PURCH_ORDER_FACT maximum trace
         /*-*/
         pkg_pur_fact_max_seqn := 0;
         open csr_pur_fact;
         fetch csr_pur_fact into rcd_pur_fact;
         if csr_pur_fact%found then
            pkg_pur_fact_max_seqn := rcd_pur_fact.max_trace_seqn;
         end if;
         close csr_pur_fact;

         /*-*/
         /* STOCK_FACT maximum trace
         /*-*/
         pkg_stk_fact_max_seqn := 0;
         open csr_stk_fact;
         fetch csr_stk_fact into rcd_stk_fact;
         if csr_stk_fact%found then
            pkg_stk_fact_max_seqn := rcd_stk_fact.max_trace_seqn;
         end if;
         close csr_stk_fact;

         /*-*/
         /* ORDER_FACT maximum trace
         /*-*/
         pkg_ord_fact_max_seqn := 0;
         open csr_ord_fact;
         fetch csr_ord_fact into rcd_ord_fact;
         if csr_ord_fact%found then
            pkg_ord_fact_max_seqn := rcd_ord_fact.max_trace_seqn;
         end if;
         close csr_ord_fact;

         /*-*/
         /* DLVRY_FACT maximum trace
         /*-*/
         pkg_del_fact_max_seqn := 0;
         open csr_del_fact;
         fetch csr_del_fact into rcd_del_fact;
         if csr_del_fact%found then
            pkg_del_fact_max_seqn := rcd_del_fact.max_trace_seqn;
         end if;
         close csr_del_fact;

         /*-*/
         /* PURCH_BASE load
         /*-*/
     --    begin
     --       purch_order_fact_load;
     --    exception
     --       when others then
     --          var_errors := true;
     --    end;

         /*-*/
         /* STOCK_BASE load
         /*-*/
         begin
            stock_base_load;
         exception
            when others then
               var_errors := true;
         end;

         /*-*/
         /* ORDER_BASE load
         /*-*/
     --    begin
     --       order_fact_load;
     --    exception
     --       when others then
     --          var_errors := true;
     --    end;

         /*-*/
         /* DLVRY_BASE load
         /*-*/
     --    begin
     --       dlvry_fact_load;
     --    exception
     --       when others then
     --          var_errors := true;
     --    end;

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
   /* This procedure performs the purchase order fact load routine */
   /****************************************************************/
   procedure purch_order_fact_load is

      /*-*/
      /* Local variables
      /*-*/
      rcd_purch_order_fact dw_purch_base%rowtype;
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
                                      and t01.trace_seqn > pkg_pur_fact_max_seqn
                                    group by t01.purch_order_doc_num)
            and not(t01.purch_order_doc_line_num is null)
            and t01.purch_order_type_code = 'ZNB'
            and t01.trace_status = '*ACTIVE'
            and t01.matl_code = t02.objek(+)
            and t02.obtab = 'MARA'
            and t02.klart = '001'
            and t02.atnam = 'CLFFERT01'
          order by t01.purch_order_doc_num asc,
                   t01.purch_order_doc_line_num asc;
      rcd_trace csr_trace%rowtype;

      cursor csr_purch_order_type is
         select decode(t01.purch_order_type_sign,'-',-1,1) as purch_order_type_factor
           from purch_order_type t01
          where t01.purch_order_type_code = rcd_purch_order_fact.purch_order_type_code;
      rcd_purch_order_type csr_purch_order_type%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - PURCH_ORDER_FACT Load');

      /*-*/
      /* STEP #1
      /*
      /* Delete any existing purchase order fact rows 
      /* **notes** 1. Delete all purchase orders that have changed within the window
      /*              regardless of their eligibility for inclusion in this process
      /*-*/
      delete from dw_purch_base
       where (purch_order_doc_num) in (select distinct(t01.purch_order_doc_num)
                                         from sap_sto_po_trace t01
                                        where t01.company_code = pkg_company_code
                                          and trunc(t01.trace_date) <= trunc(pkg_date)
                                          and t01.trace_seqn > pkg_pur_fact_max_seqn);

      /*-*/
      /* STEP #2
      /*
      /* Load the purchase order fact rows from the ODS trace data
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

         /*---------------------------------*/
         /* PURCH_ORDER_FACT Initialisation */
         /*---------------------------------*/

         /*-*/
         /* Initialise the purchase order fact row
         /*-*/
         rcd_purch_order_fact.purch_order_doc_num := rcd_trace.purch_order_doc_num;
         rcd_purch_order_fact.purch_order_doc_line_num := rcd_trace.purch_order_doc_line_num;
         rcd_purch_order_fact.purch_order_line_status := '*OUTSTANDING';
         rcd_purch_order_fact.purch_order_trace_seqn := rcd_trace.trace_seqn;
         rcd_purch_order_fact.creatn_date := rcd_trace.creatn_date;
         rcd_purch_order_fact.creatn_yyyyppdd := rcd_trace.creatn_yyyyppdd;
         rcd_purch_order_fact.creatn_yyyyppw := rcd_trace.creatn_yyyyppw;
         rcd_purch_order_fact.creatn_yyyypp := rcd_trace.creatn_yyyypp;
         rcd_purch_order_fact.creatn_yyyymm := rcd_trace.creatn_yyyymm;
         rcd_purch_order_fact.purch_order_eff_date := rcd_trace.purch_order_eff_date;
         rcd_purch_order_fact.purch_order_eff_yyyyppdd := rcd_trace.purch_order_eff_yyyyppdd;
         rcd_purch_order_fact.purch_order_eff_yyyyppw := rcd_trace.purch_order_eff_yyyyppw;
         rcd_purch_order_fact.purch_order_eff_yyyypp := rcd_trace.purch_order_eff_yyyypp;
         rcd_purch_order_fact.purch_order_eff_yyyymm := rcd_trace.purch_order_eff_yyyymm;
         rcd_purch_order_fact.confirmed_date := rcd_trace.confirmed_date;
         rcd_purch_order_fact.confirmed_yyyyppdd := rcd_trace.confirmed_yyyyppdd;
         rcd_purch_order_fact.confirmed_yyyyppw := rcd_trace.confirmed_yyyyppw;
         rcd_purch_order_fact.confirmed_yyyypp := rcd_trace.confirmed_yyyypp;
         rcd_purch_order_fact.confirmed_yyyymm := rcd_trace.confirmed_yyyymm;
         rcd_purch_order_fact.company_code := rcd_trace.company_code;
         rcd_purch_order_fact.sales_org_code := rcd_trace.sales_org_code;
         rcd_purch_order_fact.distbn_chnl_code := rcd_trace.distbn_chnl_code;
         rcd_purch_order_fact.division_code := rcd_trace.division_code;
         rcd_purch_order_fact.doc_currcy_code := rcd_trace.currcy_code;
         rcd_purch_order_fact.company_currcy_code := pkg_company_currcy;
         rcd_purch_order_fact.exch_rate := rcd_trace.exch_rate;
         rcd_purch_order_fact.purchg_company_code := rcd_trace.purchg_company_code;
         rcd_purch_order_fact.purch_order_type_code := rcd_trace.purch_order_type_code;
         rcd_purch_order_fact.purch_order_reasn_code := rcd_trace.purch_order_reasn_code;
         rcd_purch_order_fact.purch_order_usage_code := rcd_trace.purch_order_usage_code;
         rcd_purch_order_fact.vendor_code := rcd_trace.vendor_code;
         rcd_purch_order_fact.cust_code := rcd_trace.cust_code;
         rcd_purch_order_fact.matl_code := dw_trim_code(rcd_trace.matl_code);
         rcd_purch_order_fact.ods_matl_code := rcd_trace.matl_code;
         rcd_purch_order_fact.plant_code := rcd_trace.plant_code;
         rcd_purch_order_fact.storage_locn_code := rcd_trace.storage_locn_code;
         rcd_purch_order_fact.purch_order_weight_unit := rcd_trace.purch_order_weight_unit;
         rcd_purch_order_fact.purch_order_gross_weight := rcd_trace.purch_order_gross_weight;
         rcd_purch_order_fact.purch_order_net_weight := rcd_trace.purch_order_net_weight;
         rcd_purch_order_fact.purch_order_uom_code := rcd_trace.purch_order_uom_code;
         rcd_purch_order_fact.purch_order_base_uom_code := null;
         rcd_purch_order_fact.ord_qty := 0;
         rcd_purch_order_fact.ord_qty_base_uom := 0;
         rcd_purch_order_fact.ord_qty_gross_tonnes := 0;
         rcd_purch_order_fact.ord_qty_net_tonnes := 0;
         rcd_purch_order_fact.ord_gsv := 0;
         rcd_purch_order_fact.ord_gsv_xactn := 0;
         rcd_purch_order_fact.ord_gsv_aud := 0;
         rcd_purch_order_fact.ord_gsv_usd := 0;
         rcd_purch_order_fact.ord_gsv_eur := 0;
         rcd_purch_order_fact.con_qty := 0;
         rcd_purch_order_fact.con_qty_base_uom := 0;
         rcd_purch_order_fact.con_qty_gross_tonnes := 0;
         rcd_purch_order_fact.con_qty_net_tonnes := 0;
         rcd_purch_order_fact.con_gsv := 0;
         rcd_purch_order_fact.con_gsv_xactn := 0;
         rcd_purch_order_fact.con_gsv_aud := 0;
         rcd_purch_order_fact.con_gsv_usd := 0;
         rcd_purch_order_fact.con_gsv_eur := 0;
         rcd_purch_order_fact.req_qty := 0;
         rcd_purch_order_fact.req_qty_base_uom := 0;
         rcd_purch_order_fact.req_qty_gross_tonnes := 0;
         rcd_purch_order_fact.req_qty_net_tonnes := 0;
         rcd_purch_order_fact.req_gsv := 0;
         rcd_purch_order_fact.req_gsv_xactn := 0;
         rcd_purch_order_fact.req_gsv_aud := 0;
         rcd_purch_order_fact.req_gsv_usd := 0;
         rcd_purch_order_fact.req_gsv_eur := 0;
         rcd_purch_order_fact.del_qty := 0;
         rcd_purch_order_fact.del_qty_base_uom := 0;
         rcd_purch_order_fact.del_qty_gross_tonnes := 0;
         rcd_purch_order_fact.del_qty_net_tonnes := 0;
         rcd_purch_order_fact.del_gsv := 0;
         rcd_purch_order_fact.del_gsv_xactn := 0;
         rcd_purch_order_fact.del_gsv_aud := 0;
         rcd_purch_order_fact.del_gsv_usd := 0;
         rcd_purch_order_fact.del_gsv_eur := 0;
         rcd_purch_order_fact.inv_qty := 0;
         rcd_purch_order_fact.inv_qty_base_uom := 0;
         rcd_purch_order_fact.inv_qty_gross_tonnes := 0;
         rcd_purch_order_fact.inv_qty_net_tonnes := 0;
         rcd_purch_order_fact.inv_gsv := 0;
         rcd_purch_order_fact.inv_gsv_xactn := 0;
         rcd_purch_order_fact.inv_gsv_aud := 0;
         rcd_purch_order_fact.inv_gsv_usd := 0;
         rcd_purch_order_fact.inv_gsv_eur := 0;
         rcd_purch_order_fact.out_qty := 0;
         rcd_purch_order_fact.out_qty_base_uom := 0;
         rcd_purch_order_fact.out_qty_gross_tonnes := 0;
         rcd_purch_order_fact.out_qty_net_tonnes := 0;
         rcd_purch_order_fact.out_gsv := 0;
         rcd_purch_order_fact.out_gsv_xactn := 0;
         rcd_purch_order_fact.out_gsv_aud := 0;
         rcd_purch_order_fact.out_gsv_usd := 0;
         rcd_purch_order_fact.out_gsv_eur := 0;
         rcd_purch_order_fact.mfanz_icb_flag := 'N';
         rcd_purch_order_fact.demand_plng_grp_division_code := rcd_trace.division_code;
         if rcd_purch_order_fact.demand_plng_grp_division_code = '57' then
            if rcd_trace.mat_bus_sgmnt_code = '05' then
               rcd_purch_order_fact.demand_plng_grp_division_code := '56';
            end if;
         end if;

         /*-*/
         /* Retrieve the purchase order type factor
         /*
         /* **note**
         /* 1. The purchase order type factor defaults to 1 for unrecognised purchase type codes
         /*    and will therefore be loaded into the purchase fact table as a positive
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
         if rcd_purch_order_fact.company_code != rcd_purch_order_fact.purchg_company_code then
            rcd_purch_order_fact.mfanz_icb_flag := 'Y';
         end if;

         /*-------------------------------*/
         /* PURCH_ORDER_FACT Calculations */
         /*-------------------------------*/

         /*-*/
         /* Calculate the purchase order quantity values from the material GRD data
         /* **notes** 1. Recalculation from the material GRD data allows the fact tables to be rebuilt from the ODS when GRD data errors are corrected.
         /*           2. Ensures consistency when reducing outstanding quantity and weight from delivery and invoice.
         /*           3. Is the only way to reduce the order quantity with the delivery quantity (different material or UOM).
         /*-*/
         rcd_purch_order_fact.ord_qty := var_purch_order_type_factor * rcd_trace.purch_order_qty;
         dw_utility.pkg_qty_fact.ods_matl_code := rcd_purch_order_fact.ods_matl_code;
         dw_utility.pkg_qty_fact.uom_code := rcd_purch_order_fact.purch_order_uom_code;
         dw_utility.pkg_qty_fact.uom_qty := rcd_purch_order_fact.ord_qty;
         dw_utility.calculate_quantity;
         rcd_purch_order_fact.purch_order_base_uom_code := dw_utility.pkg_qty_fact.base_uom_code;
         rcd_purch_order_fact.ord_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
         rcd_purch_order_fact.ord_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
         rcd_purch_order_fact.ord_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

         /*-*/
         /* Calculate the purchase order GSV values
         /*-*/
         rcd_purch_order_fact.ord_gsv_xactn := round(var_purch_order_type_factor * rcd_trace.purch_order_gsv, 2);
         var_gsv_value := var_purch_order_type_factor * rcd_trace.purch_order_gsv;
         rcd_purch_order_fact.ord_gsv := round(
                                            ods_app.currcy_conv(
                                               var_gsv_value,
                                               rcd_purch_order_fact.doc_currcy_code,
                                               rcd_purch_order_fact.company_currcy_code,
                                               rcd_purch_order_fact.creatn_date,
                                               'USDX'), 2);
         rcd_purch_order_fact.ord_gsv_aud := round(
                                                ods_app.currcy_conv(
                                                   ods_app.currcy_conv(
                                                      var_gsv_value,
                                                      rcd_purch_order_fact.doc_currcy_code,
                                                      rcd_purch_order_fact.company_currcy_code,
                                                      rcd_purch_order_fact.creatn_date,
                                                      'USDX'),
                                                   rcd_purch_order_fact.company_currcy_code,
                                                   'AUD',
                                                   rcd_purch_order_fact.creatn_date,
                                                   'MPPR'), 2);
         rcd_purch_order_fact.ord_gsv_usd := round(
                                                ods_app.currcy_conv(
                                                   ods_app.currcy_conv(
                                                      var_gsv_value,
                                                      rcd_purch_order_fact.doc_currcy_code,
                                                      rcd_purch_order_fact.company_currcy_code,
                                                      rcd_purch_order_fact.creatn_date,
                                                      'USDX'),
                                                   rcd_purch_order_fact.company_currcy_code,
                                                   'USD',
                                                   rcd_purch_order_fact.creatn_date,
                                                   'MPPR'), 2);
         rcd_purch_order_fact.ord_gsv_eur := round(
                                                ods_app.currcy_conv(
                                                   ods_app.currcy_conv(
                                                      var_gsv_value,
                                                      rcd_purch_order_fact.doc_currcy_code,
                                                      rcd_purch_order_fact.company_currcy_code,
                                                      rcd_purch_order_fact.creatn_date,
                                                      'USDX'),
                                                   rcd_purch_order_fact.company_currcy_code,
                                                   'EUR',
                                                   rcd_purch_order_fact.creatn_date,
                                                   'MPPR'), 2);

         /*-*/
         /* Calculate the confirmed quantity values
         /*-*/
         rcd_purch_order_fact.con_qty := var_purch_order_type_factor * rcd_trace.confirmed_qty;
         dw_utility.pkg_qty_fact.ods_matl_code := rcd_purch_order_fact.ods_matl_code;
         dw_utility.pkg_qty_fact.uom_code := rcd_purch_order_fact.purch_order_uom_code;
         dw_utility.pkg_qty_fact.uom_qty := rcd_purch_order_fact.con_qty;
         dw_utility.calculate_quantity;
         rcd_purch_order_fact.con_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
         rcd_purch_order_fact.con_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
         rcd_purch_order_fact.con_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

         /*-*/
         /* Calculate the confirmed GSV values
         /*-*/
         if rcd_purch_order_fact.ord_qty = 0 then
            rcd_purch_order_fact.con_gsv := rcd_purch_order_fact.ord_gsv;
            rcd_purch_order_fact.con_gsv_xactn := rcd_purch_order_fact.ord_gsv_xactn;
            rcd_purch_order_fact.con_gsv_aud := rcd_purch_order_fact.ord_gsv_aud;
            rcd_purch_order_fact.con_gsv_usd := rcd_purch_order_fact.ord_gsv_usd;
            rcd_purch_order_fact.con_gsv_eur := rcd_purch_order_fact.ord_gsv_eur;
         else
            rcd_purch_order_fact.con_gsv := round((rcd_purch_order_fact.ord_gsv / rcd_purch_order_fact.ord_qty) * rcd_purch_order_fact.con_qty, 2);
            rcd_purch_order_fact.con_gsv_xactn := round((rcd_purch_order_fact.ord_gsv_xactn / rcd_purch_order_fact.ord_qty) * rcd_purch_order_fact.con_qty, 2);
            rcd_purch_order_fact.con_gsv_aud := round((rcd_purch_order_fact.ord_gsv_aud / rcd_purch_order_fact.ord_qty) * rcd_purch_order_fact.con_qty, 2);
            rcd_purch_order_fact.con_gsv_usd := round((rcd_purch_order_fact.ord_gsv_usd / rcd_purch_order_fact.ord_qty) * rcd_purch_order_fact.con_qty, 2);
            rcd_purch_order_fact.con_gsv_eur := round((rcd_purch_order_fact.ord_gsv_eur / rcd_purch_order_fact.ord_qty) * rcd_purch_order_fact.con_qty, 2);
         end if;

         /*---------------------------*/
         /* PURCH_ORDER_FACT Creation */
         /*---------------------------*/

         /*-*/
         /* Insert the purchase order fact row
         /*-*/
         insert into dw_purch_base values rcd_purch_order_fact;

         /*-------------------------*/
         /* PURCH_ORDER_FACT Status */
         /*-------------------------*/

         /*-*/
         /* Update the purchase order fact status
         /*-*/
         dw_utility.purch_order_fact_status(rcd_purch_order_fact.purch_order_doc_num, rcd_purch_order_fact.purch_order_doc_line_num);

      end loop;
      close csr_trace;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - PURCH_ORDER_FACT Load');

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
            lics_logging.write_log('**ERROR** - PURCH_ORDER_FACT Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - PURCH_ORDER_FACT Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purch_order_fact_load;

   /*******************************************************/
   /* This procedure performs the stock base load routine */
   /*******************************************************/
   procedure stock_base_load is

      /*-*/
      /* Local variables
      /*-*/
      rcd_stock_base dw_stock_base%rowtype;
      var_stock_trnfr_factor number;
      var_stock_trnfr_price number;
      var_gsv_value number;
      var_process boolean;

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
                                      and t01.trace_seqn > pkg_stk_base_max_seqn
                                    group by t01.purch_order_doc_num)
            and not(t01.purch_order_doc_line_num is null)
            and t01.purch_order_type_code = 'ZUB'
            and t01.trace_status = '*ACTIVE'
            and t01.matl_code = t02.objek(+)
            and t02.obtab = 'MARA'
            and t02.klart = '001'
            and t02.atnam = 'CLFFERT01'
          order by t01.purch_order_doc_num asc,
                   t01.purch_order_doc_line_num asc;
      rcd_trace csr_trace%rowtype;

      cursor csr_pricing is
         select t02.kbetr
           from lads_prc_lst_hdr t01,
                lads_prc_lst_det t02
          where t01.vakey = t02.vakey
            and t01.kschl = t02.kschl
            and t01.datab = t02.datab
            and t01.knumh = t02.knumh
            and t01.lads_status = '1'
            and t01.kschl = 'ZV01'
            and t01.kotabnr = '969'
            and t01.vakey = lpad(nvl('0000010882','0'),10,'0')||rpad(rcd_purch_order_fact.ods_matl_code,18,' ')||'0'
            and (t01.datab <= to_char(rcd_purch_order_fact.purch_order_eff_date,'yyyymmdd') and
                 t01.datbi >= to_char(rcd_purch_order_fact.purch_order_eff_date,'yyyymmdd'))
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
      lics_logging.write_log('Begin - STOCK_BASE Load');

      /*-*/
      /* STEP #1
      /*
      /* Delete any existing stock base rows 
      /* **notes** 1. Delete all stock transfers that have changed within the window
      /*              regardless of their eligibility for inclusion in this process
      /*-*/
      delete from dw_stock_base
       where (purch_order_doc_num) in (select distinct(t01.purch_order_doc_num)
                                         from sap_sto_po_trace t01
                                        where t01.company_code = pkg_company_code
                                          and trunc(t01.trace_date) <= trunc(pkg_date)
                                          and t01.trace_seqn > pkg_stk_base_max_seqn);

      /*-*/
      /* STEP #2
      /*
      /* Load the stock base rows from the ODS trace data
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

         /* Only process required stock transfers
         /*
         /* **notes**
         /* 1. Reset the process indicator
         /* 2. Retrieve the required stock transfers to record as sales
         /*    (ie. where stock ownership has changed within the same company)
         /*-*/
         var_process := false;
         if (t01.source_plant_code = 'NZ01' and
             t01.plant_code = 'NZ11' and
             t01.matl_type_code = 'FERT' and
             t01.bus_sgmnt_code = '05' and
             t01.cnsmr_pack_frmt_code = '51') then
            var_stock_trnfr_code := 'DOG_ROLL';
            var_stock_trnfr_factor := 1;
            var_process := true;
         end if;
         if (t01.source_plant_code = 'NZ11' and
             t01.plant_code = 'NZ01' and
             t01.matl_type_code = 'FERT' and
             t01.bus_sgmnt_code = '05' and
             t01.cnsmr_pack_frmt_code = '51') then
            var_stock_trnfr_code := 'DOG_ROLL';
            var_stock_trnfr_factor := -1;
            var_process := true;
         end if;
         if (t01.source_plant_code in ('NZ01','NZ11') and
             t01.plant_code in ('NZ13','NZ14') and
             t01.matl_type_code = 'FERT' and
             t01.bus_sgmnt_code = '05' and
             t01.cnsmr_pack_frmt_code = '45') then
            var_stock_trnfr_code := 'POUCH';
            var_stock_trnfr_factor := 1;
            var_process := true;
         end if;
         if (t01.source_plant_code in ('NZ13','NZ14') and
             t01.plant_code in ('NZ01','NZ11') and
             t01.matl_type_code = 'FERT' and
             t01.bus_sgmnt_code = '05' and
             t01.cnsmr_pack_frmt_code = '45') then
            var_stock_trnfr_code := 'POUCH';
            var_stock_trnfr_factor := -1;
            var_process := true;
         end if;


         /*-*/
         /* Process the ODS data when required
         /*-*/
         if var_process = true then

            /*---------------------------*/
            /* STOCK_BASE Initialisation */
            /*---------------------------*/

            /*-*/
            /* Initialise the stock base row
            /*-*/
            rcd_purch_order_fact.purch_order_doc_num := rcd_trace.purch_order_doc_num;
            rcd_purch_order_fact.purch_order_doc_line_num := rcd_trace.purch_order_doc_line_num;
            rcd_purch_order_fact.purch_order_line_status := '*OUTSTANDING';
            rcd_purch_order_fact.purch_order_trace_seqn := rcd_trace.trace_seqn;
            rcd_purch_order_fact.creatn_date := rcd_trace.creatn_date;
            rcd_purch_order_fact.creatn_yyyyppdd := rcd_trace.creatn_yyyyppdd;
            rcd_purch_order_fact.creatn_yyyyppw := rcd_trace.creatn_yyyyppw;
            rcd_purch_order_fact.creatn_yyyypp := rcd_trace.creatn_yyyypp;
            rcd_purch_order_fact.creatn_yyyymm := rcd_trace.creatn_yyyymm;
            rcd_purch_order_fact.purch_order_eff_date := rcd_trace.purch_order_eff_date;
            rcd_purch_order_fact.purch_order_eff_yyyyppdd := rcd_trace.purch_order_eff_yyyyppdd;
            rcd_purch_order_fact.purch_order_eff_yyyyppw := rcd_trace.purch_order_eff_yyyyppw;
            rcd_purch_order_fact.purch_order_eff_yyyypp := rcd_trace.purch_order_eff_yyyypp;
            rcd_purch_order_fact.purch_order_eff_yyyymm := rcd_trace.purch_order_eff_yyyymm;
            rcd_purch_order_fact.confirmed_date := rcd_trace.confirmed_date;
            rcd_purch_order_fact.confirmed_yyyyppdd := rcd_trace.confirmed_yyyyppdd;
            rcd_purch_order_fact.confirmed_yyyyppw := rcd_trace.confirmed_yyyyppw;
            rcd_purch_order_fact.confirmed_yyyypp := rcd_trace.confirmed_yyyypp;
            rcd_purch_order_fact.confirmed_yyyymm := rcd_trace.confirmed_yyyymm;
            rcd_purch_order_fact.company_code := rcd_trace.company_code;
            rcd_purch_order_fact.sales_org_code := rcd_trace.sales_org_code;
            rcd_purch_order_fact.distbn_chnl_code := rcd_trace.distbn_chnl_code;
            rcd_purch_order_fact.division_code := rcd_trace.division_code;
            rcd_purch_order_fact.doc_currcy_code := rcd_trace.currcy_code;
            rcd_purch_order_fact.company_currcy_code := pkg_company_currcy;
            rcd_purch_order_fact.exch_rate := rcd_trace.exch_rate;
            rcd_purch_order_fact.purchg_company_code := rcd_trace.purchg_company_code;
            rcd_purch_order_fact.purch_order_type_code := rcd_trace.purch_order_type_code;
            rcd_purch_order_fact.purch_order_reasn_code := rcd_trace.purch_order_reasn_code;
            rcd_purch_order_fact.purch_order_usage_code := rcd_trace.purch_order_usage_code;
            rcd_purch_order_fact.vendor_code := rcd_trace.vendor_code;
            rcd_purch_order_fact.cust_code := rcd_trace.cust_code;
            rcd_purch_order_fact.matl_code := dw_trim_code(rcd_trace.matl_code);
            rcd_purch_order_fact.ods_matl_code := rcd_trace.matl_code;
            rcd_purch_order_fact.plant_code := rcd_trace.plant_code;
            rcd_purch_order_fact.storage_locn_code := rcd_trace.storage_locn_code;
            rcd_purch_order_fact.purch_order_weight_unit := rcd_trace.purch_order_weight_unit;
            rcd_purch_order_fact.purch_order_gross_weight := rcd_trace.purch_order_gross_weight;
            rcd_purch_order_fact.purch_order_net_weight := rcd_trace.purch_order_net_weight;
            rcd_purch_order_fact.purch_order_uom_code := rcd_trace.purch_order_uom_code;
            rcd_purch_order_fact.purch_order_base_uom_code := null;
            rcd_purch_order_fact.ord_qty := 0;
            rcd_purch_order_fact.ord_qty_base_uom := 0;
            rcd_purch_order_fact.ord_qty_gross_tonnes := 0;
            rcd_purch_order_fact.ord_qty_net_tonnes := 0;
            rcd_purch_order_fact.ord_gsv := 0;
            rcd_purch_order_fact.ord_gsv_xactn := 0;
            rcd_purch_order_fact.ord_gsv_aud := 0;
            rcd_purch_order_fact.ord_gsv_usd := 0;
            rcd_purch_order_fact.ord_gsv_eur := 0;
            rcd_purch_order_fact.con_qty := 0;
            rcd_purch_order_fact.con_qty_base_uom := 0;
            rcd_purch_order_fact.con_qty_gross_tonnes := 0;
            rcd_purch_order_fact.con_qty_net_tonnes := 0;
            rcd_purch_order_fact.con_gsv := 0;
            rcd_purch_order_fact.con_gsv_xactn := 0;
            rcd_purch_order_fact.con_gsv_aud := 0;
            rcd_purch_order_fact.con_gsv_usd := 0;
            rcd_purch_order_fact.con_gsv_eur := 0;
            rcd_purch_order_fact.req_qty := 0;
            rcd_purch_order_fact.req_qty_base_uom := 0;
            rcd_purch_order_fact.req_qty_gross_tonnes := 0;
            rcd_purch_order_fact.req_qty_net_tonnes := 0;
            rcd_purch_order_fact.req_gsv := 0;
            rcd_purch_order_fact.req_gsv_xactn := 0;
            rcd_purch_order_fact.req_gsv_aud := 0;
            rcd_purch_order_fact.req_gsv_usd := 0;
            rcd_purch_order_fact.req_gsv_eur := 0;
            rcd_purch_order_fact.del_qty := 0;
            rcd_purch_order_fact.del_qty_base_uom := 0;
            rcd_purch_order_fact.del_qty_gross_tonnes := 0;
            rcd_purch_order_fact.del_qty_net_tonnes := 0;
            rcd_purch_order_fact.del_gsv := 0;
            rcd_purch_order_fact.del_gsv_xactn := 0;
            rcd_purch_order_fact.del_gsv_aud := 0;
            rcd_purch_order_fact.del_gsv_usd := 0;
            rcd_purch_order_fact.del_gsv_eur := 0;
            rcd_purch_order_fact.inv_qty := 0;
            rcd_purch_order_fact.inv_qty_base_uom := 0;
            rcd_purch_order_fact.inv_qty_gross_tonnes := 0;
            rcd_purch_order_fact.inv_qty_net_tonnes := 0;
            rcd_purch_order_fact.inv_gsv := 0;
            rcd_purch_order_fact.inv_gsv_xactn := 0;
            rcd_purch_order_fact.inv_gsv_aud := 0;
            rcd_purch_order_fact.inv_gsv_usd := 0;
            rcd_purch_order_fact.inv_gsv_eur := 0;
            rcd_purch_order_fact.out_qty := 0;
            rcd_purch_order_fact.out_qty_base_uom := 0;
            rcd_purch_order_fact.out_qty_gross_tonnes := 0;
            rcd_purch_order_fact.out_qty_net_tonnes := 0;
            rcd_purch_order_fact.out_gsv := 0;
            rcd_purch_order_fact.out_gsv_xactn := 0;
            rcd_purch_order_fact.out_gsv_aud := 0;
            rcd_purch_order_fact.out_gsv_usd := 0;
            rcd_purch_order_fact.out_gsv_eur := 0;
            rcd_purch_order_fact.mfanz_icb_flag := 'N';
            rcd_purch_order_fact.demand_plng_grp_division_code := rcd_trace.division_code;
            if rcd_purch_order_fact.demand_plng_grp_division_code = '57' then
               if rcd_trace.mat_bus_sgmnt_code = '05' then
                  rcd_purch_order_fact.demand_plng_grp_division_code := '56';
               end if;
            end if;

            /*-*/
            /* Retrieve the stock transfer pricing data
            /*-*/
            var_stock_trnfr_price := 0;
            open csr_pricing;
            fetch csr_pricing into rcd_pricing;
            if csr_purch_order_type%found then
               var_stock_trnfr_price := rcd_pricing.kbetr;
            end if;
            close csr_pricing;

            /*-------------------------*/
            /* STOCK_BASE Calculations */
            /*-------------------------*/

            /*-*/
            /* Calculate the purchase order quantity values from the material GRD data
            /* **notes** 1. Recalculation from the material GRD data allows the fact tables to be rebuilt from the ODS when GRD data errors are corrected.
            /*           2. Ensures consistency when reducing outstanding quantity and weight from delivery and invoice.
            /*           3. Is the only way to reduce the order quantity with the delivery quantity (different material or UOM).
            /*-*/
            rcd_purch_order_fact.ord_qty := var_purch_order_type_factor * rcd_trace.purch_order_qty;
            dw_utility.pkg_qty_fact.ods_matl_code := rcd_purch_order_fact.ods_matl_code;
            dw_utility.pkg_qty_fact.uom_code := rcd_purch_order_fact.purch_order_uom_code;
            dw_utility.pkg_qty_fact.uom_qty := rcd_purch_order_fact.ord_qty;
            dw_utility.calculate_quantity;
            rcd_purch_order_fact.purch_order_base_uom_code := dw_utility.pkg_qty_fact.base_uom_code;
            rcd_purch_order_fact.ord_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
            rcd_purch_order_fact.ord_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
            rcd_purch_order_fact.ord_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

            /*-*/
            /* Calculate the purchase order GSV values
            /*-*/
            rcd_purch_order_fact.ord_gsv_xactn := round(var_purch_order_type_factor * rcd_trace.purch_order_gsv, 2);
            var_gsv_value := var_purch_order_type_factor * rcd_trace.purch_order_gsv;
            rcd_purch_order_fact.ord_gsv := round(
                                               ods_app.currcy_conv(
                                                  var_gsv_value,
                                                  rcd_purch_order_fact.doc_currcy_code,
                                                  rcd_purch_order_fact.company_currcy_code,
                                                  rcd_purch_order_fact.creatn_date,
                                                  'USDX'), 2);
            rcd_purch_order_fact.ord_gsv_aud := round(
                                                   ods_app.currcy_conv(
                                                      ods_app.currcy_conv(
                                                         var_gsv_value,
                                                         rcd_purch_order_fact.doc_currcy_code,
                                                         rcd_purch_order_fact.company_currcy_code,
                                                         rcd_purch_order_fact.creatn_date,
                                                         'USDX'),
                                                      rcd_purch_order_fact.company_currcy_code,
                                                      'AUD',
                                                      rcd_purch_order_fact.creatn_date,
                                                      'MPPR'), 2);
            rcd_purch_order_fact.ord_gsv_usd := round(
                                                   ods_app.currcy_conv(
                                                      ods_app.currcy_conv(
                                                         var_gsv_value,
                                                         rcd_purch_order_fact.doc_currcy_code,
                                                         rcd_purch_order_fact.company_currcy_code,
                                                         rcd_purch_order_fact.creatn_date,
                                                         'USDX'),
                                                      rcd_purch_order_fact.company_currcy_code,
                                                      'USD',
                                                      rcd_purch_order_fact.creatn_date,
                                                      'MPPR'), 2);
            rcd_purch_order_fact.ord_gsv_eur := round(
                                                   ods_app.currcy_conv(
                                                      ods_app.currcy_conv(
                                                         var_gsv_value,
                                                         rcd_purch_order_fact.doc_currcy_code,
                                                         rcd_purch_order_fact.company_currcy_code,
                                                         rcd_purch_order_fact.creatn_date,
                                                         'USDX'),
                                                      rcd_purch_order_fact.company_currcy_code,
                                                      'EUR',
                                                      rcd_purch_order_fact.creatn_date,
                                                      'MPPR'), 2);

            /*-*/
            /* Calculate the confirmed quantity values
            /*-*/
            rcd_purch_order_fact.con_qty := var_purch_order_type_factor * rcd_trace.confirmed_qty;
            dw_utility.pkg_qty_fact.ods_matl_code := rcd_purch_order_fact.ods_matl_code;
            dw_utility.pkg_qty_fact.uom_code := rcd_purch_order_fact.purch_order_uom_code;
            dw_utility.pkg_qty_fact.uom_qty := rcd_purch_order_fact.con_qty;
            dw_utility.calculate_quantity;
            rcd_purch_order_fact.con_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
            rcd_purch_order_fact.con_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
            rcd_purch_order_fact.con_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

            /*-*/
            /* Calculate the confirmed GSV values
            /*-*/
            if rcd_purch_order_fact.ord_qty = 0 then
               rcd_purch_order_fact.con_gsv := rcd_purch_order_fact.ord_gsv;
               rcd_purch_order_fact.con_gsv_xactn := rcd_purch_order_fact.ord_gsv_xactn;
               rcd_purch_order_fact.con_gsv_aud := rcd_purch_order_fact.ord_gsv_aud;
               rcd_purch_order_fact.con_gsv_usd := rcd_purch_order_fact.ord_gsv_usd;
               rcd_purch_order_fact.con_gsv_eur := rcd_purch_order_fact.ord_gsv_eur;
            else
               rcd_purch_order_fact.con_gsv := round((rcd_purch_order_fact.ord_gsv / rcd_purch_order_fact.ord_qty) * rcd_purch_order_fact.con_qty, 2);
               rcd_purch_order_fact.con_gsv_xactn := round((rcd_purch_order_fact.ord_gsv_xactn / rcd_purch_order_fact.ord_qty) * rcd_purch_order_fact.con_qty, 2);
               rcd_purch_order_fact.con_gsv_aud := round((rcd_purch_order_fact.ord_gsv_aud / rcd_purch_order_fact.ord_qty) * rcd_purch_order_fact.con_qty, 2);
               rcd_purch_order_fact.con_gsv_usd := round((rcd_purch_order_fact.ord_gsv_usd / rcd_purch_order_fact.ord_qty) * rcd_purch_order_fact.con_qty, 2);
               rcd_purch_order_fact.con_gsv_eur := round((rcd_purch_order_fact.ord_gsv_eur / rcd_purch_order_fact.ord_qty) * rcd_purch_order_fact.con_qty, 2);
            end if;

            /*---------------------*/
            /* STOCK_BASE Creation */
            /*---------------------*/

            /*-*/
            /* Insert the purchase order fact row
            /*-*/
            insert into dw_purch_base values rcd_purch_order_fact;

            /*-------------------*/
            /* STOCK_BASE Status */
            /*-------------------*/

            /*-*/
            /* Update the stock base status
            /*-*/
            dw_utility.purch_order_fact_status(rcd_purch_order_fact.purch_order_doc_num, rcd_purch_order_fact.purch_order_doc_line_num);

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
      lics_logging.write_log('End - STOCK_BASE Load');

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
            lics_logging.write_log('**ERROR** - STOCK_BASE Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - STOCK_BASE Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end stock_base_load;

   /*******************************************************/
   /* This procedure performs the order fact load routine */
   /*******************************************************/
   procedure order_fact_load is

      /*-*/
      /* Local variables
      /*-*/
      rcd_order_fact dw_order_base%rowtype;
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
                                      and t01.trace_seqn > pkg_ord_fact_max_seqn
                                    group by t01.order_doc_num)
            and not(t01.order_doc_line_num is null)
            and (t01.order_line_rejectn_code is null or t01.order_line_rejectn_code = 'ZA')
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
          where t01.order_type_code = rcd_order_fact.order_type_code;
      rcd_order_type csr_order_type%rowtype;

      cursor csr_icb_flag is
         select 'Y' as icb_flag
           from table(lics_datastore.retrieve_value('CDW','ICB_FLAG',rcd_order_fact.company_code)) t01
          where t01.dsv_value = rcd_order_fact.ship_to_cust_code;
      rcd_icb_flag csr_icb_flag%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - ORDER_FACT Load');

      /*-*/
      /* STEP #1
      /*
      /* Delete any existing order fact rows 
      /* **notes** 1. Delete all orders that have changed within the window.
      /*-*/
      delete from dw_order_base
       where (order_doc_num) in (select distinct(t01.order_doc_num)
                                   from sap_sal_ord_trace t01
                                  where t01.company_code = pkg_company_code
                                    and trunc(t01.trace_date) <= trunc(pkg_date)
                                    and t01.trace_seqn > pkg_ord_fact_max_seqn);

      /*-*/
      /* STEP #2
      /*
      /* Load the order fact rows from the ODS trace data
      /* **notes** 1. Select all orders that have changed within the window
      /*           2. Only inter-company non-rejected orders (ORDER_LINE_REJECTN_CODE = NULL or 'ZA') are selected
      /*           3. Only valid orders are selected (TRACE_STATUS = *ACTIVE)
      /*-*/
      open csr_trace;
      loop
         fetch csr_trace into rcd_trace;
         if csr_trace%notfound then
            exit;
         end if;

         /*---------------------------*/
         /* ORDER_FACT Initialisation */
         /*---------------------------*/

         /*-*/
         /* Initialise the order fact row
         /*-*/
         rcd_order_fact.order_doc_num := rcd_trace.order_doc_num;
         rcd_order_fact.order_doc_line_num := rcd_trace.order_doc_line_num;
         rcd_order_fact.order_line_status := '*OUTSTANDING';
         rcd_order_fact.order_trace_seqn := rcd_trace.trace_seqn;
         rcd_order_fact.creatn_date := rcd_trace.creatn_date;
         rcd_order_fact.creatn_yyyyppdd := rcd_trace.creatn_yyyyppdd;
         rcd_order_fact.creatn_yyyyppw := rcd_trace.creatn_yyyyppw;
         rcd_order_fact.creatn_yyyypp := rcd_trace.creatn_yyyypp;
         rcd_order_fact.creatn_yyyymm := rcd_trace.creatn_yyyymm;
         rcd_order_fact.order_eff_date := nvl(rcd_trace.confirmed_date, rcd_trace.order_eff_date);
         rcd_order_fact.order_eff_yyyyppdd := nvl(rcd_trace.confirmed_yyyyppdd, rcd_trace.order_eff_yyyyppdd);
         rcd_order_fact.order_eff_yyyyppw := nvl(rcd_trace.confirmed_yyyyppw, rcd_trace.order_eff_yyyyppw);
         rcd_order_fact.order_eff_yyyypp := nvl(rcd_trace.confirmed_yyyypp, rcd_trace.order_eff_yyyypp);
         rcd_order_fact.order_eff_yyyymm := nvl(rcd_trace.confirmed_yyyymm, rcd_trace.order_eff_yyyymm);
         rcd_order_fact.confirmed_date := rcd_trace.confirmed_date;
         rcd_order_fact.confirmed_yyyyppdd := rcd_trace.confirmed_yyyyppdd;
         rcd_order_fact.confirmed_yyyyppw := rcd_trace.confirmed_yyyyppw;
         rcd_order_fact.confirmed_yyyypp := rcd_trace.confirmed_yyyypp;
         rcd_order_fact.confirmed_yyyymm := rcd_trace.confirmed_yyyymm;
         rcd_order_fact.company_code := rcd_trace.company_code;
         rcd_order_fact.cust_order_doc_num := rcd_trace.cust_order_doc_num;
         rcd_order_fact.cust_order_doc_line_num := rcd_trace.cust_order_doc_line_num;
         rcd_order_fact.cust_order_due_date := rcd_trace.cust_order_due_date;
         rcd_order_fact.sales_org_code := rcd_trace.sales_org_code;
         rcd_order_fact.distbn_chnl_code := rcd_trace.distbn_chnl_code;
         rcd_order_fact.division_code := rcd_trace.division_code;
         rcd_order_fact.doc_currcy_code := rcd_trace.currcy_code;
         rcd_order_fact.company_currcy_code := pkg_company_currcy;
         rcd_order_fact.exch_rate := rcd_trace.exch_rate;
         rcd_order_fact.order_type_code := rcd_trace.order_type_code;
         rcd_order_fact.order_reasn_code := rcd_trace.order_reasn_code;
         rcd_order_fact.order_usage_code := rcd_trace.order_usage_code;
         rcd_order_fact.sold_to_cust_code := nvl(rcd_trace.gen_sold_to_cust_code, rcd_trace.hdr_sold_to_cust_code);
         rcd_order_fact.bill_to_cust_code := nvl(rcd_trace.gen_bill_to_cust_code, rcd_trace.hdr_bill_to_cust_code);
         rcd_order_fact.payer_cust_code := nvl(rcd_trace.gen_payer_cust_code, rcd_trace.hdr_payer_cust_code);
         rcd_order_fact.ship_to_cust_code := nvl(rcd_trace.gen_ship_to_cust_code, rcd_trace.hdr_ship_to_cust_code);
         rcd_order_fact.matl_code := dw_trim_code(rcd_trace.matl_code);
         rcd_order_fact.ods_matl_code := rcd_trace.matl_code;
         rcd_order_fact.matl_entd := dw_trim_code(rcd_trace.matl_entd);
         rcd_order_fact.plant_code := rcd_trace.plant_code;
         rcd_order_fact.storage_locn_code := rcd_trace.storage_locn_code;
         rcd_order_fact.order_line_rejectn_code := rcd_trace.order_line_rejectn_code;
         rcd_order_fact.order_weight_unit := rcd_trace.order_weight_unit;
         rcd_order_fact.order_gross_weight := rcd_trace.order_gross_weight;
         rcd_order_fact.order_net_weight := rcd_trace.order_net_weight;
         rcd_order_fact.order_uom_code := rcd_trace.order_uom_code;
         rcd_order_fact.order_base_uom_code := null;
         rcd_order_fact.ord_qty := 0;
         rcd_order_fact.ord_qty_base_uom := 0;
         rcd_order_fact.ord_qty_gross_tonnes := 0;
         rcd_order_fact.ord_qty_net_tonnes := 0;
         rcd_order_fact.ord_gsv := 0;
         rcd_order_fact.ord_gsv_xactn := 0;
         rcd_order_fact.ord_gsv_aud := 0;
         rcd_order_fact.ord_gsv_usd := 0;
         rcd_order_fact.ord_gsv_eur := 0;
         rcd_order_fact.con_qty := 0;
         rcd_order_fact.con_qty_base_uom := 0;
         rcd_order_fact.con_qty_gross_tonnes := 0;
         rcd_order_fact.con_qty_net_tonnes := 0;
         rcd_order_fact.con_gsv := 0;
         rcd_order_fact.con_gsv_xactn := 0;
         rcd_order_fact.con_gsv_aud := 0;
         rcd_order_fact.con_gsv_usd := 0;
         rcd_order_fact.con_gsv_eur := 0;
         rcd_order_fact.req_qty := 0;
         rcd_order_fact.req_qty_base_uom := 0;
         rcd_order_fact.req_qty_gross_tonnes := 0;
         rcd_order_fact.req_qty_net_tonnes := 0;
         rcd_order_fact.req_gsv := 0;
         rcd_order_fact.req_gsv_xactn := 0;
         rcd_order_fact.req_gsv_aud := 0;
         rcd_order_fact.req_gsv_usd := 0;
         rcd_order_fact.req_gsv_eur := 0;
         rcd_order_fact.del_qty := 0;
         rcd_order_fact.del_qty_base_uom := 0;
         rcd_order_fact.del_qty_gross_tonnes := 0;
         rcd_order_fact.del_qty_net_tonnes := 0;
         rcd_order_fact.del_gsv := 0;
         rcd_order_fact.del_gsv_xactn := 0;
         rcd_order_fact.del_gsv_aud := 0;
         rcd_order_fact.del_gsv_usd := 0;
         rcd_order_fact.del_gsv_eur := 0;
         rcd_order_fact.inv_qty := 0;
         rcd_order_fact.inv_qty_base_uom := 0;
         rcd_order_fact.inv_qty_gross_tonnes := 0;
         rcd_order_fact.inv_qty_net_tonnes := 0;
         rcd_order_fact.inv_gsv := 0;
         rcd_order_fact.inv_gsv_xactn := 0;
         rcd_order_fact.inv_gsv_aud := 0;
         rcd_order_fact.inv_gsv_usd := 0;
         rcd_order_fact.inv_gsv_eur := 0;
         rcd_order_fact.out_qty := 0;
         rcd_order_fact.out_qty_base_uom := 0;
         rcd_order_fact.out_qty_gross_tonnes := 0;
         rcd_order_fact.out_qty_net_tonnes := 0;
         rcd_order_fact.out_gsv := 0;
         rcd_order_fact.out_gsv_xactn := 0;
         rcd_order_fact.out_gsv_aud := 0;
         rcd_order_fact.out_gsv_usd := 0;
         rcd_order_fact.out_gsv_eur := 0;
         rcd_order_fact.mfanz_icb_flag := 'N';
         rcd_order_fact.demand_plng_grp_division_code := rcd_trace.division_code;
         if rcd_order_fact.demand_plng_grp_division_code = '57' then
            if rcd_trace.mat_bus_sgmnt_code = '05' then
               rcd_order_fact.demand_plng_grp_division_code := '56';
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
         /*    and will therefore be loaded into the order fact table as a positive
         /* 2. The order usage GSV flag defaults to 'GSV' for unrecognised order usage codes
         /*    and will therefore always be loaded into the sales fact table
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
            rcd_order_fact.mfanz_icb_flag := 'Y';
         end if;
         close csr_icb_flag;

         /*-*/
         /* Only load the order fact row when order type 'GSV'
         /*-*/
         if var_order_type_gsv_flag = 'GSV' then

            /*-------------------------*/
            /* ORDER_FACT Calculations */
            /*-------------------------*/

            /*-*/
            /* Calculate the order quantity values
            /* **notes** 1. Recalculation from the material GRD data allows the fact tables to be rebuilt from the ODS when GRD data errors are corrected.
            /*           2. Ensures consistency when reducing outstanding quantity and weight from delivery and invoice.
            /*           3. Is the only way to reduce the order quantity with the delivery quantity (different material or UOM).
            /*-*/
            rcd_order_fact.ord_qty := var_order_type_factor * rcd_trace.order_qty;
            dw_utility.pkg_qty_fact.ods_matl_code := rcd_order_fact.ods_matl_code;
            dw_utility.pkg_qty_fact.uom_code := rcd_order_fact.order_uom_code;
            dw_utility.pkg_qty_fact.uom_qty := rcd_order_fact.ord_qty;
            dw_utility.calculate_quantity;
            rcd_order_fact.order_base_uom_code := dw_utility.pkg_qty_fact.base_uom_code;
            rcd_order_fact.ord_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
            rcd_order_fact.ord_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
            rcd_order_fact.ord_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

            /*-*/
            /* Calculate the order GSV values
            /*-*/
            rcd_order_fact.ord_gsv_xactn := round(var_order_type_factor * rcd_trace.order_gsv, 2);
            var_gsv_value := (var_order_type_factor / ods_app.exch_rate_factor('ICB',
                                                                               rcd_order_fact.doc_currcy_code,
                                                                               rcd_order_fact.company_currcy_code,
                                                                               rcd_order_fact.creatn_date))
                             * (rcd_trace.order_gsv * rcd_order_fact.exch_rate);
            rcd_order_fact.ord_gsv := round(var_gsv_value, 2);
            rcd_order_fact.ord_gsv_aud := round(
                                             ods_app.currcy_conv(
                                                var_gsv_value,
                                                rcd_order_fact.company_currcy_code,
                                                'AUD',
                                                rcd_order_fact.creatn_date,
                                                'MPPR'), 2);
            rcd_order_fact.ord_gsv_usd := round(
                                             ods_app.currcy_conv(
                                                var_gsv_value,
                                                rcd_order_fact.company_currcy_code,
                                                'USD',
                                                rcd_order_fact.creatn_date,
                                                'MPPR'), 2);
            rcd_order_fact.ord_gsv_eur := round(
                                             ods_app.currcy_conv(
                                                var_gsv_value,
                                                rcd_order_fact.company_currcy_code,
                                                'EUR',
                                                rcd_order_fact.creatn_date,
                                                'MPPR'), 2);

            /*-*/
            /* Calculate the confirmed quantity values
            /*-*/
            rcd_order_fact.con_qty := var_order_type_factor * rcd_trace.confirmed_qty;
            dw_utility.pkg_qty_fact.ods_matl_code := rcd_order_fact.ods_matl_code;
            dw_utility.pkg_qty_fact.uom_code := rcd_order_fact.order_uom_code;
            dw_utility.pkg_qty_fact.uom_qty := rcd_order_fact.con_qty;
            dw_utility.calculate_quantity;
            rcd_order_fact.con_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
            rcd_order_fact.con_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
            rcd_order_fact.con_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

            /*-*/
            /* Calculate the confirmed GSV values
            /*-*/
            if rcd_order_fact.ord_qty = 0 then
               rcd_order_fact.con_gsv := rcd_order_fact.ord_gsv;
               rcd_order_fact.con_gsv_xactn := rcd_order_fact.ord_gsv_xactn;
               rcd_order_fact.con_gsv_aud := rcd_order_fact.ord_gsv_aud;
               rcd_order_fact.con_gsv_usd := rcd_order_fact.ord_gsv_usd;
               rcd_order_fact.con_gsv_eur := rcd_order_fact.ord_gsv_eur;
            else
               rcd_order_fact.con_gsv := round((rcd_order_fact.ord_gsv / rcd_order_fact.ord_qty) * rcd_order_fact.con_qty, 2);
               rcd_order_fact.con_gsv_xactn := round((rcd_order_fact.ord_gsv_xactn / rcd_order_fact.ord_qty) * rcd_order_fact.con_qty, 2);
               rcd_order_fact.con_gsv_aud := round((rcd_order_fact.ord_gsv_aud / rcd_order_fact.ord_qty) * rcd_order_fact.con_qty, 2);
               rcd_order_fact.con_gsv_usd := round((rcd_order_fact.ord_gsv_usd / rcd_order_fact.ord_qty) * rcd_order_fact.con_qty, 2);
               rcd_order_fact.con_gsv_eur := round((rcd_order_fact.ord_gsv_eur / rcd_order_fact.ord_qty) * rcd_order_fact.con_qty, 2);
            end if;

            /*---------------------*/
            /* ORDER_FACT Creation */
            /*---------------------*/

            /*-*/
            /* Insert the order fact row
            /*-*/
            insert into dw_order_base values rcd_order_fact;

            /*-------------------*/
            /* ORDER_FACT Status */
            /*-------------------*/

            /*-*/
            /* Update the order fact status
            /*-*/
            dw_utility.order_fact_status(rcd_order_fact.order_doc_num, rcd_order_fact.order_doc_line_num);

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
      lics_logging.write_log('End - ORDER_FACT Load');

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
            lics_logging.write_log('**ERROR** - ORDER_FACT Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - ORDER_FACT Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end order_fact_load;

   /**********************************************************/
   /* This procedure performs the delivery fact load routine */
   /**********************************************************/
   procedure dlvry_fact_load is

      /*-*/
      /* Local variables
      /*-*/
      rcd_dlvry_fact dw_dlvry_base%rowtype;
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
                                       and t01.trace_seqn > pkg_del_fact_max_seqn
                                     group by t01.dlvry_doc_num) or
                 t01.trace_seqn in (select max(t01.trace_seqn)
                                      from sap_del_trace t01
                                     where t01.company_code = pkg_company_code
                                       and trunc(t01.trace_date) <= trunc(pkg_date)
                                       and (t01.order_doc_num) in (select distinct(t01.order_doc_num)
                                                                     from sap_sal_ord_trace t01
                                                                    where t01.company_code = pkg_company_code
                                                                      and trunc(t01.trace_date) <= trunc(pkg_date)
                                                                      and t01.trace_seqn > pkg_ord_fact_max_seqn)
                                     group by t01.dlvry_doc_num) or
                 t01.trace_seqn in (select max(t01.trace_seqn)
                                      from sap_del_trace t01
                                     where t01.company_code = pkg_company_code
                                       and trunc(t01.trace_date) <= trunc(pkg_date)
                                       and (t01.purch_order_doc_num) in (select distinct(t01.purch_order_doc_num)
                                                                           from sap_sto_po_trace t01
                                                                          where t01.company_code = pkg_company_code
                                                                            and trunc(t01.trace_date) <= trunc(pkg_date)
                                                                            and t01.trace_seqn > pkg_pur_fact_max_seqn)
                                     group by t01.dlvry_doc_num))
            and not(t01.dlvry_doc_line_num is null)
            and t01.trace_status = '*ACTIVE'
            and t01.matl_code = t02.objek(+)
            and t02.obtab(+) = 'MARA'
            and t02.klart(+) = '001'
            and t02.atnam(+) = 'CLFFERT01'
          order by t01.dlvry_doc_num asc,
                   t01.dlvry_doc_line_num asc;
      rcd_trace csr_trace%rowtype;

      cursor csr_order_fact is
         select t01.*,
                decode(t02.order_type_sign,'-',-1,1) as order_type_factor
           from dw_order_base t01,
                order_type t02
          where t01.order_type_code = t02.order_type_code(+)
            and t01.order_doc_num = rcd_trace.order_doc_line_num
            and t01.order_doc_line_num = rcd_trace.order_doc_line_num;
      rcd_order_fact csr_order_fact%rowtype;

      cursor csr_purch_order_fact is
         select t01.*,
                decode(t02.purch_order_type_sign,'-',-1,1) as purch_order_type_factor
           from dw_purch_base t01,
                purch_order_type t02
          where t01.purch_order_type_code = t02.purch_order_type_code(+)
            and t01.purch_order_doc_num = rcd_trace.purch_order_doc_line_num
            and t01.purch_order_doc_line_num = rcd_trace.purch_order_doc_line_num;
      rcd_purch_order_fact csr_purch_order_fact%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - DLVRY_FACT Load');

      /*-*/
      /* STEP #1
      /*
      /* Delete any existing delivery fact rows 
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
                                    and t01.trace_seqn > pkg_del_fact_max_seqn)
          or (order_doc_num) in (select distinct(t01.order_doc_num)
                                   from sap_sal_ord_trace t01
                                  where t01.company_code = pkg_company_code
                                    and trunc(t01.trace_date) <= trunc(pkg_date)
                                    and t01.trace_seqn > pkg_ord_fact_max_seqn)
          or (purch_order_doc_num) in (select distinct(t01.purch_order_doc_num)
                                         from sap_sto_po_trace t01
                                        where t01.company_code = pkg_company_code
                                          and trunc(t01.trace_date) <= trunc(pkg_date)
                                          and t01.trace_seqn > pkg_pur_fact_max_seqn);

      /*-*/
      /* STEP #2
      /*
      /* Load the delivery fact rows from the ODS trace data
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
         /* 2. Retrieve the related ORDER_FACT row when required
         /* 3. Retrieve the related PURCH_ORDER_FACT row when required
         /* 4. This will ensure the removal of any DLVRY_FACT rows that
         /*    pointed to deleted ORDER_FACT or PURCH_ORDER_FACT rows
         /*-*/
         var_process := false;
         if not(rcd_trace.order_doc_num is null) then
            open csr_order_fact;
            fetch csr_order_fact into rcd_order_fact;
            if csr_order_fact%found then
               var_process := true;
               var_dlvry_type_factor := rcd_order_fact.order_type_factor;
            end if;
            close csr_order_fact;
         elsif not(rcd_trace.purch_order_doc_num is null) then
            open csr_purch_order_fact;
            fetch csr_purch_order_fact into rcd_purch_order_fact;
            if csr_purch_order_fact%found then
               var_process := true;
               var_dlvry_type_factor := rcd_purch_order_fact.purch_order_type_factor;
            end if;
            close csr_purch_order_fact;
         end if;
 
         /*-*/
         /* Process the ODS data when required
         /*-*/
         if var_process = true then

            /*---------------------------*/
            /* DLVRY_FACT Initialisation */
            /*---------------------------*/

            /*-*/
            /* Initialise the delivery fact row
            /*-*/
            rcd_dlvry_fact.dlvry_doc_num := rcd_trace.dlvry_doc_num;
            rcd_dlvry_fact.dlvry_doc_line_num := rcd_trace.dlvry_doc_line_num;
            rcd_dlvry_fact.dlvry_line_status := '*OUTSTANDING';
            rcd_dlvry_fact.dlvry_trace_seqn := rcd_trace.trace_seqn;
            rcd_dlvry_fact.creatn_date := rcd_trace.creatn_date;
            rcd_dlvry_fact.creatn_yyyyppdd := rcd_trace.creatn_yyyyppdd;
            rcd_dlvry_fact.creatn_yyyyppw := rcd_trace.creatn_yyyyppw;
            rcd_dlvry_fact.creatn_yyyypp := rcd_trace.creatn_yyyypp;
            rcd_dlvry_fact.creatn_yyyymm := rcd_trace.creatn_yyyymm;
            rcd_dlvry_fact.dlvry_eff_date := rcd_trace.dlvry_eff_date;
            rcd_dlvry_fact.dlvry_eff_yyyyppdd := rcd_trace.dlvry_eff_yyyyppdd;
            rcd_dlvry_fact.dlvry_eff_yyyyppw := rcd_trace.dlvry_eff_yyyyppw;
            rcd_dlvry_fact.dlvry_eff_yyyypp := rcd_trace.dlvry_eff_yyyypp;
            rcd_dlvry_fact.dlvry_eff_yyyymm := rcd_trace.dlvry_eff_yyyymm;
            rcd_dlvry_fact.goods_issue_date := rcd_trace.goods_issue_date;
            rcd_dlvry_fact.goods_issue_yyyyppdd := rcd_trace.goods_issue_yyyyppdd;
            rcd_dlvry_fact.goods_issue_yyyyppw := rcd_trace.goods_issue_yyyyppw;
            rcd_dlvry_fact.goods_issue_yyyypp := rcd_trace.goods_issue_yyyypp;
            rcd_dlvry_fact.goods_issue_yyyymm := rcd_trace.goods_issue_yyyymm;
            rcd_dlvry_fact.order_doc_num := rcd_trace.order_doc_num;
            rcd_dlvry_fact.order_doc_line_num := rcd_trace.order_doc_line_num;
            rcd_dlvry_fact.purch_order_doc_num := rcd_trace.purch_order_doc_num;
            rcd_dlvry_fact.purch_order_doc_line_num := rcd_trace.purch_order_doc_line_num;
            rcd_dlvry_fact.company_code := rcd_trace.company_code;
            rcd_dlvry_fact.sales_org_code := rcd_trace.sales_org_code;
            rcd_dlvry_fact.distbn_chnl_code := rcd_trace.distbn_chnl_code;
            rcd_dlvry_fact.division_code := null;
            rcd_dlvry_fact.doc_currcy_code := null;
            rcd_dlvry_fact.company_currcy_code := pkg_company_currcy;
            rcd_dlvry_fact.exch_rate := null;
            rcd_dlvry_fact.dlvry_type_code := rcd_trace.dlvry_type_code;
            rcd_dlvry_fact.dlvry_procg_stage := rcd_trace.dlvry_procg_stage;
            rcd_dlvry_fact.sold_to_cust_code := rcd_trace.sold_to_cust_code;
            rcd_dlvry_fact.bill_to_cust_code := rcd_trace.bill_to_cust_code;
            rcd_dlvry_fact.payer_cust_code := rcd_trace.payer_cust_code;
            rcd_dlvry_fact.ship_to_cust_code := rcd_trace.ship_to_cust_code;
            rcd_dlvry_fact.matl_code := dw_trim_code(rcd_trace.matl_code);
            rcd_dlvry_fact.ods_matl_code := rcd_trace.matl_code;
            rcd_dlvry_fact.matl_entd := dw_trim_code(rcd_trace.matl_entd);
            rcd_dlvry_fact.plant_code := rcd_trace.plant_code;
            rcd_dlvry_fact.storage_locn_code := rcd_trace.storage_locn_code;
            rcd_dlvry_fact.dlvry_weight_unit := rcd_trace.dlvry_weight_unit;
            rcd_dlvry_fact.dlvry_gross_weight := rcd_trace.dlvry_gross_weight;
            rcd_dlvry_fact.dlvry_net_weight := rcd_trace.dlvry_net_weight;
            rcd_dlvry_fact.dlvry_uom_code := rcd_trace.dlvry_uom_code;
            rcd_dlvry_fact.dlvry_base_uom_code := rcd_trace.dlvry_base_uom_code;
            rcd_dlvry_fact.req_qty := 0;
            rcd_dlvry_fact.req_qty_base_uom := 0;
            rcd_dlvry_fact.req_qty_gross_tonnes := 0;
            rcd_dlvry_fact.req_qty_net_tonnes := 0;
            rcd_dlvry_fact.req_gsv := 0;
            rcd_dlvry_fact.req_gsv_xactn := 0;
            rcd_dlvry_fact.req_gsv_aud := 0;
            rcd_dlvry_fact.req_gsv_usd := 0;
            rcd_dlvry_fact.req_gsv_eur := 0;
            rcd_dlvry_fact.del_qty := 0;
            rcd_dlvry_fact.del_qty_base_uom := 0;
            rcd_dlvry_fact.del_qty_gross_tonnes := 0;
            rcd_dlvry_fact.del_qty_net_tonnes := 0;
            rcd_dlvry_fact.del_gsv := 0;
            rcd_dlvry_fact.del_gsv_xactn := 0;
            rcd_dlvry_fact.del_gsv_aud := 0;
            rcd_dlvry_fact.del_gsv_usd := 0;
            rcd_dlvry_fact.del_gsv_eur := 0;
            rcd_dlvry_fact.inv_qty := 0;
            rcd_dlvry_fact.inv_qty_base_uom := 0;
            rcd_dlvry_fact.inv_qty_gross_tonnes := 0;
            rcd_dlvry_fact.inv_qty_net_tonnes := 0;
            rcd_dlvry_fact.inv_gsv := 0;
            rcd_dlvry_fact.inv_gsv_xactn := 0;
            rcd_dlvry_fact.inv_gsv_aud := 0;
            rcd_dlvry_fact.inv_gsv_usd := 0;
            rcd_dlvry_fact.inv_gsv_eur := 0;
            rcd_dlvry_fact.out_qty := 0;
            rcd_dlvry_fact.out_qty_base_uom := 0;
            rcd_dlvry_fact.out_qty_gross_tonnes := 0;
            rcd_dlvry_fact.out_qty_net_tonnes := 0;
            rcd_dlvry_fact.out_gsv := 0;
            rcd_dlvry_fact.out_gsv_xactn := 0;
            rcd_dlvry_fact.out_gsv_aud := 0;
            rcd_dlvry_fact.out_gsv_usd := 0;
            rcd_dlvry_fact.out_gsv_eur := 0;
            rcd_dlvry_fact.mfanz_icb_flag := null;
            rcd_dlvry_fact.demand_plng_grp_division_code := null;

            /*-*/
            /* Set the related data ORDER_FACT or PURCH_ORDER_FACT
            /*-*/
            if not(rcd_dlvry_fact.order_doc_num is null) then
               rcd_dlvry_fact.division_code := rcd_order_fact.division_code;
               rcd_dlvry_fact.doc_currcy_code := rcd_order_fact.doc_currcy_code;
               rcd_dlvry_fact.exch_rate := rcd_order_fact.exch_rate;
               rcd_dlvry_fact.mfanz_icb_flag := rcd_order_fact.mfanz_icb_flag;
               rcd_dlvry_fact.demand_plng_grp_division_code := rcd_order_fact.demand_plng_grp_division_code;
            end if;
            if not(rcd_dlvry_fact.purch_order_doc_num is null) then
               rcd_dlvry_fact.division_code := rcd_purch_order_fact.division_code;
               rcd_dlvry_fact.doc_currcy_code := rcd_purch_order_fact.doc_currcy_code;
               rcd_dlvry_fact.exch_rate := rcd_purch_order_fact.exch_rate;
               rcd_dlvry_fact.mfanz_icb_flag := rcd_purch_order_fact.mfanz_icb_flag;
               rcd_dlvry_fact.demand_plng_grp_division_code := rcd_purch_order_fact.demand_plng_grp_division_code;
            end if;

            /*-------------------------*/
            /* DLVRY_FACT Calculations */
            /*-------------------------*/

            /*-*/
            /* Calculate the requested quantity values
            /* **notes** 1. Recalculation from the material GRD data allows the fact tables to be rebuilt from the ODS when GRD data errors are corrected.
            /*           2. Ensures consistency when reducing outstanding quantity and weight from invoice.
            /*-*/
            rcd_dlvry_fact.req_qty := var_dlvry_type_factor * rcd_trace.allocated_qty;
            dw_utility.pkg_qty_fact.ods_matl_code := rcd_dlvry_fact.ods_matl_code;
            dw_utility.pkg_qty_fact.uom_code := rcd_dlvry_fact.dlvry_uom_code;
            dw_utility.pkg_qty_fact.uom_qty := rcd_dlvry_fact.req_qty;
            dw_utility.calculate_quantity;
            rcd_dlvry_fact.dlvry_base_uom_code := dw_utility.pkg_qty_fact.base_uom_code;
            rcd_dlvry_fact.req_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
            rcd_dlvry_fact.req_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
            rcd_dlvry_fact.req_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

            /*-*/
            /* Calculate the requested GSV values
            /*-*/
            if not(rcd_dlvry_fact.order_doc_num is null) then
               if rcd_order_fact.ord_qty != 0 then
                  rcd_dlvry_fact.req_gsv_xactn := round(var_dlvry_type_factor * ((rcd_order_fact.ord_gsv_xactn / rcd_order_fact.ord_qty) * rcd_trace.allocated_qty), 2);
                  rcd_dlvry_fact.req_gsv := round(var_dlvry_type_factor * ((rcd_order_fact.ord_gsv / rcd_order_fact.ord_qty) * rcd_trace.allocated_qty), 2);
                  rcd_dlvry_fact.req_gsv_aud := round(var_dlvry_type_factor * ((rcd_order_fact.ord_gsv_aud / rcd_order_fact.ord_qty) * rcd_trace.allocated_qty), 2);
                  rcd_dlvry_fact.req_gsv_usd := round(var_dlvry_type_factor * ((rcd_order_fact.ord_gsv_usd / rcd_order_fact.ord_qty) * rcd_trace.allocated_qty), 2);
                  rcd_dlvry_fact.req_gsv_eur := round(var_dlvry_type_factor * ((rcd_order_fact.ord_gsv_eur / rcd_order_fact.ord_qty) * rcd_trace.allocated_qty), 2);
               end if;
            end if;
            if not(rcd_dlvry_fact.purch_order_doc_num is null) then
               if rcd_purch_order_fact.ord_qty != 0 then
                  rcd_dlvry_fact.req_gsv_xactn := round(var_dlvry_type_factor * ((rcd_purch_order_fact.ord_gsv_xactn / rcd_purch_order_fact.ord_qty) * rcd_trace.allocated_qty), 2);
                  rcd_dlvry_fact.req_gsv := round(var_dlvry_type_factor * ((rcd_purch_order_fact.ord_gsv / rcd_purch_order_fact.ord_qty) * rcd_trace.allocated_qty), 2);
                  rcd_dlvry_fact.req_gsv_aud := round(var_dlvry_type_factor * ((rcd_purch_order_fact.ord_gsv_aud / rcd_purch_order_fact.ord_qty) * rcd_trace.allocated_qty), 2);
                  rcd_dlvry_fact.req_gsv_usd := round(var_dlvry_type_factor * ((rcd_purch_order_fact.ord_gsv_usd / rcd_purch_order_fact.ord_qty) * rcd_trace.allocated_qty), 2);
                  rcd_dlvry_fact.req_gsv_eur := round(var_dlvry_type_factor * ((rcd_purch_order_fact.ord_gsv_eur / rcd_purch_order_fact.ord_qty) * rcd_trace.allocated_qty), 2);
               end if;
            end if;

            /*-*/
            /* Calculate the delivered quantity values
            /* **notes** 1. Recalculation from the material GRD data allows the fact tables to be rebuilt from the ODS when GRD data errors are corrected.
            /*           2. Ensures consistency when reducing outstanding quantity and weight from  invoice.
            /*-*/
            rcd_dlvry_fact.del_qty := var_dlvry_type_factor * rcd_trace.dlvry_qty;
            dw_utility.pkg_qty_fact.ods_matl_code := rcd_dlvry_fact.ods_matl_code;
            dw_utility.pkg_qty_fact.uom_code := rcd_dlvry_fact.dlvry_uom_code;
            dw_utility.pkg_qty_fact.uom_qty := rcd_dlvry_fact.del_qty;
            dw_utility.calculate_quantity;
            rcd_dlvry_fact.dlvry_base_uom_code := dw_utility.pkg_qty_fact.base_uom_code;
            rcd_dlvry_fact.del_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
            rcd_dlvry_fact.del_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
            rcd_dlvry_fact.del_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

            /*-*/
            /* Calculate the delivered GSV values
            /*-*/
            if not(rcd_dlvry_fact.order_doc_num is null) then
               if rcd_order_fact.ord_qty != 0 then
                  rcd_dlvry_fact.del_gsv_xactn := round(var_dlvry_type_factor * ((rcd_order_fact.ord_gsv_xactn / rcd_order_fact.ord_qty) * rcd_trace.dlvry_qty), 2);
                  rcd_dlvry_fact.del_gsv := round(var_dlvry_type_factor * ((rcd_order_fact.ord_gsv / rcd_order_fact.ord_qty) * rcd_trace.dlvry_qty), 2);
                  rcd_dlvry_fact.del_gsv_aud := round(var_dlvry_type_factor * ((rcd_order_fact.ord_gsv_aud / rcd_order_fact.ord_qty) * rcd_trace.dlvry_qty), 2);
                  rcd_dlvry_fact.del_gsv_usd := round(var_dlvry_type_factor * ((rcd_order_fact.ord_gsv_usd / rcd_order_fact.ord_qty) * rcd_trace.dlvry_qty), 2);
                  rcd_dlvry_fact.del_gsv_eur := round(var_dlvry_type_factor * ((rcd_order_fact.ord_gsv_eur / rcd_order_fact.ord_qty) * rcd_trace.dlvry_qty), 2);
               end if;
            end if;
            if not(rcd_dlvry_fact.purch_order_doc_num is null) then
               if rcd_purch_order_fact.ord_qty != 0 then
                  rcd_dlvry_fact.del_gsv_xactn := round(var_dlvry_type_factor * ((rcd_purch_order_fact.ord_gsv_xactn / rcd_purch_order_fact.ord_qty) * rcd_trace.dlvry_qty), 2);
                  rcd_dlvry_fact.del_gsv := round(var_dlvry_type_factor * ((rcd_purch_order_fact.ord_gsv / rcd_purch_order_fact.ord_qty) * rcd_trace.dlvry_qty), 2);
                  rcd_dlvry_fact.del_gsv_aud := round(var_dlvry_type_factor * ((rcd_purch_order_fact.ord_gsv_aud / rcd_purch_order_fact.ord_qty) * rcd_trace.dlvry_qty), 2);
                  rcd_dlvry_fact.del_gsv_usd := round(var_dlvry_type_factor * ((rcd_purch_order_fact.ord_gsv_usd / rcd_purch_order_fact.ord_qty) * rcd_trace.dlvry_qty), 2);
                  rcd_dlvry_fact.del_gsv_eur := round(var_dlvry_type_factor * ((rcd_purch_order_fact.ord_gsv_eur / rcd_purch_order_fact.ord_qty) * rcd_trace.dlvry_qty), 2);
               end if;
            end if;

            /*---------------------*/
            /* DLVRY_FACT Creation */
            /*---------------------*/

            /*-*/
            /* Insert the delivery fact row
            /*-*/
            insert into dw_dlvry_base values rcd_dlvry_fact;

            /*-------------------*/
            /* DLVRY_FACT Status */
            /*-------------------*/

            /*-*/
            /* Update the delivery fact status
            /*-*/
            dw_utility.dlvry_fact_status(rcd_dlvry_fact.dlvry_doc_num, rcd_dlvry_fact.dlvry_doc_line_num);

            /*-------------------*/
            /* ORDER_FACT Status */
            /*-------------------*/

            /*-*/
            /* Update the order fact status when required
            /* **notes**
            /* 1. A deadly embrace with triggered aggregation is avoided by both
            /*    triggered and scheduled aggregation using the same process isolation locking
            /*    string and sharing the same ICS stream code
            /*-*/
            if not(rcd_dlvry_fact.order_doc_num is null) then
               dw_utility.order_fact_status(rcd_dlvry_fact.order_doc_num, rcd_dlvry_fact.order_doc_line_num);
            end if;

            /*-------------------------*/
            /* PURCH_ORDER_FACT Status */
            /*-------------------------*/

            /*-*/
            /* Update the purchase order fact status when required
            /* **notes**
            /* 1. A deadly embrace with triggered aggregation is avoided by both
            /*    triggered and scheduled aggregation using the same process isolation locking
            /*    string and sharing the same ICS stream code
            /*-*/
            if not(rcd_dlvry_fact.purch_order_doc_num is null) then
               dw_utility.purch_order_fact_status(rcd_dlvry_fact.purch_order_doc_num, rcd_dlvry_fact.purch_order_doc_line_num);
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
      lics_logging.write_log('End - DLVRY_FACT Load');

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
            lics_logging.write_log('**ERROR** - DLVRY_FACT Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - DLVRY_FACT Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end dlvry_fact_load;

end dw_scheduled_aggregation;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_scheduled_aggregation for dw_app.dw_scheduled_aggregation;
grant execute on dw_scheduled_aggregation to public;
