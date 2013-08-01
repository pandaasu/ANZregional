create or replace 
PACKAGE BODY          PXIPMX03_EXTRACT as

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
          pxi_common.char_format('300001', 6, pxi_common.format_type_none, pxi_common.is_nullable) || -- CONSTANT '300001' -> RecordType
          pxi_common.char_format('149', 3, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- CONSTANT '149' -> PXDivisionCode
          pxi_common.char_format('149', 3, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- CONSTANT '149' -> PXCompanyCode
          pxi_common.char_format(customer_code, 10, pxi_common.format_type_ltrim_zeros, pxi_common.is_not_nullable) || -- customer_code -> CustomerNumber
          pxi_common.char_format(customer_name, 40, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- customer_name -> Longname
          pxi_common.char_format('Y', 1, pxi_common.format_type_none, pxi_common.is_nullable) || -- CONSTANT 'Y' -> PACSCustomer
          pxi_common.char_format(payer_customer_code, 10, pxi_common.format_type_ltrim_zeros, pxi_common.is_nullable) || -- payer_customer_code -> PayerCode
          pxi_common.char_format(tax_exempt, 1, pxi_common.format_type_none, pxi_common.is_nullable) || -- tax_exempt -> TaxExempt
          pxi_common.char_format('NZD', 3, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- CONSTANT 'NZD' -> DefaultCurrenty
          pxi_common.char_format('149', 3, pxi_common.format_type_none, pxi_common.is_nullable) -- CONSTANT '149' -> SalesOrg
        ------------------------------------------------------------------------
        from (
        ------------------------------------------------------------------------
        -- SQL
        ------------------------------------------------------------------------
          select 
            t10.customer_code, 
            t10.customer_name,
            t10.payer_customer_code,
            (case t10.tax_classification_code when '0' then 'Y' else 'N' end) as tax_exempt
          from (
            select 
              t1.customer_code, 
              t3.sales_org_code,
              t3.distbn_chnl_code,
              t3.division_code,
              t2.name as customer_name,
              -- Payer Customer Code
              ( select partner_cust_code 
                from bds_cust_sales_area_pnrfun t0 
                where 
                  t0.customer_code = t3.customer_code and 
                  t0.sales_org_code = t3.sales_org_code and 
                  t0.distbn_chnl_code = t3.distbn_chnl_code and 
                  t0.division_code = t3.division_code and t0.partner_text = 'Payer') as payer_customer_code,
              -- Tax Indicator
              ( select tax_classification_code 
                from bds_cust_sales_area_taxind t0 
                where 
                  t0.customer_code = t3.customer_code and 
                  t0.sales_org_code = t3.sales_org_code and 
                  t0.distbn_chnl_code = t3.distbn_chnl_code and 
                  t0.division_code = t3.division_code and t0.tax_category_code = 'MWST') as tax_classification_code
            from 
              bds_cust_header t1,  
              bds_addr_customer t2,
              bds_cust_sales_area t3
            where 
              -- Table Joins
              t1.customer_code = t2.customer_code and 
              t1.customer_code = t3.customer_code and 
              -- Only Customers extended into sales organisation for New Zealand.
              t3.sales_org_code = '149' and 
              -- Only show the main english customer name.
              t2.address_version = '*NONE' and
              -- Still include customer in the extract even if order block is in place if they have had sales in the last 12 weeks.
              (t1.order_block_flag is null or (t1.order_block_flag is not null and exists (select * from sale_cdw_gsv t0 where t0.sold_to_cust_code = t1.customer_code))) and 
              (t3.order_block_flag is null or (t3.order_block_flag is not null and exists (select * from sale_cdw_gsv t0 where t0.sold_to_cust_code = t1.customer_code))) and 
              -- Only include customers that are not deleted.
              t3.deletion_flag is null and
              -- Only include not rasw and packs or affiliate customers
              t3.distbn_chnl_code not in ('98','99') and 
              -- Customer is not a hierachy customer code
              t1.customer_code not like '004%'
            ) t10
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
            var_instance := lics_outbound_loader.create_interface('PXIPMX03');
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

end PXIPMX03_EXTRACT;
/
