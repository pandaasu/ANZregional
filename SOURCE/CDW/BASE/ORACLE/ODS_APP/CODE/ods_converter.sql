/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : ods_converter
 Owner   : ods_app

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
create or replace package ods_converter as

   /**/
   /* Public declarations
   /**/
   procedure execute_purch_order_trace(fr_yyyymmdd in varchar2);
   procedure execute_order_trace(fr_yyyymmdd in varchar2);
   procedure execute_dlvry_trace(fr_yyyymmdd in varchar2);
   procedure execute_sales_trace(fr_yyyymmdd in varchar2);

end ods_converter;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_converter as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /********************************************************************/
   /* This procedure performs the execute purchase order trace routine */
   /********************************************************************/
   procedure execute_purch_order_trace(fr_yyyymmdd in varchar2) is

      /*-*/
      /* Local variables
      /*-*/
      var_sequence number;
      rcd_sap_sto_po_trace sap_sto_po_trace%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_ods_list is
         select t01.belnr
           from sap_sto_po_hdr t01,
               (select belnr, orgid from sap_sto_po_org where qualf = '013') t02
          where t01.belnr = t02.belnr
            and ((t02.orgid = 'ZNB' and to_char(t01.sap_sto_po_hdr_lupdt,'yyyymmdd') >= fr_yyyymmdd) or t02.orgid != 'ZNB');
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
                t04.source_plant_code,
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
                       t03.source_plant_code,
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
                       (select trim(substr(t01.z_data,4,4)) as source_plant_code,
                               trim(substr(t01.z_data,42,10)) as cust_code,
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
                         where t01.belnr = rcd_ods_list.belnr
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
         /* Initialise the sequence for current stream action
         /*-*/
         select sap_trace_sequence.nextval into var_sequence from dual;

         /*-*/
         /* Initialise the purchase order trace data
         /*-*/
         rcd_sap_sto_po_trace.trace_seqn := var_sequence;
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
            rcd_sap_sto_po_trace.source_plant_code := rcd_ods_data.source_plant_code;
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
   procedure execute_order_trace(fr_yyyymmdd in varchar2) is

      /*-*/
      /* Local variables
      /*-*/
      var_sequence number;
      rcd_sap_sal_ord_trace sap_sal_ord_trace%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_ods_list is
         select t01.belnr
           from sap_sal_ord_hdr t01,
                (select belnr from sap_sal_ord_dat where iddat = '002' and datum >= fr_yyyymmdd) t02
          where t01.belnr = t02.belnr
            and t01.belnr not in (select order_doc_num from sap_sal_ord_trace);
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
                           and t01.belnr = rcd_ods_list.belnr
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
         /* Initialise the sequence for current stream action
         /*-*/
         select sap_trace_sequence.nextval into var_sequence from dual;

         /*-*/
         /* Initialise the sales order trace data
         /*-*/
         rcd_sap_sal_ord_trace.trace_seqn := var_sequence;
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
   procedure execute_dlvry_trace(fr_yyyymmdd in varchar2) is

      /*-*/
      /* Local variables
      /*-*/
      var_sequence number;
      rcd_sap_del_trace sap_del_trace%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_ods_list is
         select t01.vbeln
           from sap_del_hdr t01,
                (select vbeln from sap_del_tim where qualf = '007' and nvl(ltrim(isdd,'0'),ltrim(ntanf,'0')) >= fr_yyyymmdd) t02
          where t01.vbeln = t02.vbeln
            and t01.vbeln not in (select dlvry_doc_num from sap_del_trace);
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
                               sum(nvl(t01.brgew,0)) as dlvry_gross_weight,
                               sum(nvl(t01.ntgew,0)) as dlvry_net_weight,
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
         /* Initialise the sequence for current stream action
         /*-*/
         select sap_trace_sequence.nextval into var_sequence from dual;

         /*-*/
         /* Initialise the delivery trace data
         /*-*/
         rcd_sap_del_trace.trace_seqn := var_sequence;
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
   procedure execute_sales_trace(fr_yyyymmdd in varchar2) is

      /*-*/
      /* Local variables
      /*-*/
      var_sequence number;
      rcd_sap_inv_trace sap_inv_trace%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_ods_list is
         select t01.belnr
           from sap_inv_hdr t01,
                (select belnr from sap_inv_dat where iddat = '015' and datum >= fr_yyyymmdd) t02
          where t01.belnr = t02.belnr;
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
         /* Initialise the sequence for current stream action
         /*-*/
         select sap_trace_sequence.nextval into var_sequence from dual;

         /*-*/
         /* Initialise the invoice trace data
         /*-*/
         rcd_sap_inv_trace.trace_seqn := var_sequence;
         rcd_sap_inv_trace.trace_date := sysdate;
         rcd_sap_inv_trace.trace_status := '*ACTIVE';

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
            /* Set the trace status
            /*-*/
            rcd_sap_inv_trace.trace_status := '*ACTIVE';

            /*-*/
            /* Deleted invoice line
            /* **notes** no invoice lines found
            /*-*/
            if rcd_ods_data.billing_doc_num is null then
               rcd_sap_inv_trace.trace_status := '*DELETED';
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

end ods_converter;
/  