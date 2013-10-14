create or replace 
PACKAGE BODY PXIPMX05_EXTRACT as

/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'PXIPMX05_EXTRACT';
  pc_interface_name constant pxi_common.st_interface_name := 'PXIPMX05';

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
          pxi_common.char_format('347001', 6, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- CONSTANT '347001' -> ICRecordType
          pxi_common.char_format(promax_company, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_company -> PXCompanyCode
          pxi_common.char_format(promax_division, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_division -> PXDivisionCode
          pxi_common.char_format(vendor_code, 10, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_not_nullable) || -- vendor_code -> VendorNumber
          pxi_common.char_format(longname, 40, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- longname -> Longname
          pxi_common.char_format('Y', 1, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- CONSTANT 'Y' -> PACSVendor
          pxi_common.char_format('1', 1, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) -- CONSTANT '1' -> TaxExempt

        ------------------------------------------------------------------------
        from (
        ------------------------------------------------------------------------
        -- SQL
        ------------------------------------------------------------------------
          select 
            t3.promax_company,
            t3.promax_division,
            t1.vendor_code,
            t2.company_code,
            substr(t1.vendor_name_01 ||' '|| t1.vendor_name_02,1,40) as longname
          from
            bds_vend_header@ap0064p_promax_testing t1, --@ap0064p_promax_testing
            bds_vend_comp@ap0064p_promax_testing t2, --@ap0064p_promax_testing
            table(pxi_common.promax_config(i_pmx_company,i_pmx_division)) t3  -- Promax Configuration table
          where
            t1.vendor_code = t2.vendor_code
            and group_key like 'PMX%'
            and t1.posting_block_flag is null
            and t1.purchasing_block_flag is null and 
            -- This join, since there does not appear to be any customer or 
            -- material division information the vendor will result in a cross product output. when multiple australian segments are live.
            t2.company_code = t3.promax_company 
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

end PXIPMX05_EXTRACT; 