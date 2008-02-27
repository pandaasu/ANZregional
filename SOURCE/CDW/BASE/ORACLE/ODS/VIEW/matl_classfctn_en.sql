/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : matl_classfctn_en   
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Materical Classification View 

 YYYY/MM   Author             Description 
 -------   ------             ----------- 
 2008/02   Jonathan Girling   Created 
 2008/02   Jonathan Girling   Added classification codes and descriptions for:
                               - Z-APCHAR11 
                               - Z_APCHAR12 
                               - Z_APCHAR13

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.matl_classfctn_en as
select t01.material_code,
  t01.prdct_type_code,                          -- SAP Product Type Code 
  t02.prdct_type_abbrd_desc,                    -- Product Type Abbreviated Description 
  t02.prdct_type_desc,                          -- Product Type Description
  t01.supply_sgmnt_code,                        -- SAP Supply Segment Code 
  t03.supply_sgmnt_abbrd_desc,                  -- Supply Segment Abbreviated Description 
  t03.supply_sgmnt_desc,                        -- Supply Segment Description    
  t01.trad_unit_config_code,                    -- SAP Traded Unit Configuration Code  
  t04.trad_unit_config_abbrd_desc,              -- Traded Unit Configuration Abbreviated Description 
  t04.trad_unit_config_desc,                    -- Traded Unit Configuration Description  
  t01.trad_unit_frmt_code,                      -- SAP Traded Unit Format Code  
  t05.trad_unit_frmt_abbrd_desc,                -- Traded Unit Format Abbreviated Description   
  t05.trad_unit_frmt_desc,                      -- Traded Unit Format Description    
  t01.trade_sector_code,                        -- SAP Trade Sector Code  
  t06.trade_sector_abbrd_desc,                  -- Trade Sector Abbreviated Description   
  t06.trade_sector_desc,                        -- Trade Sector Description  
  t01.brand_essnc_code,                         -- SAP Brand Essence Code  
  t07.brand_essnc_abbrd_desc,                   -- Brand Essence Abbreviated Description 
  t07.brand_essnc_desc,                         -- Brand Essence Description 
  t01.brand_flag_code,                          -- SAP Brand Flag Code 
  t08.brand_flag_abbrd_desc,                    -- Brand Flag Abbreviated Description 
  t08.brand_flag_desc,                          -- Brand Flag Description 
  t01.brand_sub_flag_code,                      -- SAP Brand Sub-Flag Code 
  t09.brand_sub_flag_abbrd_desc,                -- Brand Sub-Flag Abbreviated Description 
  t09.brand_sub_flag_desc,                      -- Brand Sub-Flag Description   
  t01.bus_sgmnt_code,                           -- SAP Business Segment Code 
  t10.bus_sgmnt_abbrd_desc,                     -- Business Segment Abbreviated Description 
  t10.bus_sgmnt_desc,                           -- Business Segment Description 
  t01.cnsmr_pack_frmt_code,                     -- SAP Consumer Pack Format Code 
  t11.cnsmr_pack_frmt_abbrd_desc,               -- Consumer Pack Format Abbreviated Description   
  t11.cnsmr_pack_frmt_desc,                     -- Consumer Pack Format Description  
  t01.cnsmr_pack_type_code,                     -- SAP Consumer Pack Type Code  
  t12.cnsmr_pack_type_abbrd_desc,               -- Consumer Pack Type Abbreviated Description   
  t12.cnsmr_pack_type_desc,                     -- Consumer Pack Type Description  
  t01.cuisine_code,                             -- SAP Cuisine Code  
  t13.cuisine_abbrd_desc,                       -- Cuisine Abbreviated Description   
  t13.cuisine_desc,                             -- Cuisine Description  
  t01.disp_strg_cndtn_code,                     -- SAP Display Storage Condition Code  
  t14.disp_strg_cndtn_abbrd_desc,               -- Display Storage Condition Abbreviated Description   
  t14.disp_strg_cndtn_desc,                     -- Display Storage Condition Description 
  t01.funcl_vrty_code,                          -- SAP Functional Variety Code 
  t15.funcl_vrty_abbrd_desc,                    -- Functional Variety Abbreviated Description 
  t15.funcl_vrty_desc,                          -- Functional Variety Description 
  t01.ingred_vrty_code,                         -- SAP Ingredient Variety Code 
  t16.ingred_vrty_abbrd_desc,                   -- Ingredient Variety Abbreviated Description 
  t16.ingred_vrty_desc,                         -- Ingredient Variety Description 
  t01.mkt_sgmnt_code,                           -- SAP Market Segment Code 
  t17.mkt_sgmnt_abbrd_desc,                     -- Market Segment Abbreviated Description 
  t17.mkt_sgmnt_desc,                           -- Market Segment Description 
  t01.mktg_concept_code,                        -- SAP Marketing Concept Code  
  t18.mktg_concept_abbrd_desc,                  -- Marketing Concept Abbreviated Description   
  t18.mktg_concept_desc,                        -- Marketing Concept Description  
  t01.multi_pack_qty_code,                      -- SAP Multi-pack Quantity Code 
  t19.multi_pack_qty_abbrd_desc,                -- Multi-pack Quantity Abbreviated Description 
  t19.multi_pack_qty_desc,                      -- Multi-pack Quantity Description 
  t01.occsn_code,                               -- SAP Occasion Code 
  t20.occsn_abbrd_desc,                         -- Occasion Abbreviated Description  
  t20.occsn_desc,                               -- Occasion Description 
  t01.onpack_cnsmr_offer_code,                  -- SAP On-pack Consumer Offer Code 
  t21.onpack_cnsmr_offer_abbrd_desc,            -- On-pack Consumer Offer Abbreviated Description   
  t21.onpack_cnsmr_offer_desc,                  -- On-pack Consumer Offer Description  
  t01.onpack_cnsmr_value_code,                  -- SAP On-pack Consumer Value Code  
  t22.onpack_cnsmr_value_abbrd_desc,            -- On-pack Consumer Value Abbreviated Description   
  t22.onpack_cnsmr_value_desc,                  -- On-pack Consumer Value Description  
  t01.onpack_trade_offer_code,                  -- SAP On-pack Trade Offer Code  
  t23.onpack_trade_offer_abbrd_desc,            -- On-pack Trade Offer Abbreviated Description   
  t23.onpack_trade_offer_desc,                  -- On-pack Trade Offer Description  
  t01.prdct_ctgry_code,                         -- SAP Product Category Code 
  t24.prdct_ctgry_abbrd_desc,                   -- Product Category Abbreviated Description 
  t24.prdct_ctgry_desc,                         -- Product Category Description 
  t01.prdct_pack_size_code,                     -- SAP Product Pack Size Code  
  t25.prdct_pack_size_abbrd_desc,               -- Product Pack Size Abbreviated Description    
  t25.prdct_pack_size_desc,                     -- Product Pack Size Description  
  t01.prdct_size_grp_code,                      -- SAP Product Size Group Code  
  t26.prdct_size_grp_abbrd_desc,                -- Product Size Group Abbreviated Description   
  t26.prdct_size_grp_desc,                      -- Product Size Group Description 
  t01.sop_bus_code,                             -- SAP S and OP Business Code 
  t27.sop_bus_desc,                             -- S and OP Business Description 
  t01.fighting_unit_code,                       -- SAP Fighting Unit Code 
  t28.fighting_unit_desc,                       -- Fighting Unit Description 
  t01.mkt_ctgry_code,                           -- SAP Market Category Code 
  t29.mkt_ctgry_desc,                           -- Market Category Description 
  t01.mkt_sub_ctgry_code,                       -- SAP Market Sub-Category Code 
  t30.mkt_sub_ctgry_desc,                       -- Market Sub-Category Description 
  t01.mkt_sub_ctgry_grp_code,                   -- SAP Market Sub-Category Group Code 
  t31.mkt_sub_ctgry_grp_desc,                   -- Market Sub-Category Group Description 
  t01.plng_srce_code,                           -- SAP Planning Source Code 
  t32.plng_srce_desc,                           -- Planning Source Description 
  t01.prodn_line_code,                          -- SAP Production Line Code 
  t33.prodn_line_desc,                          -- Production Line Description
  t01.nz_promo_grp_code,                        -- NZ Promotional Group Code
  t34.nz_promo_grp_desc,                        -- NZ Promotional Group Description
  t01.nz_sop_bus_code,                          -- NZ S and OP Business Code
  t35.nz_sop_bus_desc,                          -- NZ S and OP Business Description
  t01.nz_must_win_code,                         -- NZ Must Win Category Code
  t36.nz_must_win_desc                          -- NZ Must Win Category Description
