/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : matl_clssfctn_fg 
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Material Classification View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/06   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu.matl_clssfctn_fg_ics as
  select ltrim(t01.sap_material_code,'0') as matl_code,
    t01.sap_bus_sgmnt_code as bus_sgmnt_code,
    t01.sap_mrkt_sgmnt_code as mkt_sgmnt_code,
    t01.sap_brand_flag_code as brand_flag_code,
    t01.sap_brand_sub_flag_code as brand_sub_flag_code,
    t01.sap_supply_sgmnt_code as spply_sgmnt_code,
    t01.sap_ingrdnt_vrty_code as ingrdnt_vrty_code,
    t01.sap_funcl_vrty_code as fnctnl_vrty_code,
    t01.sap_trade_sector_code as trade_sctr_code,
    t01.sap_mrkting_concpt_code as mrktng_cncpt_code,
    t01.sap_multi_pack_qty_code as mltpck_qty_code,
    t01.sap_occsn_code as occsn_code,
    t01.sap_prdct_ctgry_code as prdct_ctgry_code,
    t01.sap_prdct_type_code as prdct_type_code,
    t01.sap_size_code as size_code,
    t01.sap_brand_essnc_code as brand_essnc_code,
    t01.sap_pack_type_code as pack_type_code,
    t01.sap_size_grp_code as size_group_code,
    t01.sap_dsply_storg_condtn_code as dsply_strg_cndtn_code,
    t01.sap_trad_unit_frmt_code as tdu_frmt_code,
    t01.sap_trad_unit_config_code as tdu_cnfgrtn_code,
    t01.sap_onpack_cnsmr_value_code as on_pack_cnsmr_value_code,
    t01.sap_onpack_cnsmr_offer_code as on_pack_cnsmr_offer_code,
    t01.sap_onpack_trade_offer_code as on_pack_trade_offer_code,
    t01.sap_cnsmr_pack_frmt_code as cnsmr_pack_frmt_code
  from bds_material_classfctn_ics t01,
    bds_material_plant_mfanz_test t02
  where t01.sap_material_code = t02.sap_material_code 
    and t02.material_type in ('FERT', 'ZREP', 'ZHIE')
  group by t01.sap_material_code,
    t01.sap_bus_sgmnt_code,
    t01.sap_mrkt_sgmnt_code,
    t01.sap_brand_flag_code,
    t01.sap_brand_sub_flag_code,
    t01.sap_supply_sgmnt_code,
    t01.sap_ingrdnt_vrty_code,
    t01.sap_funcl_vrty_code,
    t01.sap_trade_sector_code,
    t01.sap_mrkting_concpt_code,
    t01.sap_multi_pack_qty_code,
    t01.sap_occsn_code,
    t01.sap_prdct_ctgry_code,
    t01.sap_prdct_type_code,
    t01.sap_size_code,
    t01.sap_brand_essnc_code,
    t01.sap_pack_type_code,
    t01.sap_size_grp_code,
    t01.sap_dsply_storg_condtn_code,
    t01.sap_trad_unit_frmt_code,
    t01.sap_trad_unit_config_code,
    t01.sap_onpack_cnsmr_value_code,
    t01.sap_onpack_cnsmr_offer_code,
    t01.sap_onpack_trade_offer_code,
    t01.sap_cnsmr_pack_frmt_code;
  
/**/
/* Authority 
/**/
grant select on manu.matl_clssfctn_fg_ics to bds_app with grant option;
grant select on manu.matl_clssfctn_fg_ics to pt_app with grant option;
grant select on manu.matl_clssfctn_fg_ics to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym matl_clssfctn_fg_ics for manu.matl_clssfctn_fg_ics;   