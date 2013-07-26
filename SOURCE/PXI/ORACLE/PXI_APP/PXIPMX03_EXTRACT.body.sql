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
        select
          rpad(trim('300001'), 6, ' ') || -- CONSTANT '300001' -> ICRecordType
          rpad(trim(customer_code), 10, ' ') || -- .customer_code -> CustomerNumber
          rpad(trim(customer_name), 40, ' ') || -- .customer_name -> Longname
          rpad(trim('Y'), 1, ' ') || -- CONSTANT 'Y' -> PACSCustomer
          rpad(trim(payer_customer_code), 10, ' ') || -- .payer_customer_code -> PayerCode
          rpad(trim(tax_exempt), 1, ' ') || -- .tax_exempt -> TaxExempt
          rpad(trim('NZD'), 3, ' ') || -- CONSTANT 'NZD' -> DefaultCurrenty
          rpad(trim('149'), 10, ' ') || -- CONSTANT '149' -> PXDivisionCode
          rpad(trim('149'), 10, ' ') || -- CONSTANT '149' -> PXCompanyCode
          rpad(trim('149'), 3, ' ') -- CONSTANT '149' -> SalesOrg
        from (
        ------------------------------------------------------------------------
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
              (t3.order_block_flag is null or (t3.order_block_flag is not null and exists (select * from sale_cdw_gsv t0 where t0.sold_to_cust_code = t1.customer_code))) and 
              -- Only include customers that are not deleted.
              t3.deletion_flag is null and
              -- Only include not rasw and packs or affiliate customers
              t3.distbn_chnl_code not in ('98','99') and 
              -- Customer is not a hierachy customer code
              t1.customer_code not like '004%'
            ) t10
        ------------------------------------------------------------------------
        ------------------------------------------------------------------------
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

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end PXIPMX03_EXTRACT;
/
