create or replace package DW_APP.nzmkt_pricing as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : nzmkt_pricing 
    Owner   : dw_app 

    Description
    -----------
    Dimensional Data Store - NZ Market Pricing 

    This package contain the NZ Market Pricing procedures. The package exposes one
    procedure EXECUTE that performs the pricing update.  No parameters are required.

    YYYY/MM   Author            Description
    -------   ------            -----------
    ????/??   ???               Created 
    2013/09   Trevor Keon       Added support for new 996 Condition Table (KOTABNR) 

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end nzmkt_pricing;

create or replace package body DW_APP.nzmkt_pricing as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*********************************************************/
   /* This procedure performs the NZ market pricing routine */
   /*********************************************************/
   procedure execute is

      /*-*/
      /* Local variables
      /*-*/
      var_nzmkt_price number;
      var_gsv_value number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_nzmkt_base is
         select t01.*
           from dw_nzmkt_base t01;
      rcd_nzmkt_base csr_nzmkt_base%rowtype;

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
            and t01.vakey = lpad(nvl(rcd_nzmkt_base.nzmkt_vendor_code,'0'),10,'0')||rpad(rcd_nzmkt_base.ods_matl_code,18,' ')||'0'
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
      /* Retrieve the BASE data and update the pricing
      /*-*/
      open csr_nzmkt_base;
      loop
         fetch csr_nzmkt_base into rcd_nzmkt_base;
         if csr_nzmkt_base%notfound then
            exit;
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

         /*-*/
         /* Calculate the NZ market stock transfer GSV values
         /*-*/
         rcd_nzmkt_base.ord_gsv_xactn := round(rcd_nzmkt_base.ord_qty * var_nzmkt_price, 2);
         var_gsv_value := rcd_nzmkt_base.ord_qty * var_nzmkt_price;
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

         /*-*/
         /* Update the NZ market base row
         /*-*/
         update dw_nzmkt_base
            set ord_gsv_xactn = rcd_nzmkt_base.ord_gsv_xactn,
                ord_gsv = rcd_nzmkt_base.ord_gsv,
                ord_gsv_aud = rcd_nzmkt_base.ord_gsv_aud,
                ord_gsv_usd = rcd_nzmkt_base.ord_gsv_usd,
                ord_gsv_eur = rcd_nzmkt_base.ord_gsv_eur,
                con_gsv_xactn = rcd_nzmkt_base.con_gsv_xactn,
                con_gsv = rcd_nzmkt_base.con_gsv,
                con_gsv_aud = rcd_nzmkt_base.con_gsv_aud,
                con_gsv_usd = rcd_nzmkt_base.con_gsv_usd,
                con_gsv_eur = rcd_nzmkt_base.con_gsv_eur
          where purch_order_doc_num = rcd_nzmkt_base.purch_order_doc_num
            and purch_order_doc_line_num = rcd_nzmkt_base.purch_order_doc_line_num;

      end loop;
      close csr_nzmkt_base;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

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
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end nzmkt_pricing;

create or replace public synonym nzmkt_pricing for dw_app.nzmkt_pricing;
grant execute on nzmkt_pricing to public;