/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : matl_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Material Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/12   Trevor Keon    Created 

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
  v27.uom_abbrd_desc as wgt_unit_abbrd_desc,                  -- Weight Unit Abbreviated Description 
  v27.uom_desc as wgt_unit_desc,                              -- Weight Unit Description 
  t01.volum as vol,                                           -- Volume 
  t01.voleh as vol_unit_code,                                 -- SAP Volume Unit Code 
  v28.uom_abbrd_desc as vol_unit_abbrd_desc,                  -- Volume Unit Abbreviated Description 
  v28.uom_desc as vol_unit_desc,                              -- Volume Unit Description 
  t01.meins as base_uom_code,                                 -- SAP Base Unit of Measure Code 
  v29.uom_abbrd_desc as base_uom_abbrd_desc,                  -- Base Unit of Measure Abbreviated Description 
  v29.uom_desc as base_uom_desc,                              -- Base Unit of Measure Description 
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
  v30.division_desc as matl_division_desc,                    -- Material Division Description 
  t01.mtart as matl_type_code,                                -- SAP Material Type Code 
  t01.mtart as matl_type_desc,                                -- Material Type Description (Not Loaded) 
  t01.matkl as matl_grp_code,                                 -- SAP Material Group Code 
  v01.matl_grp_desc,                                          -- Material Group Description 
  t01.magrv as matl_grp_packs_code,                           -- SAP Material Group Packs Code 
  '' as matl_grp_packs_desc,                                  -- Material Group Packs Description (Not Loaded) 
  v02.bus_sgmnt_code,                                         -- SAP Business Segment Code 
  v02.bus_sgmnt_abbrd_desc,                                   -- Business Segment Abbreviated Description 
  v02.bus_sgmnt_desc,                                         -- Business Segment Description 
  v03.mkt_sgmnt_code,                                         -- SAP Market Segment Code 
  v03.mkt_sgmnt_abbrd_desc,                                   -- Market Segment Abbreviated Description 
  v03.mkt_sgmnt_desc,                                         -- Market Segment Description 
  v04.brand_essnc_code,                                       -- SAP Brand Essence Code 
  v04.brand_essnc_abbrd_desc,                                 -- Brand Essence Abbreviated Description 
  v04.brand_essnc_desc,                                       -- Brand Essence Description 
  v05.brand_flag_code,                                        -- SAP Brand Flag Code 
  v05.brand_flag_abbrd_desc,                                  -- Brand Flag Abbreviated Description 
  v05.brand_flag_desc,                                        -- Brand Flag Description 
  v06.brand_sub_flag_code,                                    -- SAP Brand Sub-Flag Code 
  v06.brand_sub_flag_abbrd_desc,                              -- Brand Sub-Flag Abbreviated Description 
  v06.brand_sub_flag_desc,                                    -- Brand Sub-Flag Description
  v07.supply_sgmnt_code,                                      -- SAP Supply Segment Code 
  v07.supply_sgmnt_abbrd_desc,                                -- Supply Segment Abbreviated Description 
  v07.supply_sgmnt_desc,                                      -- Supply Segment Description
  v08.ingred_vrty_code,                                       -- SAP Ingredient Variety Code 
  v08.ingred_vrty_abbrd_desc,                                 -- Ingredient Variety Abbreviated Description 
  v08.ingred_vrty_desc,                                       -- Ingredient Variety Description 
  v09.funcl_vrty_code,                                        -- SAP Functional Variety Code 
  v09.funcl_vrty_abbrd_desc,                                  -- Functional Variety Abbreviated Description 
  v09.funcl_vrty_desc,                                        -- Functional Variety Description
  v10.multi_pack_qty_code,                                    -- SAP Multi-pack Quantity Code 
  v10.multi_pack_qty_abbrd_desc,                              -- Multi-pack Quantity Abbreviated Description 
  v10.multi_pack_qty_desc,                                    -- Multi-pack Quantity Description   
  v11.occsn_code,                                             -- SAP Occasion Code 
  v11.occsn_abbrd_desc,                                       -- Occasion Abbreviated Description 
  v11.occsn_desc,                                             -- Occasion Description
  v12.prdct_ctgry_code,                                       -- SAP Product Category Code 
  v12.prdct_ctgry_abbrd_desc,                                 -- Product Category Abbreviated Description 
  v12.prdct_ctgry_desc,                                       -- Product Category Description
  v13.prdct_type_code,                                        -- SAP Product Type Code 
  v13.prdct_type_abbrd_desc,                                  -- Product Type Abbreviated Description 
  v13.prdct_type_desc,                                        -- Product Type Description
  v14.prdct_pack_size_code,                                   -- SAP Product Pack Size Code 
  v14.prdct_pack_size_abbrd_desc,                             -- Product Pack Size Abbreviated Description 
  v14.prdct_pack_size_desc,                                   -- Product Pack Size Description
  v15.cnsmr_pack_frmt_code,                                   -- SAP Consumer Pack Format Code 
  v15.cnsmr_pack_frmt_abbrd_desc,                             -- Consumer Pack Format Abbreviated Description 
  v15.cnsmr_pack_frmt_desc,                                   -- Consumer Pack Format Description
  v16.cnsmr_pack_type_code,                                   -- SAP Consumer Pack Type Code 
  v16.cnsmr_pack_type_abbrd_desc,                             -- Consumer Pack Type Abbreviated Description 
  v16.cnsmr_pack_type_desc,                                   -- Consumer Pack Type Description
  v17.prdct_size_grp_code,                                    -- SAP Product Size Group Code 
  v17.prdct_size_grp_abbrd_desc,                              -- Product Size Group Abbreviated Description 
  v17.prdct_size_grp_desc,                                    -- Product Size Group Description 
  v18.trad_unit_frmt_code,                                    -- SAP Traded Unit Format Code 
  v18.trad_unit_frmt_abbrd_desc,                              -- Traded Unit Format Abbreviated Description 
  v18.trad_unit_frmt_desc,                                    -- Traded Unit Format Description
  v19.trad_unit_config_code,                                  -- SAP Traded Unit Configuration Code 
  v19.trad_unit_config_abbrd_desc,                            -- Traded Unit Configuration Abbreviated Description 
  v19.trad_unit_config_desc,                                  -- Traded Unit Configuration Description  
  v20.onpack_cnsmr_value_code,                                -- SAP On-pack Consumer Value Code 
  v20.onpack_cnsmr_value_abbrd_desc,                          -- On-pack Consumer Value Abbreviated Description 
  v20.onpack_cnsmr_value_desc,                                -- On-pack Consumer Value Description
  v21.onpack_cnsmr_offer_code,                                -- SAP On-pack Consumer Offer Code 
  v21.onpack_cnsmr_offer_abbrd_desc,                          -- On-pack Consumer Offer Abbreviated Description 
  v21.onpack_cnsmr_offer_desc,                                -- On-pack Consumer Offer Description
  v22.onpack_trade_offer_code,                                -- SAP On-pack Trade Offer Code 
  v22.onpack_trade_offer_abbrd_desc,                          -- On-pack Trade Offer Abbreviated Description 
  v22.onpack_trade_offer_desc,                                -- On-pack Trade Offer Description
  v23.mktg_concept_code,                                      -- SAP Marketing Concept Code 
  v23.mktg_concept_abbrd_desc,                                -- Marketing Concept Abbreviated Description 
  v23.mktg_concept_desc,                                      -- Marketing Concept Description
  v24.cuisine_code,                                           -- SAP Cuisine Code 
  v24.cuisine_abbrd_desc,                                     -- Cuisine Abbreviated Description 
  v24.cuisine_desc,                                           -- Cuisine Description
  v25.disp_strg_cndtn_code,                                   -- SAP Display Storage Condition Code 
  v25.disp_strg_cndtn_abbrd_desc,                             -- Display Storage Condition Abbreviated Description 
  v25.disp_strg_cndtn_desc,                                   -- Display Storage Condition Description
  v26.trade_sector_code,                                      -- SAP Trade Sector Code 
  v26.trade_sector_abbrd_desc,                                -- Trade Sector Abbreviated Description 
  v26.trade_sector_desc,                                      -- Trade Sector Description
  v31.mkt_ctgry_code,                                         -- SAP Market Category Code 
  v31.mkt_ctgry_desc,                                         -- Market Category Description  
  v32.mkt_sub_ctgry_code,                                     -- SAP Market Sub-Category Code 
  v32.mkt_sub_ctgry_desc,                                     -- Market Sub-Category Description
  v33.mkt_sub_ctgry_grp_code,                                 -- SAP Market Sub-Category Group Code 
  v33.mkt_sub_ctgry_grp_desc,                                 -- Market Sub-Category Group Description       
  v34.fighting_unit_code,                                     -- SAP Fighting Unit Code 
  v34.fighting_unit_desc,                                     -- Fighting Unit Description 
  v35.sop_bus_code,                                           -- SAP S&OP Business Code 
  v35.sop_bus_desc,                                           -- S&OP Business Description
  v36.plng_srce_code,                                         -- SAP Planning Source Code 
  v36.plng_srce_desc,                                         -- Planning Source Description
  v37.prodn_line_code,                                        -- SAP Production Line Code 
  v37.prodn_line_desc                                         -- Production Line Description                                                     
