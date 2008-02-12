/******************/
/* Package Header */
/******************/
create or replace package dw_utility as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_utility
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Utility Procedures and Functions

    This package contain utility procedures and functions. 

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/11   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure purch_base_status(par_purch_order_doc_num in varchar2, par_purch_order_doc_line_num in varchar2);
   procedure order_base_status(par_order_doc_num in varchar2, par_order_doc_line_num in varchar2);
   procedure dlvry_base_status(par_dlvry_doc_num in varchar2, par_dlvry_doc_line_num in varchar2);
   procedure calculate_quantity;
   function convert_buom_to_uom(par_ods_matl_code in varchar2, par_uom_code in varchar2, par_qty_buom in number) return number;
   function convert_uom_to_buom(par_ods_matl_code in varchar2, par_uom_code in varchar2, par_qty_uom in number) return number;

   /*-*/
   /* Public definitions
   /*-*/
   type rcd_qty_fact is record(ods_matl_code varchar2(18 char),
                               uom_code varchar2(10 char),
                               uom_qty number,
                               base_uom_code varchar2(10 char),
                               qty_base_uom number,
                               qty_gross_tonnes number,
                               qty_net_tonnes number);
   pkg_qty_fact rcd_qty_fact;

end dw_utility;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_utility as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /******************************************************************/
   /* This procedure performs the purchase order base status routine */
   /******************************************************************/
   procedure purch_base_status(par_purch_order_doc_num in varchar2, par_purch_order_doc_line_num in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_purch_base is
         select t01.*
           from dw_purch_base t01
          where t01.purch_order_doc_num = par_purch_order_doc_num
            and t01.purch_order_doc_line_num = par_purch_order_doc_line_num;
      rcd_purch_base csr_purch_base%rowtype;

      cursor csr_dlvry_base is
         select t01.*
           from dw_dlvry_base t01
          where t01.purch_order_doc_num = rcd_purch_base.purch_order_doc_num
            and t01.purch_order_doc_line_num = rcd_purch_base.purch_order_doc_line_num;
      rcd_dlvry_base csr_dlvry_base%rowtype;

      cursor csr_sales_base is
         select t01.*
           from dw_sales_base t01
          where t01.purch_order_doc_num = rcd_purch_base.purch_order_doc_num
            and t01.purch_order_doc_line_num = rcd_purch_base.purch_order_doc_line_num;
      rcd_sales_base csr_sales_base%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*----------------------*/
      /* PURCH_BASE Retrieval */
      /*----------------------*/

      /*-*/
      /* Retrieve the PURCH_BASE row
      /*-*/
      open csr_purch_base;
      fetch csr_purch_base into rcd_purch_base;
      if csr_purch_base%notfound then
         return;
      end if;
      close csr_purch_base;

      /*---------------------------*/
      /* PURCH_BASE Initialisation */
      /*---------------------------*/

      /*-*/
      /* Reset the purchase order values
      /*-*/
      rcd_purch_base.purch_order_line_status := '*OUTSTANDING';
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

      /*----------------------*/
      /* DLVRY_BASE Alignment */
      /*----------------------*/

      /*-*/
      /* Retrieve the related DLVRY_BASE rows and update the PURCH_BASE row values
      /* 1. Purchase order material and UOM is same as delivered material and UOM then purchase order delivery quantity is increased by delivery quantity
      /* 2. Purchase order material or UOM differs from delivered material or UOM then purchase order delivery quantity is increased by delivery base UOM quantity
      /*    converted into the ordered material UOM. This assumes that both materials belong to the same representative material
      /*    and that the conversion is logical. 
      /*-*/
      open csr_dlvry_base;
      loop
         fetch csr_dlvry_base into rcd_dlvry_base;
         if csr_dlvry_base%notfound then
            exit;
         end if;

         /*-*/
         /* Delivery request values
         /*-*/
         if (rcd_purch_base.ods_matl_code = rcd_dlvry_base.ods_matl_code and
             rcd_purch_base.purch_order_uom_code = rcd_dlvry_base.dlvry_uom_code) then
            rcd_purch_base.req_qty := rcd_purch_base.req_qty + rcd_dlvry_base.req_qty;
         else
            rcd_purch_base.req_qty := rcd_purch_base.req_qty + convert_buom_to_uom(rcd_purch_base.ods_matl_code, rcd_purch_base.purch_order_uom_code, rcd_dlvry_base.req_qty_base_uom);
         end if;
         rcd_purch_base.req_gsv := rcd_purch_base.req_gsv + rcd_dlvry_base.req_gsv;
         rcd_purch_base.req_gsv_xactn := rcd_purch_base.req_gsv_xactn + rcd_dlvry_base.req_gsv_xactn;
         rcd_purch_base.req_gsv_aud := rcd_purch_base.req_gsv_aud + rcd_dlvry_base.req_gsv_aud;
         rcd_purch_base.req_gsv_usd := rcd_purch_base.req_gsv_usd + rcd_dlvry_base.req_gsv_usd;
         rcd_purch_base.req_gsv_eur := rcd_purch_base.req_gsv_eur + rcd_dlvry_base.req_gsv_eur;

         /*-*/
         /* Delivery confirm values
         /*-*/
         if (rcd_purch_base.ods_matl_code = rcd_dlvry_base.ods_matl_code and
             rcd_purch_base.purch_order_uom_code = rcd_dlvry_base.dlvry_uom_code) then
            rcd_purch_base.del_qty := rcd_purch_base.del_qty + rcd_dlvry_base.del_qty;
         else
            rcd_purch_base.del_qty := rcd_purch_base.del_qty + convert_buom_to_uom(rcd_purch_base.ods_matl_code, rcd_purch_base.purch_order_uom_code, rcd_dlvry_base.del_qty_base_uom);
         end if;
         rcd_purch_base.del_gsv := rcd_purch_base.del_gsv + rcd_dlvry_base.del_gsv;
         rcd_purch_base.del_gsv_xactn := rcd_purch_base.del_gsv_xactn + rcd_dlvry_base.del_gsv_xactn;
         rcd_purch_base.del_gsv_aud := rcd_purch_base.del_gsv_aud + rcd_dlvry_base.del_gsv_aud;
         rcd_purch_base.del_gsv_usd := rcd_purch_base.del_gsv_usd + rcd_dlvry_base.del_gsv_usd;
         rcd_purch_base.del_gsv_eur := rcd_purch_base.del_gsv_eur + rcd_dlvry_base.del_gsv_eur;

      end loop;
      close csr_dlvry_base;

      /*-*/
      /* Update the GRD delivery request quantities
      /*-*/
      pkg_qty_fact.ods_matl_code := rcd_purch_base.ods_matl_code;
      pkg_qty_fact.uom_code := rcd_purch_base.purch_order_uom_code;
      pkg_qty_fact.uom_qty := rcd_purch_base.req_qty;
      calculate_quantity;
      rcd_purch_base.req_qty_base_uom := pkg_qty_fact.qty_base_uom;
      rcd_purch_base.req_qty_gross_tonnes := pkg_qty_fact.qty_gross_tonnes;
      rcd_purch_base.req_qty_net_tonnes := pkg_qty_fact.qty_net_tonnes;

      /*-*/
      /* Update the GRD delivery confirm quantities
      /*-*/
      pkg_qty_fact.ods_matl_code := rcd_purch_base.ods_matl_code;
      pkg_qty_fact.uom_code := rcd_purch_base.purch_order_uom_code;
      pkg_qty_fact.uom_qty := rcd_purch_base.del_qty;
      calculate_quantity;
      rcd_purch_base.del_qty_base_uom := pkg_qty_fact.qty_base_uom;
      rcd_purch_base.del_qty_gross_tonnes := pkg_qty_fact.qty_gross_tonnes;
      rcd_purch_base.del_qty_net_tonnes := pkg_qty_fact.qty_net_tonnes;

      /*-*/
      /* Calculate the outstanding values when required
      /* 1. Purchase order only becomes outstanding when confirmed
      /*-*/
      if not(rcd_purch_base.confirmed_date is null) then

         /*-*/
         /* Update the purchase order outstanding quantities
         /*-*/
         rcd_purch_base.out_qty := rcd_purch_base.con_qty - rcd_purch_base.req_qty;
         rcd_purch_base.out_qty_base_uom := rcd_purch_base.con_qty_base_uom - rcd_purch_base.req_qty_base_uom;
         rcd_purch_base.out_qty_gross_tonnes := rcd_purch_base.con_qty_gross_tonnes - rcd_purch_base.req_qty_gross_tonnes;
         rcd_purch_base.out_qty_net_tonnes := rcd_purch_base.con_qty_net_tonnes - rcd_purch_base.req_qty_net_tonnes;
         rcd_purch_base.out_gsv := rcd_purch_base.con_gsv - rcd_purch_base.req_gsv;
         rcd_purch_base.out_gsv_xactn := rcd_purch_base.con_gsv_xactn - rcd_purch_base.req_gsv_xactn;
         rcd_purch_base.out_gsv_aud := rcd_purch_base.con_gsv_aud - rcd_purch_base.req_gsv_aud;
         rcd_purch_base.out_gsv_usd := rcd_purch_base.con_gsv_usd - rcd_purch_base.req_gsv_usd;
         rcd_purch_base.out_gsv_eur := rcd_purch_base.con_gsv_eur - rcd_purch_base.req_gsv_eur;

         /*-*/
         /* Update the purchase order line status when no outstanding quantity (*DELIVERED)
         /*-*/
         if rcd_purch_base.out_qty = 0 then
            rcd_purch_base.purch_order_line_status := '*DELIVERED';
         end if;

      end if;

      /*----------------------*/
      /* SALES_BASE Alignment */
      /*----------------------*/

      /*-*/
      /* Retrieve the related SALES_BASE rows and update the PURCH_BASE row values
      /* 1. Purchase order material and UOM is same as billed material and UOM then purchase order billed quantity is increased by billed quantity
      /* 2. Purchase order material or UOM differs from billed material or UOM then purchase order billed quantity is increased by billed base UOM quantity
      /*    converted into the ordered material UOM. This assumes that both materials belong to the same representative material
      /*    and that the conversion is logical. 
      /*-*/
      open csr_sales_base;
      loop
         fetch csr_sales_base into rcd_sales_base;
         if csr_sales_base%notfound then
            exit;
         end if;
         if (rcd_purch_base.ods_matl_code = rcd_sales_base.ods_matl_code and
             rcd_purch_base.purch_order_uom_code = rcd_sales_base.billed_uom_code) then
            rcd_purch_base.inv_qty := rcd_purch_base.inv_qty + rcd_sales_base.billed_qty;
         else
            rcd_purch_base.inv_qty := rcd_purch_base.inv_qty + convert_buom_to_uom(rcd_purch_base.ods_matl_code, rcd_purch_base.purch_order_uom_code, rcd_sales_base.billed_qty_base_uom);
         end if;
         rcd_purch_base.inv_gsv := rcd_purch_base.inv_gsv + rcd_sales_base.billed_gsv;
         rcd_purch_base.inv_gsv_xactn := rcd_purch_base.inv_gsv_xactn + rcd_sales_base.billed_gsv_xactn;
         rcd_purch_base.inv_gsv_aud := rcd_purch_base.inv_gsv_aud + rcd_sales_base.billed_gsv_aud;
         rcd_purch_base.inv_gsv_usd := rcd_purch_base.inv_gsv_usd + rcd_sales_base.billed_gsv_usd;
         rcd_purch_base.inv_gsv_eur := rcd_purch_base.inv_gsv_eur + rcd_sales_base.billed_gsv_eur;
      end loop;
      close csr_sales_base;

      /*-*/
      /* Update the GRD billed quantities
      /*-*/
      pkg_qty_fact.ods_matl_code := rcd_purch_base.ods_matl_code;
      pkg_qty_fact.uom_code := rcd_purch_base.purch_order_uom_code;
      pkg_qty_fact.uom_qty := rcd_purch_base.inv_qty;
      calculate_quantity;
      rcd_purch_base.inv_qty_base_uom := pkg_qty_fact.qty_base_uom;
      rcd_purch_base.inv_qty_gross_tonnes := pkg_qty_fact.qty_gross_tonnes;
      rcd_purch_base.inv_qty_net_tonnes := pkg_qty_fact.qty_net_tonnes;

      /*-*/
      /* Update the purchase order line status (*INVOICED)
      /*-*/
      if rcd_purch_base.purch_order_line_status = '*DELIVERED' then
         if rcd_purch_base.del_qty = rcd_purch_base.inv_qty then
            rcd_purch_base.purch_order_line_status := '*INVOICED';
         end if;
      end if;

      /*-------------------*/
      /* PURCH_BASE Update */
      /*-------------------*/

      /*-*/
      /* Update the purchase order base row
      /*-*/
      update dw_purch_base
         set purch_order_line_status = rcd_purch_base.purch_order_line_status,
             req_qty = rcd_purch_base.req_qty,
             req_qty_base_uom = rcd_purch_base.req_qty_base_uom,
             req_qty_gross_tonnes = rcd_purch_base.req_qty_gross_tonnes,
             req_qty_net_tonnes = rcd_purch_base.req_qty_net_tonnes,
             req_gsv = rcd_purch_base.req_gsv,
             req_gsv_xactn = rcd_purch_base.req_gsv_xactn,
             req_gsv_aud = rcd_purch_base.req_gsv_aud,
             req_gsv_usd = rcd_purch_base.req_gsv_usd,
             req_gsv_eur = rcd_purch_base.req_gsv_eur,
             del_qty = rcd_purch_base.del_qty,
             del_qty_base_uom = rcd_purch_base.del_qty_base_uom,
             del_qty_gross_tonnes = rcd_purch_base.del_qty_gross_tonnes,
             del_qty_net_tonnes = rcd_purch_base.del_qty_net_tonnes,
             del_gsv = rcd_purch_base.del_gsv,
             del_gsv_xactn = rcd_purch_base.del_gsv_xactn,
             del_gsv_aud = rcd_purch_base.del_gsv_aud,
             del_gsv_usd = rcd_purch_base.del_gsv_usd,
             del_gsv_eur = rcd_purch_base.del_gsv_eur,
             inv_qty = rcd_purch_base.inv_qty,
             inv_qty_base_uom = rcd_purch_base.inv_qty_base_uom,
             inv_qty_gross_tonnes = rcd_purch_base.inv_qty_gross_tonnes,
             inv_qty_net_tonnes = rcd_purch_base.inv_qty_net_tonnes,
             inv_gsv = rcd_purch_base.inv_gsv,
             inv_gsv_xactn = rcd_purch_base.inv_gsv_xactn,
             inv_gsv_aud = rcd_purch_base.inv_gsv_aud,
             inv_gsv_usd = rcd_purch_base.inv_gsv_usd,
             inv_gsv_eur = rcd_purch_base.inv_gsv_eur,
             out_qty = rcd_purch_base.out_qty,
             out_qty_base_uom = rcd_purch_base.out_qty_base_uom,
             out_qty_gross_tonnes = rcd_purch_base.out_qty_gross_tonnes,
             out_qty_net_tonnes = rcd_purch_base.out_qty_net_tonnes,
             out_gsv = rcd_purch_base.out_gsv,
             out_gsv_xactn = rcd_purch_base.out_gsv_xactn,
             out_gsv_aud = rcd_purch_base.out_gsv_aud,
             out_gsv_usd = rcd_purch_base.out_gsv_usd,
             out_gsv_eur = rcd_purch_base.out_gsv_eur
       where purch_order_doc_num = rcd_purch_base.purch_order_doc_num
         and purch_order_doc_line_num = rcd_purch_base.purch_order_doc_line_num;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purch_base_status;

   /*********************************************************/
   /* This procedure performs the order base status routine */
   /*********************************************************/
   procedure order_base_status(par_order_doc_num in varchar2, par_order_doc_line_num in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_order_base is
         select t01.*
           from dw_order_base t01
          where t01.order_doc_num = par_order_doc_num
            and t01.order_doc_line_num = par_order_doc_line_num;
      rcd_order_base csr_order_base%rowtype;

      cursor csr_dlvry_base is
         select t01.*
           from dw_dlvry_base t01
          where t01.order_doc_num = rcd_order_base.order_doc_num
            and t01.order_doc_line_num = rcd_order_base.order_doc_line_num;
      rcd_dlvry_base csr_dlvry_base%rowtype;

      cursor csr_sales_base is
         select t01.*
           from dw_sales_base t01
          where t01.order_doc_num = rcd_order_base.order_doc_num
            and t01.order_doc_line_num = rcd_order_base.order_doc_line_num;
      rcd_sales_base csr_sales_base%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*----------------------*/
      /* ORDER_BASE Retrieval */
      /*----------------------*/

      /*-*/
      /* Retrieve the ORDER_BASE row
      /*-*/
      open csr_order_base;
      fetch csr_order_base into rcd_order_base;
      if csr_order_base%notfound then
         return;
      end if;
      close csr_order_base;

      /*---------------------------*/
      /* ORDER_BASE Initialisation */
      /*---------------------------*/

      /*-*/
      /* Reset the order values
      /*-*/
      rcd_order_base.order_line_status := '*OUTSTANDING';
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

      /*---------------------------------*/
      /* ORDER_BASE - APO Zero Confirmed */
      /*---------------------------------*/

      /*-*/
      /* Update the order base row and return
      /*-*/
      if rcd_order_base.order_line_rejectn_code = 'ZA' then
         update dw_order_base
            set order_line_status = '*UNALLOCATED'
          where order_doc_num = rcd_order_base.order_doc_num
            and order_doc_line_num = rcd_order_base.order_doc_line_num;
          return;
      end if;

      /*----------------------*/
      /* DLVRY_BASE Alignment */
      /*----------------------*/

      /*-*/
      /* Retrieve the related DLVRY_BASE rows and update the ORDER_BASE row values
      /* 1. Order material and UOM is same as delivered material and UOM then order delivery quantity is increased by delivery quantity
      /* 2. Order material or UOM differs from delivered material or UOM then order delivery quantity is increased by delivery base UOM quantity
      /*    converted into the ordered material UOM. This assumes that both materials belong to the same representative material
      /*    and that the conversion is logical. 
      /*-*/
      open csr_dlvry_base;
      loop
         fetch csr_dlvry_base into rcd_dlvry_base;
         if csr_dlvry_base%notfound then
            exit;
         end if;

         /*-*/
         /* Delivery request values
         /*-*/
         if (rcd_order_base.ods_matl_code = rcd_dlvry_base.ods_matl_code and
             rcd_order_base.order_uom_code = rcd_dlvry_base.dlvry_uom_code) then
            rcd_order_base.req_qty := rcd_order_base.req_qty + rcd_dlvry_base.req_qty;
         else
            rcd_order_base.req_qty := rcd_order_base.req_qty + convert_buom_to_uom(rcd_order_base.ods_matl_code, rcd_order_base.order_uom_code, rcd_dlvry_base.req_qty_base_uom);
         end if;
         rcd_order_base.req_gsv := rcd_order_base.req_gsv + rcd_dlvry_base.req_gsv;
         rcd_order_base.req_gsv_xactn := rcd_order_base.req_gsv_xactn + rcd_dlvry_base.req_gsv_xactn;
         rcd_order_base.req_gsv_aud := rcd_order_base.req_gsv_aud + rcd_dlvry_base.req_gsv_aud;
         rcd_order_base.req_gsv_usd := rcd_order_base.req_gsv_usd + rcd_dlvry_base.req_gsv_usd;
         rcd_order_base.req_gsv_eur := rcd_order_base.req_gsv_eur + rcd_dlvry_base.req_gsv_eur;

         /*-*/
         /* Delivery confirm values
         /*-*/
         if (rcd_order_base.ods_matl_code = rcd_dlvry_base.ods_matl_code and
             rcd_order_base.order_uom_code = rcd_dlvry_base.dlvry_uom_code) then
            rcd_order_base.del_qty := rcd_order_base.del_qty + rcd_dlvry_base.del_qty;
         else
            rcd_order_base.del_qty := rcd_order_base.del_qty + convert_buom_to_uom(rcd_order_base.ods_matl_code, rcd_order_base.order_uom_code, rcd_dlvry_base.del_qty_base_uom);
         end if;
         rcd_order_base.del_gsv := rcd_order_base.del_gsv + rcd_dlvry_base.del_gsv;
         rcd_order_base.del_gsv_xactn := rcd_order_base.del_gsv_xactn + rcd_dlvry_base.del_gsv_xactn;
         rcd_order_base.del_gsv_aud := rcd_order_base.del_gsv_aud + rcd_dlvry_base.del_gsv_aud;
         rcd_order_base.del_gsv_usd := rcd_order_base.del_gsv_usd + rcd_dlvry_base.del_gsv_usd;
         rcd_order_base.del_gsv_eur := rcd_order_base.del_gsv_eur + rcd_dlvry_base.del_gsv_eur;

      end loop;
      close csr_dlvry_base;

      /*-*/
      /* Update the GRD delivery request quantities
      /*-*/
      pkg_qty_fact.ods_matl_code := rcd_order_base.ods_matl_code;
      pkg_qty_fact.uom_code := rcd_order_base.order_uom_code;
      pkg_qty_fact.uom_qty := rcd_order_base.req_qty;
      calculate_quantity;
      rcd_order_base.req_qty_base_uom := pkg_qty_fact.qty_base_uom;
      rcd_order_base.req_qty_gross_tonnes := pkg_qty_fact.qty_gross_tonnes;
      rcd_order_base.req_qty_net_tonnes := pkg_qty_fact.qty_net_tonnes;

      /*-*/
      /* Update the GRD delivery confirm quantities
      /*-*/
      pkg_qty_fact.ods_matl_code := rcd_order_base.ods_matl_code;
      pkg_qty_fact.uom_code := rcd_order_base.order_uom_code;
      pkg_qty_fact.uom_qty := rcd_order_base.del_qty;
      calculate_quantity;
      rcd_order_base.del_qty_base_uom := pkg_qty_fact.qty_base_uom;
      rcd_order_base.del_qty_gross_tonnes := pkg_qty_fact.qty_gross_tonnes;
      rcd_order_base.del_qty_net_tonnes := pkg_qty_fact.qty_net_tonnes;

      /*-*/
      /* Calculate the outstanding values when required
      /* 1. Order only becomes outstanding when confirmed
      /*-*/
      if not(rcd_order_base.confirmed_date is null) then

         /*-*/
         /* Update the order outstanding quantities
         /*-*/
         rcd_order_base.out_qty := rcd_order_base.con_qty - rcd_order_base.req_qty;
         rcd_order_base.out_qty_base_uom := rcd_order_base.con_qty_base_uom - rcd_order_base.req_qty_base_uom;
         rcd_order_base.out_qty_gross_tonnes := rcd_order_base.con_qty_gross_tonnes - rcd_order_base.req_qty_gross_tonnes;
         rcd_order_base.out_qty_net_tonnes := rcd_order_base.con_qty_net_tonnes - rcd_order_base.req_qty_net_tonnes;
         rcd_order_base.out_gsv := rcd_order_base.con_gsv - rcd_order_base.req_gsv;
         rcd_order_base.out_gsv_xactn := rcd_order_base.con_gsv_xactn - rcd_order_base.req_gsv_xactn;
         rcd_order_base.out_gsv_aud := rcd_order_base.con_gsv_aud - rcd_order_base.req_gsv_aud;
         rcd_order_base.out_gsv_usd := rcd_order_base.con_gsv_usd - rcd_order_base.req_gsv_usd;
         rcd_order_base.out_gsv_eur := rcd_order_base.con_gsv_eur - rcd_order_base.req_gsv_eur;

         /*-*/
         /* Update the order line status when no outstanding quantity (*DELIVERED)
         /*-*/
         if rcd_order_base.out_qty = 0 then
            rcd_order_base.order_line_status := '*DELIVERED';
         end if;

      end if;

      /*----------------------*/
      /* SALES_BASE Alignment */
      /*----------------------*/

      /*-*/
      /* Retrieve the related SALES_BASE rows and update the ORDER_BASE row values
      /* 1. Order material and UOM is same as billed material and UOM then order billed quantity is increased by billed quantity
      /* 2. Order material or UOM differs from billed material or UOM then order billed quantity is increased by billed base UOM quantity
      /*    converted into the ordered material UOM. This assumes that both materials belong to the same representative material
      /*    and that the conversion is logical. 
      /*-*/
      open csr_sales_base;
      loop
         fetch csr_sales_base into rcd_sales_base;
         if csr_sales_base%notfound then
            exit;
         end if;
         if (rcd_order_base.ods_matl_code = rcd_sales_base.ods_matl_code and
             rcd_order_base.order_uom_code = rcd_sales_base.billed_uom_code) then
            rcd_order_base.inv_qty := rcd_order_base.inv_qty + rcd_sales_base.billed_qty;
         else
            rcd_order_base.inv_qty := rcd_order_base.inv_qty + convert_buom_to_uom(rcd_order_base.ods_matl_code, rcd_order_base.order_uom_code, rcd_sales_base.billed_qty_base_uom);
         end if;
         rcd_order_base.inv_gsv := rcd_order_base.inv_gsv + rcd_sales_base.billed_gsv;
         rcd_order_base.inv_gsv_xactn := rcd_order_base.inv_gsv_xactn + rcd_sales_base.billed_gsv_xactn;
         rcd_order_base.inv_gsv_aud := rcd_order_base.inv_gsv_aud + rcd_sales_base.billed_gsv_aud;
         rcd_order_base.inv_gsv_usd := rcd_order_base.inv_gsv_usd + rcd_sales_base.billed_gsv_usd;
         rcd_order_base.inv_gsv_eur := rcd_order_base.inv_gsv_eur + rcd_sales_base.billed_gsv_eur;
      end loop;
      close csr_sales_base;

      /*-*/
      /* Update the GRD billed quantities
      /*-*/
      pkg_qty_fact.ods_matl_code := rcd_order_base.ods_matl_code;
      pkg_qty_fact.uom_code := rcd_order_base.order_uom_code;
      pkg_qty_fact.uom_qty := rcd_order_base.inv_qty;
      calculate_quantity;
      rcd_order_base.inv_qty_base_uom := pkg_qty_fact.qty_base_uom;
      rcd_order_base.inv_qty_gross_tonnes := pkg_qty_fact.qty_gross_tonnes;
      rcd_order_base.inv_qty_net_tonnes := pkg_qty_fact.qty_net_tonnes;

      /*-*/
      /* Update the order line status (*INVOICED)
      /*-*/
      if rcd_order_base.order_line_status = '*DELIVERED' then
         if rcd_order_base.del_qty = rcd_order_base.inv_qty then
            rcd_order_base.order_line_status := '*INVOICED';
         end if;
      end if;

      /*-------------------*/
      /* ORDER_BASE Update */
      /*-------------------*/

      /*-*/
      /* Update the order base row
      /*-*/
      update dw_order_base
         set order_line_status = rcd_order_base.order_line_status,
             req_qty = rcd_order_base.req_qty,
             req_qty_base_uom = rcd_order_base.req_qty_base_uom,
             req_qty_gross_tonnes = rcd_order_base.req_qty_gross_tonnes,
             req_qty_net_tonnes = rcd_order_base.req_qty_net_tonnes,
             req_gsv = rcd_order_base.req_gsv,
             req_gsv_xactn = rcd_order_base.req_gsv_xactn,
             req_gsv_aud = rcd_order_base.req_gsv_aud,
             req_gsv_usd = rcd_order_base.req_gsv_usd,
             req_gsv_eur = rcd_order_base.req_gsv_eur,
             del_qty = rcd_order_base.del_qty,
             del_qty_base_uom = rcd_order_base.del_qty_base_uom,
             del_qty_gross_tonnes = rcd_order_base.del_qty_gross_tonnes,
             del_qty_net_tonnes = rcd_order_base.del_qty_net_tonnes,
             del_gsv = rcd_order_base.del_gsv,
             del_gsv_xactn = rcd_order_base.del_gsv_xactn,
             del_gsv_aud = rcd_order_base.del_gsv_aud,
             del_gsv_usd = rcd_order_base.del_gsv_usd,
             del_gsv_eur = rcd_order_base.del_gsv_eur,
             inv_qty = rcd_order_base.inv_qty,
             inv_qty_base_uom = rcd_order_base.inv_qty_base_uom,
             inv_qty_gross_tonnes = rcd_order_base.inv_qty_gross_tonnes,
             inv_qty_net_tonnes = rcd_order_base.inv_qty_net_tonnes,
             inv_gsv = rcd_order_base.inv_gsv,
             inv_gsv_xactn = rcd_order_base.inv_gsv_xactn,
             inv_gsv_aud = rcd_order_base.inv_gsv_aud,
             inv_gsv_usd = rcd_order_base.inv_gsv_usd,
             inv_gsv_eur = rcd_order_base.inv_gsv_eur,
             out_qty = rcd_order_base.out_qty,
             out_qty_base_uom = rcd_order_base.out_qty_base_uom,
             out_qty_gross_tonnes = rcd_order_base.out_qty_gross_tonnes,
             out_qty_net_tonnes = rcd_order_base.out_qty_net_tonnes,
             out_gsv = rcd_order_base.out_gsv,
             out_gsv_xactn = rcd_order_base.out_gsv_xactn,
             out_gsv_aud = rcd_order_base.out_gsv_aud,
             out_gsv_usd = rcd_order_base.out_gsv_usd,
             out_gsv_eur = rcd_order_base.out_gsv_eur
       where order_doc_num = rcd_order_base.order_doc_num
         and order_doc_line_num = rcd_order_base.order_doc_line_num;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end order_base_status;

   /*********************************************************/
   /* This procedure performs the dlvry base status routine */
   /*********************************************************/
   procedure dlvry_base_status(par_dlvry_doc_num in varchar2, par_dlvry_doc_line_num in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_dlvry_base is
         select t01.*
           from dw_dlvry_base t01
          where t01.dlvry_doc_num = par_dlvry_doc_num
            and t01.dlvry_doc_line_num = par_dlvry_doc_line_num;
      rcd_dlvry_base csr_dlvry_base%rowtype;

      cursor csr_sales_base is
         select t01.*
           from dw_sales_base t01
          where t01.dlvry_doc_num = rcd_dlvry_base.dlvry_doc_num
            and t01.dlvry_doc_line_num = rcd_dlvry_base.dlvry_doc_line_num;
      rcd_sales_base csr_sales_base%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*----------------------*/
      /* DLVRY_BASE Retrieval */
      /*----------------------*/

      /*-*/
      /* Retrieve the DLVRY_BASE row
      /*-*/
      open csr_dlvry_base;
      fetch csr_dlvry_base into rcd_dlvry_base;
      if csr_dlvry_base%notfound then
         return;
      end if;
      close csr_dlvry_base;

      /*---------------------------*/
      /* DLVRY_BASE Initialisation */
      /*---------------------------*/

      /*-*/
      /* Reset the delivery values
      /*-*/
      rcd_dlvry_base.dlvry_line_status := '*OUTSTANDING';
      rcd_dlvry_base.inv_qty := 0;
      rcd_dlvry_base.inv_qty_base_uom := 0;
      rcd_dlvry_base.inv_qty_gross_tonnes := 0;
      rcd_dlvry_base.inv_qty_net_tonnes := 0;
      rcd_dlvry_base.inv_gsv := 0;
      rcd_dlvry_base.inv_gsv_xactn := 0;
      rcd_dlvry_base.inv_gsv_aud := 0;
      rcd_dlvry_base.inv_gsv_usd := 0;
      rcd_dlvry_base.inv_gsv_eur := 0;
      rcd_dlvry_base.out_qty := rcd_dlvry_base.req_qty;
      rcd_dlvry_base.out_qty_base_uom := rcd_dlvry_base.req_qty_base_uom;
      rcd_dlvry_base.out_qty_gross_tonnes := rcd_dlvry_base.req_qty_gross_tonnes;
      rcd_dlvry_base.out_qty_net_tonnes := rcd_dlvry_base.req_qty_net_tonnes;
      rcd_dlvry_base.out_gsv := rcd_dlvry_base.req_gsv;
      rcd_dlvry_base.out_gsv_xactn := rcd_dlvry_base.req_gsv_xactn;
      rcd_dlvry_base.out_gsv_aud := rcd_dlvry_base.req_gsv_aud;
      rcd_dlvry_base.out_gsv_usd := rcd_dlvry_base.req_gsv_usd;
      rcd_dlvry_base.out_gsv_eur := rcd_dlvry_base.req_gsv_eur;
      if upper(rcd_dlvry_base.dlvry_procg_stage) = 'CONFIRMED' then
         rcd_dlvry_base.out_qty := rcd_dlvry_base.del_qty;
         rcd_dlvry_base.out_qty_base_uom := rcd_dlvry_base.del_qty_base_uom;
         rcd_dlvry_base.out_qty_gross_tonnes := rcd_dlvry_base.del_qty_gross_tonnes;
         rcd_dlvry_base.out_qty_net_tonnes := rcd_dlvry_base.del_qty_net_tonnes;
         rcd_dlvry_base.out_gsv := rcd_dlvry_base.del_gsv;
         rcd_dlvry_base.out_gsv_xactn := rcd_dlvry_base.del_gsv_xactn;
         rcd_dlvry_base.out_gsv_aud := rcd_dlvry_base.del_gsv_aud;
         rcd_dlvry_base.out_gsv_usd := rcd_dlvry_base.del_gsv_usd;
         rcd_dlvry_base.out_gsv_eur := rcd_dlvry_base.del_gsv_eur;
      end if;

      /*----------------------*/
      /* SALES_BASE Alignment */
      /*----------------------*/

      /*-*/
      /* Retrieve the related SALES_BASE row and update the DLVRY_BASE row values
      /* 1. Delivery material and UOM is same as billed material and UOM then delivery billed quantity is set to billed quantity
      /* 2. Delivery material or UOM differs from billed material or UOM then delivery billed quantity is set to billed base UOM quantity
      /*    converted into the ordered material UOM. This assumes that both materials belong to the same representative material
      /*    and that the conversion is logical. 
      /* 3. This logic continues to assume that there will always be a one to one relationship between the delivery line and the invoice line.
      /*-*/
      open csr_sales_base;
      if csr_sales_base%found then
         if (rcd_dlvry_base.ods_matl_code = rcd_sales_base.ods_matl_code and
             rcd_dlvry_base.dlvry_uom_code = rcd_sales_base.billed_uom_code) then
            rcd_dlvry_base.inv_qty := rcd_sales_base.billed_qty;
         else
            rcd_dlvry_base.inv_qty := convert_buom_to_uom(rcd_dlvry_base.ods_matl_code, rcd_dlvry_base.dlvry_uom_code, rcd_sales_base.billed_qty_base_uom);
         end if;
         rcd_dlvry_base.inv_gsv := rcd_sales_base.billed_gsv;
         rcd_dlvry_base.inv_gsv_xactn := rcd_sales_base.billed_gsv_xactn;
         rcd_dlvry_base.inv_gsv_aud := rcd_sales_base.billed_gsv_aud;
         rcd_dlvry_base.inv_gsv_usd := rcd_sales_base.billed_gsv_usd;
         rcd_dlvry_base.inv_gsv_eur := rcd_sales_base.billed_gsv_eur;
      end if;
      close csr_sales_base;

      /*-*/
      /* Update the GRD billed quantities
      /*-*/
      pkg_qty_fact.ods_matl_code := rcd_dlvry_base.ods_matl_code;
      pkg_qty_fact.uom_code := rcd_dlvry_base.dlvry_uom_code;
      pkg_qty_fact.uom_qty := rcd_dlvry_base.inv_qty;
      calculate_quantity;
      rcd_dlvry_base.inv_qty_base_uom := pkg_qty_fact.qty_base_uom;
      rcd_dlvry_base.inv_qty_gross_tonnes := pkg_qty_fact.qty_gross_tonnes;
      rcd_dlvry_base.inv_qty_net_tonnes := pkg_qty_fact.qty_net_tonnes;

      /*-*/
      /* Update the delivery line status when related billed quantity found
      /*-*/
      if rcd_dlvry_base.inv_qty != 0 then
         rcd_dlvry_base.dlvry_line_status := '*INVOICED';
         rcd_dlvry_base.out_qty := 0;
         rcd_dlvry_base.out_qty_base_uom := 0;
         rcd_dlvry_base.out_qty_gross_tonnes := 0;
         rcd_dlvry_base.out_qty_net_tonnes := 0;
         rcd_dlvry_base.out_gsv := 0;
         rcd_dlvry_base.out_gsv_xactn := 0;
         rcd_dlvry_base.out_gsv_aud := 0;
         rcd_dlvry_base.out_gsv_usd := 0;
         rcd_dlvry_base.out_gsv_eur := 0;
      end if;

      /*-------------------*/
      /* DLVRY_BASE Update */
      /*-------------------*/

      /*-*/
      /* Update the delivery base row
      /*-*/
      update dw_dlvry_base
         set dlvry_line_status = rcd_dlvry_base.dlvry_line_status,
             inv_qty = rcd_dlvry_base.inv_qty,
             inv_qty_base_uom = rcd_dlvry_base.inv_qty_base_uom,
             inv_qty_gross_tonnes = rcd_dlvry_base.inv_qty_gross_tonnes,
             inv_qty_net_tonnes = rcd_dlvry_base.inv_qty_net_tonnes,
             inv_gsv = rcd_dlvry_base.inv_gsv,
             inv_gsv_xactn = rcd_dlvry_base.inv_gsv_xactn,
             inv_gsv_aud = rcd_dlvry_base.inv_gsv_aud,
             inv_gsv_usd = rcd_dlvry_base.inv_gsv_usd,
             inv_gsv_eur = rcd_dlvry_base.inv_gsv_eur,
             out_qty = rcd_dlvry_base.out_qty,
             out_qty_base_uom = rcd_dlvry_base.out_qty_base_uom,
             out_qty_gross_tonnes = rcd_dlvry_base.out_qty_gross_tonnes,
             out_qty_net_tonnes = rcd_dlvry_base.out_qty_net_tonnes,
             out_gsv = rcd_dlvry_base.out_gsv,
             out_gsv_xactn = rcd_dlvry_base.out_gsv_xactn,
             out_gsv_aud = rcd_dlvry_base.out_gsv_aud,
             out_gsv_usd = rcd_dlvry_base.out_gsv_usd,
             out_gsv_eur = rcd_dlvry_base.out_gsv_eur
       where dlvry_doc_num = rcd_dlvry_base.dlvry_doc_num
         and dlvry_doc_line_num = rcd_dlvry_base.dlvry_doc_line_num;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end dlvry_base_status;

   /************************************************************/
   /* This procedure performs the quantity calculation routine */
   /************************************************************/
   procedure calculate_quantity is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_material is
         select t01.meins as mat_meins,
                t01.gewei as mat_gewei,
                nvl(t01.ntgew,0) as mat_ntgew,
                nvl(t01.brgew,0) as mat_brgew,
                nvl(t02.umren,1) as mat_umren,
                nvl(t02.umrez,1) as mat_umrez
           from sap_mat_hdr t01,
                (select t01.matnr,
                        t01.umren,
                        t01.umrez
                   from sap_mat_uom t01
                  where t01.matnr = pkg_qty_fact.ods_matl_code
                    and t01.meinh = pkg_qty_fact.uom_code) t02
          where t01.matnr = t02.matnr(+)
            and t01.matnr = pkg_qty_fact.ods_matl_code;
      rcd_material csr_material%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Calculate the quantity values from the material GRD data
      /*-*/
      open csr_material;
      fetch csr_material into rcd_material;
      if csr_material%found then
         pkg_qty_fact.base_uom_code := rcd_material.mat_meins;
         pkg_qty_fact.qty_base_uom := (pkg_qty_fact.uom_qty * rcd_material.mat_umrez) / rcd_material.mat_umren;
         pkg_qty_fact.qty_gross_tonnes := pkg_qty_fact.qty_base_uom * rcd_material.mat_brgew;
         pkg_qty_fact.qty_net_tonnes := pkg_qty_fact.qty_base_uom * rcd_material.mat_ntgew;
         case rcd_material.mat_gewei
            when 'KGM' then
               pkg_qty_fact.qty_gross_tonnes := pkg_qty_fact.qty_gross_tonnes / 1000;
               pkg_qty_fact.qty_net_tonnes := pkg_qty_fact.qty_net_tonnes / 1000;
            when 'GRM' then
               pkg_qty_fact.qty_gross_tonnes := pkg_qty_fact.qty_gross_tonnes / 1000000;
               pkg_qty_fact.qty_net_tonnes := pkg_qty_fact.qty_net_tonnes / 1000000;
            when 'MGM' then
               pkg_qty_fact.qty_gross_tonnes := pkg_qty_fact.qty_gross_tonnes / 1000000000;
               pkg_qty_fact.qty_net_tonnes := pkg_qty_fact.qty_net_tonnes / 1000000000;
         end case;
      end if;
      close csr_material;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end calculate_quantity;

   /****************************************************************/
   /* This procedure performs the quantity buom conversion routine */
   /****************************************************************/
   function convert_buom_to_uom(par_ods_matl_code in varchar2, par_uom_code in varchar2, par_qty_buom in number) return number is

      /*-*/
      /* Local variables
      /*-*/
      var_result number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_material is
         select nvl(t01.umren,1) as mat_umren,
                nvl(t01.umrez,1) as mat_umrez
           from sap_mat_uom t01
          where t01.matnr = par_ods_matl_code
            and t01.meinh = par_uom_code;
      rcd_material csr_material%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Convert the base uom quantity to the requested uom quantity
      /*-*/
      var_result := 0;
      open csr_material;
      fetch csr_material into rcd_material;
      if csr_material%found then
         var_result := (par_qty_buom / rcd_material.mat_umrez) * rcd_material.mat_umren;
      end if;
      close csr_material;

      /*-*/
      /* Return the result
      /*-*/
      return var_result;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end convert_buom_to_uom;

   /***************************************************************/
   /* This procedure performs the quantity uom conversion routine */
   /***************************************************************/
   function convert_uom_to_buom(par_ods_matl_code in varchar2, par_uom_code in varchar2, par_qty_uom in number) return number is

      /*-*/
      /* Local variables
      /*-*/
      var_result number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_material is
         select nvl(t01.umren,1) as mat_umren,
                nvl(t01.umrez,1) as mat_umrez
           from sap_mat_uom t01
          where t01.matnr = par_ods_matl_code
            and t01.meinh = par_uom_code;
      rcd_material csr_material%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Convert the uom quantity to the base uom quantity
      /*-*/
      var_result := 0;
      open csr_material;
      fetch csr_material into rcd_material;
      if csr_material%found then
         var_result := (par_qty_uom * rcd_material.mat_umrez) / rcd_material.mat_umren;
      end if;
      close csr_material;

      /*-*/
      /* Return the result
      /*-*/
      return var_result;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end convert_uom_to_buom;

end dw_utility;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_utility for dw_app.dw_utility;
grant execute on dw_utility to public;
