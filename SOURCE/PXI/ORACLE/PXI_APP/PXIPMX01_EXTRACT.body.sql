create or replace 
PACKAGE BODY          PXIPMX01_EXTRACT as

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
          pxi_common.char_format('302001', 6, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- CONSTANT '302001' -> RecordType
          pxi_common.char_format(zrep_matl_code, 18, pxi_common.format_type_ltrim_zeros, pxi_common.is_not_nullable) || -- zrep_matl_code -> ProductItemNumber
          pxi_common.char_format(zrep_matl_desc, 40, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- zrep_matl_desc -> Description
          pxi_common.char_format('1', 2, pxi_common.format_type_none, pxi_common.is_nullable) || -- CONSTANT '1' -> Status
          pxi_common.char_format(zrep_matl_code, 10, pxi_common.format_type_ltrim_zeros, pxi_common.is_nullable) || -- zrep_matl_code -> ShortName
          pxi_common.char_format(rsu_ean, 18, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- rsu_ean -> APN
          pxi_common.char_format(tdu_ean, 18, pxi_common.format_type_none, pxi_common.is_nullable) || -- tdu_ean -> TUN
          pxi_common.char_format(rsu_uom, 3, pxi_common.format_type_none, pxi_common.is_nullable) || -- rsu_uom -> UOM
          pxi_common.char_format(tdu_uom, 3, pxi_common.format_type_none, pxi_common.is_nullable) || -- tdu_uom -> SellableUOM
          pxi_common.numb_format(rsus_per_tdu, '99999999999990', pxi_common.is_nullable) || -- rsus_per_tdu -> UnitsPerCase
          pxi_common.numb_format(rsus_per_tdu, '99999999999990', pxi_common.is_nullable) || -- rsus_per_tdu -> BaseUnitsPerSellable
          pxi_common.char_format('149', 10, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- CONSTANT '149' -> PXCompanyCode
          pxi_common.char_format('149', 10, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- CONSTANT '149' -> PXDivisionCode
          pxi_common.char_format('0', 1, pxi_common.format_type_none, pxi_common.is_nullable) || -- CONSTANT '0' -> Type
          pxi_common.numb_format(tdu_net_weight, '9999999990.000', pxi_common.is_nullable) || -- tdu_net_weight -> ShipperNetWeightKG
          pxi_common.numb_format(tdu_height, '9999999990', pxi_common.is_nullable) || -- tdu_height -> CaseHeight
          pxi_common.numb_format(tdu_width, '9999999990', pxi_common.is_nullable) || -- tdu_width -> CaseWidth
          pxi_common.numb_format(tdu_length, '9999999990', pxi_common.is_nullable) || -- tdu_length -> CaseLength
          pxi_common.numb_format(rsu_height, '9999999990', pxi_common.is_nullable) || -- rsu_height -> UnitHeight
          pxi_common.numb_format(rsu_width, '9999999990', pxi_common.is_nullable) || -- rsu_width -> UnitWidth
          pxi_common.numb_format(rsu_length, '9999999990', pxi_common.is_nullable) -- rsu_length -> UnitLength
        ------------------------------------------------------------------------
        from (
        ------------------------------------------------------------------------
        -- SQL
        ------------------------------------------------------------------------
          -- Duplicates are possible, if the data in SAP is not 100% Consistent with business process.  
          select distinct -- Removes the various duplicate TDU's per ZREP that may exist, where dimensions are the same.  
            t4.sap_material_code as zrep_matl_code, -- ZREP Code
            t4.bds_material_desc_en as zrep_matl_desc, -- ZREP Description
            t3.child_ian as rsu_ean,  -- Retail EAN
            t3.parent_ian as tdu_ean, -- Shipper EAN
            t3.parent_base_uom as tdu_uom, -- Shipper UOM
            t3.child_base_uom as rsu_uom, -- Retail UOM
            t3.child_per_parent as rsus_per_tdu,  -- Units Per Case
            (case t1.gross_weight_unit when 'GRM' then t1.net_weight/1000 else t1.net_weight end) as tdu_net_weight, -- ShipperNetWeightKG
            t1.length as tdu_length, -- CaseLength  
            t1.width as tdu_width, -- CaseLength
            t1.height as tdu_height, -- CaseHeight
            t5.length as rsu_length, -- UnitLength
            t5.width as rsu_width, -- UnitWidth
            t5.height as rsu_height -- UnitHeight
          from 
            bds_material_hdr@ap0064p_promax_testing t1,  -- TDU Material Header Information
            bds_material_dstrbtn_chain@ap0064p_promax_testing t2, -- Material Sales Area Information
            bds_material_bom_all@ap0064p_promax_testing t3, -- TDU to RSU Information
            bds_material_hdr@ap0064p_promax_testing t4, -- Zrep Material Description.  
            bds_material_hdr@ap0064p_promax_testing t5 -- RSU Material Information
          where
            -- Table Joins
            t2.sap_material_code = t1.sap_material_code and 
            t3.parent_material_code = t1.sap_material_code and
            t4.sap_material_code = t1.mars_rprsnttv_item_code and 
            t5.sap_material_code = t3.child_material_code and 
            -- Ensure Material Type is a FERT and that it is a Tradded Unit
            t1.material_type = 'FERT' and t1.mars_traded_unit_flag = 'X' and 
            -- Ensure that this project is allowed to be distributed.
            t1.xdstrbtn_chain_status = '10' and 
            -- Make sure this product is not being sold to affilate markers or as a raws and packs product.
            t2.dstrbtn_channel not in ('98','99') and
            -- Make sure the distribution channel status is not inactive
            t2.dstrbtn_chain_status != '99' and
            -- Filter for new zealand.
            t2.sales_organisation = '149' and 
            -- Ensure the data hasn't been deleted and is correct in lads.
            t1.deletion_flag is null and t1.bds_lads_status = 1 and t2.dstrbtn_chain_delete_indctr is null and
            -- Ensure we have the correct TDU to RSU Bom Details 
            t3.bom_plant = '*NONE' and t3.bom_alternative = 1 and
            t3.bom_status in (1, 7) and t3.bom_usage = 5 and 
            t3.child_material_type = 'FERT' and t3.child_rsu_flag = 'X' and 
            -- Make sure only the current bom is being used for the TDU to RSU information
            t3.bom_eff_date = (select max(t0.bom_eff_date) from bds_material_bom_all@ap0064p_promax_testing t0 where t0.bom_eff_date <= trunc(sysdate) and t0.parent_material_code = t1.sap_material_code)
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
            var_instance := lics_outbound_loader.create_interface('PXIPMX01');
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

end PXIPMX01_EXTRACT;
/