create or replace 
PACKAGE BODY          PXIPMX05_EXTRACT as

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
          pxi_common.char_format('347001', 6, pxi_common.format_type_none, pxi_common.is_nullable) || -- CONSTANT '347001' -> ICRecordType
          pxi_common.char_format(company_code, 10, pxi_common.format_type_ltrim_zeros, pxi_common.is_not_nullable) || -- company_code -> VendorNumber
          pxi_common.char_format(longname, 40, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- longname -> Longname
          pxi_common.char_format('Y', 1, pxi_common.format_type_none, pxi_common.is_nullable) || -- CONSTANT 'Y' -> PACSVendor
          pxi_common.char_format('1', 1, pxi_common.format_type_none, pxi_common.is_nullable) || -- CONSTANT '1' -> TaxExempt
          pxi_common.char_format('149', 10, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- CONSTANT '149' -> PXCompanyCode
          pxi_common.char_format('149', 10, pxi_common.format_type_none, pxi_common.is_not_nullable) -- CONSTANT '149' -> PXDivisionCode
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
            var_instance := lics_outbound_loader.create_interface('PXIPMX05');
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

end PXIPMX05_EXTRACT;
/
