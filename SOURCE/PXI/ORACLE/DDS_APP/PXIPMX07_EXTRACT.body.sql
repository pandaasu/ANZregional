create or replace 
PACKAGE BODY          PXIPMX07_EXTRACT as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(i_creation_date in date default sysdate-1) is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);
      var_data varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_input is
        select 
          rpad(trim('306001'), 6, ' ') || -- CONSTANT '306001' -> ICRecordType
          rpad(trim('149'), 10, ' ') || -- CONSTANT '149' -> PXCompanyCode
          rpad(trim(hdr_division_code), 10, ' ') || -- dw_sales_base.hdr_division_code -> PXDivisionCode
          rpad(trim(sold_to_cust_code), 20, ' ') || -- dw_sales_base.sold_to_cust_code -> CustomerNumber
          rpad(trim(billing_doc_num), 10, ' ') || -- dw_sales_base.billing_doc_num -> InvoiceNumber
          rpad(trim(billing_doc_line_num), 6, ' ') || -- dw_sales_base.billing_doc_line_num -> InvoiceLineNumber
          rpad(trim(matl_entd), 18, ' ') || -- dw_sales_base.matl_entd -> Material
          lpad(to_char(order_eff_date, 'dd/mm/yyyy'), 10, ' ') || -- dw_order_base.order_eff_date -> OrderDate
          lpad(to_char(billing_eff_date, 'dd/mm/yyyy'), 10, ' ') || -- dw_sales_base.billing_eff_date -> InvoiceDate
          lpad(to_char(billed_qty_base_uom, '9999999999999.00'), 17, ' ') || -- dw_sales_base.billed_qty_base_uom -> QuantityInvoiced
          lpad(to_char(billed_gsv, '999999999.00'), 13, ' ') || -- dw_sales_base.billed_gsv -> GrossAmount
          rpad(trim(doc_currcy_code), 5, ' ') -- dw_sales_base.doc_currcy_code -> Currency
          as data 
        from (
          select 
            t1.hdr_division_code,
            t1.company_code,
            t1.sold_to_cust_code,
            t1.billing_doc_num, 
            t1.billing_doc_line_num, 
            t1.matl_entd,
            t2.order_eff_date,
            t1.billing_eff_date,
            t1.billed_qty_base_uom, 
            t1.billed_gsv,
            t1.doc_currcy_code
          from 
            dw_sales_base t1,
            dw_order_base t2
          where 
            t1.company_code = 149 
            and t1.creatn_date = to_date('31/12/2001','DD/MM/YYYY') 
            -- and t1.creatn_date = trunc(i_datime) 
            and t1.order_doc_num = t2.order_doc_num (+) 
            and t1.order_doc_line_num = t2.order_doc_line_num (+)
        );

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Retrieve the rows
      /*-*/
      open csr_input;
      loop
         fetch csr_input into var_data;
         if csr_input%notfound then
            exit;
         end if;

         /*-*/
         /* Create the new interface when required
         /*-*/
         if lics_outbound_loader.is_created = false then
            var_instance := lics_outbound_loader.create_interface('PXIPMX07');
         end if;

         /*-*/
         /* Append the interface data
         /*-*/
         lics_outbound_loader.append_data(var_data);

      end loop;
      close csr_input;

      /*-*/
      /* Finalise the interface when required
      /*-*/
      if lics_outbound_loader.is_created = true then
         lics_outbound_loader.finalise_interface;
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then
         rollback;
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
            lics_outbound_loader.finalise_interface;
         end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end PXIPMX07_EXTRACT;
/