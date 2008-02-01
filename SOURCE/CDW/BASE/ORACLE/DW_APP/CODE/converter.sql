/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : converter
 Owner   : dw_app

 Description
 -----------
 CLIO - Converter

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package converter as

   /**/
   /* Public declarations
   /**/
   procedure execute_purch_order_trace;
   procedure execute_order_trace;
   procedure execute_dlvry_trace;
   procedure execute_sales_trace;
   procedure execute_purch_order_fact;
   procedure execute_order_fact;
   procedure execute_dlvry_fact;
   procedure execute_sales_fact;

end converter;
/

/****************/
/* Package Body */
/****************/
create or replace package body converter as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /********************************************************************/
   /* This procedure performs the execute purchase order trace routine */
   /********************************************************************/
   procedure execute_purch_order_trace is

      /*-*/
      /* Local variables
      /*-*/
      rcd_sap_sto_po_trace sap_sto_po_trace%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_ods_list is
         select t01.belnr
           from sap_sto_po_hdr t01
          order by t01.belnr;
      rcd_ods_list csr_ods_list%rowtype;

      cursor csr_ods_data is
         select t01.purch_order_doc_num,
                t01.currcy_code,
                t01.exch_rate,
                t01.purch_order_reasn_code,
                t02.creatn_date,
                t02.creatn_yyyyppdd,
                t02.creatn_yyyyppw,
                t02.creatn_yyyypp,
                t02.creatn_yyyymm,
                t02.purch_order_eff_date,
                t02.purch_order_eff_yyyyppdd,
                t02.purch_order_eff_yyyyppw,
                t02.purch_order_eff_yyyypp,
                t02.purch_order_eff_yyyymm,
                t03.purch_order_type_code,
                t03.purchg_company_code,
                t04.vendor_code,
                t04.vendor_reference,
                t04.sold_to_reference,
                t04.sales_org_code,
                t04.distbn_chnl_code,
                t04.division_code,
                t05.purch_order_doc_line_num,
                t05.purch_order_uom_code,
                t05.plant_code,
                t05.storage_locn_code,
                t05.purch_order_usage_code,
                t05.purch_order_qty,
                t05.purch_order_gsv,
                t05.purch_order_gross_weight,
                t05.purch_order_net_weight,
                t05.purch_order_weight_unit,
                t05.cust_code,
                t06.matl_code,
                t07.confirmed_qty,
                t07.confirmed_date,
                t07.confirmed_yyyyppdd,
                t07.confirmed_yyyyppw,
                t07.confirmed_yyyypp,
                t07.confirmed_yyyymm
          from --
               -- Purchase order header information
               --
               (select t01.belnr,
                       t01.belnr as purch_order_doc_num,
                       t01.curcy as currcy_code,
                       nvl(dw_to_number(t01.wkurs),1) as exch_rate,
                       t01.augru as purch_order_reasn_code
                  from sap_sto_po_hdr t01
                 where t01.belnr = rcd_ods_list.belnr) t01,
               --
               -- Purchase order date information
               --
               (select t01.belnr,
                       t01.purch_order_eff_date as purch_order_eff_date,
                       t01.creatn_date as creatn_date,
                       t02.mars_yyyyppdd as purch_order_eff_yyyyppdd,
                       t02.mars_week as purch_order_eff_yyyyppw,
                       t02.mars_period as purch_order_eff_yyyypp,
                       (t02.year_num * 100) + t02.month_num as purch_order_eff_yyyymm,
                       t03.mars_yyyyppdd as creatn_yyyyppdd,
                       t03.mars_week as creatn_yyyyppw,
                       t03.mars_period as creatn_yyyypp,
                       (t03.year_num * 100) + t03.month_num as creatn_yyyymm
                  from (select t01.belnr as belnr,
                               max(case when t01.iddat = '012' then dw_to_date(t01.datum,'yyyymmdd') end) as purch_order_eff_date,
                               max(case when t01.iddat = '011' then dw_to_date(t01.datum,'yyyymmdd') end) as creatn_date
                          from sap_sto_po_dat t01
                         where t01.belnr = rcd_ods_list.belnr
                           and t01.iddat in ('012','011')
                         group by t01.belnr) t01,
                       mars_date t02,
                       mars_date t03
                 where t01.purch_order_eff_date = t02.calendar_date(+)
                   and t01.creatn_date = t03.calendar_date(+)) t02,
               --
               -- Purchase order organisation information
               --
               (select t01.belnr,
                       max(case when t01.qualf = '013' then t01.orgid end) as purch_order_type_code,
                       max(case when t01.qualf = '011' then t01.orgid end) as purchg_company_code
                  from sap_sto_po_org t01
                 where t01.belnr = rcd_ods_list.belnr
                   and t01.qualf in ('013','011')
                 group by t01.belnr) t03,
               --
               -- Purchase order partner information
               --
               (select t01.belnr,
                       t01.vendor_code,
                       t01.vendor_reference,
                       t01.sold_to_reference,
                       t03.sales_org_code,
                       t03.distbn_chnl_code,
                       t03.division_code
                  from (select t01.belnr,
                               max(case when t01.parvw = 'LF' then t01.partn end) as vendor_code,
                               max(case when t01.parvw = 'LF' then t01.ihrez end) as vendor_reference,
                               max(case when t01.parvw = 'AG' then t01.ihrez end) as sold_to_reference
                          from sap_sto_po_pnr t01
                         where t01.belnr = rcd_ods_list.belnr
                           and t01.parvw in ('LF','AG')
                         group by t01.belnr) t01,
                       (select lifnr,
                               max(t01.kunnr) as kunnr
                          from sap_cus_hdr t01
                         group by t01.lifnr) t02,
                       (select trim(substr(t01.z_data,42,10)) as cust_code,
                               trim(substr(t01.z_data,173,3)) as sales_org_code,
                               trim(substr(t01.z_data,223,2)) as distbn_chnl_code,
                               trim(substr(t01.z_data,225,2)) as division_code
                          from sap_ref_dat t01
                         where t01.z_tabname = 'T001W') t03
                 where t01.vendor_code = t02.lifnr(+)
                   and t02.kunnr = t03.cust_code(+)) t04,
               --
               -- Purchase order line information
               --
               (select t01.belnr,
                       t01.genseq,
                       t01.purch_order_doc_line_num,
                       t01.purch_order_uom_code,
                       t01.plant_code,
                       t01.storage_locn_code,
                       t01.purch_order_usage_code,
                       t01.purch_order_qty,
                       t01.purch_order_gsv,
                       t01.purch_order_gross_weight,
                       t01.purch_order_net_weight,
                       t01.purch_order_weight_unit,
                       t02.cust_code
                  from (select t01.belnr,
                               t01.genseq,
                               t01.posex as purch_order_doc_line_num,
                               t01.menee as purch_order_uom_code,
                               t01.werks as plant_code,
                               t01.lgort as storage_locn_code,
                               t01.abrvw as purch_order_usage_code,
                               nvl(dw_to_number(t01.menge),0) as purch_order_qty,
                               nvl(dw_to_number(t01.netwr),0) as purch_order_gsv,
                               nvl(dw_to_number(t01.brgew),0) as purch_order_gross_weight,
                               nvl(dw_to_number(t01.ntgew),0) as purch_order_net_weight,
                               t01.gewei as purch_order_weight_unit
                          from sap_sto_po_gen t01
                         where t01.belnr = rcd_ods_list.belnr) t01,
                       (select trim(substr(t01.z_data,4,4)) as plant_code,
                               trim(substr(t01.z_data,42,10)) as cust_code
                          from sap_ref_dat t01
                         where t01.z_tabname = 'T001W') t02
                 where t01.plant_code = t02.plant_code(+)) t05,
               --
               -- Purchase order line identifier information
               --
               (select t01.belnr,
                       t01.genseq,
                       max(case when t01.qualf = '001' then t01.idtnr end) as matl_code
                  from sap_sto_po_oid t01
                 where t01.belnr = rcd_ods_list.belnr
                   and t01.qualf in ('001')
                 group by t01.belnr, t01.genseq) t06,
               --
               -- Purchase order line schedule information
               --
               (select t01.belnr,
                       t01.genseq,
                       t01.confirmed_qty as confirmed_qty,
                       t01.confirmed_date as confirmed_date,
                       t02.mars_yyyyppdd as confirmed_yyyyppdd,
                       t02.mars_week as confirmed_yyyyppw,
                       t02.mars_period as confirmed_yyyypp,
                       (t02.year_num * 100) + t02.month_num as confirmed_yyyymm
                  from (select t01.belnr as belnr,
                               t01.genseq as genseq,
                               sum(nvl(dw_to_number(t01.wmeng),0)) as confirmed_qty,
                               max(dw_to_date(t01.edatu,'yyyymmdd')) as confirmed_date
                          from sap_sto_po_sch t01
                         where t01.belnr = par_belnr
                         group by t01.belnr, t01.genseq) t01,
                       mars_date t02
                 where t01.confirmed_date = t02.calendar_date(+)) t07
         --
         -- Joins
         --
         where t01.belnr = t02.belnr(+)
           and t01.belnr = t03.belnr(+)
           and t01.belnr = t04.belnr(+)
           and t01.belnr = t05.belnr(+)
           and t05.belnr = t06.belnr(+)
           and t05.genseq = t06.genseq(+)
           and t05.belnr = t07.belnr(+)
           and t05.genseq = t07.genseq(+);
      rcd_ods_data csr_ods_data%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the purchase orders
      /*-*/
      open csr_ods_list;
      loop
         fetch csr_ods_list into rcd_ods_list;
         if csr_ods_list%notfound then
            exit;
         end if;

         /*-*/
         /* Initialise the purchase order trace data (converted data has a zero sequence)
         /*-*/
         rcd_sap_sto_po_trace.trace_seqn := 0;
         rcd_sap_sto_po_trace.trace_date := sysdate;
         rcd_sap_sto_po_trace.trace_status := '*ACTIVE';

         /*-*/
         /* Retrieve the purchase order trace detail
         /*-*/
         open csr_ods_data;
         loop
            fetch csr_ods_data into rcd_ods_data;
            if csr_ods_data%notfound then
               exit;
            end if;

            /*-*/
            /* Set the trace status
            /*-*/
            rcd_sap_sto_po_trace.trace_status := '*ACTIVE';
            if not(rcd_ods_data.vendor_reference is null) then
               rcd_sap_sto_po_trace.trace_status := '*EXCLUDED';
            end if;
            if upper(rcd_ods_data.sold_to_reference) = '*DELETED' then
               rcd_sap_sto_po_trace.trace_status := '*DELETED';
            end if;

            /*-*/
            /* Initialise the purchase order trace row
            /*-*/
            rcd_sap_sto_po_trace.company_code := rcd_ods_data.sales_org_code;
            rcd_sap_sto_po_trace.purch_order_doc_num := rcd_ods_data.purch_order_doc_num;
            rcd_sap_sto_po_trace.currcy_code := rcd_ods_data.currcy_code;
            rcd_sap_sto_po_trace.exch_rate := rcd_ods_data.exch_rate;
            rcd_sap_sto_po_trace.purch_order_reasn_code := rcd_ods_data.purch_order_reasn_code;
            rcd_sap_sto_po_trace.creatn_date := rcd_ods_data.creatn_date;
            rcd_sap_sto_po_trace.creatn_yyyyppdd := rcd_ods_data.creatn_yyyyppdd;
            rcd_sap_sto_po_trace.creatn_yyyyppw := rcd_ods_data.creatn_yyyyppw;
            rcd_sap_sto_po_trace.creatn_yyyypp := rcd_ods_data.creatn_yyyypp;
            rcd_sap_sto_po_trace.creatn_yyyymm := rcd_ods_data.creatn_yyyymm;
            rcd_sap_sto_po_trace.purch_order_eff_date := rcd_ods_data.purch_order_eff_date;
            rcd_sap_sto_po_trace.purch_order_eff_yyyyppdd := rcd_ods_data.purch_order_eff_yyyyppdd;
            rcd_sap_sto_po_trace.purch_order_eff_yyyyppw := rcd_ods_data.purch_order_eff_yyyyppw;
            rcd_sap_sto_po_trace.purch_order_eff_yyyypp := rcd_ods_data.purch_order_eff_yyyypp;
            rcd_sap_sto_po_trace.purch_order_eff_yyyymm := rcd_ods_data.purch_order_eff_yyyymm;
            rcd_sap_sto_po_trace.purch_order_type_code := rcd_ods_data.purch_order_type_code;
            rcd_sap_sto_po_trace.purchg_company_code := rcd_ods_data.purchg_company_code;
            rcd_sap_sto_po_trace.vendor_code := rcd_ods_data.vendor_code;
            rcd_sap_sto_po_trace.sales_org_code := rcd_ods_data.sales_org_code;
            rcd_sap_sto_po_trace.distbn_chnl_code := rcd_ods_data.distbn_chnl_code;
            rcd_sap_sto_po_trace.division_code := rcd_ods_data.division_code;
            rcd_sap_sto_po_trace.purch_order_doc_line_num := rcd_ods_data.purch_order_doc_line_num;
            rcd_sap_sto_po_trace.purch_order_uom_code := rcd_ods_data.purch_order_uom_code;
            rcd_sap_sto_po_trace.plant_code := rcd_ods_data.plant_code;
            rcd_sap_sto_po_trace.storage_locn_code := rcd_ods_data.storage_locn_code;
            rcd_sap_sto_po_trace.purch_order_usage_code := rcd_ods_data.purch_order_usage_code;
            rcd_sap_sto_po_trace.purch_order_qty := rcd_ods_data.purch_order_qty;
            rcd_sap_sto_po_trace.purch_order_gsv := rcd_ods_data.purch_order_gsv;
            rcd_sap_sto_po_trace.purch_order_gross_weight := rcd_ods_data.purch_order_gross_weight;
            rcd_sap_sto_po_trace.purch_order_net_weight := rcd_ods_data.purch_order_net_weight;
            rcd_sap_sto_po_trace.purch_order_weight_unit := rcd_ods_data.purch_order_weight_unit;
            rcd_sap_sto_po_trace.cust_code := rcd_ods_data.cust_code;
            rcd_sap_sto_po_trace.matl_code := rcd_ods_data.matl_code;
            rcd_sap_sto_po_trace.confirmed_qty := rcd_ods_data.confirmed_qty;
            rcd_sap_sto_po_trace.confirmed_date := rcd_ods_data.confirmed_date;
            rcd_sap_sto_po_trace.confirmed_yyyyppdd := rcd_ods_data.confirmed_yyyyppdd;
            rcd_sap_sto_po_trace.confirmed_yyyyppw := rcd_ods_data.confirmed_yyyyppw;
            rcd_sap_sto_po_trace.confirmed_yyyypp := rcd_ods_data.confirmed_yyyypp;
            rcd_sap_sto_po_trace.confirmed_yyyymm := rcd_ods_data.confirmed_yyyymm;

            /*-*/
            /* Insert the purchase order trace row
            /*-*/
            insert into sap_sto_po_trace values rcd_sap_sto_po_trace;

         end loop;
         close csr_ods_data;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_ods_list;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_purch_order_trace;

   /***********************************************************/
   /* This procedure performs the execute order trace routine */
   /***********************************************************/
   procedure execute_order_trace is

      /*-*/
      /* Local variables
      /*-*/
      rcd_sap_sal_ord_trace sap_sal_ord_trace%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_ods_list is
         select t01.belnr
           from sap_sal_ord_hdr t01
          order by t01.belnr;
      rcd_ods_list csr_ods_list%rowtype;

      cursor csr_ods_data is
         select t01.order_doc_num,
                t01.currcy_code,
                t01.exch_rate,
                t01.order_reasn_code,
                t02.creatn_date,
                t02.creatn_yyyyppdd,
                t02.creatn_yyyyppw,
                t02.creatn_yyyypp,
                t02.creatn_yyyymm,
                t02.order_eff_date,
                t02.order_eff_yyyyppdd,
                t02.order_eff_yyyyppw,
                t02.order_eff_yyyypp,
                t02.order_eff_yyyymm,
                t03.order_type_code,
                t03.sales_org_code,
                t03.distbn_chnl_code,
                t03.division_code,
                t04.hdr_sold_to_cust_code,
                t04.hdr_bill_to_cust_code,
                t04.hdr_payer_cust_code,
                t04.hdr_ship_to_cust_code,
                t05.order_doc_line_num,
                t05.order_uom_code,
                t05.plant_code,
                t05.storage_locn_code,
                t05.order_usage_code,
                t05.order_line_rejectn_code,
                t05.order_qty,
                t05.order_gross_weight,
                t05.order_net_weight,
                t05.order_weight_unit,
                t06.cust_order_doc_num,
                t06.cust_order_doc_line_num,
                t06.cust_order_due_date,
                t07.matl_code,
                t07.matl_entd,
                t08.confirmed_qty,
                t08.confirmed_date,
                t08.confirmed_yyyyppdd,
                t08.confirmed_yyyyppw,
                t08.confirmed_yyyypp,
                t08.confirmed_yyyymm,
                t09.gen_sold_to_cust_code,
                t09.gen_bill_to_cust_code,
                t09.gen_payer_cust_code,
                t09.gen_ship_to_cust_code,
                t10.order_gsv
          from --
               -- Sales order header information
               --
               (select t01.belnr,
                       t01.belnr as order_doc_num,
                       t01.curcy as currcy_code,
                       nvl(dw_to_number(t01.wkurs),1) as exch_rate,
                       t01.augru as order_reasn_code
                  from sap_sal_ord_hdr t01
                 where t01.belnr = rcd_ods_list.belnr) t01,
               --
               -- Sales order date information
               --
               (select t01.belnr,
                       t01.order_eff_date as order_eff_date,
                       t01.creatn_date as creatn_date,
                       t02.mars_yyyyppdd as order_eff_yyyyppdd,
                       t02.mars_week as order_eff_yyyyppw,
                       t02.mars_period as order_eff_yyyypp,
                       (t02.year_num * 100) + t02.month_num as order_eff_yyyymm,
                       t03.mars_yyyyppdd as creatn_yyyyppdd,
                       t03.mars_week as creatn_yyyyppw,
                       t03.mars_period as creatn_yyyypp,
                       (t03.year_num * 100) + t03.month_num as creatn_yyyymm
                  from (select t01.belnr as belnr,
                               max(case when t01.iddat = '002' then dw_to_date(t01.datum,'yyyymmdd') end) as order_eff_date,
                               max(case when t01.iddat = '025' then trunc(dw_to_timezone(dw_to_date(t01.datum||t01.uzeit,'yyyymmddhh24miss'),'Australia/Victoria','America/New_York')) end) as creatn_date
                          from sap_sal_ord_dat t01
                         where t01.belnr = rcd_ods_list.belnr
                           and t01.iddat in ('002','025')
                         group by t01.belnr) t01,
                       mars_date t02,
                       mars_date t03
                 where t01.order_eff_date = t02.calendar_date(+)
                   and t01.creatn_date = t03.calendar_date(+)) t02,
               --
               -- Sales order organisation information
               --
               (select t01.belnr,
                       max(case when t01.qualf = '012' then t01.orgid end) as order_type_code,
                       max(case when t01.qualf = '008' then t01.orgid end) as sales_org_code,
                       max(case when t01.qualf = '007' then t01.orgid end) as distbn_chnl_code,
                       max(case when t01.qualf = '006' then t01.orgid end) as division_code
                  from sap_sal_ord_org t01
                 where t01.belnr = rcd_ods_list.belnr
                   and t01.qualf in ('006','007','008','012')
                 group by t01.belnr) t03,
               --
               -- Sales order partner information
               --
               (select t01.belnr,
                       max(case when t01.parvw = 'AG' then t01.partn end) as hdr_sold_to_cust_code,
                       max(case when t01.parvw = 'RE' then t01.partn end) as hdr_bill_to_cust_code,
                       max(case when t01.parvw = 'RG' then t01.partn end) as hdr_payer_cust_code,
                       max(case when t01.parvw = 'WE' then t01.partn end) as hdr_ship_to_cust_code
                  from sap_sal_ord_pnr t01
                 where t01.belnr = rcd_ods_list.belnr
                   and t01.parvw in ('AG','RE','RG','WE')
                 group by t01.belnr) t04,
               --
               -- Sales order line information
               --
               (select t01.belnr,
                       t01.genseq,
                       t01.posex as order_doc_line_num,
                       t01.menee as order_uom_code,
                       t01.werks as plant_code,
                       t01.lgort as storage_locn_code,
                       t01.abrvw as order_usage_code,
                       t01.abgru as order_line_rejectn_code,
                       nvl(dw_to_number(t01.menge),0) as order_qty,
                       nvl(dw_to_number(t01.brgew),0) as order_gross_weight,
                       nvl(dw_to_number(t01.ntgew),0) as order_net_weight,
                       t01.gewei as order_weight_unit
                  from sap_sal_ord_gen t01
                 where t01.belnr = rcd_ods_list.belnr
                   and not(t01.pstyv in ('ZAPS','ZAPA'))
                   and nvl(dw_to_number(t01.menge),0) != 0) t05,
               --
               -- Sales order line reference information
               --
               (select t01.belnr,
                       t01.genseq,
                       max(case when t01.qualf = '001' then t01.refnr end) as cust_order_doc_num,
                       max(case when t01.qualf = '001' then t01.zeile end) as cust_order_doc_line_num,
                       max(case when t01.qualf = '001' then dw_to_date(t01.datum,'yyyymmdd') end) as cust_order_due_date
                  from sap_sal_ord_irf t01
                 where t01.belnr = rcd_ods_list.belnr
                   and t01.qualf in ('001')
                 group by t01.belnr, t01.genseq) t06,
               --
               -- Sales order line identifier information
               --
               (select t01.belnr,
                       t01.genseq,
                       max(case when t01.qualf = '002' then t01.idtnr end) as matl_code,
                       max(case when t01.qualf = 'Z01' then t01.idtnr end) as matl_entd
                  from sap_sal_ord_iid t01
                 where t01.belnr = rcd_ods_list.belnr
                   and t01.qualf in ('002','Z01')
                 group by t01.belnr, t01.genseq) t07,
               --
               -- Sales order line schedule information
               --
               (select t01.belnr,
                       t01.genseq,
                       t01.confirmed_qty as confirmed_qty,
                       t01.confirmed_date as confirmed_date,
                       t02.mars_yyyyppdd as confirmed_yyyyppdd,
                       t02.mars_week as confirmed_yyyyppw,
                       t02.mars_period as confirmed_yyyypp,
                       (t02.year_num * 100) + t02.month_num as confirmed_yyyymm
                  from (select t01.belnr as belnr,
                               t01.genseq as genseq,
                               sum(nvl(dw_to_number(t01.wmeng),0)) as confirmed_qty,
                               max(dw_to_date(t01.edatu,'yyyymmdd')) as confirmed_date
                          from sap_sal_ord_isc t01
                         where t01.belnr = rcd_ods_list.belnr
                         group by t01.belnr, t01.genseq) t01,
                       mars_date t02
                 where t01.confirmed_date = t02.calendar_date(+)) t08,
               --
               -- Sales order line partner information
               --
               (select t01.belnr,
                       t01.genseq,
                       max(case when t01.parvw = 'AG' then t01.partn end) as gen_sold_to_cust_code,
                       max(case when t01.parvw = 'RE' then t01.partn end) as gen_bill_to_cust_code,
                       max(case when t01.parvw = 'RG' then t01.partn end) as gen_payer_cust_code,
                       max(case when t01.parvw = 'WE' then t01.partn end) as gen_ship_to_cust_code
                  from sap_sal_ord_ipn t01
                 where t01.belnr = rcd_ods_list.belnr
                   and t01.parvw in ('AG','RE','RG','WE')
                 group by t01.belnr, t01.genseq) t09,
               --
               -- Sales order line value information
               --
               (select t01.belnr,
                       t01.genseq,
                       sum(order_gsv) as order_gsv
                  from (select t01.belnr,
                               t01.genseq,
                               decode(t01.alckz,'-',-1,1)*nvl(dw_to_number(t01.betrg),0) as order_gsv
                          from sap_sal_ord_ico t01
                         where t01.belnr = rcd_ods_list.belnr
                           and (upper(t01.kschl) = 'ZV01' or
                                upper(t01.kotxt) = 'GSV')
                         union all
                        select t01.belnr,
                               t01.genseq,
                               decode(t01.alckz,'-',-1,1)*nvl(dw_to_number(t01.betrg),0) as order_gsv
                          from sap_sal_ord_ico t01,
                               (select t01.belnr,
                                       t01.genseq
                                  from sap_sal_ord_ico t01
                                 where t01.belnr = rcd_ods_list.belnr
                                   and upper(t01.kschl) = 'ZZ01') t02
                         where t01.belnr = t02.belnr
                           and t01.genseq = t02.genseq
                           and t01.belnr = par_belnr
                           and upper(t01.kotxt) = 'GROSS VALUE') t01
                 group by t01.belnr, t01.genseq) t10
         --
         -- Joins
         --
         where t01.belnr = t02.belnr(+)
           and t01.belnr = t03.belnr(+)
           and t01.belnr = t04.belnr(+)
           and t01.belnr = t05.belnr(+)
           and t05.belnr = t06.belnr(+)
           and t05.genseq = t06.genseq(+)
           and t05.belnr = t07.belnr(+)
           and t05.genseq = t07.genseq(+)
           and t05.belnr = t08.belnr(+)
           and t05.genseq = t08.genseq(+)
           and t05.belnr = t09.belnr(+)
           and t05.genseq = t09.genseq(+)
           and t05.belnr = t10.belnr(+)
           and t05.genseq = t10.genseq(+);
      rcd_ods_data csr_ods_data%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the sales orders
      /*-*/
      open csr_ods_list;
      loop
         fetch csr_ods_list into rcd_ods_list;
         if csr_ods_list%notfound then
            exit;
         end if;

         /*-*/
         /* Initialise the sales order trace data (converted data has a zero sequence)
         /*-*/
         rcd_sap_sal_ord_trace.trace_seqn := 0;
         rcd_sap_sal_ord_trace.trace_date := sysdate;
         rcd_sap_sal_ord_trace.trace_status := '*ACTIVE';

         /*-*/
         /* Retrieve the sales order trace detail
         /*-*/
         open csr_ods_data;
         loop
            fetch csr_ods_data into rcd_ods_data;
            if csr_ods_data%notfound then
               exit;
            end if;

            /*-*/
            /* Initialise the sales order trace row
            /*-*/
            rcd_sap_sal_ord_trace.company_code := rcd_ods_data.sales_org_code;
            rcd_sap_sal_ord_trace.order_doc_num := rcd_ods_data.order_doc_num;
            rcd_sap_sal_ord_trace.currcy_code := rcd_ods_data.currcy_code;
            rcd_sap_sal_ord_trace.exch_rate := rcd_ods_data.exch_rate;
            rcd_sap_sal_ord_trace.order_reasn_code := rcd_ods_data.order_reasn_code;
            rcd_sap_sal_ord_trace.creatn_date := rcd_ods_data.creatn_date;
            rcd_sap_sal_ord_trace.creatn_yyyyppdd := rcd_ods_data.creatn_yyyyppdd;
            rcd_sap_sal_ord_trace.creatn_yyyyppw := rcd_ods_data.creatn_yyyyppw;
            rcd_sap_sal_ord_trace.creatn_yyyypp := rcd_ods_data.creatn_yyyypp;
            rcd_sap_sal_ord_trace.creatn_yyyymm := rcd_ods_data.creatn_yyyymm;
            rcd_sap_sal_ord_trace.order_eff_date := rcd_ods_data.order_eff_date;
            rcd_sap_sal_ord_trace.order_eff_yyyyppdd := rcd_ods_data.order_eff_yyyyppdd;
            rcd_sap_sal_ord_trace.order_eff_yyyyppw := rcd_ods_data.order_eff_yyyyppw;
            rcd_sap_sal_ord_trace.order_eff_yyyypp := rcd_ods_data.order_eff_yyyypp;
            rcd_sap_sal_ord_trace.order_eff_yyyymm := rcd_ods_data.order_eff_yyyymm;
            rcd_sap_sal_ord_trace.order_type_code := rcd_ods_data.order_type_code;
            rcd_sap_sal_ord_trace.sales_org_code := rcd_ods_data.sales_org_code;
            rcd_sap_sal_ord_trace.distbn_chnl_code := rcd_ods_data.distbn_chnl_code;
            rcd_sap_sal_ord_trace.division_code := rcd_ods_data.division_code;
            rcd_sap_sal_ord_trace.hdr_sold_to_cust_code := rcd_ods_data.hdr_sold_to_cust_code;
            rcd_sap_sal_ord_trace.hdr_bill_to_cust_code := rcd_ods_data.hdr_bill_to_cust_code;
            rcd_sap_sal_ord_trace.hdr_payer_cust_code := rcd_ods_data.hdr_payer_cust_code;
            rcd_sap_sal_ord_trace.hdr_ship_to_cust_code := rcd_ods_data.hdr_ship_to_cust_code;
            rcd_sap_sal_ord_trace.order_doc_line_num := rcd_ods_data.order_doc_line_num;
            rcd_sap_sal_ord_trace.order_uom_code := rcd_ods_data.order_uom_code;
            rcd_sap_sal_ord_trace.plant_code := rcd_ods_data.plant_code;
            rcd_sap_sal_ord_trace.storage_locn_code := rcd_ods_data.storage_locn_code;
            rcd_sap_sal_ord_trace.order_usage_code := rcd_ods_data.order_usage_code;
            rcd_sap_sal_ord_trace.order_line_rejectn_code := rcd_ods_data.order_line_rejectn_code;
            rcd_sap_sal_ord_trace.order_qty := rcd_ods_data.order_qty;
            rcd_sap_sal_ord_trace.order_gross_weight := rcd_ods_data.order_gross_weight;
            rcd_sap_sal_ord_trace.order_net_weight := rcd_ods_data.order_net_weight;
            rcd_sap_sal_ord_trace.order_weight_unit := rcd_ods_data.order_weight_unit;
            rcd_sap_sal_ord_trace.cust_order_doc_num := rcd_ods_data.cust_order_doc_num;
            rcd_sap_sal_ord_trace.cust_order_doc_line_num := rcd_ods_data.cust_order_doc_line_num;
            rcd_sap_sal_ord_trace.cust_order_due_date := rcd_ods_data.cust_order_due_date;
            rcd_sap_sal_ord_trace.matl_code := rcd_ods_data.matl_code;
            rcd_sap_sal_ord_trace.matl_entd := rcd_ods_data.matl_entd;
            rcd_sap_sal_ord_trace.confirmed_qty := rcd_ods_data.confirmed_qty;
            rcd_sap_sal_ord_trace.confirmed_date := rcd_ods_data.confirmed_date;
            rcd_sap_sal_ord_trace.confirmed_yyyyppdd := rcd_ods_data.confirmed_yyyyppdd;
            rcd_sap_sal_ord_trace.confirmed_yyyyppw := rcd_ods_data.confirmed_yyyyppw;
            rcd_sap_sal_ord_trace.confirmed_yyyypp := rcd_ods_data.confirmed_yyyypp;
            rcd_sap_sal_ord_trace.confirmed_yyyymm := rcd_ods_data.confirmed_yyyymm;
            rcd_sap_sal_ord_trace.gen_sold_to_cust_code := rcd_ods_data.gen_sold_to_cust_code;
            rcd_sap_sal_ord_trace.gen_bill_to_cust_code := rcd_ods_data.gen_bill_to_cust_code;
            rcd_sap_sal_ord_trace.gen_payer_cust_code := rcd_ods_data.gen_payer_cust_code;
            rcd_sap_sal_ord_trace.gen_ship_to_cust_code := rcd_ods_data.gen_ship_to_cust_code;
            rcd_sap_sal_ord_trace.order_gsv := rcd_ods_data.order_gsv;

            /*-*/
            /* Insert the sales order trace row
            /*-*/
            insert into sap_sal_ord_trace values rcd_sap_sal_ord_trace;

         end loop;
         close csr_ods_data;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_ods_list;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_order_trace;

   /**************************************************************/
   /* This procedure performs the execute delivery trace routine */
   /**************************************************************/
   procedure execute_dlvry_trace is

      /*-*/
      /* Local variables
      /*-*/
      rcd_sap_del_trace sap_del_trace%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_ods_list is
         select t01.vbeln
           from sap_del_hdr t01
          order by t01.vbeln;
      rcd_ods_list csr_ods_list%rowtype;

      cursor csr_ods_data is
         select t01.dlvry_doc_num,
                t01.dlvry_type_code,
                t01.dlvry_procg_stage,
                t01.sales_org_code,
                t02.creatn_date,
                t02.creatn_yyyyppdd,
                t02.creatn_yyyyppw,
                t02.creatn_yyyypp,
                t02.creatn_yyyymm,
                t02.dlvry_eff_date,
                t02.dlvry_eff_yyyyppdd,
                t02.dlvry_eff_yyyyppw,
                t02.dlvry_eff_yyyypp,
                t02.dlvry_eff_yyyymm,
                t02.goods_issue_date,
                t02.goods_issue_yyyyppdd,
                t02.goods_issue_yyyyppw,
                t02.goods_issue_yyyypp,
                t02.goods_issue_yyyymm,
                t03.sold_to_cust_code,
                t03.bill_to_cust_code,
                t03.payer_cust_code,
                t03.ship_to_cust_code,
                t04.dlvry_doc_line_num,
                t04.matl_code,
                t04.matl_entd,
                t04.dlvry_uom_code,
                t04.dlvry_base_uom_code,
                t04.plant_code,
                t04.storage_locn_code,
                t04.distbn_chnl_code,
                t04.dlvry_qty,
                t04.allocated_qty,
                t04.ordered_qty,
                t04.dlvry_gross_weight,
                t04.dlvry_net_weight,
                t04.dlvry_weight_unit,
                t05.order_doc_num,
                t05.order_doc_line_num,
                t06.purch_order_doc_num,
                t06.purch_order_doc_line_num
          from --
               -- Delivery header information
               --
               (select t01.vbeln,
                       t01.vbeln as dlvry_doc_num,
                       t01.lfart as dlvry_type_code,
                       t01.dlvry_procg_stage as dlvry_procg_stage,
                       t01.vkorg as sales_org_code
                  from sap_del_hdr t01
                 where t01.vbeln = rcd_ods_list.vbeln) t01,
               --
               -- Delivery time information
               --
               (select t01.vbeln,
                       t01.creatn_date as creatn_date,
                       t02.mars_yyyyppdd as creatn_yyyyppdd,
                       t02.mars_week as creatn_yyyyppw,
                       t02.mars_period as creatn_yyyypp,
                       (t02.year_num * 100) + t02.month_num as creatn_yyyymm,
                       t01.dlvry_eff_date as dlvry_eff_date,
                       t03.mars_yyyyppdd as dlvry_eff_yyyyppdd,
                       t03.mars_week as dlvry_eff_yyyyppw,
                       t03.mars_period as dlvry_eff_yyyypp,
                       (t03.year_num * 100) + t03.month_num as dlvry_eff_yyyymm,
                       t01.goods_issue_date as goods_issue_date,
                       t04.mars_yyyyppdd as goods_issue_yyyyppdd,
                       t04.mars_week as goods_issue_yyyyppw,
                       t04.mars_period as goods_issue_yyyypp,
                       (t04.year_num * 100) + t04.month_num as goods_issue_yyyymm
                  from (select t01.vbeln,
                               max(case when t01.qualf = '015' then dw_to_date(nvl(ltrim(t01.isdd,'0'),ltrim(t01.ntanf,'0')),'yyyymmdd') end) as creatn_date,
                               max(case when t01.qualf = '007' then dw_to_date(nvl(ltrim(t01.isdd,'0'),ltrim(t01.ntanf,'0')),'yyyymmdd') end) as dlvry_eff_date,
                               max(case when t01.qualf = '006' then dw_to_date(nvl(ltrim(t01.isdd,'0'),ltrim(t01.ntanf,'0')),'yyyymmdd') end) as goods_issue_date
                          from sap_del_tim t01
                         where vbeln = rcd_ods_list.vbeln
                           and t01.qualf in ('006','007','015')
                         group by t01.vbeln) t01,
                       mars_date t02,
                       mars_date t03,
                       mars_date t04
                 where t01.creatn_date = t02.calendar_date(+)
                   and t01.dlvry_eff_date = t03.calendar_date(+)
                   and t01.goods_issue_date = t04.calendar_date(+)) t02,
               --
               -- Delivery partner information
               --
               (select t01.vbeln,
                       max(case when t01.partner_q = 'AG' then t01.partner_id end) as sold_to_cust_code,
                       max(case when t01.partner_q = 'RE' then t01.partner_id end) as bill_to_cust_code,
                       max(case when t01.partner_q = 'RG' then t01.partner_id end) as payer_cust_code,
                       max(case when t01.partner_q = 'WE' then t01.partner_id end) as ship_to_cust_code
                  from sap_del_add t01
                 where t01.vbeln = rcd_ods_list.vbeln
                   and t01.partner_q in ('AG','RE','RG','WE')
                 group by t01.vbeln) t03,
               --
               -- Delivery line information
               --
               (select t01.vbeln,
                       t01.detseq,
                       t01.posnr as dlvry_doc_line_num,
                       t01.matnr as matl_code,
                       t01.matwa as matl_entd,
                       t01.vrkme as dlvry_uom_code,
                       t01.meins as dlvry_base_uom_code,
                       t01.werks as plant_code,
                       t01.lgort as storage_locn_code,
                       t01.vtweg as distbn_chnl_code,
                       t01.lfimg as dlvry_qty,
                       nvl(t01.kwmeng,0) as ordered_qty,
                       t02.allocated_qty,
                       t02.dlvry_gross_weight,
                       t02.dlvry_net_weight,
                       t02.dlvry_weight_unit
                  from sap_del_det t01,
                       (select t01.vbeln,
                               t01.hipos,
                               sum(nvl(t01.zzlfimg,0)) as allocated_qty,
                               sum(nvl(t01.brgew),0) as dlvry_gross_weight,
                               sum(nvl(t01.ntgew),0) as dlvry_net_weight,
                               max(t01.gewei) as dlvry_weight_unit
                          from sap_del_det t01
                         where t01.vbeln = rcd_ods_list.vbeln
                           and t01.posnr > '900000'
                         group by t01.vbeln, t01.hipos) t02
                 where t01.vbeln = t02.vbeln(+)
                   and t01.posnr = t02.hipos(+)
                   and t01.vbeln = rcd_ods_list.vbeln
                   and nvl(t01.lfimg,0) != 0
                   and t01.posnr < '900000') t04,
               --
               -- Delivery line reference information - sales order
               --
               (select t01.vbeln,
                       t01.detseq,
                       t01.order_doc_num,
                       t01.order_doc_line_num
                  from (select t01.vbeln as vbeln,
                               t01.detseq as detseq,
                               t01.belnr as order_doc_num,
                               t01.posnr as order_doc_line_num,
                               rank() over (partition by t01.vbeln, t01.detseq order by t01.irfseq asc) as rnkseq
                          from sap_del_irf t01
                         where t01.vbeln = rcd_ods_list.vbeln
                           and t01.qualf in ('C','H','I','K','L')
                           and not(t01.belnr is null)
                           and not(t01.datum is null)) t01
                 where t01.rnkseq = 1) t05,
               --
               -- Delivery line reference information - purchase order
               --
               (select t01.vbeln,
                       t01.detseq,
                       t01.purch_order_doc_num,
                       t01.purch_order_doc_line_num
                  from (select t01.vbeln as vbeln,
                               t01.detseq as detseq,
                               t01.belnr as purch_order_doc_num,
                               t01.posnr as purch_order_doc_line_num,
                               rank() over (partition by t01.vbeln, t01.detseq order by t01.irfseq asc) as rnkseq
                          from sap_del_irf t01
                         where t01.vbeln = rcd_ods_list.vbeln
                           and t01.qualf in ('V')
                           and not(t01.belnr is null)) t01
                 where t01.rnkseq = 1) t06
         --
         -- Joins
         --
         where t01.vbeln = t02.vbeln(+)
           and t01.vbeln = t03.vbeln(+)
           and t01.vbeln = t04.vbeln(+)
           and t04.vbeln = t05.vbeln(+)
           and t04.detseq = t05.detseq(+)
           and t04.vbeln = t06.vbeln(+)
           and t04.detseq = t06.detseq(+);
      rcd_ods_data csr_ods_data%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the deliveries
      /*-*/
      open csr_ods_list;
      loop
         fetch csr_ods_list into rcd_ods_list;
         if csr_ods_list%notfound then
            exit;
         end if;

         /*-*/
         /* Initialise the delivery trace data (converted data has a zero sequence)
         /*-*/
         rcd_sap_del_trace.trace_seqn := 0;
         rcd_sap_del_trace.trace_date := sysdate;
         rcd_sap_del_trace.trace_status := '*ACTIVE';

         /*-*/
         /* Retrieve the delivery trace data
         /*-*/
         open csr_ods_data;
         loop
            fetch csr_ods_data into rcd_ods_data;
            if csr_ods_data%notfound then
               exit;
            end if;

            /*-*/
            /* Initialise the delivery trace row
            /*-*/
            rcd_sap_del_trace.company_code := rcd_ods_data.sales_org_code;
            rcd_sap_del_trace.dlvry_doc_num := rcd_ods_data.dlvry_doc_num;
            rcd_sap_del_trace.dlvry_type_code := rcd_ods_data.dlvry_type_code;
            rcd_sap_del_trace.dlvry_procg_stage := rcd_ods_data.dlvry_procg_stage;
            rcd_sap_del_trace.sales_org_code := rcd_ods_data.sales_org_code;
            rcd_sap_del_trace.creatn_date := rcd_ods_data.creatn_date;
            rcd_sap_del_trace.creatn_yyyyppdd := rcd_ods_data.creatn_yyyyppdd;
            rcd_sap_del_trace.creatn_yyyyppw := rcd_ods_data.creatn_yyyyppw;
            rcd_sap_del_trace.creatn_yyyypp := rcd_ods_data.creatn_yyyypp;
            rcd_sap_del_trace.creatn_yyyymm := rcd_ods_data.creatn_yyyymm;
            rcd_sap_del_trace.dlvry_eff_date := rcd_ods_data.dlvry_eff_date;
            rcd_sap_del_trace.dlvry_eff_yyyyppdd := rcd_ods_data.dlvry_eff_yyyyppdd;
            rcd_sap_del_trace.dlvry_eff_yyyyppw := rcd_ods_data.dlvry_eff_yyyyppw;
            rcd_sap_del_trace.dlvry_eff_yyyypp := rcd_ods_data.dlvry_eff_yyyypp;
            rcd_sap_del_trace.dlvry_eff_yyyymm := rcd_ods_data.dlvry_eff_yyyymm;
            rcd_sap_del_trace.goods_issue_date := rcd_ods_data.goods_issue_date;
            rcd_sap_del_trace.goods_issue_yyyyppdd := rcd_ods_data.goods_issue_yyyyppdd;
            rcd_sap_del_trace.goods_issue_yyyyppw := rcd_ods_data.goods_issue_yyyyppw;
            rcd_sap_del_trace.goods_issue_yyyypp := rcd_ods_data.goods_issue_yyyypp;
            rcd_sap_del_trace.goods_issue_yyyymm := rcd_ods_data.goods_issue_yyyymm;
            rcd_sap_del_trace.sold_to_cust_code := rcd_ods_data.sold_to_cust_code;
            rcd_sap_del_trace.bill_to_cust_code := rcd_ods_data.bill_to_cust_code;
            rcd_sap_del_trace.payer_cust_code := rcd_ods_data.payer_cust_code;
            rcd_sap_del_trace.ship_to_cust_code := rcd_ods_data.ship_to_cust_code;
            rcd_sap_del_trace.dlvry_doc_line_num := rcd_ods_data.dlvry_doc_line_num;
            rcd_sap_del_trace.matl_code := rcd_ods_data.matl_code;
            rcd_sap_del_trace.matl_entd := rcd_ods_data.matl_entd;
            rcd_sap_del_trace.dlvry_uom_code := rcd_ods_data.dlvry_uom_code;
            rcd_sap_del_trace.dlvry_base_uom_code := rcd_ods_data.dlvry_base_uom_code;
            rcd_sap_del_trace.plant_code := rcd_ods_data.plant_code;
            rcd_sap_del_trace.storage_locn_code := rcd_ods_data.storage_locn_code;
            rcd_sap_del_trace.distbn_chnl_code := rcd_ods_data.distbn_chnl_code;
            rcd_sap_del_trace.dlvry_qty := rcd_ods_data.dlvry_qty;
            rcd_sap_del_trace.allocated_qty := rcd_ods_data.allocated_qty;
            rcd_sap_del_trace.ordered_qty := rcd_ods_data.ordered_qty;
            rcd_sap_del_trace.dlvry_gross_weight := rcd_ods_data.dlvry_gross_weight;
            rcd_sap_del_trace.dlvry_net_weight := rcd_ods_data.dlvry_net_weight;
            rcd_sap_del_trace.dlvry_weight_unit := rcd_ods_data.dlvry_weight_unit;
            rcd_sap_del_trace.order_doc_num := rcd_ods_data.order_doc_num;
            rcd_sap_del_trace.order_doc_line_num := rcd_ods_data.order_doc_line_num;
            rcd_sap_del_trace.purch_order_doc_num := rcd_ods_data.purch_order_doc_num;
            rcd_sap_del_trace.purch_order_doc_line_num := rcd_ods_data.purch_order_doc_line_num;
            if not(rcd_sap_del_trace.purch_order_doc_line_num is null) then 
               rcd_sap_del_trace.purch_order_doc_line_num := lpad(ltrim(rcd_ods_data.purch_order_doc_line_num,'0'),5,'0');
            end if;

            /*-*/
            /* Insert the delivery trace row
            /*-*/
            insert into sap_del_trace values rcd_sap_del_trace;

         end loop;
         close csr_ods_data;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_ods_list;
   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_dlvry_trace;

   /***********************************************************/
   /* This procedure performs the execute sales trace routine */
   /***********************************************************/
   procedure execute_sales_trace is

      /*-*/
      /* Local variables
      /*-*/
      rcd_sap_inv_trace sap_inv_trace%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_ods_list is
         select t01.belnr
           from sap_inv_hdr t01
          order by t01.belnr;
      rcd_ods_list csr_ods_list%rowtype;

      cursor csr_ods_data is
         select t01.billing_doc_num,
                t01.doc_currcy_code,
                t01.exch_rate,
                t01.order_reasn_code,
                t02.creatn_date,
                t02.creatn_yyyyppdd,
                t02.creatn_yyyyppw,
                t02.creatn_yyyypp,
                t02.creatn_yyyymm,
                t02.billing_eff_date,
                t02.billing_eff_yyyyppdd,
                t02.billing_eff_yyyyppw,
                t02.billing_eff_yyyypp,
                t02.billing_eff_yyyymm,
                t03.order_type_code,
                t03.invc_type_code,
                t03.company_code,
                t03.hdr_sales_org_code,
                t03.hdr_distbn_chnl_code,
                t03.hdr_division_code,
                t04.hdr_sold_to_cust_code,
                t04.hdr_bill_to_cust_code,
                t04.hdr_payer_cust_code,
                t04.hdr_ship_to_cust_code,
                t05.billing_doc_line_num,
                t05.billed_uom_code,
                t05.billed_base_uom_code,
                t05.plant_code,
                t05.storage_locn_code,
                t05.gen_sales_org_code,
                t05.gen_distbn_chnl_code,
                t05.gen_division_code,
                t05.order_usage_code,
                t05.order_qty,
                t05.billed_qty,
                t05.billed_qty_base_uom,
                t05.billed_gross_weight,
                t05.billed_net_weight,
                t05.billed_weight_unit,
                t06.matl_code,
                t06.matl_entd,
                t07.gen_sold_to_cust_code,
                t07.gen_bill_to_cust_code,
                t07.gen_payer_cust_code,
                t07.gen_ship_to_cust_code,
                t08.order_doc_num,
                t08.order_doc_line_num,
                t08.dlvry_doc_num,
                t08.dlvry_doc_line_num,
                t09.billed_gsv
           from --
                -- Invoice header information
                --
                (select t01.belnr,
                        t01.belnr as billing_doc_num,
                        t01.curcy as doc_currcy_code,
                        nvl(dw_to_number(t01.wkurs),1) as exch_rate,
                        t01.augru as order_reasn_code
                   from sap_inv_hdr t01
                  where t01.belnr = rcd_ods_list.belnr) t01,
                --
                -- Invoice date information
                --
               (select t01.belnr,
                       t01.creatn_date as creatn_date,
                       t01.billing_eff_date as billing_eff_date,
                       t02.mars_yyyyppdd as creatn_yyyyppdd,
                       t02.mars_week as creatn_yyyyppw,
                       t02.mars_period as creatn_yyyypp,
                       (t02.year_num * 100) + t02.month_num as creatn_yyyymm,
                       t03.mars_yyyyppdd as billing_eff_yyyyppdd,
                       t03.mars_week as billing_eff_yyyyppw,
                       t03.mars_period as billing_eff_yyyypp,
                       (t03.year_num * 100) + t03.month_num as billing_eff_yyyymm
                  from (select t01.belnr as belnr,
                               max(case when t01.iddat = '015' then dw_to_date(t01.datum,'yyyymmdd') end) as creatn_date,
                               max(case when t01.iddat = '026' then dw_to_date(t01.datum,'yyyymmdd') end) as billing_eff_date
                          from sap_inv_dat t01
                         where t01.belnr = rcd_ods_list.belnr
                           and t01.iddat in ('015','026')
                         group by t01.belnr) t01,
                       mars_date t02,
                       mars_date t03
                 where t01.creatn_date = t02.calendar_date(+)
                   and t01.billing_eff_date = t03.calendar_date(+)) t02,
                --
                -- Invoice organisation information
                --
                (select t01.belnr,
                        max(case when t01.qualf = '012' then t01.orgid end) as order_type_code,
                        max(case when t01.qualf = '015' then t01.orgid end) as invc_type_code,
                        max(case when t01.qualf = '003' then t01.orgid end) as company_code,
                        max(case when t01.qualf = '008' then t01.orgid end) as hdr_sales_org_code,
                        max(case when t01.qualf = '007' then t01.orgid end) as hdr_distbn_chnl_code,
                        max(case when t01.qualf = '006' then t01.orgid end) as hdr_division_code
                   from sap_inv_org t01
                  where t01.belnr = rcd_ods_list.belnr
                    and t01.qualf in ('003','006','007','008','012','015')
                  group by t01.belnr) t03,
                --
                -- Invoice partner information
                --
                (select t01.belnr,
                        max(case when t01.parvw = 'AG' then t01.partn end) as hdr_sold_to_cust_code,
                        max(case when t01.parvw = 'RE' then t01.partn end) as hdr_bill_to_cust_code,
                        max(case when t01.parvw = 'RG' then t01.partn end) as hdr_payer_cust_code,
                        max(case when t01.parvw = 'WE' then t01.partn end) as hdr_ship_to_cust_code
                   from sap_inv_pnr t01
                  where t01.belnr = rcd_ods_list.belnr
                    and t01.parvw in ('AG','RE','RG','WE')
                  group by t01.belnr) t04,
                --
                -- Invoice line information
                --
                (select t01.belnr,
                        t01.genseq,
                        t01.posex as billing_doc_line_num,
                        t01.menee as billed_uom_code,
                        t01.meins as billed_base_uom_code,
                        t01.werks as plant_code,
                        t01.lgort as storage_locn_code,
                        t01.vkorg as gen_sales_org_code,
                        t01.vtweg as gen_distbn_chnl_code,
                        t01.spart as gen_division_code,
                        t01.abrvw as order_usage_code,
                        nvl(t01.kwmeng,0) as order_qty,
                        nvl(dw_to_number(t01.menge),0) as billed_qty,
                        nvl(dw_to_number(t01.fklmg),0) as billed_qty_base_uom,
                        nvl(dw_to_number(t01.brgew),0) as billed_gross_weight,
                        nvl(dw_to_number(t01.ntgew),0) as billed_net_weight,
                        t01.gewei as billed_weight_unit
                   from sap_inv_gen t01
                  where t01.belnr = rcd_ods_list.belnr) t05,
                --
                -- Invoice line material information
                --
                (select t01.belnr,
                        t01.genseq,
                        max(case when t01.qualf = '002' then t01.idtnr end) as matl_code,
                        max(case when t01.qualf = 'Z01' then t01.idtnr end) as matl_entd
                   from sap_inv_iob t01
                  where t01.belnr = rcd_ods_list.belnr
                    and t01.qualf in ('002','Z01')
                  group by t01.belnr,
                           t01.genseq) t06,
                --
                -- Invoice line partner information
                --
                (select t01.belnr,
                        t01.genseq,
                        max(case when t01.parvw = 'AG' then t01.partn end) as gen_sold_to_cust_code,
                        max(case when t01.parvw = 'RE' then t01.partn end) as gen_bill_to_cust_code,
                        max(case when t01.parvw = 'RG' then t01.partn end) as gen_payer_cust_code,
                        max(case when t01.parvw = 'WE' then t01.partn end) as gen_ship_to_cust_code
                   from sap_inv_ipn t01
                  where t01.belnr = rcd_ods_list.belnr
                    and t01.parvw in ('AG','RE','RG','WE')
                  group by t01.belnr,
                           t01.genseq) t07,
                --
                -- Invoice line reference information
                --
                (select t01.belnr,
                        t01.genseq,
                        max(case when t01.qualf = '002' then t01.refnr end) as order_doc_num,
                        max(case when t01.qualf = '002' then t01.zeile end) as order_doc_line_num,
                        max(case when t01.qualf = '016' then t01.refnr end) as dlvry_doc_num,
                        max(case when t01.qualf = '016' then t01.zeile end) as dlvry_doc_line_num
                   from sap_inv_irf t01
                  where t01.belnr = rcd_ods_list.belnr
                    and t01.qualf in ('002','016')
                  group by t01.belnr,
                        t01.genseq) t08,
                --
                -- Invoice line value information
                --
               (select t01.belnr,
                       t01.genseq,
                       sum(billed_gsv) as billed_gsv
                  from (select t01.belnr,
                               t01.genseq,
                               decode(t01.alckz,'-',-1,1)*nvl(dw_to_number(t01.betrg),0) as billed_gsv
                          from sap_inv_icn t01
                         where t01.belnr = rcd_ods_list.belnr
                           and (upper(t01.kschl) = 'ZV01' or
                                upper(t01.kschl) = 'ZR03' or
                                upper(t01.kschl) = 'ZR04' or
                                upper(t01.kotxt) = 'GSV')
                         union all
                        select t01.belnr,
                               t01.genseq,
                               decode(t01.alckz,'-',-1,1)*nvl(dw_to_number(t01.betrg),0) as billed_gsv
                          from sap_inv_icn t01,
                               (select t01.belnr,
                                       t01.genseq
                                  from sap_inv_icn t01
                                 where t01.belnr = rcd_ods_list.belnr
                                   and upper(t01.kschl) = 'ZZ01') t02
                         where t01.belnr = t02.belnr
                           and t01.genseq = t02.genseq
                           and t01.belnr = rcd_ods_list.belnr
                           and upper(t01.kotxt) = 'GROSS VALUE') t01
                 group by t01.belnr, t01.genseq) t09
          --
          -- Joins
          --
          where t01.belnr = t02.belnr(+)
            and t01.belnr = t03.belnr(+)
            and t01.belnr = t04.belnr(+)
            and t01.belnr = t05.belnr(+)
            and t05.belnr = t06.belnr(+)
            and t05.genseq = t06.genseq(+)
            and t05.belnr = t07.belnr(+)
            and t05.genseq = t07.genseq(+)
            and t05.belnr = t08.belnr(+)
            and t05.genseq = t08.genseq(+)
            and t05.genseq = t07.genseq(+)
            and t05.belnr = t09.belnr(+)
            and t05.genseq = t09.genseq(+);
      rcd_ods_data csr_ods_data%rowtype;

      cursor csr_ods_lookup is
         select t01.dlvry_doc_num,
                t01.dlvry_doc_line_num
           from sap_del_trace t01
          where t01.dlvry_doc_num = (select refnr from sap_inv_ref
                                      where belnr = rcd_sap_inv_trace.billing_doc_num
                                        and qualf = '012')
            and t01.order_doc_num = rcd_sap_inv_trace.order_doc_num
            and t01.order_doc_line_num = rcd_sap_inv_trace.order_doc_line_num
          order by t01.trace_seqn desc;
      rcd_ods_lookup csr_ods_lookup%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the invoices
      /*-*/
      open csr_ods_list;
      loop
         fetch csr_ods_list into rcd_ods_list;
         if csr_ods_list%notfound then
            exit;
         end if;

         /*-*/
         /* Initialise the invoice trace data (converted data has a zero sequence)
         /*-*/
         rcd_sap_inv_trace.trace_seqn := 0;
         rcd_sap_inv_trace.trace_date := sysdate;

         /*-*/
         /* Retrieve the invoice trace detail
         /*-*/
         open csr_ods_data;
         loop
            fetch csr_ods_data into rcd_ods_data;
            if csr_ods_data%notfound then
               exit;
            end if;

            /*-*/
            /* Initialise the invoice trace row
            /*-*/
            rcd_sap_inv_trace.company_code := rcd_ods_data.company_code;
            rcd_sap_inv_trace.billing_doc_num := rcd_ods_data.billing_doc_num;
            rcd_sap_inv_trace.doc_currcy_code := rcd_ods_data.doc_currcy_code;
            rcd_sap_inv_trace.exch_rate := rcd_ods_data.exch_rate;
            rcd_sap_inv_trace.order_reasn_code := rcd_ods_data.order_reasn_code;
            rcd_sap_inv_trace.creatn_date := rcd_ods_data.creatn_date;
            rcd_sap_inv_trace.creatn_yyyyppdd := rcd_ods_data.creatn_yyyyppdd;
            rcd_sap_inv_trace.creatn_yyyyppw := rcd_ods_data.creatn_yyyyppw;
            rcd_sap_inv_trace.creatn_yyyypp := rcd_ods_data.creatn_yyyypp;
            rcd_sap_inv_trace.creatn_yyyymm := rcd_ods_data.creatn_yyyymm;
            rcd_sap_inv_trace.billing_eff_date := rcd_ods_data.billing_eff_date;
            rcd_sap_inv_trace.billing_eff_yyyyppdd := rcd_ods_data.billing_eff_yyyyppdd;
            rcd_sap_inv_trace.billing_eff_yyyyppw := rcd_ods_data.billing_eff_yyyyppw;
            rcd_sap_inv_trace.billing_eff_yyyypp := rcd_ods_data.billing_eff_yyyypp;
            rcd_sap_inv_trace.billing_eff_yyyymm := rcd_ods_data.billing_eff_yyyymm;
            rcd_sap_inv_trace.order_type_code := rcd_ods_data.order_type_code;
            rcd_sap_inv_trace.invc_type_code := rcd_ods_data.invc_type_code;
            rcd_sap_inv_trace.hdr_sales_org_code := rcd_ods_data.hdr_sales_org_code;
            rcd_sap_inv_trace.hdr_distbn_chnl_code := rcd_ods_data.hdr_distbn_chnl_code;
            rcd_sap_inv_trace.hdr_division_code := rcd_ods_data.hdr_division_code;
            rcd_sap_inv_trace.hdr_sold_to_cust_code := rcd_ods_data.hdr_sold_to_cust_code;
            rcd_sap_inv_trace.hdr_bill_to_cust_code := rcd_ods_data.hdr_bill_to_cust_code;
            rcd_sap_inv_trace.hdr_payer_cust_code := rcd_ods_data.hdr_payer_cust_code;
            rcd_sap_inv_trace.hdr_ship_to_cust_code := rcd_ods_data.hdr_ship_to_cust_code;
            rcd_sap_inv_trace.billing_doc_line_num := rcd_ods_data.billing_doc_line_num;
            rcd_sap_inv_trace.billed_uom_code := rcd_ods_data.billed_uom_code;
            rcd_sap_inv_trace.billed_base_uom_code := rcd_ods_data.billed_base_uom_code;
            rcd_sap_inv_trace.plant_code := rcd_ods_data.plant_code;
            rcd_sap_inv_trace.storage_locn_code := rcd_ods_data.storage_locn_code;
            rcd_sap_inv_trace.gen_sales_org_code := rcd_ods_data.gen_sales_org_code;
            rcd_sap_inv_trace.gen_distbn_chnl_code := rcd_ods_data.gen_distbn_chnl_code;
            rcd_sap_inv_trace.gen_division_code := rcd_ods_data.gen_division_code;
            rcd_sap_inv_trace.order_usage_code := rcd_ods_data.order_usage_code;
            rcd_sap_inv_trace.order_qty := rcd_ods_data.order_qty;
            rcd_sap_inv_trace.billed_qty := rcd_ods_data.billed_qty;
            rcd_sap_inv_trace.billed_qty_base_uom := rcd_ods_data.billed_qty_base_uom;
            rcd_sap_inv_trace.billed_gross_weight := rcd_ods_data.billed_gross_weight;
            rcd_sap_inv_trace.billed_net_weight := rcd_ods_data.billed_net_weight;
            rcd_sap_inv_trace.billed_weight_unit := rcd_ods_data.billed_weight_unit;
            rcd_sap_inv_trace.matl_code := rcd_ods_data.matl_code;
            rcd_sap_inv_trace.matl_entd := rcd_ods_data.matl_entd;
            rcd_sap_inv_trace.gen_sold_to_cust_code := rcd_ods_data.gen_sold_to_cust_code;
            rcd_sap_inv_trace.gen_bill_to_cust_code := rcd_ods_data.gen_bill_to_cust_code;
            rcd_sap_inv_trace.gen_payer_cust_code := rcd_ods_data.gen_payer_cust_code;
            rcd_sap_inv_trace.gen_ship_to_cust_code := rcd_ods_data.gen_ship_to_cust_code;
            rcd_sap_inv_trace.purch_order_doc_num := null;
            rcd_sap_inv_trace.purch_order_doc_line_num := null;
            rcd_sap_inv_trace.order_doc_num := null;
            rcd_sap_inv_trace.order_doc_line_num := null;
            rcd_sap_inv_trace.dlvry_doc_num := rcd_ods_data.dlvry_doc_num;
            rcd_sap_inv_trace.dlvry_doc_line_num := rcd_ods_data.dlvry_doc_line_num;
            rcd_sap_inv_trace.billed_gsv := rcd_ods_data.billed_gsv;
            if rcd_sap_inv_trace.invc_type_code in ('ZIV','ZIVR','ZIVS') then
               rcd_sap_inv_trace.purch_order_doc_num := rcd_ods_data.order_doc_num;
               rcd_sap_inv_trace.purch_order_doc_line_num := lpad(ltrim(rcd_ods_data.order_doc_line_num,'0'),5,'0');
            else
               rcd_sap_inv_trace.order_doc_num := rcd_ods_data.order_doc_num;
               rcd_sap_inv_trace.order_doc_line_num := rcd_ods_data.order_doc_line_num;
            end if;

            /*-*/
            /* Lookup the delivery line from the delivery trace when required
            /*-*/
            if rcd_sap_inv_trace.dlvry_doc_num = rcd_sap_inv_trace.order_doc_num then
               open csr_ods_lookup;
               fetch csr_ods_lookup into rcd_ods_lookup;
               if csr_ods_lookup%found then
                  rcd_sap_inv_trace.dlvry_doc_num := rcd_ods_lookup.dlvry_doc_num;
                  rcd_sap_inv_trace.dlvry_doc_line_num := rcd_ods_lookup.dlvry_doc_line_num;
               end if;
               close csr_ods_lookup;
            end if;

            /*-*/
            /* Insert the invoice trace row
            /*-*/
            insert into sap_inv_trace values rcd_sap_inv_trace;

         end loop;
         close csr_ods_data;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_ods_list;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_sales_trace;

   /*******************************************************************/
   /* This procedure performs the execute purchase order fact routine */
   /*******************************************************************/
   procedure execute_purch_order_fact is

      /*-*/
      /* Local definitions
      /*-*/
      var_size number(5,0);
      var_work number(5,0);
      var_exit boolean;
      type rcd_dw_purch_base is table of dw_purch_base%rowtype index by binary_integer;
      tab_dw_purch_base rcd_dw_purch_base;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_source is 
         select t01.*,
                t02.mars_week as creatn_yyyyppw,
                t02.mars_period as creatn_yyyypp,
                (t02.year_num * 100) + t02.month_num as creatn_yyyymm,
                t03.mars_period as purch_order_eff_yyyypp,
                (t03.year_num * 100) + t03.month_num as purch_order_eff_yyyymm
           from purch_order_fact t01,
                mars_date t02,
                mars_date t03
          where t01.creatn_date = t02.calendar_date(+)
            and t01.purch_order_eff_date = t03.calendar_date(+)
            and substr(t01.creatn_yyyyppdd,1,6) = par_yyyypp
          order by t01.creatn_yyyyppdd asc;
      rcd_source csr_source%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve rows from the source
      /*-*/
      var_size := 1000;
      var_work := 0;
      var_exit := false;
      open csr_source;
      loop
         fetch csr_source into rcd_source;
         if csr_source%notfound then
            var_exit := true;
         end if;    

         /*-*/
         /* Load the bulk arrays when required
         /*-*/
         if var_exit = false then
            var_work := var_work + 1;
            tab_dw_purch_base(var_work).purch_order_doc_num := rcd_source.purch_order_doc_num;
            tab_dw_purch_base(var_work).purch_order_doc_line_num := rcd_source.purch_order_doc_line_num;
            tab_dw_purch_base(var_work).purch_order_line_status := '*OUTSTANDING';
            tab_dw_purch_base(var_work).purch_order_trace_seqn := 0;
            tab_dw_purch_base(var_work).creatn_date := rcd_source.creatn_date;
            tab_dw_purch_base(var_work).creatn_yyyyppdd := rcd_source.creatn_yyyyppdd;
            tab_dw_purch_base(var_work).creatn_yyyyppw := rcd_source.creatn_yyyyppw;
            tab_dw_purch_base(var_work).creatn_yyyypp := rcd_source.creatn_yyyypp;
            tab_dw_purch_base(var_work).creatn_yyyymm := rcd_source.creatn_yyyymm;
            tab_dw_purch_base(var_work).purch_order_eff_date := rcd_source.purch_order_eff_date;
            tab_dw_purch_base(var_work).purch_order_eff_yyyyppdd := rcd_source.purch_order_eff_yyyyppdd;
            tab_dw_purch_base(var_work).purch_order_eff_yyyyppw := rcd_source.purch_order_eff_yyyyppw;
            tab_dw_purch_base(var_work).purch_order_eff_yyyypp := rcd_source.purch_order_eff_yyyypp;
            tab_dw_purch_base(var_work).purch_order_eff_yyyymm := rcd_source.purch_order_eff_yyyymm;
            tab_dw_purch_base(var_work).confirmed_date := rcd_source.purch_order_eff_date;
            tab_dw_purch_base(var_work).confirmed_yyyyppdd := rcd_source.purch_order_eff_yyyyppdd;
            tab_dw_purch_base(var_work).confirmed_yyyyppw := rcd_source.purch_order_eff_yyyyppw;
            tab_dw_purch_base(var_work).confirmed_yyyypp := rcd_source.purch_order_eff_yyyypp;
            tab_dw_purch_base(var_work).confirmed_yyyymm := rcd_source.purch_order_eff_yyyymm;
            tab_dw_purch_base(var_work).company_code := rcd_source.company_code;
            tab_dw_purch_base(var_work).sales_org_code := rcd_source.sales_org_code;
            tab_dw_purch_base(var_work).distbn_chnl_code := rcd_source.distbn_chnl_code;
            tab_dw_purch_base(var_work).division_code := rcd_source.division_code;
            tab_dw_purch_base(var_work).doc_currcy_code := rcd_source.currcy_code;
            tab_dw_purch_base(var_work).company_currcy_code := rcd_source.company_currcy_code;
            tab_dw_purch_base(var_work).exch_rate := rcd_source.exch_rate;
            tab_dw_purch_base(var_work).purchg_company_code := rcd_source.purchg_company_code;
            tab_dw_purch_base(var_work).purch_order_type_code := rcd_source.purch_order_type_code;
            tab_dw_purch_base(var_work).purch_order_reasn_code := rcd_source.purch_order_reasn_code;
            tab_dw_purch_base(var_work).purch_order_usage_code := rcd_source.purch_order_usage_code;
            tab_dw_purch_base(var_work).vendor_code := rcd_source.vendor_code;
            tab_dw_purch_base(var_work).cust_code := rcd_source.cust_code;
            tab_dw_purch_base(var_work).matl_code := rcd_source.matl_code;
            tab_dw_purch_base(var_work).ods_matl_code := rcd_source.matl_code;
            tab_dw_purch_base(var_work).plant_code := rcd_source.plant_code;
            tab_dw_purch_base(var_work).storage_locn_code := rcd_source.storage_locn_code;
            tab_dw_purch_base(var_work).purch_order_weight_unit := null;
            tab_dw_purch_base(var_work).purch_order_gross_weight := 0;
            tab_dw_purch_base(var_work).purch_order_net_weight := 0;
            tab_dw_purch_base(var_work).purch_order_uom_code := rcd_source.purch_order_qty_uom_code;
            tab_dw_purch_base(var_work).purch_order_base_uom_code := rcd_source.purch_order_qty_base_uom_code;
            tab_dw_purch_base(var_work).ord_qty := rcd_source.purch_order_qty;
            tab_dw_purch_base(var_work).ord_qty_base_uom := rcd_source.base_uom_purch_order_qty;
            tab_dw_purch_base(var_work).ord_qty_gross_tonnes := rcd_source.purch_order_qty_gross_tonnes;
            tab_dw_purch_base(var_work).ord_qty_net_tonnes := rcd_source.purch_order_qty_net_tonnes;
            tab_dw_purch_base(var_work).ord_gsv := rcd_source.gsv;
            tab_dw_purch_base(var_work).ord_gsv_xactn := rcd_source.gsv_xactn;
            tab_dw_purch_base(var_work).ord_gsv_aud := rcd_source.gsv_aud;
            tab_dw_purch_base(var_work).ord_gsv_usd := rcd_source.gsv_usd;
            tab_dw_purch_base(var_work).ord_gsv_eur := rcd_source.gsv_eur;
            tab_dw_purch_base(var_work).con_qty := rcd_source.purch_order_qty;
            tab_dw_purch_base(var_work).con_qty_base_uom := rcd_source.base_uom_purch_order_qty;
            tab_dw_purch_base(var_work).con_qty_gross_tonnes := rcd_source.purch_order_qty_gross_tonnes;
            tab_dw_purch_base(var_work).con_qty_net_tonnes := rcd_source.purch_order_qty_net_tonnes;
            tab_dw_purch_base(var_work).con_gsv := rcd_source.gsv;
            tab_dw_purch_base(var_work).con_gsv_xactn := rcd_source.gsv_xactn;
            tab_dw_purch_base(var_work).con_gsv_aud := rcd_source.gsv_aud;
            tab_dw_purch_base(var_work).con_gsv_usd := rcd_source.gsv_usd;
            tab_dw_purch_base(var_work).con_gsv_eur := rcd_source.gsv_eur;
            tab_dw_purch_base(var_work).req_qty := 0;
            tab_dw_purch_base(var_work).req_qty_base_uom := 0;
            tab_dw_purch_base(var_work).req_qty_gross_tonnes := 0;
            tab_dw_purch_base(var_work).req_qty_net_tonnes := 0;
            tab_dw_purch_base(var_work).req_gsv := 0;
            tab_dw_purch_base(var_work).req_gsv_xactn := 0;
            tab_dw_purch_base(var_work).req_gsv_aud := 0;
            tab_dw_purch_base(var_work).req_gsv_usd := 0;
            tab_dw_purch_base(var_work).req_gsv_eur := 0;
            tab_dw_purch_base(var_work).del_qty := 0;
            tab_dw_purch_base(var_work).del_qty_base_uom := 0;
            tab_dw_purch_base(var_work).del_qty_gross_tonnes := 0;
            tab_dw_purch_base(var_work).del_qty_net_tonnes := 0;
            tab_dw_purch_base(var_work).del_gsv := 0;
            tab_dw_purch_base(var_work).del_gsv_xactn := 0;
            tab_dw_purch_base(var_work).del_gsv_aud := 0;
            tab_dw_purch_base(var_work).del_gsv_usd := 0;
            tab_dw_purch_base(var_work).del_gsv_eur := 0;
            tab_dw_purch_base(var_work).inv_qty := 0;
            tab_dw_purch_base(var_work).inv_qty_base_uom := 0;
            tab_dw_purch_base(var_work).inv_qty_gross_tonnes := 0;
            tab_dw_purch_base(var_work).inv_qty_net_tonnes := 0;
            tab_dw_purch_base(var_work).inv_gsv := 0;
            tab_dw_purch_base(var_work).inv_gsv_xactn := 0;
            tab_dw_purch_base(var_work).inv_gsv_aud := 0;
            tab_dw_purch_base(var_work).inv_gsv_usd := 0;
            tab_dw_purch_base(var_work).inv_gsv_eur := 0;
            tab_dw_purch_base(var_work).out_qty := rcd_source.purch_order_qty;
            tab_dw_purch_base(var_work).out_qty_base_uom := rcd_source.base_uom_purch_order_qty;
            tab_dw_purch_base(var_work).out_qty_gross_tonnes := rcd_source.purch_order_qty_gross_tonnes;
            tab_dw_purch_base(var_work).out_qty_net_tonnes := rcd_source.purch_order_qty_net_tonnes;
            tab_dw_purch_base(var_work).out_gsv := rcd_source.gsv;
            tab_dw_purch_base(var_work).out_gsv_xactn := rcd_source.gsv_xactn;
            tab_dw_purch_base(var_work).out_gsv_aud := rcd_source.gsv_aud;
            tab_dw_purch_base(var_work).out_gsv_usd := rcd_source.gsv_usd;
            tab_dw_purch_base(var_work).out_gsv_eur := rcd_source.gsv_eur;
            tab_dw_purch_base(var_work).mfanz_icb_flag := rcd_source.mfanz_icb_flag;
            tab_dw_purch_base(var_work).demand_plng_grp_division_code := rcd_source.demand_plng_grp_division_code;
            if rcd_source.purch_order_line_status = 'DELIVERED' then
               tab_dw_purch_base(var_work).purch_order_line_status := '*DELIVERED';
            end if;
            if rcd_source.purch_order_line_status = 'INVOICED' then
               tab_dw_purch_base(var_work).purch_order_line_status := '*INVOICED';
            end if;
            if tab_dw_purch_base(var_work).purch_order_line_status = '*DELIVERED' or
               tab_dw_purch_base(var_work).purch_order_line_status = '*INVOICED' then
               tab_dw_purch_base(var_work).req_qty := tab_dw_purch_base(var_work).ord_qty;
               tab_dw_purch_base(var_work).req_qty_base_uom := tab_dw_purch_base(var_work).ord_qty_base_uom;
               tab_dw_purch_base(var_work).req_qty_gross_tonnes := tab_dw_purch_base(var_work).ord_qty_gross_tonnes;
               tab_dw_purch_base(var_work).req_qty_net_tonnes := tab_dw_purch_base(var_work).ord_qty_net_tonnes;
               tab_dw_purch_base(var_work).req_gsv := tab_dw_purch_base(var_work).ord_gsv;
               tab_dw_purch_base(var_work).req_gsv_xactn := tab_dw_purch_base(var_work).ord_gsv_xactn;
               tab_dw_purch_base(var_work).req_gsv_aud := tab_dw_purch_base(var_work).ord_gsv_aud;
               tab_dw_purch_base(var_work).req_gsv_usd := tab_dw_purch_base(var_work).ord_gsv_usd;
               tab_dw_purch_base(var_work).req_gsv_eur := tab_dw_purch_base(var_work).ord_gsv_eur;
               tab_dw_purch_base(var_work).del_qty := tab_dw_purch_base(var_work).ord_qty;
               tab_dw_purch_base(var_work).del_qty_base_uom := tab_dw_purch_base(var_work).ord_qty_base_uom;
               tab_dw_purch_base(var_work).del_qty_gross_tonnes := tab_dw_purch_base(var_work).ord_qty_gross_tonnes;
               tab_dw_purch_base(var_work).del_qty_net_tonnes := tab_dw_purch_base(var_work).ord_qty_net_tonnes;
               tab_dw_purch_base(var_work).del_gsv := tab_dw_purch_base(var_work).ord_gsv;
               tab_dw_purch_base(var_work).del_gsv_xactn := tab_dw_purch_base(var_work).ord_gsv_xactn;
               tab_dw_purch_base(var_work).del_gsv_aud := tab_dw_purch_base(var_work).ord_gsv_aud;
               tab_dw_purch_base(var_work).del_gsv_usd := tab_dw_purch_base(var_work).ord_gsv_usd;
               tab_dw_purch_base(var_work).del_gsv_eur := tab_dw_purch_base(var_work).ord_gsv_eur;
               tab_dw_purch_base(var_work).out_qty := 0;
               tab_dw_purch_base(var_work).out_qty_base_uom := 0;
               tab_dw_purch_base(var_work).out_qty_gross_tonnes := 0;
               tab_dw_purch_base(var_work).out_qty_net_tonnes := 0;
               tab_dw_purch_base(var_work).out_gsv := 0;
               tab_dw_purch_base(var_work).out_gsv_xactn := 0;
               tab_dw_purch_base(var_work).out_gsv_aud := 0;
               tab_dw_purch_base(var_work).out_gsv_usd := 0;
               tab_dw_purch_base(var_work).out_gsv_eur := 0;
            end if;
            if tab_dw_purch_base(var_work).purch_order_line_status = '*INVOICED' then
               tab_dw_purch_base(var_work).inv_qty := tab_dw_purch_base(var_work).ord_qty;
               tab_dw_purch_base(var_work).inv_qty_base_uom := tab_dw_purch_base(var_work).ord_qty_base_uom;
               tab_dw_purch_base(var_work).inv_qty_gross_tonnes := tab_dw_purch_base(var_work).ord_qty_gross_tonnes;
               tab_dw_purch_base(var_work).inv_qty_net_tonnes := tab_dw_purch_base(var_work).ord_qty_net_tonnes;
               tab_dw_purch_base(var_work).inv_gsv := tab_dw_purch_base(var_work).ord_gsv;
               tab_dw_purch_base(var_work).inv_gsv_xactn := tab_dw_purch_base(var_work).ord_gsv_xactn;
               tab_dw_purch_base(var_work).inv_gsv_aud := tab_dw_purch_base(var_work).ord_gsv_aud;
               tab_dw_purch_base(var_work).inv_gsv_usd := tab_dw_purch_base(var_work).ord_gsv_usd;
               tab_dw_purch_base(var_work).inv_gsv_eur := tab_dw_purch_base(var_work).ord_gsv_eur;
            end if;
         end if;

         /*-*/
         /* Insert the bulk target data when required
         /*-*/
         if (var_exit = false and var_work = var_size) or
            (var_exit = true and var_work > 0) then
            forall idx in 1..var_work
               insert into dw_purch_base values tab_dw_purch_base(idx);
            commit;
            var_work := 0;
         end if;

         /*-*/
         /* Exit the loop when required
         /*-*/
         if var_exit = true then
            exit;
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
         raise_application_error(-20000, 'FATAL ERROR - CDW - CONVERTER - PURCH_ORDER_FACT Procedure -' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_purch_order_fact;

   /**********************************************************/
   /* This procedure performs the execute order fact routine */
   /**********************************************************/
   procedure execute_order_fact is

      /*-*/
      /* Local definitions
      /*-*/
      var_size number(5,0);
      var_work number(5,0);
      var_exit boolean;
      type rcd_dw_order_base is table of dw_order_base%rowtype index by binary_integer;
      tab_dw_order_base rcd_dw_order_base;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_source is 
         select t01.*,
                t02.mars_week as creatn_yyyyppw,
                t02.mars_period as creatn_yyyypp,
                (t02.year_num * 100) + t02.month_num as creatn_yyyymm,
                t03.mars_period as order_eff_yyyypp,
                (t03.year_num * 100) + t03.month_num as order_eff_yyyymm
           from order_fact t01,
                mars_date t02,
                mars_date t03
          where t01.creatn_date = t02.calendar_date(+)
            and t01.order_eff_date = t03.calendar_date(+)
          order by t01.creatn_date asc;
      rcd_source csr_source%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve rows from the source
      /*-*/
      var_size := 1000;
      var_work := 0;
      var_exit := false;
      open csr_source;
      loop
         fetch csr_source into rcd_source;
         if csr_source%notfound then
            var_exit := true;
         end if;

         /*-*/
         /* Load the bulk arrays when required
         /*-*/
         if var_exit = false then
            var_work := var_work + 1;
            tab_dw_order_base(var_work).order_doc_num := rcd_source.order_doc_num;
            tab_dw_order_base(var_work).order_doc_line_num := rcd_source.order_doc_line_num;
            tab_dw_order_base(var_work).order_line_status := '*ORDERED';
            tab_dw_order_base(var_work).order_trace_seqn := 0;
            tab_dw_order_base(var_work).creatn_date := rcd_source.creatn_date;
            tab_dw_order_base(var_work).creatn_yyyyppdd := rcd_source.creatn_yyyyppdd;
            tab_dw_order_base(var_work).creatn_yyyyppw := rcd_source.creatn_yyyyppw;
            tab_dw_order_base(var_work).creatn_yyyypp := rcd_source.creatn_yyyypp;
            tab_dw_order_base(var_work).creatn_yyyymm := rcd_source.creatn_yyyymm;
            tab_dw_order_base(var_work).order_eff_date := rcd_source.order_eff_date;
            tab_dw_order_base(var_work).order_eff_yyyyppdd := rcd_source.order_eff_yyyyppdd;
            tab_dw_order_base(var_work).order_eff_yyyyppw := rcd_source.order_eff_yyyyppw;
            tab_dw_order_base(var_work).order_eff_yyyypp := rcd_source.order_eff_yyyypp;
            tab_dw_order_base(var_work).order_eff_yyyymm := rcd_source.order_eff_yyyymm;
            tab_dw_order_base(var_work).confirmed_date := rcd_source.order_eff_date;
            tab_dw_order_base(var_work).confirmed_yyyyppdd := rcd_source.order_eff_yyyyppdd;
            tab_dw_order_base(var_work).confirmed_yyyyppw := rcd_source.order_eff_yyyyppw;
            tab_dw_order_base(var_work).confirmed_yyyypp := rcd_source.order_eff_yyyypp;
            tab_dw_order_base(var_work).confirmed_yyyymm := rcd_source.order_eff_yyyymm;
            tab_dw_order_base(var_work).company_code := rcd_source.company_code;
            tab_dw_order_base(var_work).cust_order_doc_num := rcd_source.cust_order_doc_num;
            tab_dw_order_base(var_work).cust_order_doc_line_num := rcd_source.cust_order_doc_line_num;
            tab_dw_order_base(var_work).cust_order_due_date := rcd_source.cust_order_due_date;
            tab_dw_order_base(var_work).sales_org_code := rcd_source.sales_org_code;
            tab_dw_order_base(var_work).distbn_chnl_code := rcd_source.distbn_chnl_code;
            tab_dw_order_base(var_work).division_code := rcd_source.division_code;
            tab_dw_order_base(var_work).doc_currcy_code := rcd_source.currcy_code;
            tab_dw_order_base(var_work).company_currcy_code := rcd_source.company_currcy_code;
            tab_dw_order_base(var_work).exch_rate := rcd_source.exch_rate;
            tab_dw_order_base(var_work).order_type_code := rcd_source.order_type_code;
            tab_dw_order_base(var_work).order_reasn_code := rcd_source.order_reasn_code;
            tab_dw_order_base(var_work).order_usage_code := rcd_source.order_usage_code;
            tab_dw_order_base(var_work).sold_to_cust_code := rcd_source.sold_to_cust_code;
            tab_dw_order_base(var_work).bill_to_cust_code := rcd_source.bill_to_cust_code;
            tab_dw_order_base(var_work).payer_cust_code := rcd_source.payer_cust_code;
            tab_dw_order_base(var_work).ship_to_cust_code := rcd_source.ship_to_cust_code;
            tab_dw_order_base(var_work).matl_code := rcd_source.matl_code;
            tab_dw_order_base(var_work).ods_matl_code := rcd_source.matl_code;
            tab_dw_order_base(var_work).matl_entd := rcd_source.matl_entd;
            tab_dw_order_base(var_work).plant_code := rcd_source.plant_code;
            tab_dw_order_base(var_work).storage_locn_code := rcd_source.storage_locn_code;
            tab_dw_order_base(var_work).order_line_rejectn_code := rcd_source.order_line_rejectn_code;
            tab_dw_order_base(var_work).order_weight_unit := null;
            tab_dw_order_base(var_work).order_gross_weight := 0;
            tab_dw_order_base(var_work).order_net_weight := 0;
            tab_dw_order_base(var_work).order_uom_code := rcd_source.order_qty_uom_code;
            tab_dw_order_base(var_work).order_base_uom_code := rcd_source.order_qty_base_uom_code;
            tab_dw_order_base(var_work).ord_qty := rcd_source.order_qty;
            tab_dw_order_base(var_work).ord_qty_base_uom := rcd_source.base_uom_order_qty;
            tab_dw_order_base(var_work).ord_qty_gross_tonnes := rcd_source.order_qty_gross_tonnes;
            tab_dw_order_base(var_work).ord_qty_net_tonnes := rcd_source.order_qty_net_tonnes;
            tab_dw_order_base(var_work).ord_gsv := rcd_source.order_gsv;
            tab_dw_order_base(var_work).ord_gsv_xactn := rcd_source.order_gsv_xactn;
            tab_dw_order_base(var_work).ord_gsv_aud := rcd_source.order_gsv_aud;
            tab_dw_order_base(var_work).ord_gsv_usd := rcd_source.order_gsv_usd;
            tab_dw_order_base(var_work).ord_gsv_eur := rcd_source.order_gsv_eur;
            tab_dw_order_base(var_work).con := rcd_source.confirmed_qty;
            tab_dw_order_base(var_work).con_qty_base_uom := rcd_source.base_uom_confirmed_qty;
            tab_dw_order_base(var_work).con_qty_gross_tonnes := rcd_source.confirmed_qty_gross_tonnes;
            tab_dw_order_base(var_work).con_qty_net_tonnes := rcd_source.confirmed_qty_net_tonnes;
            tab_dw_order_base(var_work).con_gsv := rcd_source.confirmed_gsv;
            tab_dw_order_base(var_work).con_gsv_xactn := rcd_source.confirmed_gsv_xactn;
            tab_dw_order_base(var_work).con_gsv_aud := rcd_source.confirmed_gsv_aud;
            tab_dw_order_base(var_work).con_gsv_usd := rcd_source.confirmed_gsv_usd;
            tab_dw_order_base(var_work).con_gsv_eur := rcd_source.confirmed_gsv_eur;
            tab_dw_order_base(var_work).req_qty := 0;
            tab_dw_order_base(var_work).req_qty_base_uom := 0;
            tab_dw_order_base(var_work).req_qty_gross_tonnes := 0;
            tab_dw_order_base(var_work).req_qty_net_tonnes := 0;
            tab_dw_order_base(var_work).req_gsv := 0;
            tab_dw_order_base(var_work).req_gsv_xactn := 0;
            tab_dw_order_base(var_work).req_gsv_aud := 0;
            tab_dw_order_base(var_work).req_gsv_usd := 0;
            tab_dw_order_base(var_work).req_gsv_eur := 0;
            tab_dw_order_base(var_work).del_qty := 0;
            tab_dw_order_base(var_work).del_qty_base_uom := 0;
            tab_dw_order_base(var_work).del_qty_gross_tonnes := 0;
            tab_dw_order_base(var_work).del_qty_net_tonnes := 0;
            tab_dw_order_base(var_work).del_gsv := 0;
            tab_dw_order_base(var_work).del_gsv_xactn := 0;
            tab_dw_order_base(var_work).del_gsv_aud := 0;
            tab_dw_order_base(var_work).del_gsv_usd := 0;
            tab_dw_order_base(var_work).del_gsv_eur := 0;
            tab_dw_order_base(var_work).inv_qty := 0;
            tab_dw_order_base(var_work).inv_qty_base_uom := 0;
            tab_dw_order_base(var_work).inv_qty_gross_tonnes := 0;
            tab_dw_order_base(var_work).inv_qty_net_tonnes := 0;
            tab_dw_order_base(var_work).inv_gsv := 0;
            tab_dw_order_base(var_work).inv_gsv_xactn := 0;
            tab_dw_order_base(var_work).inv_gsv_aud := 0;
            tab_dw_order_base(var_work).inv_gsv_usd := 0;
            tab_dw_order_base(var_work).inv_gsv_eur := 0;
            tab_dw_order_base(var_work).out_qty := rcd_source.confirmed_qty;
            tab_dw_order_base(var_work).out_qty_base_uom := rcd_source.base_uom_confirmed_qty;
            tab_dw_order_base(var_work).out_qty_gross_tonnes := rcd_source.confirmed_qty_gross_tonnes;
            tab_dw_order_base(var_work).out_qty_net_tonnes := rcd_source.confirmed_qty_net_tonnes;
            tab_dw_order_base(var_work).out_gsv := rcd_source.confirmed_gsv;
            tab_dw_order_base(var_work).out_gsv_xactn := rcd_source.confirmed_gsv_xactn;
            tab_dw_order_base(var_work).out_gsv_aud := rcd_source.confirmed_gsv_aud;
            tab_dw_order_base(var_work).out_gsv_usd := rcd_source.confirmed_gsv_usd;
            tab_dw_order_base(var_work).out_gsv_eur := rcd_source.confirmed_gsv_eur;
            tab_dw_order_base(var_work).mfanz_icb_flag := rcd_source.mfanz_icb_flag;
            tab_dw_order_base(var_work).demand_plng_grp_division_code := rcd_source.demand_plng_grp_division_code;
            if rcd_source.order_line_rejectn_code = 'ZA' then
               tab_dw_order_base(var_work).order_line_status := '*UNALLOCATED';
            end if;
            if rcd_source.order_line_status = 'DELIVERED' then
               tab_dw_order_base(var_work).order_line_status := '*DELIVERED';
            end if;
            if rcd_source.order_line_status = 'INVOICED' then
               tab_dw_order_base(var_work).order_line_status := '*INVOICED';
            end if;
            if tab_dw_order_base(var_work).order_line_status = '*DELIVERED' or
               tab_dw_order_base(var_work).order_line_status = '*INVOICED' then
               tab_dw_order_base(var_work).req_qty := tab_dw_order_base(var_work).con_qty;
               tab_dw_order_base(var_work).req_qty_base_uom := tab_dw_order_base(var_work).con_qty_base_uom;
               tab_dw_order_base(var_work).req_qty_gross_tonnes := tab_dw_order_base(var_work).con_qty_gross_tonnes;
               tab_dw_order_base(var_work).req_qty_net_tonnes := tab_dw_order_base(var_work).con_qty_net_tonnes;
               tab_dw_order_base(var_work).req_gsv := tab_dw_order_base(var_work).con_gsv;
               tab_dw_order_base(var_work).req_gsv_xactn := tab_dw_order_base(var_work).con_gsv_xactn;
               tab_dw_order_base(var_work).req_gsv_aud := tab_dw_order_base(var_work).con_gsv_aud;
               tab_dw_order_base(var_work).req_gsv_usd := tab_dw_order_base(var_work).con_gsv_usd;
               tab_dw_order_base(var_work).req_gsv_eur := tab_dw_order_base(var_work).con_gsv_eur;
               tab_dw_order_base(var_work).del_qty := tab_dw_order_base(var_work).con_qty;
               tab_dw_order_base(var_work).del_qty_base_uom := tab_dw_order_base(var_work).con_qty_base_uom;
               tab_dw_order_base(var_work).del_qty_gross_tonnes := tab_dw_order_base(var_work).con_qty_gross_tonnes;
               tab_dw_order_base(var_work).del_qty_net_tonnes := tab_dw_order_base(var_work).con_qty_net_tonnes;
               tab_dw_order_base(var_work).del_gsv := tab_dw_order_base(var_work).con_gsv;
               tab_dw_order_base(var_work).del_gsv_xactn := tab_dw_order_base(var_work).con_gsv_xactn;
               tab_dw_order_base(var_work).del_gsv_aud := tab_dw_order_base(var_work).con_gsv_aud;
               tab_dw_order_base(var_work).del_gsv_usd := tab_dw_order_base(var_work).con_gsv_usd;
               tab_dw_order_base(var_work).del_gsv_eur := tab_dw_order_base(var_work).con_gsv_eur;
               tab_dw_order_base(var_work).out_qty := 0;
               tab_dw_order_base(var_work).out_qty_base_uom := 0;
               tab_dw_order_base(var_work).out_qty_gross_tonnes := 0;
               tab_dw_order_base(var_work).out_qty_net_tonnes := 0;
               tab_dw_order_base(var_work).out_gsv := 0;
               tab_dw_order_base(var_work).out_gsv_xactn := 0;
               tab_dw_order_base(var_work).out_gsv_aud := 0;
               tab_dw_order_base(var_work).out_gsv_usd := 0;
               tab_dw_order_base(var_work).out_gsv_eur := 0;
            end if;
            if tab_dw_order_base(var_work).order_line_status = '*INVOICED' then
               tab_dw_order_base(var_work).inv_qty := tab_dw_order_base(var_work).con_qty;
               tab_dw_order_base(var_work).inv_qty_base_uom := tab_dw_order_base(var_work).con_qty_base_uom;
               tab_dw_order_base(var_work).inv_qty_gross_tonnes := tab_dw_order_base(var_work).con_qty_gross_tonnes;
               tab_dw_order_base(var_work).inv_qty_net_tonnes := tab_dw_order_base(var_work).con_qty_net_tonnes;
               tab_dw_order_base(var_work).inv_gsv := tab_dw_order_base(var_work).con_gsv;
               tab_dw_order_base(var_work).inv_gsv_xactn := tab_dw_order_base(var_work).con_gsv_xactn;
               tab_dw_order_base(var_work).inv_gsv_aud := tab_dw_order_base(var_work).con_gsv_aud;
               tab_dw_order_base(var_work).inv_gsv_usd := tab_dw_order_base(var_work).con_gsv_usd;
               tab_dw_order_base(var_work).inv_gsv_eur := tab_dw_order_base(var_work).con_gsv_eur;
            end if;
         end if;

         /*-*/
         /* Insert the bulk target data when required
         /*-*/
         if (var_exit = false and var_work = var_size) or
            (var_exit = true and var_work > 0) then
            forall idx in 1..var_work
               insert into dw_order_base values tab_dw_order_base(idx);
            commit;
            var_work := 0;
         end if;

         /*-*/
         /* Exit the loop when required
         /*-*/
         if var_exit = true then
            exit;
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
         raise_application_error(-20000, 'FATAL ERROR - CDW - CONVERTER - ORDER_FACT Procedure -' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_order_fact;

   /*************************************************************/
   /* This procedure performs the execute delivery fact routine */
   /*************************************************************/
   procedure execute_dlvry_fact is

      /*-*/
      /* Local definitions
      /*-*/
      var_size number(5,0);
      var_work number(5,0);
      var_exit boolean;
      type rcd_dw_dlvry_base is table of dw_dlvry_base%rowtype index by binary_integer;
      tab_dw_dlvry_base rcd_dw_dlvry_base;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_source is 
         select t01.*,
                t02.mars_week as creatn_yyyyppw,
                t02.mars_period as creatn_yyyypp,
                (t02.year_num * 100) + t02.month_num as creatn_yyyymm,
                t03.mars_period as dlvry_eff_yyyypp,
                (t03.year_num * 100) + t03.month_num as dlvry_eff_yyyymm,
                t04.mars_week as goods_issue_yyyyppw,
                t04.mars_period as goods_issue_yyyypp,
                (t04.year_num * 100) + t04.month_num as goods_issue_yyyymm
           from dlvry_fact t01,
                mars_date t02,
                mars_date t03,
                mars_date t04
          where t01.creatn_date = t02.calendar_date(+)
            and t01.dlvry_eff_date = t03.calendar_date(+)
            and t01.goods_issue_date = t04.calendar_date(+)
          order by t01.creatn_date asc;
      rcd_source csr_source%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve rows from the source
      /*-*/
      var_size := 1000;
      var_work := 0;
      var_exit := false;
      open csr_source;
      loop
         fetch csr_source into rcd_source;
         if csr_source%notfound then
            var_exit := true;
         end if;

         /*-*/
         /* Load the bulk arrays when required
         /*-*/
         if var_exit = false then
            var_work := var_work + 1;
            tab_dw_dlvry_base(var_work).dlvry_doc_num := rcd_source.dlvry_doc_num;
            tab_dw_dlvry_base(var_work).dlvry_doc_line_num := rcd_source.dlvry_doc_line_num;
            tab_dw_dlvry_base(var_work).dlvry_line_status := '*OUTSTANDING';
            tab_dw_dlvry_base(var_work).dlvry_trace_seqn := 0;
            tab_dw_dlvry_base(var_work).creatn_date := rcd_source.creatn_date;
            tab_dw_dlvry_base(var_work).creatn_yyyyppdd := rcd_source.creatn_yyyyppdd;
            tab_dw_dlvry_base(var_work).creatn_yyyyppw := rcd_source.creatn_yyyyppw;
            tab_dw_dlvry_base(var_work).creatn_yyyypp := rcd_source.creatn_yyyypp;
            tab_dw_dlvry_base(var_work).creatn_yyyymm := rcd_source.creatn_yyyymm;
            tab_dw_dlvry_base(var_work).dlvry_eff_date := rcd_source.dlvry_eff_date;
            tab_dw_dlvry_base(var_work).dlvry_eff_yyyyppdd := rcd_source.dlvry_eff_yyyyppdd;
            tab_dw_dlvry_base(var_work).dlvry_eff_yyyyppw := rcd_source.dlvry_eff_yyyyppw;
            tab_dw_dlvry_base(var_work).dlvry_eff_yyyypp := rcd_source.dlvry_eff_yyyypp;
            tab_dw_dlvry_base(var_work).dlvry_eff_yyyymm := rcd_source.dlvry_eff_yyyymm;
            tab_dw_dlvry_base(var_work).goods_issue_date := rcd_source.goods_issue_date;
            tab_dw_dlvry_base(var_work).goods_issue_yyyyppdd := rcd_source.goods_issue_yyyyppdd;
            tab_dw_dlvry_base(var_work).goods_issue_yyyyppw := rcd_source.goods_issue_yyyyppw;
            tab_dw_dlvry_base(var_work).goods_issue_yyyypp := rcd_source.goods_issue_yyyypp;
            tab_dw_dlvry_base(var_work).goods_issue_yyyymm := rcd_source.goods_issue_yyyymm;
            tab_dw_dlvry_base(var_work).order_doc_num := rcd_source.order_doc_num;
            tab_dw_dlvry_base(var_work).order_doc_line_num := rcd_source.order_doc_line_num;
            tab_dw_dlvry_base(var_work).purch_order_doc_num := rcd_source.purch_order_doc_num;
            tab_dw_dlvry_base(var_work).purch_order_doc_line_num := rcd_source.purch_order_doc_line_num;
            tab_dw_dlvry_base(var_work).company_code := rcd_source.company_code;
            tab_dw_dlvry_base(var_work).sales_org_code := rcd_source.sales_org_code;
            tab_dw_dlvry_base(var_work).distbn_chnl_code := rcd_source.distbn_chnl_code;
            tab_dw_dlvry_base(var_work).division_code := rcd_source.division_code;
            tab_dw_dlvry_base(var_work).doc_currcy_code := rcd_source.doc_currcy_code;
            tab_dw_dlvry_base(var_work).company_currcy_code := rcd_source.company_currcy_code;
            tab_dw_dlvry_base(var_work).exch_rate := rcd_source.exch_rate;
            tab_dw_dlvry_base(var_work).dlvry_type_code := rcd_source.dlvry_type_code;
            tab_dw_dlvry_base(var_work).dlvry_procg_stage := rcd_source.dlvry_procg_stage;
            tab_dw_dlvry_base(var_work).sold_to_cust_code := rcd_source.sold_to_cust_code;
            tab_dw_dlvry_base(var_work).bill_to_cust_code := rcd_source.bill_to_cust_code;
            tab_dw_dlvry_base(var_work).payer_cust_code := rcd_source.payer_cust_code;
            tab_dw_dlvry_base(var_work).ship_to_cust_code := rcd_source.ship_to_cust_code;
            tab_dw_dlvry_base(var_work).matl_code := rcd_source.matl_code;
            tab_dw_dlvry_base(var_work).ods_matl_code := rcd_source.matl_code;
            tab_dw_dlvry_base(var_work).matl_entd := rcd_source.matl_entd;
            tab_dw_dlvry_base(var_work).plant_code := rcd_source.plant_code;
            tab_dw_dlvry_base(var_work).storage_locn_code := rcd_source.storage_locn_code;
            tab_dw_dlvry_base(var_work).dlvry_weight_unit := null;
            tab_dw_dlvry_base(var_work).dlvry_gross_weight := 0;
            tab_dw_dlvry_base(var_work).dlvry_net_weight := 0;
            tab_dw_dlvry_base(var_work).dlvry_uom_code := rcd_source.dlvry_qty_uom_code;
            tab_dw_dlvry_base(var_work).dlvry_base_uom_code := rcd_source.dlvry_qty_base_uom_code;
            tab_dw_dlvry_base(var_work).req_qty := rcd_source.dlvry_qty;
            tab_dw_dlvry_base(var_work).req_qty_base_uom := rcd_source.base_uom_dlvry_qty;
            tab_dw_dlvry_base(var_work).req_qty_gross_tonnes := rcd_source.dlvry_qty_gross_tonnes;
            tab_dw_dlvry_base(var_work).req_qty_net_tonnes := rcd_source.dlvry_qty_net_tonnes;
            tab_dw_dlvry_base(var_work).req_gsv := rcd_source.gsv;
            tab_dw_dlvry_base(var_work).req_gsv_xactn := rcd_source.gsv_xactn;
            tab_dw_dlvry_base(var_work).req_gsv_aud := rcd_source.gsv_aud;
            tab_dw_dlvry_base(var_work).req_gsv_usd := rcd_source.gsv_usd;
            tab_dw_dlvry_base(var_work).req_gsv_eur := rcd_source.gsv_eur;
            tab_dw_dlvry_base(var_work).del_qty := rcd_source.dlvry_qty;
            tab_dw_dlvry_base(var_work).del_qty_base_uom := rcd_source.base_uom_dlvry_qty;
            tab_dw_dlvry_base(var_work).del_qty_gross_tonnes := rcd_source.dlvry_qty_gross_tonnes;
            tab_dw_dlvry_base(var_work).del_qty_net_tonnes := rcd_source.dlvry_qty_net_tonnes;
            tab_dw_dlvry_base(var_work).del_gsv := rcd_source.gsv;
            tab_dw_dlvry_base(var_work).del_gsv_xactn := rcd_source.gsv_xactn;
            tab_dw_dlvry_base(var_work).del_gsv_aud := rcd_source.gsv_aud;
            tab_dw_dlvry_base(var_work).del_gsv_usd := rcd_source.gsv_usd;
            tab_dw_dlvry_base(var_work).del_gsv_eur := rcd_source.gsv_eur;
            tab_dw_dlvry_base(var_work).inv_qty := 0;
            tab_dw_dlvry_base(var_work).inv_qty_base_uom := 0;
            tab_dw_dlvry_base(var_work).inv_qty_gross_tonnes := 0;
            tab_dw_dlvry_base(var_work).inv_qty_net_tonnes := 0;
            tab_dw_dlvry_base(var_work).inv_gsv := 0;
            tab_dw_dlvry_base(var_work).inv_gsv_xactn := 0;
            tab_dw_dlvry_base(var_work).inv_gsv_aud := 0;
            tab_dw_dlvry_base(var_work).inv_gsv_usd := 0;
            tab_dw_dlvry_base(var_work).inv_gsv_eur := 0;
            tab_dw_dlvry_base(var_work).out_qty := rcd_source.dlvry_qty;
            tab_dw_dlvry_base(var_work).out_qty_base_uom := rcd_source.base_uom_dlvry_qty;
            tab_dw_dlvry_base(var_work).out_qty_gross_tonnes := rcd_source.dlvry_qty_gross_tonnes;
            tab_dw_dlvry_base(var_work).out_qty_net_tonnes := rcd_source.dlvry_qty_net_tonnes;
            tab_dw_dlvry_base(var_work).out_gsv := rcd_source.gsv;
            tab_dw_dlvry_base(var_work).out_gsv_xactn := rcd_source.gsv_xactn;
            tab_dw_dlvry_base(var_work).out_gsv_aud := rcd_source.gsv_aud;
            tab_dw_dlvry_base(var_work).out_gsv_usd := rcd_source.gsv_usd;
            tab_dw_dlvry_base(var_work).out_gsv_eur := rcd_source.gsv_eur;
            tab_dw_dlvry_base(var_work).mfanz_icb_flag := rcd_source.mfanz_icb_flag;
            tab_dw_dlvry_base(var_work).demand_plng_grp_division_code := rcd_source.demand_plng_grp_division_code;
            if rcd_source.dlvry_line_status = 'INVOICED' then
               tab_dw_dlvry_base(var_work).dlvry_line_status := '*INVOICED';
            end if;
            if tab_dw_dlvry_base(var_work).dlvry_line_status = '*INVOICED' then
               tab_dw_dlvry_base(var_work).inv_qty := rcd_source.dlvry_qty;
               tab_dw_dlvry_base(var_work).inv_qty_base_uom := rcd_source.base_uom_dlvry_qty;
               tab_dw_dlvry_base(var_work).inv_qty_gross_tonnes := rcd_source.dlvry_qty_gross_tonnes;
               tab_dw_dlvry_base(var_work).inv_qty_net_tonnes := rcd_source.dlvry_qty_net_tonnes;
               tab_dw_dlvry_base(var_work).inv_gsv := rcd_source.gsv;
               tab_dw_dlvry_base(var_work).inv_gsv_xactn := rcd_source.gsv_xactn;
               tab_dw_dlvry_base(var_work).inv_gsv_aud := rcd_source.gsv_aud;
               tab_dw_dlvry_base(var_work).inv_gsv_usd := rcd_source.gsv_usd;
               tab_dw_dlvry_base(var_work).inv_gsv_eur := rcd_source.gsv_eur;
               tab_dw_dlvry_base(var_work).out_qty := 0;
               tab_dw_dlvry_base(var_work).out_qty_base_uom := 0;
               tab_dw_dlvry_base(var_work).out_qty_gross_tonnes := 0;
               tab_dw_dlvry_base(var_work).out_qty_net_tonnes := 0;
               tab_dw_dlvry_base(var_work).out_gsv := 0;
               tab_dw_dlvry_base(var_work).out_gsv_xactn := 0;
               tab_dw_dlvry_base(var_work).out_gsv_aud := 0;
               tab_dw_dlvry_base(var_work).out_gsv_usd := 0;
               tab_dw_dlvry_base(var_work).out_gsv_eur := 0;
            end if;
         end if;

         /*-*/
         /* Insert the bulk target data when required
         /*-*/
         if (var_exit = false and var_work = var_size) or
            (var_exit = true and var_work > 0) then
            forall idx in 1..var_work
               insert into dw_dlvry_base values tab_dw_dlvry_base(idx);
            commit;
            var_work := 0;
         end if;

         /*-*/
         /* Exit the loop when required
         /*-*/
         if var_exit = true then
            exit;
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
         raise_application_error(-20000, 'FATAL ERROR - CDW - CONVERTER - DLVRY_FACT Procedure -' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_dlvry_fact;

   /**********************************************************/
   /* This procedure performs the execute sales fact routine */
   /**********************************************************/
   procedure execute_sales_fact is

      /*-*/
      /* Local definitions
      /*-*/
      var_size number(5,0);
      var_work number(5,0);
      var_exit boolean;
      type rcd_dw_sales_base is table of dw_sales_base%rowtype index by binary_integer;
      tab_dw_sales_base rcd_dw_sales_base;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_source is 
         select t01.*,
                t02.mars_week as creatn_yyyyppw,
                t02.mars_period as creatn_yyyypp,
                (t02.year_num * 100) + t02.month_num as creatn_yyyymm
           from sales_fact t01,
                mars_date t02
          where t01.creatn_date = t02.calendar_date(+)
          order by t01.creatn_date asc;
      rcd_source csr_source%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve rows from the source
      /*-*/
      var_size := 1000;
      var_work := 0;
      var_exit := false;
      open csr_source;
      loop
         fetch csr_source into rcd_source;
         if csr_source%notfound then
            var_exit := true;
         end if;

         /*-*/
         /* Load the bulk arrays when required
         /*-*/
         if var_exit = false then
            var_work := var_work + 1;
            tab_dw_sales_base(var_work).billing_doc_num := rcd_source.billing_doc_num;
            tab_dw_sales_base(var_work).billing_doc_line_num := rcd_source.billing_doc_line_num;
            tab_dw_sales_base(var_work).billing_trace_seqn := 0;
            tab_dw_sales_base(var_work).creatn_date := rcd_source.creatn_date;
            tab_dw_sales_base(var_work).creatn_yyyyppdd := rcd_source.creatn_yyyyppdd;
            tab_dw_sales_base(var_work).creatn_yyyyppw := rcd_source.creatn_yyyyppw;
            tab_dw_sales_base(var_work).creatn_yyyypp := rcd_source.creatn_yyyypp;
            tab_dw_sales_base(var_work).creatn_yyyymm := rcd_source.creatn_yyyymm;
            tab_dw_sales_base(var_work).billing_eff_date := rcd_source.billing_eff_date;
            tab_dw_sales_base(var_work).billing_eff_yyyyppdd := rcd_source.billing_eff_yyyyppdd;
            tab_dw_sales_base(var_work).billing_eff_yyyyppw := rcd_source.billing_eff_yyyyppw;
            tab_dw_sales_base(var_work).billing_eff_yyyypp := rcd_source.billing_eff_yyyypp;
            tab_dw_sales_base(var_work).billing_eff_yyyymm := rcd_source.billing_eff_yyyymm;
            tab_dw_sales_base(var_work).order_doc_num := rcd_source.order_doc_num;
            tab_dw_sales_base(var_work).order_doc_line_num := rcd_source.order_doc_line_num;
            tab_dw_sales_base(var_work).purch_order_doc_num := rcd_source.purch_order_doc_num;
            tab_dw_sales_base(var_work).purch_order_doc_line_num := rcd_source.purch_order_doc_line_num;
            tab_dw_sales_base(var_work).dlvry_doc_num := rcd_source.dlvry_doc_num;
            tab_dw_sales_base(var_work).dlvry_doc_line_num := rcd_source.dlvry_doc_line_num;
            tab_dw_sales_base(var_work).company_code := rcd_source.company_code;
            tab_dw_sales_base(var_work).hdr_sales_org_code := rcd_source.hdr_sales_org_code;
            tab_dw_sales_base(var_work).hdr_distbn_chnl_code := rcd_source.hdr_distbn_chnl_code;
            tab_dw_sales_base(var_work).hdr_division_code := rcd_source.hdr_division_code;
            tab_dw_sales_base(var_work).gen_sales_org_code := rcd_source.gen_sales_org_code;
            tab_dw_sales_base(var_work).gen_distbn_chnl_code := rcd_source.gen_distbn_chnl_code;
            tab_dw_sales_base(var_work).gen_division_code := rcd_source.gen_division_code;
            tab_dw_sales_base(var_work).doc_currcy_code := rcd_source.doc_currcy_code;
            tab_dw_sales_base(var_work).company_currcy_code := rcd_source.company_currcy_code;
            tab_dw_sales_base(var_work).exch_rate := rcd_source.exch_rate;
            tab_dw_sales_base(var_work).invc_type_code := rcd_source.invc_type_code;
            tab_dw_sales_base(var_work).order_type_code := rcd_source.order_type_code;
            tab_dw_sales_base(var_work).order_reasn_code := rcd_source.order_reasn_code;
            tab_dw_sales_base(var_work).order_usage_code := rcd_source.order_usage_code;
            tab_dw_sales_base(var_work).sold_to_cust_code := rcd_source.sold_to_cust_code;
            tab_dw_sales_base(var_work).bill_to_cust_code := rcd_source.bill_to_cust_code;
            tab_dw_sales_base(var_work).payer_cust_code := rcd_source.payer_cust_code;
            tab_dw_sales_base(var_work).ship_to_cust_code := rcd_source.ship_to_cust_code;
            tab_dw_sales_base(var_work).matl_code := rcd_source.matl_code;
            tab_dw_sales_base(var_work).ods_matl_code := rcd_source.matl_code;
            tab_dw_sales_base(var_work).matl_entd := rcd_source.matl_entd;
            tab_dw_sales_base(var_work).plant_code := rcd_source.plant_code;
            tab_dw_sales_base(var_work).storage_locn_code := rcd_source.storage_locn_code;
            tab_dw_sales_base(var_work).order_qty := rcd_source.order_qty;
            tab_dw_sales_base(var_work).billed_weight_unit := null;
            tab_dw_sales_base(var_work).billed_gross_weight := 0;
            tab_dw_sales_base(var_work).billed_net_weight := 0;
            tab_dw_sales_base(var_work).billed_uom_code := rcd_source.billed_qty_uom_code;
            tab_dw_sales_base(var_work).billed_base_uom_code := rcd_source.billed_qty_base_uom_code;
            tab_dw_sales_base(var_work).billed_qty := rcd_source.billed_qty;
            tab_dw_sales_base(var_work).billed_qty_base_uom := rcd_source.base_uom_billed_qty;
            tab_dw_sales_base(var_work).billed_qty_gross_tonnes := rcd_source.billed_qty_gross_tonnes;
            tab_dw_sales_base(var_work).billed_qty_net_tonnes := rcd_source.billed_qty_net_tonnes;
            tab_dw_sales_base(var_work).billed_gsv := rcd_source.gsv;
            tab_dw_sales_base(var_work).billed_gsv_xactn := rcd_source.gsv_xactn;
            tab_dw_sales_base(var_work).billed_gsv_aud := rcd_source.gsv_aud;
            tab_dw_sales_base(var_work).billed_gsv_usd := rcd_source.gsv_usd;
            tab_dw_sales_base(var_work).billed_gsv_eur := rcd_source.gsv_eur;
            tab_dw_sales_base(var_work).mfanz_icb_flag := rcd_source.mfanz_icb_flag;
            tab_dw_sales_base(var_work).demand_plng_grp_division_code := rcd_source.demand_plng_grp_division_code;
         end if;

         /*-*/
         /* Insert the bulk target data when required
         /*-*/
         if (var_exit = false and var_work = var_size) or
            (var_exit = true and var_work > 0) then
            forall idx in 1..var_work
               insert into dw_sales_base values tab_dw_sales_base(idx);
            commit;
            var_work := 0;
         end if;

         /*-*/
         /* Exit the loop when required
         /*-*/
         if var_exit = true then
            exit;
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
         raise_application_error(-20000, 'FATAL ERROR - CDW - CONVERTER - SALES_FACT Procedure -' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_sales_fact;

end converter;
/  