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
 Manufacturing - Material Classification View (Finished Goods)

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/08   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view bds_app.matl_clssfctn_fg_ics as
  select material_code,
    bus_sgmnt_code,
    mkt_sgmnt_code,
    brand_flag_code,
    brand_sub_flag_code,
    spply_sgmnt_code,
    ingrdnt_vrty_code,
    fnctnl_vrty_code,
    trade_sctr_code,
    mrktng_cncpt_code,
    mltpck_qty_code,
    occsn_code,
    prdct_ctgry_code,
    prdct_type_code,
    size_code,
    brand_essnc_code,
    pack_type_code,
    size_group_code,
    dsply_strg_cndtn_code,
    tdu_frmt_code,
    tdu_cnfgrtn_code,
    on_pack_cnsmr_value_code,
    on_pack_cnsmr_offer_code,
    on_pack_trade_offer_code,
    cnsmr_pack_frmt_code
  from
  (
    select ltrim(t01.sap_material_code,'0') as material_code,
      t02.sap_bus_sgmnt_code as bus_sgmnt_code,
      t02.sap_mrkt_sgmnt_code	as mkt_sgmnt_code,
      t02.sap_brand_flag_code as brand_flag_code,
      t02.sap_brand_sub_flag_code as brand_sub_flag_code,
      t02.sap_supply_sgmnt_code as spply_sgmnt_code,
      t02.sap_ingrdnt_vrty_code as ingrdnt_vrty_code,
      t02.sap_funcl_vrty_code as fnctnl_vrty_code,
      t02.sap_trade_sector_code as trade_sctr_code,
      t02.sap_mrkting_concpt_code as mrktng_cncpt_code,
      t02.sap_multi_pack_qty_code as mltpck_qty_code,
      t02.sap_occsn_code as occsn_code,
      t02.sap_prdct_ctgry_code as prdct_ctgry_code,
      t02.sap_prdct_type_code as prdct_type_code,
      t02.sap_size_code as size_code,
      t02.sap_brand_essnc_code as brand_essnc_code,
      t02.sap_pack_type_code as pack_type_code,
      t02.sap_size_grp_code as size_group_code,
      t02.sap_dsply_storg_condtn_code as dsply_strg_cndtn_code,
      t02.sap_trad_unit_frmt_code as tdu_frmt_code,
      t02.sap_trad_unit_config_code as tdu_cnfgrtn_code,
      t02.sap_onpack_cnsmr_value_code as on_pack_cnsmr_value_code,
      t02.sap_onpack_cnsmr_offer_code as on_pack_cnsmr_offer_code,
      t02.sap_onpack_trade_offer_code as on_pack_trade_offer_code,
      t02.sap_cnsmr_pack_frmt_code as cnsmr_pack_frmt_code
    from bds_material_plant_mfanz t01,
      bds_material_classfctn t02    
    where t01.sap_material_code = t02.sap_material_code
      and t01.material_type in ('FERT', 'ZREP', 'ZHIE')
    group by t01.sap_material_code,
      t02.sap_bus_sgmnt_code,
      t02.sap_mrkt_sgmnt_code,
      t02.sap_brand_flag_code,
      t02.sap_brand_sub_flag_code,
      t02.sap_supply_sgmnt_code,
      t02.sap_ingrdnt_vrty_code,
      t02.sap_funcl_vrty_code,
      t02.sap_trade_sector_code,
      t02.sap_mrkting_concpt_code,
      t02.sap_multi_pack_qty_code,
      t02.sap_occsn_code,
      t02.sap_prdct_ctgry_code,
      t02.sap_prdct_type_code,
      t02.sap_size_code,
      t02.sap_brand_essnc_code,
      t02.sap_pack_type_code,
      t02.sap_size_grp_code,
      t02.sap_dsply_storg_condtn_code,
      t02.sap_trad_unit_frmt_code,
      t02.sap_trad_unit_config_code,
      t02.sap_onpack_cnsmr_value_code,
      t02.sap_onpack_cnsmr_offer_code,
      t02.sap_onpack_trade_offer_code,
      t02.sap_cnsmr_pack_frmt_code
  );

/**/
/* Authority 
/**/
--grant select on bds_app.matl_clssfctn_fg_ics to bds_app with grant option;
grant select on bds_app.matl_clssfctn_fg_ics to pt_app with grant option;
grant select on bds_app.matl_clssfctn_fg_ics to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym matl_clssfctn_fg_ics for bds_app.matl_clssfctn_fg_ics;