from (
        select t01.objek as material_code,                                                          -- Material Code  
            max(case when t02.atnam = 'CLFFERT16' then t02.atwrt end) as brand_essnc_code,          -- SAP Brand Essence Code  
            max(case when t02.atnam = 'CLFFERT03' then t02.atwrt end) as brand_flag_code,           -- SAP Brand Flag Code 
            max(case when t02.atnam = 'CLFFERT04' then t02.atwrt end) as brand_sub_flag_code,       -- SAP Brand Sub-Flag Code 
            max(case when t02.atnam = 'CLFFERT01' then t02.atwrt end) as bus_sgmnt_code,            -- SAP Business Segment Code 
            max(case when t02.atnam = 'CLFFERT25' then t02.atwrt end) as cnsmr_pack_frmt_code,      -- SAP Consumer Pack Format Code 
            max(case when t02.atnam = 'CLFFERT17' then t02.atwrt end) as cnsmr_pack_type_code,      -- SAP Consumer Pack Type Code  
            max(case when t02.atnam = 'CLFFERT40' then t02.atwrt end) as cuisine_code,              -- SAP Cuisine Code  
            max(case when t02.atnam = 'CLFFERT19' then t02.atwrt end) as disp_strg_cndtn_code,      -- SAP Display Storage Condition Code  
            max(case when t02.atnam = 'Z_APCHAR6' then t02.atwrt end) as fighting_unit_code,        -- SAP Fighting Unit Code 
            max(case when t02.atnam = 'CLFFERT07' then t02.atwrt end) as funcl_vrty_code,           -- SAP Functional Variety Code 
            max(case when t02.atnam = 'CLFFERT06' then t02.atwrt end) as ingred_vrty_code,          -- SAP Ingredient Variety Code
            max(case when t02.atnam = 'Z_APCHAR1' then t02.atwrt end) as mkt_ctgry_code,            -- SAP Market Category Code 
            max(case when t02.atnam = 'CLFFERT02' then t02.atwrt end) as mkt_sgmnt_code,            -- SAP Market Segment Code 
            max(case when t02.atnam = 'Z_APCHAR2' then t02.atwrt end) as mkt_sub_ctgry_code,        -- SAP Market Sub-Category Code
            max(case when t02.atnam = 'Z_APCHAR3' then t02.atwrt end) as mkt_sub_ctgry_grp_code,    -- SAP Market Sub-Category Group Code 
            max(case when t02.atnam = 'CLFFERT09' then t02.atwrt end) as mktg_concept_code,         -- SAP Marketing Concept Code  
            max(case when t02.atnam = 'CLFFERT10' then t02.atwrt end) as multi_pack_qty_code,       -- SAP Multi-pack Quantity Code 
            max(case when t02.atnam = 'CLFFERT11' then t02.atwrt end) as occsn_code,                -- SAP Occasion Code 
            max(case when t02.atnam = 'CLFFERT23' then t02.atwrt end) as onpack_cnsmr_offer_code,   -- SAP On-pack Consumer Offer Code 
            max(case when t02.atnam = 'CLFFERT22' then t02.atwrt end) as onpack_cnsmr_value_code,   -- SAP On-pack Consumer Value Code  
            max(case when t02.atnam = 'CLFFERT24' then t02.atwrt end) as onpack_trade_offer_code,   -- SAP On-pack Trade Offer Code  
            max(case when t02.atnam = 'Z_APCHAR8' then t02.atwrt end) as plng_srce_code,            -- SAP Planning Source Code 
            max(case when t02.atnam = 'CLFFERT12' then t02.atwrt end) as prdct_ctgry_code,          -- SAP Product Category Code 
            max(case when t02.atnam = 'CLFFERT14' then t02.atwrt end) as prdct_pack_size_code,      -- SAP Product Pack Size Code  
            max(case when t02.atnam = 'CLFFERT18' then t02.atwrt end) as prdct_size_grp_code,       -- SAP Product Size Group Code  
            max(case when t02.atnam = 'CLFFERT13' then t02.atwrt end) as prdct_type_code,           -- SAP Product Type Code   
            max(case when t02.atnam = 'Z_APCHAR5' then t02.atwrt end) as prodn_line_code,           -- SAP Production Line Code 
            max(case when t02.atnam = 'Z_APCHAR4' then t02.atwrt end) as sop_bus_code,              -- SAP S and OP Business Code 
            max(case when t02.atnam = 'CLFFERT05' then t02.atwrt end) as supply_sgmnt_code,         -- SAP Supply Segment Code 
            max(case when t02.atnam = 'CLFFERT21' then t02.atwrt end) as trad_unit_config_code,     -- SAP Traded Unit Configuration Code  
            max(case when t02.atnam = 'CLFFERT20' then t02.atwrt end) as trad_unit_frmt_code,       -- SAP Traded Unit Format Code  
            max(case when t02.atnam = 'CLFFERT08' then t02.atwrt end) as trade_sector_code,         -- SAP Trade Sector Code  
            max(case when t02.atnam = 'Z_APCHAR11' then t02.atwrt end) as nz_promo_grp_code,        -- NZ Promotional Group
            max(case when t02.atnam = 'Z_APCHAR12' then t02.atwrt end) as nz_sop_bus_code,          -- NZ S and OP Business Code
            max(case when t02.atnam = 'Z_APCHAR13' then t02.atwrt end) as nz_must_win_code          -- NZ Must Win Category
        from sap_cla_hdr t01,
            sap_cla_chr t02
        where t01.obtab = t02.obtab(+)
            and t01.objek = t02.objek(+)
            and t01.obtab = 'MARA'
            and t01.klart = '001'
        group by t01.objek
    ) t01,
    ( select trim(substr(z_data,4,3)) as prdct_type_code,  
        substr(z_data,7,12) as prdct_type_abbrd_desc,     
        substr(z_data,19,30) as prdct_type_desc          
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC013'
    ) t02,  -- Product Type 
    ( select trim(substr(z_data,4,3)) as supply_sgmnt_code,
        substr(z_data,7,12) as supply_sgmnt_abbrd_desc, 
        substr(z_data,19,30) as supply_sgmnt_desc           
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC005'
    ) t03,  -- Supply Segment 
    ( select trim(substr(z_data,4,3)) as trad_unit_config_code,  
        substr(z_data,7,12) as trad_unit_config_abbrd_desc,
        substr(z_data,19,30) as trad_unit_config_desc        
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC021'
    ) t04,  -- Traded Unit Configuration 
    ( select trim(substr(z_data,4,2)) as trad_unit_frmt_code,
        substr(z_data,6,12) as trad_unit_frmt_abbrd_desc,   
        substr(z_data,18,30) as trad_unit_frmt_desc
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC020'
    ) t05,  -- Traded Unit Format 
    ( select trim(substr(z_data,4,2)) as trade_sector_code,  
        substr(z_data,6,12) as trade_sector_abbrd_desc,   
        substr(z_data,18,30) as trade_sector_desc  
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC008'
    ) t06,  -- Trade Sector 
    ( select trim(substr(z_data,4,3)) as brand_essnc_code,  
        substr(z_data,7,12) as brand_essnc_abbrd_desc, 
        substr(z_data,19,30) as brand_essnc_desc
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC016'
    ) t07,  -- Brand Essence 
    ( select trim(substr(z_data,4,3)) as brand_flag_code, 
        substr(z_data,7,12) as brand_flag_abbrd_desc, 
        substr(z_data,19,30) as brand_flag_desc
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC003'
    ) t08,  -- Brand Flag 
    ( select trim(substr(z_data,4,3)) as brand_sub_flag_code, 
        substr(z_data,7,12) as brand_sub_flag_abbrd_desc, 
        substr(z_data,19,30) as brand_sub_flag_desc 
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC004'
    ) t09,  -- Brand Sub-Flag 
    ( select trim(substr(z_data,4,2)) as bus_sgmnt_code, 
        substr(z_data,6,12) as bus_sgmnt_abbrd_desc, 
        substr(z_data,18,30) as bus_sgmnt_desc 
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC001'
    ) t10,  -- Business Segment    
    ( select trim(substr(z_data,4,2)) as cnsmr_pack_frmt_code, 
        substr(z_data,6,12) as cnsmr_pack_frmt_abbrd_desc,   
        substr(z_data,18,30) as cnsmr_pack_frmt_desc  
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC025'
    ) t11,  -- Consumer Pack Format 
    ( select trim(substr(z_data,4,2)) as cnsmr_pack_type_code,  
        substr(z_data,6,12) as cnsmr_pack_type_abbrd_desc,   
        substr(z_data,18,30) as cnsmr_pack_type_desc   
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC017'
    ) t12,  -- Consumer Pack Type 
    ( select trim(substr(z_data,4,2)) as cuisine_code,  
        substr(z_data,6,12) as cuisine_abbrd_desc,   
        substr(z_data,18,30) as cuisine_desc     
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC040'
    ) t13,  -- Cuisine 
    ( select trim(substr(z_data,4,2)) as disp_strg_cndtn_code,  
        substr(z_data,6,12) as disp_strg_cndtn_abbrd_desc,   
        substr(z_data,18,30) as disp_strg_cndtn_desc   
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC019'
    ) t14,  -- Display Storage Condition 
    ( select trim(substr(z_data,4,3)) as funcl_vrty_code,
        substr(z_data,7,12) as funcl_vrty_abbrd_desc, 
        substr(z_data,19,30) as funcl_vrty_desc 
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC007'
    ) t15,  -- Functional Variety 
    ( select trim(substr(z_data,4,4)) as ingred_vrty_code, 
        substr(z_data,8,12) as ingred_vrty_abbrd_desc, 
        substr(z_data,20,30) as ingred_vrty_desc 
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC006'
    ) t16,  -- Ingredient Variety    
    ( select trim(substr(z_data,4,2)) as mkt_sgmnt_code, 
        substr(z_data,6,12) as mkt_sgmnt_abbrd_desc, 
        substr(z_data,18,30) as mkt_sgmnt_desc 
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC002'
    ) t17,  -- Market Segment 
    ( select trim(substr(z_data,4,3)) as mktg_concept_code,  
        substr(z_data,7,12) as mktg_concept_abbrd_desc,   
        substr(z_data,19,30) as mktg_concept_desc  
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC009'
    ) t18,  -- Marketing Concept  
    ( select trim(substr(z_data,4,2)) as multi_pack_qty_code, 
        substr(z_data,6,12) as multi_pack_qty_abbrd_desc, 
        substr(z_data,18,30) as multi_pack_qty_desc 
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC010'
    ) t19,  -- Multi-pack Quantity 
    ( select trim(substr(z_data,4,2)) as occsn_code, 
        substr(z_data,6,12) as occsn_abbrd_desc,  
        substr(z_data,18,30) as occsn_desc 
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC011'
    ) t20,  -- Occasion   
    ( select trim(substr(z_data,4,2)) as onpack_cnsmr_offer_code, 
        substr(z_data,6,12) as onpack_cnsmr_offer_abbrd_desc,   
        substr(z_data,18,30) as onpack_cnsmr_offer_desc  
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC023'
    ) t21,  -- On-pack Consumer Offer 
    ( select trim(substr(z_data,4,2)) as onpack_cnsmr_value_code,  
        substr(z_data,6,12) as onpack_cnsmr_value_abbrd_desc,   
        substr(z_data,18,30) as onpack_cnsmr_value_desc  
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC022'
    ) t22,  -- On-pack Consumer Value 
    ( select trim(substr(z_data,4,2)) as onpack_trade_offer_code,  
        substr(z_data,6,12) as onpack_trade_offer_abbrd_desc,   
        substr(z_data,18,30) as onpack_trade_offer_desc  
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC024'
    ) t23,  -- On-pack Trade Offer 
    ( select trim(substr(z_data,4,2)) as prdct_ctgry_code, 
        substr(z_data,6,12) as prdct_ctgry_abbrd_desc, 
        substr(z_data,18,30) as prdct_ctgry_desc 
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC012'
    ) t24,  -- Product Category 
    ( select trim(substr(z_data,4,3)) as prdct_pack_size_code,  
        substr(z_data,7,12) as prdct_pack_size_abbrd_desc,    
        substr(z_data,19,30) as prdct_pack_size_desc  
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC014'
    ) t25,  -- Product Pack Size 
    ( select trim(substr(z_data,4,2)) as prdct_size_grp_code,  
        substr(z_data,6,12) as prdct_size_grp_abbrd_desc,   
        substr(z_data,18,30) as prdct_size_grp_desc 
      from sap_ref_dat
      where z_tabname = '/MARS/MD_CHC018'
    ) t26,  -- Product Size Group 
    ( select trim(t01.atwrt) as sop_bus_code, 
        trim(t02.atwtb) as sop_bus_desc 
      from sap_chr_mas_val t01,
        sap_chr_mas_dsc t02
      where t01.atnam = t02.atnam
        and t01.valseq = t02.valseq
        and t01.atnam = 'Z_APCHAR4'
        and t02.spras_iso = 'EN'
    ) t27,  -- S and OP Business 
    ( select trim(t01.atwrt) as fighting_unit_code, 
        trim(t02.atwtb) as fighting_unit_desc 
      from sap_chr_mas_val t01,
        sap_chr_mas_dsc t02
      where t01.atnam = t02.atnam
        and t01.valseq = t02.valseq
        and t01.atnam = 'Z_APCHAR6'
        and t02.spras_iso = 'EN'
    ) t28,  -- Fighting Unit 
    ( select trim(t01.atwrt) as mkt_ctgry_code,
        trim(t02.atwtb) as mkt_ctgry_desc 
      from sap_chr_mas_val t01,
        sap_chr_mas_dsc t02
      where t01.atnam = t02.atnam
        and t01.valseq = t02.valseq
        and t01.atnam = 'Z_APCHAR1'
        and t02.spras_iso = 'EN'
    ) t29,  -- Market Category 
    ( select trim(t01.atwrt) as mkt_sub_ctgry_code, 
        trim(t02.atwtb) as mkt_sub_ctgry_desc 
      from sap_chr_mas_val t01,
        sap_chr_mas_dsc t02
      where t01.atnam = t02.atnam
        and t01.valseq = t02.valseq
        and t01.atnam = 'Z_APCHAR2'
        and t02.spras_iso = 'EN'
    ) t30,  -- Market Category 
    ( select trim(t01.atwrt) as mkt_sub_ctgry_grp_code, 
        trim(t02.atwtb) as mkt_sub_ctgry_grp_desc 
      from sap_chr_mas_val t01,
        sap_chr_mas_dsc t02
      where t01.atnam = t02.atnam
        and t01.valseq = t02.valseq
        and t01.atnam = 'Z_APCHAR3'
        and t02.spras_iso = 'EN'
    ) t31,  -- Market Sub-Category Group 
    ( select trim(t01.atwrt) as plng_srce_code, 
        trim(t02.atwtb) as plng_srce_desc 
      from sap_chr_mas_val t01,
        sap_chr_mas_dsc t02
      where t01.atnam = t02.atnam
        and t01.valseq = t02.valseq
        and t01.atnam = 'Z_APCHAR8'
        and t02.spras_iso = 'EN'
    ) t32,  -- Planning Source 
    ( select trim(t01.atwrt) as prodn_line_code, 
        trim(t02.atwtb) as prodn_line_desc
      from sap_chr_mas_val t01,
        sap_chr_mas_dsc t02
      where t01.atnam = t02.atnam
        and t01.valseq = t02.valseq
        and t01.atnam = 'Z_APCHAR5'
        and t02.spras_iso = 'EN'
    ) t33,   -- Production Line
    ( select trim(t01.atwrt) as nz_promo_grp_code, 
        trim(t02.atwtb) as nz_promo_grp_desc
      from sap_chr_mas_val t01,
        sap_chr_mas_dsc t02
      where t01.atnam = t02.atnam
        and t01.valseq = t02.valseq
        and t01.atnam = 'Z_APCHAR11'
        and t02.spras_iso = 'EN'
    ) t34,   -- NZ Promotional Group
    ( select trim(t01.atwrt) as nz_sop_bus_code, 
        trim(t02.atwtb) as nz_sop_bus_desc
      from sap_chr_mas_val t01,
        sap_chr_mas_dsc t02
      where t01.atnam = t02.atnam
        and t01.valseq = t02.valseq
        and t01.atnam = 'Z_APCHAR12'
        and t02.spras_iso = 'EN'
    ) t35,   -- NZ S and OP Business Code
    ( select trim(t01.atwrt) as nz_must_win_code, 
        trim(t02.atwtb) as nz_must_win_desc
      from sap_chr_mas_val t01,
        sap_chr_mas_dsc t02
      where t01.atnam = t02.atnam
        and t01.valseq = t02.valseq
        and t01.atnam = 'Z_APCHAR13'
        and t02.spras_iso = 'EN'
    ) t36   -- NZ Must Win Category
