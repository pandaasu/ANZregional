/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : pet_matl_plt_labl
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Pet Material Pallet Label View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/06   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view bds_app.pet_matl_plt_labl_ics as
  select ltrim(t01.sap_material_code,'0') as matl_code,
    t01.bds_material_desc_en as matl_desc,
    null as plant,
    t01.material_type as matl_type,
    t01.regional_code_17 as rgnl_code_nmbr,
    decode(t01.base_uom,
      'KGM','KG',
      'MTR','M',
      'EA','EA') as base_uom,
    null as altrntv_uom,
    t01.net_weight as net_wght,
    t01.interntl_article_no as ean_code,
    t01.total_shelf_life as shelf_life,
    t01.mars_traded_unit_flag as trdd_unit,
    t01.mars_semi_finished_prdct_flag as semi_fnshd_prdct,
    t04.vendor_code as vndr_code,
    t04.vendor_name_01 as vndr_name,
    t02.target_qty as crtns_per_pllt
  from bds_material_plant_mfanz t01,
    bds_material_pkg_instr_det_t t02,
    bds_refrnc_prchsing_src t03,
    bds_vend_comp t04
  where t01.sap_material_code = t02.sap_material_code(+)
    and t01.sap_material_code = t03.sap_material_code
    and t03.vendor_code = t04.vendor_code
    and t02.sales_organisation(+) = '147'
    and t01.plant_specific_status = '20'
    and t01.material_type in ('ROH', 'VERP')
    and sysdate between t03.src_list_valid_from(+) and t03.src_list_valid_to(+)
    and t01.plant_code in 
    (
      'AU15', 'AU16', 'AU17', 'AU18', 'AU19', 'AU20', 'AU21', 'AU22',
      'AU23', 'AU24', 'AU25', 'AU26', 'AU27', 'AU28', 'AU29', 'AU30',
      'AU31', 'AU32', 'AU33', 'AU34', 'AU35', 'AU36', 'AU37', 'AU38',
      'AU39', 'AU59', 'AU71', 'AU72', 'AU73', 'AU74', 'AU75', 'AU76',
      'AU77', 'AU78', 'AU79', 'AU81'
    ) 
    
  union

  select ltrim(t01.sap_material_code,'0') as matl_code,
    t01.bds_material_desc_en as matl_desc,
    t01.plant_code as plant,
    t01.material_type as matl_type,
    t01.regional_code_17 as rgnl_code_nmbr,
    t01.base_uom as base_uom,
    t03.uom_code as altrntv_uom,
    t01.net_weight as net_wght,
    t01.interntl_article_no as ean_code,
    t01.total_shelf_life as shelf_life,
    t01.mars_traded_unit_flag as trdd_unit,
    t01.mars_semi_finished_prdct_flag as semi_fnshd_prdct,
    null as vndr_code,
    null as vndr_name,
    t02.target_qty as crtns_per_pllt
  from bds_material_plant_mfanz t01,
    bds_material_pkg_instr_det_t t02,
    bds_material_uom t03
  where t01.sap_material_code = t02.sap_material_code(+)
    and t01.sap_material_code = t03.sap_material_code(+)
    and t01.plant_specific_status = '20'
    and t01.material_type = 'FERT'
    and t03.uom_code = 'CS'
    and t01.plant_code in 
    (
      'AU15', 'AU16', 'AU17', 'AU18', 'AU19', 'AU20', 'AU21', 'AU22',
      'AU23', 'AU24', 'AU25', 'AU26', 'AU27', 'AU28', 'AU29', 'AU30',
      'AU31', 'AU32', 'AU33', 'AU34', 'AU35', 'AU36', 'AU37', 'AU38',
      'AU39', 'AU59', 'AU71', 'AU72', 'AU73', 'AU74', 'AU75', 'AU76',
      'AU77', 'AU78', 'AU79', 'AU81'
    );
    
/**/
/* Authority 
/**/
--grant select on bds_app.pet_matl_plt_labl_ics to bds_app with grant option;
grant select on bds_app.pet_matl_plt_labl_ics to pt_app with grant option;
grant select on bds_app.pet_matl_plt_labl_ics to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym pet_matl_plt_labl_ics for bds_app.pet_matl_plt_labl_ics;      