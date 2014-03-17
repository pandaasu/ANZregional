prompt :: Compile Package [pxipmx05_extract_v2] :::::::::::::::::::::::::::::::::::::::

create or replace package pxi_app.pxipmx05_extract_v2 as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : LADS
 Package : PXIPMX05_EXTRACT_V2
 Owner   : PXI_APP
 Author  : Chris Horn and Mal Chambeyron

 Description
 -----------
    LADS (Outbound) -> Promax PX - Vendor Data - PX Interface 347

 This interface selects Vendor Data for New Zealand.

 Date          Author                Description
 ------------  --------------------  -----------
 24/07/2013    Chris Horn            Created.
 26/07/2013    Mal Chambeyron        Formatted SQL Output
 21/08/2013    Chris Horn            Cleaned Up Code
 28/08/2013    Chris Horn            Made more generic for OZ.
 2013-03-12    Mal Chambeyron        Remove DEFAULTS,
                                     Replace [pxi_common.promax_config]
                                     Use Suffix

*******************************************************************************/

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
  PURPOSE:   This interface creates an extract of vendor data.

             It defaults to all available live promax companies and divisions
             and just current data as of yesterday.  If null is supplied as
             the creation date then historial information will be supplied
             as defined by the business logic.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.
  1.2   2013-08-21 Chris Horn           Cleaned Up.
  1.3   2013-08-28 Chris Horn           Made generic for OZ.
  1.4   2013-10-14 Chris Horn           Vendor name too long bug fixed.

*******************************************************************************/
   procedure execute(
     i_promax_company in pxi_common.st_company,
     i_promax_division in pxi_common.st_promax_division,
     i_creation_date in date);

end pxipmx05_extract_v2;
/

create or replace package body pxi_app.pxipmx05_extract_v2 as

/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'PXIPMX05_EXTRACT_V2';
  pc_interface_name constant pxi_common.st_interface_name := 'PXIPMX05';

/*******************************************************************************
  NAME:  EXECUTE                                                          PUBLIC
*******************************************************************************/
   procedure execute(
     i_promax_company in pxi_common.st_company,
     i_promax_division in pxi_common.st_promax_division,
     i_creation_date in date) is
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
            i_promax_company as promax_company,
            i_promax_division as promax_division,
            t1.vendor_code,
            t2.company_code,
            substr(t1.vendor_name_01 ||' '|| t1.vendor_name_02,1,40) as longname
          from
            bds_vend_header t1, --
            bds_vend_comp t2 --
          where
            t1.vendor_code = t2.vendor_code
            and group_key like 'PMX%'
            and t1.posting_block_flag is null
            and t1.purchasing_block_flag is null and
            -- This join, since there does not appear to be any customer or
            -- material division information the vendor will result in a cross product output. when multiple australian segments are live.
            t2.company_code = i_promax_company
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
        v_instance := lics_outbound_loader.create_interface(pc_interface_name||'.'||pxi_common.promax_interface_suffix(i_promax_company,i_promax_division));
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

end pxipmx05_extract_v2;
/

grant execute on pxi_app.pxipmx05_extract_v2 to lics_app, fflu_app, site_app;
