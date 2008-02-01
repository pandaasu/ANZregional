/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : kyoritsu_material_view
 Owner  : dw_app

 DESCRIPTION
 -----------
 Data Warehouse - Kyoritsu Material View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view dw_app.kyoritsu_material_view
   (sap_bus_sgmnt_code,
    bus_sgmnt_desc,
    sap_mkt_sgmnt_code,
    mkt_sgmnt_desc,
    sap_prdct_ctgry_code, 
    prdct_ctgry_desc,
    sap_brand_flag_code,
    brand_flag_desc,
    sap_brand_sub_flag_code,
    brand_sub_flag_desc, 
    sap_supply_sgmnt_code,
    supply_sgmnt_desc,
    sap_prdct_pack_size_code,
    prdct_pack_size_desc,
    sap_ingred_vrty_code, 
    ingred_vrty_desc,
    sap_material_code,
    material_desc_en,
    material_desc_ja) as
   select t1.sap_bus_sgmnt_code,
          t1.bus_sgmnt_desc,
          t1.sap_mkt_sgmnt_code,
          t1.mkt_sgmnt_desc,
          t1.sap_prdct_ctgry_code,
          t1.prdct_ctgry_desc,
          t1.sap_brand_flag_code,
          t1.brand_flag_desc,
          t1.sap_brand_sub_flag_code,
          t1.brand_sub_flag_desc,
          t1.sap_supply_sgmnt_code,
          t1.supply_sgmnt_desc,
          t1.sap_prdct_pack_size_code,
          t1.prdct_pack_size_desc,
          t1.sap_ingred_vrty_code,
          t1.ingred_vrty_desc,
          t1.sap_material_code,
          t1.material_desc_en,
          t1.material_desc_ja
     from material_dim t1
    where t1.material_type_flag_tdu = 'Y';

/*-*/
/* Authority
/*-*/
grant select on dw_app.kyoritsu_material_view to ml_app;
grant select on dw_app.kyoritsu_material_view to pb_app;
grant select on dw_app.kyoritsu_material_view to pp_app;

/*-*/
/* Synonym
/*-*/
create public synonym kyoritsu_material_view for dw_app.kyoritsu_material_view;