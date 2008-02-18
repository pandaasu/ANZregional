/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : matl_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Material Dimension View 

 YYYY/MM   Author             Description 
 -------   ------             ----------- 
 2007/12   Trevor Keon        Created 
 2008/02   Jonathan Girling   Added matl_classfctn_en view

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.matl_dim_view as
select ltrim(t01.matnr, '0') as matl_code,                    -- SAP Material Code 
  t02.maktx as matl_desc_en,                                  -- Material Description EN 
  decode(t01.mstae, '01', 'DONT USE',
                '02', 'DONT USE',
                '03', 'NOT COST',
                '10', 'ACTIVE',
                '20', 'ACTIVE',
                '23', 'WDRAWN',
                '40', 'DEVELOP',
                '50', 'CREATION',
                '90', 'RETIRED',
                '99', 'RETIRED') as matl_sts_code,            -- Material Status Code 
  t01.brgew as gross_wgt,                                     -- Gross Weight 
  t01.ntgew as net_wgt,                                       -- Net Weight 
  t01.gewei as wgt_unit_code,                                 -- SAP Weight Unit Code 
  v02.uom_abbrd_desc as wgt_unit_abbrd_desc,                  -- Weight Unit Abbreviated Description 
  v02.uom_desc as wgt_unit_desc,                              -- Weight Unit Description 
  t01.volum as vol,                                           -- Volume 
  t01.voleh as vol_unit_code,                                 -- SAP Volume Unit Code 
  v03.uom_abbrd_desc as vol_unit_abbrd_desc,                  -- Volume Unit Abbreviated Description 
  v03.uom_desc as vol_unit_desc,                              -- Volume Unit Description 
  t01.meins as base_uom_code,                                 -- SAP Base Unit of Measure Code 
  v04.uom_abbrd_desc as base_uom_abbrd_desc,                  -- Base Unit of Measure Abbreviated Description 
  v04.uom_desc as base_uom_desc,                              -- Base Unit of Measure Description 
  t01.zzitemowner as matl_owner,                              -- Material Owner 
  ltrim(t01.zzrepmatnr, '0') as rep_item,                     -- Representative Item 
  t01.zzmattim as mat_lead_time_days,                         -- Maturation Lead Time Days 
  t01.mhdhb as total_shelf_life,                              -- Total Shelf Life 
  t01.bismt as old_matl_code,                                 -- Old Material Number 
  t01.zzisint as matl_type_flag_int,                          -- Material Type Flag Intermediate Product Component 
  t01.zzisrsu as matl_type_flag_rsu,                          -- Material Type Flag Retail Sales Unit 
  t01.zzistdu as matl_type_flag_tdu,                          -- Material Type Flag Traded Unit 
  t01.zzismcu as matl_type_flag_mcu,                          -- Material Type Flag Merchanising Unit 
  t01.zzispro as matl_type_flag_pro,                          -- Material Type Flag Promotional Material 
  t01.zzissfp as matl_type_flag_sfp,                          -- Material Type Flag Semi Finished Product 
  t01.zzissc as matl_type_flag_sc,                            -- Material Type Flag Shipping Container 
  decode(t01.mtart, 'ZREP', 'X', NULL) as matl_type_flag_rep, -- Material Type Flag Representative Item 
  t01.ean11 as ean_upc,                                       -- EAN-UPC 
  t01.numtp as ean_upc_ctgry_code,                            -- SAP EAN-UPC Category Code 
  '' as ean_upc_ctgry_desc,                                   -- EAN-UPC Category Description (Not Loaded) 
  t01.spart as matl_division_code,                            -- SAP Material Division Code 
  v05.division_desc as matl_division_desc,                    -- Material Division Description 
  t01.mtart as matl_type_code,                                -- SAP Material Type Code 
  t01.mtart as matl_type_desc,                                -- Material Type Description (Not Loaded) 
  t01.matkl as matl_grp_code,                                 -- SAP Material Group Code 
  v01.matl_grp_desc,                                          -- Material Group Description 
  t01.magrv as matl_grp_packs_code,                           -- SAP Material Group Packs Code 
  '' as matl_grp_packs_desc,                                  -- Material Group Packs Description (Not Loaded) 
  v06.bus_sgmnt_code,                                         -- SAP Business Segment Code 
  v06.bus_sgmnt_abbrd_desc,                                   -- Business Segment Abbreviated Description 
  v06.bus_sgmnt_desc,                                         -- Business Segment Description 
  v06.mkt_sgmnt_code,                                         -- SAP Market Segment Code 
  v06.mkt_sgmnt_abbrd_desc,                                   -- Market Segment Abbreviated Description 
  v06.mkt_sgmnt_desc,                                         -- Market Segment Description 
  v06.brand_essnc_code,                                       -- SAP Brand Essence Code 
  v06.brand_essnc_abbrd_desc,                                 -- Brand Essence Abbreviated Description 
  v06.brand_essnc_desc,                                       -- Brand Essence Description 
  v06.brand_flag_code,                                        -- SAP Brand Flag Code 
  v06.brand_flag_abbrd_desc,                                  -- Brand Flag Abbreviated Description 
  v06.brand_flag_desc,                                        -- Brand Flag Description 
  v06.brand_sub_flag_code,                                    -- SAP Brand Sub-Flag Code 
  v06.brand_sub_flag_abbrd_desc,                              -- Brand Sub-Flag Abbreviated Description 
  v06.brand_sub_flag_desc,                                    -- Brand Sub-Flag Description
  v06.supply_sgmnt_code,                                      -- SAP Supply Segment Code 
  v06.supply_sgmnt_abbrd_desc,                                -- Supply Segment Abbreviated Description 
  v06.supply_sgmnt_desc,                                      -- Supply Segment Description
  v06.ingred_vrty_code,                                       -- SAP Ingredient Variety Code 
  v06.ingred_vrty_abbrd_desc,                                 -- Ingredient Variety Abbreviated Description 
  v06.ingred_vrty_desc,                                       -- Ingredient Variety Description 
  v06.funcl_vrty_code,                                        -- SAP Functional Variety Code 
  v06.funcl_vrty_abbrd_desc,                                  -- Functional Variety Abbreviated Description 
  v06.funcl_vrty_desc,                                        -- Functional Variety Description
  v06.multi_pack_qty_code,                                    -- SAP Multi-pack Quantity Code 
  v06.multi_pack_qty_abbrd_desc,                              -- Multi-pack Quantity Abbreviated Description 
  v06.multi_pack_qty_desc,                                    -- Multi-pack Quantity Description   
  v06.occsn_code,                                             -- SAP Occasion Code 
  v06.occsn_abbrd_desc,                                       -- Occasion Abbreviated Description 
  v06.occsn_desc,                                             -- Occasion Description
  v06.prdct_ctgry_code,                                       -- SAP Product Category Code 
  v06.prdct_ctgry_abbrd_desc,                                 -- Product Category Abbreviated Description 
  v06.prdct_ctgry_desc,                                       -- Product Category Description
  v06.prdct_type_code,                                        -- SAP Product Type Code 
  v06.prdct_type_abbrd_desc,                                  -- Product Type Abbreviated Description 
  v06.prdct_type_desc,                                        -- Product Type Description
  v06.prdct_pack_size_code,                                   -- SAP Product Pack Size Code 
  v06.prdct_pack_size_abbrd_desc,                             -- Product Pack Size Abbreviated Description 
  v06.prdct_pack_size_desc,                                   -- Product Pack Size Description
  v06.cnsmr_pack_frmt_code,                                   -- SAP Consumer Pack Format Code 
  v06.cnsmr_pack_frmt_abbrd_desc,                             -- Consumer Pack Format Abbreviated Description 
  v06.cnsmr_pack_frmt_desc,                                   -- Consumer Pack Format Description
  v06.cnsmr_pack_type_code,                                   -- SAP Consumer Pack Type Code 
  v06.cnsmr_pack_type_abbrd_desc,                             -- Consumer Pack Type Abbreviated Description 
  v06.cnsmr_pack_type_desc,                                   -- Consumer Pack Type Description
  v06.prdct_size_grp_code,                                    -- SAP Product Size Group Code 
  v06.prdct_size_grp_abbrd_desc,                              -- Product Size Group Abbreviated Description 
  v06.prdct_size_grp_desc,                                    -- Product Size Group Description 
  v06.trad_unit_frmt_code,                                    -- SAP Traded Unit Format Code 
  v06.trad_unit_frmt_abbrd_desc,                              -- Traded Unit Format Abbreviated Description 
  v06.trad_unit_frmt_desc,                                    -- Traded Unit Format Description
  v06.trad_unit_config_code,                                  -- SAP Traded Unit Configuration Code 
  v06.trad_unit_config_abbrd_desc,                            -- Traded Unit Configuration Abbreviated Description 
  v06.trad_unit_config_desc,                                  -- Traded Unit Configuration Description  
  v06.onpack_cnsmr_value_code,                                -- SAP On-pack Consumer Value Code 
  v06.onpack_cnsmr_value_abbrd_desc,                          -- On-pack Consumer Value Abbreviated Description 
  v06.onpack_cnsmr_value_desc,                                -- On-pack Consumer Value Description
  v06.onpack_cnsmr_offer_code,                                -- SAP On-pack Consumer Offer Code 
  v06.onpack_cnsmr_offer_abbrd_desc,                          -- On-pack Consumer Offer Abbreviated Description 
  v06.onpack_cnsmr_offer_desc,                                -- On-pack Consumer Offer Description
  v06.onpack_trade_offer_code,                                -- SAP On-pack Trade Offer Code 
  v06.onpack_trade_offer_abbrd_desc,                          -- On-pack Trade Offer Abbreviated Description 
  v06.onpack_trade_offer_desc,                                -- On-pack Trade Offer Description
  v06.mktg_concept_code,                                      -- SAP Marketing Concept Code 
  v06.mktg_concept_abbrd_desc,                                -- Marketing Concept Abbreviated Description 
  v06.mktg_concept_desc,                                      -- Marketing Concept Description
  v06.cuisine_code,                                           -- SAP Cuisine Code 
  v06.cuisine_abbrd_desc,                                     -- Cuisine Abbreviated Description 
  v06.cuisine_desc,                                           -- Cuisine Description
  v06.disp_strg_cndtn_code,                                   -- SAP Display Storage Condition Code 
  v06.disp_strg_cndtn_abbrd_desc,                             -- Display Storage Condition Abbreviated Description 
  v06.disp_strg_cndtn_desc,                                   -- Display Storage Condition Description
  v06.trade_sector_code,                                      -- SAP Trade Sector Code 
  v06.trade_sector_abbrd_desc,                                -- Trade Sector Abbreviated Description 
  v06.trade_sector_desc,                                      -- Trade Sector Description
  v06.mkt_ctgry_code,                                         -- SAP Market Category Code 
  v06.mkt_ctgry_desc,                                         -- Market Category Description  
  v06.mkt_sub_ctgry_code,                                     -- SAP Market Sub-Category Code 
  v06.mkt_sub_ctgry_desc,                                     -- Market Sub-Category Description
  v06.mkt_sub_ctgry_grp_code,                                 -- SAP Market Sub-Category Group Code 
  v06.mkt_sub_ctgry_grp_desc,                                 -- Market Sub-Category Group Description       
  v06.fighting_unit_code,                                     -- SAP Fighting Unit Code 
  v06.fighting_unit_desc,                                     -- Fighting Unit Description 
  v06.sop_bus_code,                                           -- SAP S&OP Business Code 
  v06.sop_bus_desc,                                           -- S&OP Business Description
  v06.plng_srce_code,                                         -- SAP Planning Source Code 
  v06.plng_srce_desc,                                         -- Planning Source Description
  v06.prodn_line_code,                                        -- SAP Production Line Code 
  v06.prodn_line_desc                                         -- Production Line Description                                                     
from sap_mat_hdr t01,
  sap_mat_mkt t02,
  matl_grp v01,                                               -- Material Group 
  uom v02,                                                    -- Weight UOM 
  uom v03,                                                    -- Volume UOM 
  uom v04,                                                    -- Base UOM 
  division v05,                                               -- Material Division
  matl_classfctn_en v06                                       -- Material Classfication    
where t01.valdtn_status = 'VALID'
  and t02.spras_iso (+) = 'EN'
  and t01.matnr = t02.matnr (+)
  and t01.matkl = v01.matl_grp_code (+)                       -- Material Group 
  and t01.gewei = v02.uom_code                                -- Weight UOM 
  and t01.voleh = v03.uom_code (+)                            -- Volume UOM 
  and t01.meins = v04.uom_code                                -- Base UOM  
  and t01.matnr = v06.material_code (+)                       -- Materical Classification
  and 
  (
    t01.spart = v05.division_code (+)
    and v05.division_lang (+) = 'E'
  );                                                          -- Material Division 
  
  
/*-*/
/* Authority 
/*-*/
grant select on ods_app.matl_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym matl_dim_view for ods_app.matl_dim_view;