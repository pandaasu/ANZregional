CREATE OR REPLACE PACKAGE BODY SITE_APP.PXIPMX09_EXTRACT as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);
      var_data varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_input is
        --======================================================================
        select
        ------------------------------------------------------------------------
        -- FORMAT OUTPUT
        ------------------------------------------------------------------------
          pxi_common.char_format('336002', 6, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- CONSTANT '336002' -> RecordType
          pxi_common.char_format('149', 3, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- CONSTANT '149' -> PXCompanyCode
          pxi_common.char_format('149', 3, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- CONSTANT '149' -> PXDivisionCode
          pxi_common.char_format(invoicenumber, 10, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- invoicenumber -> InvoiceNumber
          pxi_common.char_format(invoicelinenumber, 6, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- invoicelinenumber -> InvoiceLineNumber
          pxi_common.char_format(customerhierarchy, 8, pxi_common.format_type_ltrim_zeros, pxi_common.is_not_nullable) || -- customerhierarchy -> CustomerHierarchy
          pxi_common.char_format(material, 18, pxi_common.format_type_ltrim_zeros, pxi_common.is_not_nullable) || -- material -> Material
          pxi_common.date_format(invoicedate, 'yyyymmdd', pxi_common.is_not_nullable) || -- invoicedate -> InvoiceDate
          pxi_common.numb_format(discountgiven, '9999990.00', pxi_common.is_not_nullable) || -- discountgiven -> DiscountGiven
          pxi_common.char_format(conditiontype, 10, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- conditiontype -> ConditionType
          pxi_common.char_format(currency, 3, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- currency -> Currency
          pxi_common.char_format(promotion_number, 10, pxi_common.format_type_none, pxi_common.is_not_nullable)  -- promotion_number -> number

        ------------------------------------------------------------------------
        from (
        ------------------------------------------------------------------------
        -- SQL
        ------------------------------------------------------------------------
          select
              '336002' as ICRecordType,
              sales_org as px_company_code,
              '149' as px_division_code,
              invoice_no as invoiceNumber,
              line_no as invoiceLineNumber,
              t02.kunnr as customerHierarchy,
              zrep_matl_code as material,
              to_date(invoice_date, 'yyyymmdd') as invoiceDate,
              discount as discountGiven,
              rpad(t01.pricing_condition,6) as conditionType,       -- TBC with the business. In issues log.
              t01.pmnum as promotion_number,      
              'NZD' as currency
          from
              promax_prom_inv_ext_view/*@ap0064p_promax_testing*/ t01,
              lads_prc_lst_hdr/*@ap0064p_promax_testing*/ t02
          where
              t01.pmnum = t02.kosrt and
              t01.sales_org = t02.vkorg and
              t01.cust_division = t02.spart and
              t01.zrep_matl_code = t02.matnr and
              t01.lads_date > trunc(sysdate) and
              t01.sales_org = '149'
        ------------------------------------------------------------------------
        );
        --======================================================================

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
            var_instance := lics_outbound_loader.create_interface('PXIPMX09');
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

end PXIPMX09_EXTRACT;
/