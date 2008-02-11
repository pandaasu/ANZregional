/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : dw_converter
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
create or replace package dw_converter as

   /**/
   /* Public declarations
   /**/
   procedure execute_purch_order_fact(fr_yyyypp in varchar2, to_yyyypp in varchar2);
   procedure execute_order_fact(fr_yyyypp in varchar2, to_yyyypp in varchar2);
   procedure execute_dlvry_fact(fr_yyyypp in varchar2, to_yyyypp in varchar2);
   procedure execute_sales_fact(fr_yyyypp in varchar2, to_yyyypp in varchar2);

end dw_converter;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_converter as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*******************************************************************/
   /* This procedure performs the execute purchase order fact routine */
   /*******************************************************************/
   procedure execute_purch_order_fact(fr_yyyypp in varchar2, to_yyyypp in varchar2) is

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
            and substr(t01.purch_order_eff_yyyyppdd,1,6) >= fr_yyyypp
            and substr(t01.purch_order_eff_yyyyppdd,1,6) <= to_yyyypp
            and t01.purch_order_doc_num not in (select purch_order_doc_num from dw_purch_base)
          order by t01.purch_order_eff_yyyyppdd asc;
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
            tab_dw_purch_base(var_work).doc_currcy_code := rcd_source.doc_currcy_code;
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
   procedure execute_order_fact(fr_yyyypp in varchar2, to_yyyypp in varchar2) is

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
            and substr(t01.creatn_yyyyppdd,1,6) >= fr_yyyypp
            and substr(t01.creatn_yyyyppdd,1,6) <= to_yyyypp
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
            tab_dw_order_base(var_work).sales_org_code := rcd_source.hdr_sales_org_code;
            tab_dw_order_base(var_work).distbn_chnl_code := rcd_source.hdr_distbn_chnl_code;
            tab_dw_order_base(var_work).division_code := rcd_source.hdr_division_code;
            tab_dw_order_base(var_work).doc_currcy_code := rcd_source.doc_currcy_code;
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
            tab_dw_order_base(var_work).con_qty := rcd_source.confirmed_qty;
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
   procedure execute_dlvry_fact(fr_yyyypp in varchar2, to_yyyypp in varchar2) is

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
            and substr(t01.creatn_yyyyppdd,1,6) >= fr_yyyypp
            and substr(t01.creatn_yyyyppdd,1,6) <= to_yyyypp
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
            tab_dw_dlvry_base(var_work).sales_org_code := rcd_source.hdr_sales_org_code;
            tab_dw_dlvry_base(var_work).distbn_chnl_code := rcd_source.det_distbn_chnl_code;
            tab_dw_dlvry_base(var_work).division_code := rcd_source.det_division_code;
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
   procedure execute_sales_fact(fr_yyyypp in varchar2, to_yyyypp in varchar2) is

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
            and substr(t01.creatn_yyyyppdd,1,6) >= fr_yyyypp
            and substr(t01.creatn_yyyyppdd,1,6) <= to_yyyypp
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

end dw_converter;
/  