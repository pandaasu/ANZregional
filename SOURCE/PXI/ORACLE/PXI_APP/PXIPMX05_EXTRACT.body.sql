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
        select
          rpad(trim('347001'), 6, ' ') || -- CONSTANT '347001' -> ICRecordType
          rpad(trim(company_code), 10, ' ') || -- bds_vend_comp.company_code -> VendorNumber
          rpad(trim(alias_longname), 40, ' ') || -- bds_vend_header.alias_longname -> Longname
          rpad(trim('Y'), 1, ' ') || -- CONSTANT 'Y' -> PACSVendor
          rpad(trim('1'), 1, ' ') || -- CONSTANT '1' -> TaxExempt
          rpad(trim('149'), 10, ' ') || -- CONSTANT '149' -> PXCompanyCode
          rpad(trim('149'), 10, ' ') -- CONSTANT '149' -> PXDivisionCode
        from (
          select a.vendor_code,
            b.company_code,
            a.vendor_name_01 ||' '|| a.vendor_name_02 as alias_longname
          from 
            bds_vend_header@ap0064p_promax_testing a, 
            bds_vend_comp@ap0064p_promax_testing b
          where 
            a.vendor_code = b.vendor_code
            and b.company_code = '149'
            and group_key like 'PMX%'
            and a.posting_block_flag is null
            and a.purchasing_block_flag is null
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
