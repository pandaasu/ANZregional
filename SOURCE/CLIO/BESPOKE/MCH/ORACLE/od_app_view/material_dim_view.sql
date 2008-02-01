/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : material_dim_view
 Owner  : od_app

 DESCRIPTION
 -----------
 Operational Data Store - Material Dimension View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created
 2006/04   Steve Gregan   Removed Japanese descriptions
                          Added report representative item and desc
 2006/05   Steve Gregan   Add BDT code and description

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od_app.material_dim_view
   (sap_material_code,
    material_desc_en,
    material_sts_code,
    material_sts_abbrd_desc,
    material_sts_desc,
    gross_wgt,
    net_wgt,
    sap_wgt_unit_code,
    wgt_unit_abbrd_desc,
    wgt_unit_desc,
    vol,
    sap_vol_unit_code,
    vol_unit_abbrd_desc,
    vol_unit_desc,
    sap_base_uom_code,
    base_uom_abbrd_desc,
    base_uom_desc,
    material_owner,
    sap_rep_item_code,
    rep_item_desc_en,
    sap_rpt_item_code,
    rpt_item_desc_en,
    mat_lead_time_days,
    old_material_code,
    material_type_flag_int,
    material_type_flag_rsu,
    material_type_flag_tdu,
    material_type_flag_mcu,
    material_type_flag_pro,
    material_type_flag_sfp,
    material_type_flag_sc,
    material_type_flag_rep,
    ean_upc,
    sap_ean_upc_ctgry_code,
    ean_upc_ctgry_desc,
    sap_material_division_code,
    material_division_desc,
    sap_material_type_code,
    material_type_desc,
    sap_material_grp_code,
    material_grp_desc,
    sap_material_grp_packs_code,
    material_grp_packs_desc,
    sap_cross_plant_matl_sts_code,
    cross_plant_matl_sts_desc,
    sap_bus_sgmnt_code,
    bus_sgmnt_abbrd_desc,
    bus_sgmnt_desc,
    sap_mkt_sgmnt_code,
    mkt_sgmnt_abbrd_desc,
    mkt_sgmnt_desc,
    sap_brand_essnc_code,
    brand_essnc_abbrd_desc,
    brand_essnc_desc,
    sap_brand_flag_code,
    brand_flag_abbrd_desc,
    brand_flag_desc,
    sap_brand_sub_flag_code,
    brand_sub_flag_abbrd_desc,
    brand_sub_flag_desc,
    sap_supply_sgmnt_code,
    supply_sgmnt_abbrd_desc,
    supply_sgmnt_desc,
    sap_ingred_vrty_code,
    ingred_vrty_abbrd_desc,
    ingred_vrty_desc,
    sap_funcl_vrty_code,
    funcl_vrty_abbrd_desc,
    funcl_vrty_desc,
    sap_major_pack_code,
    major_pack_abbrd_desc,
    major_pack_desc,
    sap_minor_pack_code,
    minor_pack_abbrd_desc,
    minor_pack_desc,
    sap_multi_pack_qty_code,
    multi_pack_qty_abbrd_desc,
    multi_pack_qty_desc,
    sap_occsn_code,
    occsn_abbrd_desc,
    occsn_desc,
    sap_prdct_ctgry_code,
    prdct_ctgry_abbrd_desc,
    prdct_ctgry_desc,
    sap_prdct_type_code,
    prdct_type_abbrd_desc,
    prdct_type_desc,
    sap_prdct_pack_size_code,
    prdct_pack_size_abbrd_desc,
    prdct_pack_size_desc,
    sap_cnsmr_pack_frmt_code,
    cnsmr_pack_frmt_abbrd_desc,
    cnsmr_pack_frmt_desc,
    sap_pack_type_code,
    pack_type_abbrd_desc,
    pack_type_desc,
    sap_prdct_size_grp_code,
    prdct_size_grp_abbrd_desc,
    prdct_size_grp_desc,
    sap_prim_cnsmptn_grp_code,
    prim_cnsmptn_grp_abbrd_desc,
    prim_cnsmptn_grp_desc,
    sap_trad_unit_frmt_code,
    trad_unit_frmt_abbrd_desc,
    trad_unit_frmt_desc,
    sap_trad_unit_config_code,
    trad_unit_config_abbrd_desc,
    trad_unit_config_desc,
    sap_onpack_cnsmr_value_code,
    onpack_cnsmr_value_abbrd_desc,
    onpack_cnsmr_value_desc,
    sap_onpack_cnsmr_offer_code,
    onpack_cnsmr_offer_abbrd_desc,
    onpack_cnsmr_offer_desc,
    sap_onpack_trade_offer_code,
    onpack_trade_offer_abbrd_desc,
    onpack_trade_offer_desc,
    sap_bdt_code,
    bdt_abbrd_desc,
    bdt_desc) as
   select t01.sap_material_code as sap_material_code,
          t02.material_desc as material_desc_en,
          t01.material_sts_code,
          t01.material_sts_code,
          t01.material_sts_code,
          t01.gross_wgt,
          t01.net_wgt,
          t07.sap_uom_code as sap_wgt_unit_code,
          t07.uom_abbrd_desc as wgt_unit_abbrd_desc,
          t07.uom_desc as wgt_unit_desc,
          t01.vol,
          t08.sap_uom_code as sap_vol_unit_code,
          t08.uom_abbrd_desc as vol_unit_abbrd_desc,
          t08.uom_desc as vol_unit_desc,
          t09.sap_uom_code as sap_base_uom_code,
          t09.uom_abbrd_desc as base_uom_abbrd_desc,
          t09.uom_desc as base_uom_desc,
          t01.material_owner,
          t01.sap_rep_item_code as sap_rep_item_code,
          t04.material_desc as rep_item_desc_en,
          decode(t01.sap_material_type_code,'ZREP',t01.sap_material_code,t01.sap_rep_item_code) as sap_rpt_item_code,
          decode(t01.sap_material_type_code,'ZREP',t02.material_desc,t04.material_desc) as rpt_item_desc_en,
          t01.mat_lead_time_days,
          t01.old_material_code,
          t01.material_type_flag_int,
          t01.material_type_flag_rsu,
          t01.material_type_flag_tdu,
          t01.material_type_flag_mcu,
          t01.material_type_flag_pro,
          t01.material_type_flag_sfp,
          t01.material_type_flag_sc,
          t01.material_type_flag_rep,
          t01.ean_upc,
          t10.sap_ean_upc_ctgry_code,
          t10.ean_upc_ctgry_desc,
          t11.sap_material_division_code,
          t11.material_division_desc,
          t12.sap_material_type_code,
          t12.material_type_desc,
          t13.sap_material_grp_code,
          t13.material_grp_desc,
          t14.sap_material_grp_packs_code,
          t14.material_grp_packs_desc,
          t15.sap_cross_plant_matl_sts_code,
          t15.cross_plant_matl_sts_desc,
          t16.sap_bus_sgmnt_code,
          t16.bus_sgmnt_abbrd_desc,
          t16.bus_sgmnt_desc,
          t17.sap_mkt_sgmnt_code,
          t17.mkt_sgmnt_abbrd_desc,
          t17.mkt_sgmnt_desc,
          t18.sap_brand_essnc_code,
          t18.brand_essnc_abbrd_desc,
          t18.brand_essnc_desc,
          t19.sap_brand_flag_code,
          t19.brand_flag_abbrd_desc,
          t19.brand_flag_desc,
          t20.sap_brand_sub_flag_code,
          t20.brand_sub_flag_abbrd_desc,
          t20.brand_sub_flag_desc,
          t21.sap_supply_sgmnt_code,
          t21.supply_sgmnt_abbrd_desc,
          t21.supply_sgmnt_desc,
          t22.sap_ingred_vrty_code,
          t22.ingred_vrty_abbrd_desc,
          t22.ingred_vrty_desc,
          t23.sap_funcl_vrty_code,
          t23.funcl_vrty_abbrd_desc,
          t23.funcl_vrty_desc,
          t24.sap_major_pack_code,
          t24.major_pack_abbrd_desc,
          t24.major_pack_desc,
          t25.sap_minor_pack_code,
          t25.minor_pack_abbrd_desc,
          t25.minor_pack_desc,
          t26.sap_multi_pack_qty_code,
          t26.multi_pack_qty_abbrd_desc,
          t26.multi_pack_qty_desc,
          t27.sap_occsn_code,
          t27.occsn_abbrd_desc,
          t27.occsn_desc,
          t28.sap_prdct_ctgry_code,
          t28.prdct_ctgry_abbrd_desc,
          t28.prdct_ctgry_desc,
          t29.sap_prdct_type_code,
          t29.prdct_type_abbrd_desc,
          t29.prdct_type_desc,
          t30.sap_prdct_pack_size_code,
          t30.prdct_pack_size_abbrd_desc,
          t30.prdct_pack_size_desc,
          t31.sap_cnsmr_pack_frmt_code,
          t31.cnsmr_pack_frmt_abbrd_desc,
          t31.cnsmr_pack_frmt_desc,
          t32.sap_pack_type_code,
          t32.pack_type_abbrd_desc,
          t32.pack_type_desc,
          t33.sap_prdct_size_grp_code,
          t33.prdct_size_grp_abbrd_desc,
          t33.prdct_size_grp_desc,
          t34.sap_prim_cnsmptn_grp_code,
          t34.prim_cnsmptn_grp_abbrd_desc,
          t34.prim_cnsmptn_grp_desc,
          t35.sap_trad_unit_frmt_code,
          t35.trad_unit_frmt_abbrd_desc,
          t35.trad_unit_frmt_desc,
          t36.sap_trad_unit_config_code,
          t36.trad_unit_config_abbrd_desc,
          t36.trad_unit_config_desc,
          t37.sap_onpack_cnsmr_value_code as sap_onpack_cnsmr_value_code,
          t37.onpack_cnsmr_value_abbrd_desc as onpack_cnsmr_value_abbrd_desc,
          t37.onpack_cnsmr_value_desc as onpack_cnsmr_value_desc,
          t38.sap_onpack_cnsmr_offer_code as sap_onpack_cnsmr_offer_code,
          t38.onpack_cnsmr_offer_abbrd_desc as onpack_cnsmr_offer_abbrd_desc,
          t38.onpack_cnsmr_offer_desc as onpack_cnsmr_offer_desc,
          t39.sap_onpack_trade_offer_code as sap_onpack_trade_offer_code,
          t39.onpack_trade_offer_abbrd_desc as onpack_trade_offer_abbrd_desc,
          t39.onpack_trade_offer_desc as onpack_trade_offer_desc,
          t40.sap_bdt_code as sap_bdt_code,
          t40.bdt_abbrd_desc as bdt_abbrd_desc,
          t40.bdt_desc as bdt_desc
     from material t01,
          (select t21.sap_material_code,
                  t21.material_desc
             from material_desc t21
            where t21.sap_lang_code = 'EN') t02,
          (select t41.sap_material_code,
                  t41.material_desc
             from material_desc t41
            where t41.sap_lang_code = 'EN') t04,
          uom t07,
          uom t08,
          uom t09,
          ean_upc_ctgry t10,
          material_division t11,
          material_type t12,
          material_grp t13,
          material_grp_packs t14,
          cross_plant_material_status t15,
          bus_sgmnt t16,
          mkt_sgmnt t17,
          brand_essnc t18,
          brand_flag t19,
          brand_sub_flag t20,
          supply_sgmnt t21,
          ingred_vrty t22,
          funcl_vrty t23,
          major_pack t24,
          minor_pack t25,
          multi_pack_qty t26,
          occasion t27,
          prdct_ctgry t28,
          prdct_type t29,
          prdct_pack_size t30,
          cnsmr_pack_frmt t31,
          pack_type t32,
          prdct_size_grp t33,
          prim_cnsmptn_grp t34,
          trad_unit_frmt t35,
          trad_unit_config t36,
          onpack_cnsmr_value t37,
          onpack_cnsmr_offer t38,
          onpack_trade_offer t39,
          bdt t40
    where t01.sap_material_code = t02.sap_material_code(+)
      and t01.sap_wgt_unit_code = t07.sap_uom_code(+)
      and t01.sap_vol_unit_code = t08.sap_uom_code(+)
      and t01.sap_base_uom_code = t09.sap_uom_code(+)
      and t01.sap_ean_upc_ctgry_code = t10.sap_ean_upc_ctgry_code(+)
      and t01.sap_material_division_code = t11.sap_material_division_code(+)
      and t01.sap_material_type_code = t12.sap_material_type_code(+)
      and t01.sap_material_grp_code = t13.sap_material_grp_code(+)
      and t01.sap_material_grp_packs_code = t14.sap_material_grp_packs_code(+)
      and t01.sap_cross_plant_matl_sts_code = t15.sap_cross_plant_matl_sts_code(+)
      and t01.sap_bus_sgmnt_code = t16.sap_bus_sgmnt_code(+)
      and t01.sap_mkt_sgmnt_code = t17.sap_mkt_sgmnt_code(+)
      and t01.sap_brand_essnc_code = t18.sap_brand_essnc_code(+)
      and t01.sap_brand_flag_code = t19.sap_brand_flag_code(+)
      and t01.sap_brand_sub_flag_code = t20.sap_brand_sub_flag_code(+)
      and t01.sap_supply_sgmnt_code = t21.sap_supply_sgmnt_code(+)
      and t01.sap_ingred_vrty_code = t22.sap_ingred_vrty_code(+)
      and t01.sap_funcl_vrty_code = t23.sap_funcl_vrty_code(+)
      and t01.sap_major_pack_code = t24.sap_major_pack_code(+)
      and t01.sap_minor_pack_code = t25.sap_minor_pack_code(+)
      and t01.sap_multi_pack_qty = t26.sap_multi_pack_qty_code(+)
      and t01.sap_occsn_code = t27.sap_occsn_code(+)
      and t01.sap_prdct_ctgry_code = t28.sap_prdct_ctgry_code(+)
      and t01.sap_prdct_type_code = t29.sap_prdct_type_code(+)
      and t01.sap_prdct_pack_size_code = t30.sap_prdct_pack_size_code(+)
      and t01.sap_cnsmr_pack_frmt_code = t31.sap_cnsmr_pack_frmt_code(+)
      and t01.sap_pack_type_code = t32.sap_pack_type_code(+)
      and t01.sap_prdct_size_grp_code = t33.sap_prdct_size_grp_code(+)
      and t01.sap_prim_cnsmptn_grp_code = t34.sap_prim_cnsmptn_grp_code(+)
      and t01.sap_trad_unit_frmt_code = t35.sap_trad_unit_frmt_code(+)
      and t01.sap_trad_unit_config_code = t36.sap_trad_unit_config_code(+)
      and t01.sap_onpack_cnsmr_value_code = t37.sap_onpack_cnsmr_value_code(+)
      and t01.sap_onpack_cnsmr_offer_code = t38.sap_onpack_cnsmr_offer_code(+)
      and t01.sap_onpack_trade_offer_code = t39.sap_onpack_trade_offer_code(+)
      and t01.sap_bdt_code = t40.sap_bdt_code(+)
      and t01.sap_rep_item_code = t04.sap_material_code(+);

/*-*/
/* Authority
/*-*/
grant select on od_app.material_dim_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym material_dim_view for od_app.material_dim_view;

