create or replace 
PACKAGE BODY PXIPMX01_EXTRACT as

/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'PXIPMX01_EXTRACT';
  pc_interface_name constant pxi_common.st_interface_name := 'PXIPMX01';
  pc_days_to_send_deletions constant number(5) := 10; -- Days


/*******************************************************************************
  NAME:  EXECUTE                                                          PUBLIC
*******************************************************************************/
   procedure execute(
     i_pmx_company in pxi_common.st_company default null,
     i_pmx_division in pxi_common.st_promax_division default null, 
     i_creation_date in date default sysdate-1) is
     -- Variables     
     v_instance number(15,0);
     v_include boolean;
     
     -- The extract query.
     cursor csr_input is
        --======================================================================
        -- Make sure we have all the rows available before we start processing the creation of the interface and updating the promax material hsitory table. 
        select /*+ ALL_ROWS */  
        ------------------------------------------------------------------------
        -- FORMAT OUTPUT
        ------------------------------------------------------------------------
          pxi_common.char_format('302001', 6, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT '302001' -> RecordType
          pxi_common.char_format(promax_company, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_company -> PXCompanyCode
          pxi_common.char_format(promax_division, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_division -> PXDivisionCode
          pxi_common.char_format(zrep_matl_code, 18, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_not_nullable) || -- zrep_matl_code -> ProductItemNumber
          pxi_common.char_format(zrep_matl_desc, 40, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- zrep_matl_desc -> Description
          pxi_common.char_format(product_status, 2, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- product_status -> Status
          pxi_common.char_format(zrep_matl_code, 10, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_nullable) || -- zrep_matl_code -> ShortName
          pxi_common.char_format(rsu_ean, 18, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- rsu_ean -> APN
          pxi_common.char_format(tdu_ean, 18, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- tdu_ean -> TUN
          pxi_common.char_format(rsu_uom, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- rsu_uom -> UOM
          pxi_common.char_format(tdu_uom, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- tdu_uom -> SellableUOM
          pxi_common.numb_format(rsus_per_tdu, '99999999999990', pxi_common.fc_is_nullable) || -- rsus_per_tdu -> UnitsPerCase
          pxi_common.numb_format(rsus_per_tdu, '99999999999990', pxi_common.fc_is_nullable) || -- rsus_per_tdu -> BaseUnitsPerSellable
          pxi_common.char_format('0', 1, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- CONSTANT '0' -> Type
          pxi_common.numb_format(tdu_net_weight, '9999999990.000', pxi_common.fc_is_nullable) || -- tdu_net_weight -> ShipperNetWeightKG
          pxi_common.numb_format(tdu_height, '9999999990', pxi_common.fc_is_nullable) || -- tdu_height -> CaseHeight
          pxi_common.numb_format(tdu_width, '9999999990', pxi_common.fc_is_nullable) || -- tdu_width -> CaseWidth
          pxi_common.numb_format(tdu_length, '9999999990', pxi_common.fc_is_nullable) || -- tdu_length -> CaseLength
          pxi_common.numb_format(rsu_height, '9999999990', pxi_common.fc_is_nullable) || -- rsu_height -> UnitHeight
          pxi_common.numb_format(rsu_width, '9999999990', pxi_common.fc_is_nullable) || -- rsu_width -> UnitWidth
          pxi_common.numb_format(rsu_length, '9999999990', pxi_common.fc_is_nullable) -- rsu_length -> UnitLength
          as row_data,
          promax_company,
          promax_division,
          zrep_matl_code,
          xdstrbtn_chain_status,
          dstrbtn_chain_status
        ------------------------------------------------------------------------
        from (
        ------------------------------------------------------------------------
        -- SQL
        ------------------------------------------------------------------------
          select
            t1.promax_company,
            t1.promax_division,
            t1.sales_org,
            t1.dstrbtn_channel,
            t1.xdstrbtn_chain_status,
            t1.dstrbtn_chain_status,
            case when t1.dstrbtn_chain_status != '99' and t1.xdstrbtn_chain_status = '10' then 1 else 4 end as product_status,
            t1.zrep_matl_code, -- ZREP Material Code
            t1.zrep_matl_desc, -- ZREP Material Description.
            t2.sap_material_code as tdu_matl_code, -- TDU Material Code
            t2.bds_material_desc_en as tdu_matl_desc, -- TDU Material Description.
            t2.interntl_article_no as tdu_ean, -- Shipper EAN
            t3.rsu_ean,  -- Retail EAN
            t2.base_uom as tdu_uom, -- Shipper UOM
            t3.rsu_uom, -- Retail UOM
            t3.rsus_per_tdu,  -- Units Per Case
            (case t2.gross_weight_unit when 'GRM' then t2.net_weight/1000 else t2.net_weight end) as tdu_net_weight, -- ShipperNetWeightKG
            t2.length as tdu_length, -- CaseLength
            t2.width as tdu_width, -- CaseLength
            t2.height as tdu_height, -- CaseHeight
            t3.rsu_length, -- UnitLength
            t3.rsu_width, -- UnitWidth
            t3.rsu_height -- UnitHeight
          from 
            -- Create the driving table of zreps that are distributed in the destination site, all records in this query must be in the output.
            pmx_zrep_materials t1,
            bds_material_hdr t2, -- @ap0064p_promax_testing -- TDU Material Header Information
            pmx_matl_tdu_to_rsu t3 
          where
            -- Get the traded unit ferts for those zreps.
            t2.sap_material_code  = pxi_utils.determine_tdu_from_zrep(t1.zrep_matl_code,t1.sales_org,t1.dstrbtn_channel,null,i_creation_date) and
            t2.material_type = 'FERT' and t2.mars_traded_unit_flag  = 'X' and 
            -- Note We do not care if there are no current TDU's available for distribution.  ie.  No t2.xdstrbtn_chain_status = '10' Filter is included here.
            -- Ensure the data hasn't been deleted and is correct in lads.
            t2.deletion_flag is null and t2.bds_lads_status = 1 and 
            -- Now join RSU Information to the TDU Information
            t3.tdu_matl_code  = t2.sap_material_code and
            -- Now only display the final rows that have valid RSU information
            t3.rsu_ean is not null
            -- If looking for missing materials, outer join t2 and t3 values, including the all the t2 fitler predicates.
        ------------------------------------------------------------------------
        );
        -- Record type to hold the promax extract data and the extra determination / mainteance criteria for the sending table. 
        rv_product csr_input%rowtype;
      
     -- This function updates the product history table.
     procedure update_product_history is
     begin
       -- Perform an initial update for the time this record was last extracted. 
       update pmx_matl_hist set last_extracted = sysdate
         where cmpny_code = rv_product.promax_company 
         and div_code = rv_product.promax_division and zrep_matl_code = rv_product.zrep_matl_code;
       -- If no update was performed then add the record to the table.
       if sql%rowcount = 0 then
         insert into pmx_matl_hist (cmpny_code,div_code,zrep_matl_code,xdstrbtn_chain_status,dstrbtn_chain_status,change_date,last_extracted) values (
           rv_product.promax_company, rv_product.promax_division, rv_product.zrep_matl_code,rv_product.xdstrbtn_chain_status,rv_product.dstrbtn_chain_status,sysdate,sysdate);
       else 
         update pmx_matl_hist set change_date = sysdate, xdstrbtn_chain_status = rv_product.xdstrbtn_chain_status, dstrbtn_chain_status = rv_product.dstrbtn_chain_status 
           where cmpny_code = rv_product.promax_company and div_code = rv_product.promax_division and
           zrep_matl_code = rv_product.zrep_matl_code and
           (dstrbtn_chain_status <> rv_product.dstrbtn_chain_status or xdstrbtn_chain_status <> rv_product.xdstrbtn_chain_status);
       end if;
     exception 
       when others then 
         pxi_common.reraise_promax_exception(pc_package_name,'UPDATE_PRODUCT_HISTORY');
     end update_product_history;

     -- This function looks to see if the product was recently deleted.      
     function deleted_recently return boolean is
       v_result boolean;
       cursor csr_matl_hist is
         select 
           xdstrbtn_chain_status,
           dstrbtn_chain_status, 
           change_date
         from 
           pmx_matl_hist
         where 
           cmpny_code = rv_product.promax_company and div_code = rv_product.promax_division and 
           zrep_matl_code = rv_product.zrep_matl_code;
       rv_matl_hist csr_matl_hist%rowtype;
     begin
       v_result := false;
       open csr_matl_hist; 
       fetch csr_matl_hist into rv_matl_hist;
       if csr_matl_hist%found then 
         -- If the current status is not deleted then it must now have been recently deleted.
         if rv_matl_hist.dstrbtn_chain_status != '99' and rv_product.xdstrbtn_chain_status = '10' then
           v_result := true;
         else 
           -- Check if the item's status was changed in the last few days.
           if rv_matl_hist.change_date > sysdate - pc_days_to_send_deletions then
             v_result := true;
           end if;
         end if;
       end if;
       close csr_matl_hist;
       return v_result;
     exception 
       when others then 
         pxi_common.reraise_promax_exception(pc_package_name,'DELETED_RECENTLY');
     end deleted_recently; 
     
     procedure populate_temp_tables is 
     begin
       -- Update the session based temporary table. 
       delete from pmx_zrep_materials;
       insert into pmx_zrep_materials               
             select 
                t03.promax_company,    -- Promax Company
                t03.promax_division,   -- Promax Division
                t02.sales_organisation as sales_org, -- Sales Organisation
                t02.dstrbtn_channel, -- Distribution Channel
                t01.xdstrbtn_chain_status, -- Cross Distribution Channel Status
                t02.dstrbtn_chain_status, -- Distribution Channel Status
                t01.sap_material_code as zrep_matl_code,  -- ZREP Material Code
                t01.bds_material_desc_en as zrep_matl_desc -- ZREP Material Description.
              from 
                bds_material_hdr t01, --  -- ZREP Material Header Information -- @ap0064p_promax_testing 
                bds_material_dstrbtn_chain t02, -- @ap0064p_promax_testing -- Material Sales Area Information
                table(pxi_common.promax_config(i_pmx_company,i_pmx_division)) t03  -- Promax Configuration table
              where
                -- Join to promax configuration table.
                t02.sales_organisation = t03.promax_company and 
                ((t02.sales_organisation = pxi_common.gc_australia and t01.material_division = t03.promax_division) or (t02.sales_organisation = pxi_common.gc_new_zealand)) and 
                -- Get the traded unit zreps.
                t01.material_type = 'ZREP' and t01.mars_traded_unit_flag = 'X' and 
                -- Ensure the data hasn't been deleted and is correct in lads.
                t01.deletion_flag is null and t01.bds_lads_status = 1 and 
                -- Now check that this Zrep is distributed in the destination market.
                t02.sap_material_code = t01.sap_material_code and 
                -- Distribution Channel Filtering
                -- Make sure this product is not being sold to affilate markers or as a raws and packs product.
                t02.dstrbtn_channel not in ('98','99');
        -- Now update the session based temporary table for RSU Information.
        delete from pmx_matl_tdu_to_rsu;
        insert into pmx_matl_tdu_to_rsu 
               -- Bring in the records for when tdu to rsu no information. 
               select 
                  t01.parent_material_code as tdu_matl_code, -- Return the TDU material code
                  t01.child_material_code as rsu_matl_code, -- Return the child RSU Material Code.
                  t02.bds_material_desc_en as rsu_matl_desc, -- RSU Material Description
                  t01.child_ian as rsu_ean,  -- Retail EAN
                  t01.child_base_uom as rsu_uom, -- Retail UOM
                  t01.child_per_parent as rsus_per_tdu,  -- Units Per Case
                  t02.length as rsu_length, -- UnitLength
                  t02.width as rsu_width, -- UnitWidth
                  t02.height as rsu_height -- UnitHeight
                from 
                  bds_material_bom_all t01, -- @ap0064p_promax_testing t01, -- @ap0064p_promax_testing -- ZREP to TDU
                  bds_material_hdr t02 -- @ap0064p_promax_testing t02 -- @ap0064p_promax_testing -- Zrep Material Description.  
                where
                  t02.sap_material_code = t01.child_material_code and 
                  -- Ensure we have the correct TDU to RSU Bom Details 
                  t01.bom_plant = '*NONE' and t01.bom_alternative = '01' and
                  -- Units Per Case Usage Case 
                  t01.bom_usage = '5' and 
                  -- Production Bom Status
                  t01.bom_status in (1, 7) and 
                  -- That we are after where the child is the RSU
                  t01.child_rsu_flag = 'X' and 
                  -- Make sure only the current bom is being used for the TDU to RSU information
                  t01.bom_eff_date = (
                    select max(t0.bom_eff_date) 
                    from bds_material_bom_all t0 -- /*@ap0064p_promax_testing
                    where t0.bom_eff_date <= trunc(sysdate) and t0.parent_material_code = t01.parent_material_code and 
                      t0.bom_status = t01.bom_status and t0.bom_usage = t01.bom_usage and
                      t0.child_rsu_flag = t01.child_rsu_flag
                  )
                union
                -- Bring in a record for when the ZREP is the RSU.
                select 
                  t01.sap_material_code as tdu_matl_code, -- Return the 
                  t01.sap_material_code as rsu_matl_code, -- Return the child RSU Material Code.
                  t01.bds_material_desc_en as rsu_matl_desc, -- RSU Material Description
                  t01.interntl_article_no as rsu_ean,  -- Retail EAN
                  t01.base_uom as rsu_uom, -- Retail UOM
                  1 as rsus_per_tdu,  -- Units Per Case
                  t01.length as rsu_length, -- UnitLength
                  t01.width as rsu_width, -- UnitWidth
                  t01.height as rsu_height -- UnitHeight
                from 
                  bds_material_hdr t01 -- @ap0064p_promax_testing -- Zrep Material Description.  
                where
                  t01.mars_traded_unit_flag = 'X' and t01.mars_retail_sales_unit_flag = 'X';
     exception 
       when others then 
         pxi_common.reraise_promax_exception(pc_package_name,'POPULATE_TEMP_TABLES');                  
     end populate_temp_tables;
        
   begin
     -- Now populate the temp tables first.
     populate_temp_tables;
     -- Open cursor with the extract data.
     open csr_input;
     loop
       fetch csr_input into rv_product;
       exit when csr_input%notfound;
       -- Now determine if we should send this material.
       v_include := false;
       if rv_product.dstrbtn_chain_status != '99' and rv_product.xdstrbtn_chain_status = '10' then 
         v_include := true;
       else 
         if deleted_recently = true then 
           v_include := true;
         end if;
       end if;       
       -- Only include this material in the extract if we need to.
       if v_include then 
         -- If we extracted this product then lets update the product history. 
         update_product_history;   
         -- Create the new interface when required
         if lics_outbound_loader.is_created = false then
           v_instance := lics_outbound_loader.create_interface(pc_interface_name);
         end if;
         -- Append the interface data
         lics_outbound_loader.append_data(rv_product.row_data);
      end if;
    end loop;
    close csr_input;

    -- Finalise the interface when required
    if lics_outbound_loader.is_created = true then
      lics_outbound_loader.finalise_interface;
    end if;
    
    -- Now commit the changes that were made to the product history extract table.
    commit;

  exception
     when others then
       rollback;
       if lics_outbound_loader.is_created = true then
         lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
         lics_outbound_loader.finalise_interface;
       end if;
       pxi_common.reraise_promax_exception(pc_package_name,'EXECUTE');
   end execute;

end PXIPMX01_EXTRACT; 