where t01.prdct_type_code = t02.prdct_type_code(+)
  and t01.supply_sgmnt_code = t03.supply_sgmnt_code(+)
  and t01.trad_unit_config_code = t04.trad_unit_config_code(+)
  and t01.trad_unit_frmt_code = t05.trad_unit_frmt_code(+)
  and t01.trade_sector_code = t06.trade_sector_code(+)
  and t01.brand_essnc_code = t07.brand_essnc_code(+)
  and t01.brand_flag_code = t08.brand_flag_code(+)
  and t01.brand_sub_flag_code = t09.brand_sub_flag_code(+)
  and t01.bus_sgmnt_code = t10.bus_sgmnt_code(+)
  and t01.cnsmr_pack_frmt_code = t11.cnsmr_pack_frmt_code(+)
  and t01.cnsmr_pack_type_code = t12.cnsmr_pack_type_code(+)
  and t01.cuisine_code = t13.cuisine_code(+)
  and t01.disp_strg_cndtn_code = t14.disp_strg_cndtn_code(+)
  and t01.funcl_vrty_code = t15.funcl_vrty_code(+)
  and t01.ingred_vrty_code = t16.ingred_vrty_code(+)
  and t01.mkt_sgmnt_code = t17.mkt_sgmnt_code(+)
  and t01.mktg_concept_code = t18.mktg_concept_code(+)
  and t01.multi_pack_qty_code = t19.multi_pack_qty_code(+)
  and t01.occsn_code = t20.occsn_code(+)
  and t01.onpack_cnsmr_offer_code = t21.onpack_cnsmr_offer_code(+)
  and t01.onpack_cnsmr_value_code = t22.onpack_cnsmr_value_code(+)
  and t01.onpack_trade_offer_code = t23.onpack_trade_offer_code(+)
  and t01.prdct_ctgry_code = t24.prdct_ctgry_code(+)
  and t01.prdct_pack_size_code = t25.prdct_pack_size_code(+)
  and t01.prdct_size_grp_code = t26.prdct_size_grp_code(+)
  and t01.sop_bus_code = t27.sop_bus_code(+)
  and t01.fighting_unit_code = t28.fighting_unit_code(+)
  and t01.mkt_ctgry_code = t29.mkt_ctgry_code(+)
  and t01.mkt_sub_ctgry_code = t30.mkt_sub_ctgry_code(+)
  and t01.mkt_sub_ctgry_grp_code = t31.mkt_sub_ctgry_grp_code(+)
  and t01.plng_srce_code = t32.plng_srce_code(+)   
  and t01.prodn_line_code = t33.prodn_line_code(+)
  and t01.nz_promo_grp_code = t34.nz_promo_grp_code(+)
  and t01.nz_sop_bus_code = t35.nz_sop_bus_code(+)
  and t01.nz_must_win_code = t36.nz_must_win_code(+);

/*-*/
/* Authority
/*-*/
grant select on ods.matl_classfctn_en to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym matl_classfctn_en for ods.matl_classfctn_en;