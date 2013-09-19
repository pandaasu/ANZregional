-- This query can be run in production under the PXI_APP scheam to identify zrep materials that may need to be setup manually.  
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
            (case t2.gross_weight_unit when 'GRM' then t2.net_weight/1000 else t2.net_weight end) as tdu_net_weight, -- ShipperNetWeightKG
            t2.length as tdu_length, -- CaseLength
            t2.width as tdu_width, -- CaseLength
            t2.height as tdu_height -- CaseHeight
          from 
            -- Create the driving table of zreps that are distributed in the destination site, all records in this query must be in the output.
            (select 
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
                table(pxi_common.promax_config(null,null)) t03  -- Promax Configuration table
              where
                -- Join to promax configuration table.
                t02.sales_organisation = t03.promax_company and 
                ((t02.sales_organisation = '147' and t01.material_division = t03.promax_division) or (t02.sales_organisation = '149')) and 
                -- Get the traded unit zreps.
                t01.material_type = 'ZREP' and t01.mars_traded_unit_flag = 'X' and 
                -- Ensure the data hasn't been deleted and is correct in lads.
                t01.deletion_flag is null and t01.bds_lads_status = 1 and 
                -- Now check that this Zrep is distributed in the destination market.
                t02.sap_material_code = t01.sap_material_code and 
                -- Distribution Channel Filtering
                -- Make sure this product is not being sold to affilate markers or as a raws and packs product.
                t02.dstrbtn_channel not in ('98','99')) t1,
            bds_material_hdr t2, -- @ap0064p_promax_testing -- TDU Material Header Information
            (select 
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
                  t01.mars_traded_unit_flag = 'X' and t01.mars_retail_sales_unit_flag = 'X') t3 
          where
            -- Get the traded unit ferts for those zreps.
            t2.sap_material_code  = pxi_utils.determine_tdu_from_zrep(t1.zrep_matl_code,t1.sales_org,t1.dstrbtn_channel,null,sysdate) and
            t2.material_type = 'FERT' and t2.mars_traded_unit_flag  = 'X' and 
            -- Note We do not care if there are no current TDU's available for distribution.  ie.  No t2.xdstrbtn_chain_status = '10' Filter is included here.
            -- Ensure the data hasn't been deleted and is correct in lads.
            t2.deletion_flag is null and t2.bds_lads_status = 1 and 
            -- Now join RSU Information to the TDU Information
            t3.tdu_matl_code (+)  = t2.sap_material_code and 
            -- Now only display the final rows that have valid RSU information
            t3.rsu_ean is null and
            -- Now only display the final rows that have valid RSU information
            t1.dstrbtn_chain_status != '99' and t1.xdstrbtn_chain_status = '10' 