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
          pxi_common.char_format('149', 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT '149' -> PXCompanyCode
          pxi_common.char_format('149', 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT '149' -> PXDivisionCode
          pxi_common.char_format(vendor_code, 10, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_not_nullable) || -- company_code -> VendorNumber
          pxi_common.char_format(longname, 40, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- longname -> Longname
          pxi_common.char_format('Y', 1, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- CONSTANT 'Y' -> PACSVendor
          pxi_common.char_format('1', 1, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) -- CONSTANT '1' -> TaxExempt
        ------------------------------------------------------------------------
        from (
        ------------------------------------------------------------------------
        -- SQL
        ------------------------------------------------------------------------
          select a.vendor_code,
            b.company_code,
            a.vendor_name_01 ||' '|| a.vendor_name_02 as longname
          from
            bds_vend_header@ap0064p_promax_testing a,
            bds_vend_comp@ap0064p_promax_testing b
          where
            a.vendor_code = b.vendor_code
            and b.company_code = '149'
            and group_key like 'PMX%'
            and a.posting_block_flag is null
            and a.purchasing_block_flag is null
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