from sap_mat_hdr t01,
  sap_mat_mkt t02,
  matl_grp v01,                                               -- Material Group 
  bus_sgmnt v02,                                              -- Business Segment 
  mkt_sgmnt v03,                                              -- Market Segment 
  brand_essnc v04,                                            -- Brand Essence 
  brand_flag v05,                                             -- Brand Flag 
  brand_sub_flag v06,                                         -- Brand Sub Flag 
  supply_sgmnt v07,                                           -- Supply Segment 
  ingred_vrty v08,                                            -- Ingredient Variety 
  funcl_vrty v09,                                             -- Functional Variety 
  multi_pack_qty v10,                                         -- Multi Pack Quantity 
  occsn v11,                                                  -- Occasion 
  prdct_ctgry v12,                                            -- Product Category 
  prdct_type v13,                                             -- Product Type 
  prdct_pack_size v14,                                        -- Product Pack Size 
  cnsmr_pack_frmt v15,                                        -- Consumer Pack Format 
  cnsmr_pack_type v16,                                        -- Consumer Pack Type 
  prdct_size_grp v17,                                         -- Product Size Group 
  trad_unit_frmt v18,                                         -- Traded Unit Format 
  trad_unit_config v19,                                       -- Traded Unit Config 
  onpack_cnsmr_value v20,                                     -- On-pack Consumer Value 
  onpack_cnsmr_offer v21,                                     -- On-pack Consumer Offer 
  onpack_trade_offer v22,                                     -- On-pack Trade Offer 
  mktg_concept v23,                                           -- Marketing Concept 
  cuisine v24,                                                -- Cuisine 
  disp_strg_cndtn v25,                                        -- Display Storage Condition 
  trade_sector v26,                                           -- Trade Sector 
  uom v27,                                                    -- Weight UOM 
  uom v28,                                                    -- Volume UOM 
  uom v29,                                                    -- Base UOM 
  division v30,                                               -- Material Division 
  mkt_ctgry v31,                                              -- Market Category 
  mkt_sub_ctgry v32,                                          -- Market Sub Category 
  mkt_sub_ctgry_grp v33,                                      -- Market Sub Group Category 
  fighting_unit v34,                                          -- Fighting Unit 
  sop_bus v35,                                                -- S&OP Business Code 
  plng_srce v36,                                              -- Planning Source 
  prodn_line v37                                              -- Production Line 
