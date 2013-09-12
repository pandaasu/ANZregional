create or replace 
PACKAGE BODY          PXIPMX03_EXTRACT as

/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'PXIPMX03_EXTRACT';
  pc_interface_name constant pxi_common.st_interface_name := 'PXIPMX03';

/*******************************************************************************
  NAME:  EXECUTE                                                          PUBLIC
*******************************************************************************/
   procedure execute(
     i_pmx_company in pxi_common.st_company default null,
     i_pmx_division in pxi_common.st_promax_division default null, 
     i_creation_date in date default sysdate-1) is
     -- Variables     
     v_instance number(15,0);
     v_data pxi_common.st_data;
 
     -- The extract query.
     cursor csr_input is
        --======================================================================
        select
          ------------------------------------------------------------------------
          -- FORMAT OUTPUT
          ------------------------------------------------------------------------
          pxi_common.char_format('300001', 6, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- CONSTANT '300001' -> RecordType
          pxi_common.char_format(promax_company, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_company -> PXCompanyCode
          pxi_common.char_format(promax_division, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_division -> PXDivisionCode
          pxi_common.char_format(customer_code, 10, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_not_nullable) || -- customer_code -> CustomerNumber
          pxi_common.char_format(customer_name, 40, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- customer_name -> Longname
          pxi_common.char_format('Y', 1, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- CONSTANT 'Y' -> PACSCustomer
          pxi_common.char_format(payer_customer_code, 10, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_nullable) || -- payer_customer_code -> PayerCode
          pxi_common.char_format(tax_exempt, 1, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- tax_exempt -> TaxExempt
          pxi_common.char_format(currency, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- currency -> DefaultCurrenty
          pxi_common.char_format(sales_org_code, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) -- sales_org_code -> SalesOrg
        ------------------------------------------------------------------------
        from (
        ------------------------------------------------------------------------
        -- SQL
        ------------------------------------------------------------------------
          select 
            t10.promax_company,
            t10.promax_division,
            t10.customer_code, 
            t10.customer_name,
            t10.payer_customer_code,
            (case t10.tax_classification_code when '0' then 'Y' else 'N' end) as tax_exempt,
            t10.sales_org_code,
            case t10.sales_org_code when  pxi_common.gc_australia then 'AUD' when pxi_common.gc_new_zealand then 'NZD' else null end as currency
          from (
            select 
              t4.promax_company,
              t4.promax_division,
              t1.customer_code, 
              t3.sales_org_code,
              t3.distbn_chnl_code,
              t3.division_code,
              t2.name as customer_name,
              -- Payer Customer Code
              ( select partner_cust_code 
                from bds_cust_sales_area_pnrfun@ap0064p_promax_testing t0 
                where 
                  t0.customer_code = t3.customer_code and 
                  t0.sales_org_code = t3.sales_org_code and 
                  t0.distbn_chnl_code = t3.distbn_chnl_code and 
                  t0.division_code = t3.division_code and t0.partner_text = 'Payer') as payer_customer_code,
              -- Tax Indicator
              ( select tax_classification_code 
                from bds_cust_sales_area_taxind@ap0064p_promax_testing t0 
                where 
                  t0.customer_code = t3.customer_code and 
                  t0.sales_org_code = t3.sales_org_code and 
                  t0.distbn_chnl_code = t3.distbn_chnl_code and 
                  t0.division_code = t3.division_code and t0.tax_category_code = 'MWST') as tax_classification_code
            from 
              bds_cust_header@ap0064p_promax_testing t1,  
              bds_addr_customer@ap0064p_promax_testing t2,
              bds_cust_sales_area@ap0064p_promax_testing t3,
              table(pxi_common.promax_config(i_pmx_company,i_pmx_division)) t4  -- Promax Configuration table
            where 
              -- Table Joins
              t1.customer_code = t2.customer_code and 
              t1.customer_code = t3.customer_code and 
              -- Only Customers extended into sales organisation
              -- Now join to the sales organisation and division information.
              t3.sales_org_code = t4.promax_company and 
              ((t3.sales_org_code = pxi_common.gc_australia and t3.division_code = t4.cust_division) or (t3.sales_org_code = pxi_common.gc_new_zealand and t3.division_code = pxi_common.gc_cust_division_non_specific)) and
              -- Only show the main english customer name.
              t2.address_version = '*NONE' and
              -- Still include customer in the extract even if order block is in place if they have had sales in the last 12 weeks.
              ((t1.order_block_flag is null and t1.deletion_flag is null and t3.order_block_flag is null and t3.deletion_flag is null) or 
               (exists (select * from sale_cdw_gsv@ap0064p_promax_testing t0 where t0.sold_to_cust_code = t1.customer_code))) and 
              -- Only include not rasw and packs or affiliate customers
              t3.distbn_chnl_code not in ('98','99') and 
              -- Customer is not a hierachy customer code
              t1.customer_code not like '004%'
            ) t10
        ------------------------------------------------------------------------
        );
        --======================================================================

   begin
     -- Open cursor with the extract data.
     open csr_input;
     loop
       fetch csr_input into v_data;
       exit when csr_input%notfound;
      -- Create the new interface when required
      if lics_outbound_loader.is_created = false then
        v_instance := lics_outbound_loader.create_interface(pc_interface_name);
      end if;
      -- Append the interface data
      lics_outbound_loader.append_data(v_data);
    end loop;
    close csr_input;

    -- Finalise the interface when required
    if lics_outbound_loader.is_created = true then
      lics_outbound_loader.finalise_interface;
    end if;

  exception
     when others then
       rollback;
       if lics_outbound_loader.is_created = true then
         lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
         lics_outbound_loader.finalise_interface;
       end if;
       pxi_common.reraise_promax_exception(pc_package_name,'EXECUTE');
   end execute;

end PXIPMX03_EXTRACT;