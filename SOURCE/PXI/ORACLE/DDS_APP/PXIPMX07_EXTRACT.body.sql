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
          pxi_common.char_format('306001', 6, pxi_common.format_type_none, pxi_common.is_nullable) || -- CONSTANT '306001' -> ICRecordType
          pxi_common.char_format('149', 3, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- CONSTANT '149' -> PXCompanyCode
          pxi_common.char_format(hdr_division_code, 3, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- hdr_division_code -> PXDivisionCode
          pxi_common.char_format(sold_to_cust_code, 20, pxi_common.format_type_ltrim_zeros, pxi_common.is_not_nullable) || -- sold_to_cust_code -> CustomerNumber
          pxi_common.char_format(billing_doc_num, 10, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- billing_doc_num -> InvoiceNumber
          pxi_common.char_format(billing_doc_line_num, 6, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- billing_doc_line_num -> InvoiceLineNumber
          pxi_common.char_format(matl_entd, 18, pxi_common.format_type_ltrim_zeros, pxi_common.is_not_nullable) || -- matl_entd -> Material
          pxi_common.date_format(order_eff_date, 'yyyymmdd', pxi_common.is_not_nullable) || -- order_eff_date -> OrderDate
          pxi_common.date_format(billing_eff_date, 'yyyymmdd', pxi_common.is_not_nullable) || -- billing_eff_date -> InvoiceDate
          pxi_common.numb_format(billed_qty_base_uom, 'S9999999999990.00', pxi_common.is_not_nullable) || -- billed_qty_base_uom -> QuantityInvoiced
          pxi_common.numb_format(billed_gsv, 'S999999990.00', pxi_common.is_not_nullable) || -- billed_gsv -> GrossAmount
          pxi_common.char_format(doc_currcy_code, 5, pxi_common.format_type_none, pxi_common.is_nullable) -- doc_currcy_code -> Currency
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
            dw_sales_base@db1270p_promax_testing t1,
            dw_order_base@db1270p_promax_testing t2
          where
            t1.company_code = 149
            and t1.creatn_date = trunc(i_creation_date)
            and t1.order_doc_num = t2.order_doc_num (+)
            and t1.order_doc_line_num = t2.order_doc_line_num (+)
            -- not null check added to accommodate new restrictions on output format
            and t1.matl_entd is not null 
            and t2.order_eff_date is not null        
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
         raise;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end PXIPMX07_EXTRACT;
/