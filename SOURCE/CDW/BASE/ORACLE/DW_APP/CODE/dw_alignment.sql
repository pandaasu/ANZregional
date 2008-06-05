/******************/
/* Package Header */
/******************/
create or replace package dw_alignment as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_alignment
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Base data alignment

    This package contain base data alignment procedures.

    **notes**
    1. This package does NOT perform commits or rollbacks. 

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/06   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure purch_base_status(par_company_code in varchar2);
   procedure order_base_status(par_company_code in varchar2);
   procedure dlvry_base_status(par_company_code in varchar2);
   procedure sales_base_return(par_company_code in varchar2);

end dw_alignment;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_alignment as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /******************************************************************/
   /* This procedure performs the purchase order base status routine */
   /******************************************************************/
   procedure purch_base_status(par_company_code in varchar2) is

      /*-*/
      /* Local variables
      /*-*/
      var_delivered boolean;
      var_invoiced boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_purch_base is
         select t01.*
           from dw_purch_base t01
          where t01.company_code = par_company_code
            and t01.purch_order_line_status = '*OUTSTANDING';
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

      /*-------------------------*/
      /* PURCH_BASE Cancellation */
      /*-------------------------*/

      /*-*/
      /* Update the purchase base rows with *CANCELLED status when required
      /* **notes** 1. Select all purchase orders that have an outstanding status
      /*           2. Related invoice without billing date (unposted)
      /*-*/
      update dw_purch_order_base
         set purch_order_line_status = '*CANCELLED',
             out_qty = 0,
             out_qty_base_uom = 0,
             out_qty_gross_tonnes = 0,
             out_qty_net_tonnes = 0,
             out_gsv = 0,
             out_gsv_xactn = 0,
             out_gsv_aud = 0,
             out_gsv_usd = 0,
             out_gsv_eur = 0
       where company_code = par_company_code
         and purch_order_line_status in ('*OUTSTANDING')
         and (purch_order_doc_num, purch_order_doc_line_num) in (select purch_order_doc_num, purch_order_doc_line_num
                                                                   from sap_inv_trace
                                                                  where company_code = par_company_code
                                                                    and trace_status = '*UNPOSTED');

      /*----------------------*/
      /* PURCH_BASE Retrieval */
      /*----------------------*/

      /*-*/
      /* Retrieve the PURCH_BASE rows with a *OUTSTANDING status
      /*-*/
      open csr_purch_base;
      loop
         fetch csr_purch_base into rcd_purch_base;
         if csr_purch_base%notfound then
            exit;
         end if;

         /*---------------------------*/
         /* PURCH_BASE Initialisation */
         /*---------------------------*/

         /*-*/
         /* Reset the purchase order values
         /*-*/
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

         /*-*/
         /* Reset the related indicators
         /*-*/
         var_delivered := false;
         var_invoiced := false;

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
            /* Any one related delivery line delivers the purchase order line
            /* 1. Purchase orders do not use the large order line split functionality
            /*-*/
            var_delivered := true;

            /*-*/
            /* Delivery request values
            /*-*/
            if (rcd_purch_base.ods_matl_code = rcd_dlvry_base.ods_matl_code and
                rcd_purch_base.purch_order_uom_code = rcd_dlvry_base.dlvry_uom_code) then
               rcd_purch_base.req_qty := rcd_purch_base.req_qty + rcd_dlvry_base.req_qty;
            else
               rcd_purch_base.req_qty := rcd_purch_base.req_qty + dw_utility.convert_buom_to_uom(rcd_purch_base.ods_matl_code, rcd_purch_base.purch_order_uom_code, rcd_dlvry_base.req_qty_base_uom);
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
               rcd_purch_base.del_qty := rcd_purch_base.del_qty + dw_utility.convert_buom_to_uom(rcd_purch_base.ods_matl_code, rcd_purch_base.purch_order_uom_code, rcd_dlvry_base.del_qty_base_uom);
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
         dw_utility.pkg_qty_fact.ods_matl_code := rcd_purch_base.ods_matl_code;
         dw_utility.pkg_qty_fact.uom_code := rcd_purch_base.purch_order_uom_code;
         dw_utility.pkg_qty_fact.uom_qty := rcd_purch_base.req_qty;
         dw_utility.calculate_quantity;
         rcd_purch_base.req_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
         rcd_purch_base.req_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
         rcd_purch_base.req_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

         /*-*/
         /* Update the GRD delivery confirm quantities
         /*-*/
         dw_utility.pkg_qty_fact.ods_matl_code := rcd_purch_base.ods_matl_code;
         dw_utility.pkg_qty_fact.uom_code := rcd_purch_base.purch_order_uom_code;
         dw_utility.pkg_qty_fact.uom_qty := rcd_purch_base.del_qty;
         dw_utility.calculate_quantity;
         rcd_purch_base.del_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
         rcd_purch_base.del_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
         rcd_purch_base.del_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

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

            /*-*/
            /* Any one related invoice line invoices the purchase order line
            /* 1. Purchase orders do not use the large order line split functionality
            /*-*/
            var_invoiced := true;

            /*-*/
            /* Invoice billed values
            /*-*/
            if (rcd_purch_base.ods_matl_code = rcd_sales_base.ods_matl_code and
                rcd_purch_base.purch_order_uom_code = rcd_sales_base.billed_uom_code) then
               rcd_purch_base.inv_qty := rcd_purch_base.inv_qty + rcd_sales_base.billed_qty;
            else
               rcd_purch_base.inv_qty := rcd_purch_base.inv_qty + dw_utility.convert_buom_to_uom(rcd_purch_base.ods_matl_code, rcd_purch_base.purch_order_uom_code, rcd_sales_base.billed_qty_base_uom);
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
         dw_utility.pkg_qty_fact.ods_matl_code := rcd_purch_base.ods_matl_code;
         dw_utility.pkg_qty_fact.uom_code := rcd_purch_base.purch_order_uom_code;
         dw_utility.pkg_qty_fact.uom_qty := rcd_purch_base.inv_qty;
         dw_utility.calculate_quantity;
         rcd_purch_base.inv_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
         rcd_purch_base.inv_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
         rcd_purch_base.inv_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

         /*------------------------*/
         /* PURCH_BASE Outstanding */
         /*------------------------*/

         /*-*/
         /* Set the purchase order line status
         /*-*/
         if var_invoiced = true then
            rcd_purch_base.purch_order_line_status := '*CLOSED';
         end if;

         /*-*/
         /* Calculate the outstanding values when required
         /* 1. Closed purchase order lines have no outstanding values
         /* 2. Purchase order line only becomes outstanding when confirmed
         /*-*/
         if rcd_purch_base.purch_order_line_status = '*OUTSTANDING' then
            if not(rcd_purch_base.confirmed_date is null) then
               rcd_purch_base.out_qty := rcd_purch_base.con_qty - rcd_purch_base.req_qty;
               rcd_purch_base.out_qty_base_uom := rcd_purch_base.con_qty_base_uom - rcd_purch_base.req_qty_base_uom;
               rcd_purch_base.out_qty_gross_tonnes := rcd_purch_base.con_qty_gross_tonnes - rcd_purch_base.req_qty_gross_tonnes;
               rcd_purch_base.out_qty_net_tonnes := rcd_purch_base.con_qty_net_tonnes - rcd_purch_base.req_qty_net_tonnes;
               rcd_purch_base.out_gsv := rcd_purch_base.con_gsv - rcd_purch_base.req_gsv;
               rcd_purch_base.out_gsv_xactn := rcd_purch_base.con_gsv_xactn - rcd_purch_base.req_gsv_xactn;
               rcd_purch_base.out_gsv_aud := rcd_purch_base.con_gsv_aud - rcd_purch_base.req_gsv_aud;
               rcd_purch_base.out_gsv_usd := rcd_purch_base.con_gsv_usd - rcd_purch_base.req_gsv_usd;
               rcd_purch_base.out_gsv_eur := rcd_purch_base.con_gsv_eur - rcd_purch_base.req_gsv_eur;
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

      end loop;
      close csr_purch_base;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end purch_base_status;

   /*********************************************************/
   /* This procedure performs the order base status routine */
   /*********************************************************/
   procedure order_base_status(par_company_code in varchar2) is

      /*-*/
      /* Local variables
      /*-*/
      var_delivered boolean;
      var_invoiced boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_order_base is
         select t01.*
           from dw_order_base t01
          where t01.company_code = par_company_code
            and t01.order_line_status = '*OUTSTANDING';
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

      /*-------------------------*/
      /* ORDER_BASE Cancellation */
      /*-------------------------*/

      /*-*/
      /* Update the order base rows with *CANCELLED status when required
      /* **notes** 1. Select all orders that have an outstanding status
      /*           2. Related invoice without billing date (unposted)
      /*-*/
      update dw_order_base
         set order_line_status = '*CANCELLED',
             out_qty = 0,
             out_qty_base_uom = 0,
             out_qty_gross_tonnes = 0,
             out_qty_net_tonnes = 0,
             out_gsv = 0,
             out_gsv_xactn = 0,
             out_gsv_aud = 0,
             out_gsv_usd = 0,
             out_gsv_eur = 0
       where company_code = par_company_code
         and order_line_status in ('*OUTSTANDING')
         and (order_doc_num, order_doc_line_num) in (select order_doc_num, order_doc_line_num
                                                       from sap_inv_trace
                                                      where company_code = par_company_code
                                                        and trace_status = '*UNPOSTED');

      /*----------------------*/
      /* ORDER_BASE Retrieval */
      /*----------------------*/

      /*-*/
      /* Retrieve the ORDER_BASE rows with a *OUTSTANDING status
      /*-*/
      open csr_order_base;
      loop
         fetch csr_order_base into rcd_order_base;
         if csr_order_base%notfound then
            exit;
         end if;

         /*---------------------------*/
         /* ORDER_BASE Initialisation */
         /*---------------------------*/

         /*-*/
         /* Reset the order values
         /*-*/
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

         /*-*/
         /* Reset the related indicators
         /*-*/
         var_delivered := false;
         var_invoiced := false;

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
            /* Any one related delivery line indicates fully or partially delivered
            /* 1. Sales orders potentially use the large order line split functionality
            /*-*/
            var_delivered := true;

            /*-*/
            /* Delivery request values
            /*-*/
            if (rcd_order_base.ods_matl_code = rcd_dlvry_base.ods_matl_code and
                rcd_order_base.order_uom_code = rcd_dlvry_base.dlvry_uom_code) then
               rcd_order_base.req_qty := rcd_order_base.req_qty + rcd_dlvry_base.req_qty;
            else
               rcd_order_base.req_qty := rcd_order_base.req_qty + dw_utility.convert_buom_to_uom(rcd_order_base.ods_matl_code, rcd_order_base.order_uom_code, rcd_dlvry_base.req_qty_base_uom);
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
               rcd_order_base.del_qty := rcd_order_base.del_qty + dw_utility.convert_buom_to_uom(rcd_order_base.ods_matl_code, rcd_order_base.order_uom_code, rcd_dlvry_base.del_qty_base_uom);
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
         dw_utility.pkg_qty_fact.ods_matl_code := rcd_order_base.ods_matl_code;
         dw_utility.pkg_qty_fact.uom_code := rcd_order_base.order_uom_code;
         dw_utility.pkg_qty_fact.uom_qty := rcd_order_base.req_qty;
         dw_utility.calculate_quantity;
         rcd_order_base.req_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
         rcd_order_base.req_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
         rcd_order_base.req_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

         /*-*/
         /* Update the GRD delivery confirm quantities
         /*-*/
         dw_utility.pkg_qty_fact.ods_matl_code := rcd_order_base.ods_matl_code;
         dw_utility.pkg_qty_fact.uom_code := rcd_order_base.order_uom_code;
         dw_utility.pkg_qty_fact.uom_qty := rcd_order_base.del_qty;
         dw_utility.calculate_quantity;
         rcd_order_base.del_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
         rcd_order_base.del_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
         rcd_order_base.del_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

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

            /*-*/
            /* Any one related invoice line indicates fully or partially invoiced
            /* 1. Sales orders potentially use the large order line split functionality
            /*-*/
            var_invoiced := true;

            /*-*/
            /* Invoice billed values
            /*-*/
            if (rcd_order_base.ods_matl_code = rcd_sales_base.ods_matl_code and
                rcd_order_base.order_uom_code = rcd_sales_base.billed_uom_code) then
               rcd_order_base.inv_qty := rcd_order_base.inv_qty + rcd_sales_base.billed_qty;
            else
               rcd_order_base.inv_qty := rcd_order_base.inv_qty + dw_utility.convert_buom_to_uom(rcd_order_base.ods_matl_code, rcd_order_base.order_uom_code, rcd_sales_base.billed_qty_base_uom);
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
         dw_utility.pkg_qty_fact.ods_matl_code := rcd_order_base.ods_matl_code;
         dw_utility.pkg_qty_fact.uom_code := rcd_order_base.order_uom_code;
         dw_utility.pkg_qty_fact.uom_qty := rcd_order_base.inv_qty;
         dw_utility.calculate_quantity;
         rcd_order_base.inv_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
         rcd_order_base.inv_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
         rcd_order_base.inv_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

         /*------------------------*/
         /* ORDER_BASE Outstanding */
         /*------------------------*/

         /*-*/
         /* Set the order line status
         /*-*/
 --        rcd_order_base.order_line_status := rcd_order_base.atlas_line_status;

         /*-*/
         /* Calculate the outstanding values when required
         /* 1. Closed order lines have no outstanding values
         /* 2. Order line only becomes outstanding when confirmed
         /*-*/
         if rcd_order_base.order_line_status = '*OUTSTANDING' then
            if not(rcd_order_base.confirmed_date is null) then
               rcd_order_base.out_qty := rcd_order_base.con_qty - rcd_order_base.req_qty;
               rcd_order_base.out_qty_base_uom := rcd_order_base.con_qty_base_uom - rcd_order_base.req_qty_base_uom;
               rcd_order_base.out_qty_gross_tonnes := rcd_order_base.con_qty_gross_tonnes - rcd_order_base.req_qty_gross_tonnes;
               rcd_order_base.out_qty_net_tonnes := rcd_order_base.con_qty_net_tonnes - rcd_order_base.req_qty_net_tonnes;
               rcd_order_base.out_gsv := rcd_order_base.con_gsv - rcd_order_base.req_gsv;
               rcd_order_base.out_gsv_xactn := rcd_order_base.con_gsv_xactn - rcd_order_base.req_gsv_xactn;
               rcd_order_base.out_gsv_aud := rcd_order_base.con_gsv_aud - rcd_order_base.req_gsv_aud;
               rcd_order_base.out_gsv_usd := rcd_order_base.con_gsv_usd - rcd_order_base.req_gsv_usd;
               rcd_order_base.out_gsv_eur := rcd_order_base.con_gsv_eur - rcd_order_base.req_gsv_eur;
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

      end loop;
      close csr_order_base;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end order_base_status;

   /*********************************************************/
   /* This procedure performs the dlvry base status routine */
   /*********************************************************/
   procedure dlvry_base_status(par_company_code in varchar2) is

      /*-*/
      /* Local variables
      /*-*/
      var_invoiced boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_dlvry_base is
         select t01.*
           from dw_dlvry_base t01
          where t01.company_code = par_company_code
            and t01.dlvry_line_status = '*OUTSTANDING';
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

      /*-------------------------*/
      /* DLVRY_BASE Cancellation */
      /*-------------------------*/

      /*-*/
      /* Update the delivery base rows with *CANCELLED status when required
      /* **notes** 1. Select all deliveries that have an outstanding status
      /*           2. Related invoice without billing date (unposted)
      /*-*/
      update dw_dlvry_base
         set dlvry_line_status = '*CANCELLED',
             out_qty = 0,
             out_qty_base_uom = 0,
             out_qty_gross_tonnes = 0,
             out_qty_net_tonnes = 0,
             out_gsv = 0,
             out_gsv_xactn = 0,
             out_gsv_aud = 0,
             out_gsv_usd = 0,
             out_gsv_eur = 0
       where company_code = par_company_code
         and dlvry_line_status in ('*OUTSTANDING')
         and (dlvry_doc_num, dlvry_doc_line_num) in (select dlvry_doc_num, dlvry_doc_line_num
                                                       from sap_inv_trace
                                                      where company_code = par_company_code
                                                        and trace_status = '*UNPOSTED');

      /*----------------------*/
      /* DLVRY_BASE Retrieval */
      /*----------------------*/

      /*-*/
      /* Retrieve the DLVRY_BASE rows with a *OUTSTANDING status
      /*-*/
      open csr_dlvry_base;
      loop
         fetch csr_dlvry_base into rcd_dlvry_base;
         if csr_dlvry_base%notfound then
            exit;
         end if;

         /*---------------------------*/
         /* DLVRY_BASE Initialisation */
         /*---------------------------*/

         /*-*/
         /* Reset the delivery values
         /*-*/
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

         /*-*/
         /* Reset the related indicators
         /*-*/
         var_invoiced := false;

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

            /*-*/
            /* Any one related invoice line invoices the purchase order line
            /* 1. Purchase orders do not use the large order line split functionality
            /*-*/
            var_invoiced := true;

            /*-*/
            /* Invoice billed values
            /*-*/
            if (rcd_dlvry_base.ods_matl_code = rcd_sales_base.ods_matl_code and
                rcd_dlvry_base.dlvry_uom_code = rcd_sales_base.billed_uom_code) then
               rcd_dlvry_base.inv_qty := rcd_sales_base.billed_qty;
            else
               rcd_dlvry_base.inv_qty := dw_utility.convert_buom_to_uom(rcd_dlvry_base.ods_matl_code, rcd_dlvry_base.dlvry_uom_code, rcd_sales_base.billed_qty_base_uom);
            end if;
            rcd_dlvry_base.inv_gsv := rcd_sales_base.billed_gsv;
            rcd_dlvry_base.inv_gsv_xactn := rcd_sales_base.billed_gsv_xactn;
            rcd_dlvry_base.inv_gsv_aud := rcd_sales_base.billed_gsv_aud;
            rcd_dlvry_base.inv_gsv_usd := rcd_sales_base.billed_gsv_usd;
            rcd_dlvry_base.inv_gsv_eur := rcd_sales_base.billed_gsv_eur;

            /*-*/
            /* Update the GRD billed quantities
            /*-*/
            dw_utility.pkg_qty_fact.ods_matl_code := rcd_dlvry_base.ods_matl_code;
            dw_utility.pkg_qty_fact.uom_code := rcd_dlvry_base.dlvry_uom_code;
            dw_utility.pkg_qty_fact.uom_qty := rcd_dlvry_base.inv_qty;
            dw_utility.calculate_quantity;
            rcd_dlvry_base.inv_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
            rcd_dlvry_base.inv_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
            rcd_dlvry_base.inv_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

         end if;
         close csr_sales_base;

         /*------------------------*/
         /* DLVRY_BASE Outstanding */
         /*------------------------*/

         /*-*/
         /* Set the delivery line status
         /*-*/
         if var_invoiced = true then
            rcd_dlvry_base.dlvry_line_status := '*CLOSED';
         end if;

         /*-*/
         /* Calculate the outstanding values when required
         /* 1. Closed delivery lines have no outstanding values
         /* 2. Delivery line outstanding is based on the processing stage
         /*-*/
         if rcd_dlvry_base.dlvry_line_status = '*OUTSTANDING' then
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

      end loop;
      close csr_dlvry_base;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end dlvry_base_status;

   /*********************************************************/
   /* This procedure performs the sales base return routine */
   /*********************************************************/
   procedure sales_base_return(par_company_code in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_sales_base is
         select t01.billing_doc_num,
                t01.billing_doc_line_num,
                t01.order_doc_num,
                t01.order_doc_line_num
           from dw_sales_base t01
          where t01.company_code = par_company_code
            and t01.order_doc_num = t01.dlvry_doc_num;
      rcd_sales_base csr_sales_base%rowtype;

      cursor csr_dlvry_lookup is
         select t01.dlvry_doc_num,
                t01.dlvry_doc_line_num
           from dw_dlvry_base t01
          where t01.order_doc_num = rcd_sales_base.order_doc_num
            and t01.order_doc_line_num = rcd_sales_base.order_doc_line_num;
      rcd_dlvry_lookup csr_dlvry_lookup%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*--------------------------*/
      /* SALES_BASE return update */
      /*--------------------------*/

      /*-*/
      /* Retrieve the SALES_BASE rows where the order document equals the delivery document
      /* **note** 1. Delivery number is not stored on the SAP_INV_IRF table for a return invoice
      /*          2. Assumes large order line split not used for a return otherwise only first
      /*             delivery line will be assumed for the invoice
      /*          3. Must be updated from both DLVRY_BASE and SALES_BASE as the invoice could arrive
      /*             before the delivery in the ODS which would result in the update not being performed
      /*             unless the invoice was reloaded, that is, this is a catch all for both delivery and invoice
      /*-*/
      open csr_sales_base;
      loop
         fetch csr_sales_base into rcd_sales_base;
         if csr_sales_base%notfound then
            exit;
         end if;

         /*-*/
         /* Lookup the delivery line from related DLVRY_BASE via the sales order document
         /* and update the sales base row with the delivery document and line
         /*-*/
         open csr_dlvry_lookup;
         fetch csr_dlvry_lookup into rcd_dlvry_lookup;
         if csr_dlvry_lookup%found then
            update dw_sales_base
               set dlvry_doc_num = rcd_dlvry_lookup.dlvry_doc_num,
                   dlvry_doc_line_num = rcd_dlvry_lookup.dlvry_doc_line_num
             where billing_doc_num = rcd_sales_base.billing_doc_num
               and billing_doc_line_num = rcd_sales_base.billing_doc_line_num;
         end if;
         close csr_dlvry_lookup;

      end loop;
      close csr_sales_base;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end sales_base_return;

end dw_alignment;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_alignment for dw_app.dw_alignment;
grant execute on dw_alignment to public;