where t01.valdtn_status = 'VALID'
  and t02.spras_iso (+) = 'EN'
  and t01.matnr = t02.matnr (+)
  and t01.matkl = v01.matl_grp_code (+)                       -- Material Group 
  and t01.matnr = v02.objek (+)                               -- Business Segment 
  and t01.matnr = v03.objek (+)                               -- Market Segment 
  and t01.matnr = v04.objek (+)                               -- Brand Essence 
  and t01.matnr = v05.objek (+)                               -- Brand Flag 
  and t01.matnr = v06.objek (+)                               -- Brand Sub Flag 
  and t01.matnr = v07.objek (+)                               -- Supply Segment 
  and t01.matnr = v08.objek (+)                               -- Ingredient Variety 
  and t01.matnr = v09.objek (+)                               -- Functional Variety 
  and t01.matnr = v10.objek (+)                               -- Multi Pack Quantity 
  and t01.matnr = v11.objek (+)                               -- Occasion 
  and t01.matnr = v12.objek (+)                               -- Product Category 
  and t01.matnr = v13.objek (+)                               -- Product Type 
  and t01.matnr = v14.objek (+)                               -- Product Pack Size 
  and t01.matnr = v15.objek (+)                               -- Consumer Pack Format 
  and t01.matnr = v16.objek (+)                               -- Consumer Pack Type 
  and t01.matnr = v17.objek (+)                               -- Product Size Group 
  and t01.matnr = v18.objek (+)                               -- Traded Unit Format 
  and t01.matnr = v19.objek (+)                               -- Traded Unit Config 
  and t01.matnr = v20.objek (+)                               -- On-pack Consumer Value 
  and t01.matnr = v21.objek (+)                               -- On-pack Consumer Offer 
  and t01.matnr = v22.objek (+)                               -- On-pack Trade Offer 
  and t01.matnr = v23.objek (+)                               -- Marketing Concept 
  and t01.matnr = v24.objek (+)                               -- Cuisine 
  and t01.matnr = v25.objek (+)                               -- Display Storage Condition 
  and t01.matnr = v26.objek (+)                               -- Trade Sector 
  and t01.gewei = v27.uom_code                                -- Weight UOM 
  and t01.voleh = v28.uom_code (+)                            -- Volume UOM 
  and t01.meins = v29.uom_code                                -- Base UOM  
  and 
  (
    t01.spart = v30.division_code (+)
    and v30.division_lang (+) = 'E'
  )                                                           -- Material Division 
  and t01.matnr = v31.objek (+)                               -- Market Category 
  and t01.matnr = v32.objek (+)                               -- Market Sub Category 
  and t01.matnr = v33.objek (+)                               -- Market Sub Group Category 
  and t01.matnr = v34.objek (+)                               -- Fighting Unit 
  and t01.matnr = v35.objek (+)                               -- S&OP Business Code 
  and t01.matnr = v36.objek (+)                               -- Planning Source 
  and t01.matnr = v37.objek (+);                              -- Production Line 
  
/*-*/
/* Authority 
/*-*/
--grant select on ods_app.matl_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym matl_dim_view for ods_app.matl_dim_view;