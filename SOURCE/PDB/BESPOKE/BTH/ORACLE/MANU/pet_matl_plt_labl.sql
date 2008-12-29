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
create or replace force view manu.pet_matl_plt_labl as
  select ltrim(t01.sap_material_code,'0') as matl_code,
    t01.bds_material_desc_en as matl_desc,
    null as plant,
    t01.material_type as matl_type,
    decode(t01.regional_code_17,'*NONE',null,ltrim(t01.regional_code_17,'0')) as rgnl_code_nmbr,
    decode(t01.base_uom,
      'KGM','KG',
      'MTR','M',
      'EA','EA',
      t01.base_uom) as base_uom,
    null as altrntv_uom,
    t01.net_weight as net_wght,
    decode(length(t01.interntl_article_no), 13, 1 || t01.interntl_article_no, t01.interntl_article_no) as ean_code,
    t01.total_shelf_life as shelf_life,
    t01.mars_traded_unit_flag as trdd_unit,
    t01.mars_semi_finished_prdct_flag as semi_fnshd_prdct,
    t03.vndr_code as vndr_code,
    t03.vndr_name as vndr_name,
    t02.crtns_per_pllt as crtns_per_pllt
  from bds_material_plant_mfanz t01,
    (
      select t12.sap_material_code as matl_code,
        t12.target_qty as crtns_per_pllt,
        t12.rounding_qty as crtns_per_layer,
        t12.uom as uom_qty,
        t12.hu_total_weight as total_wght_hndlng_unit,
        t12.pkg_instr_start_date as start_date,
        t12.pkg_instr_end_date as end_date
      from bds_material_pkg_instr_det t12
      where t12.sap_material_code = t12.component
        and t12.pkg_instr_start_date =
        (
          select max(t98.pkg_instr_start_date)
          from bds_material_pkg_instr_det t98
          where t12.sap_material_code = t98.sap_material_code
            and t98.pkg_instr_start_date <= sysdate
            and t98.pkg_instr_table = '505'
            and t98.sales_organisation = '147'            
        )
        and exists
        (
          select 1
          from bds_material_plant_mfanz t97
          where t12.sap_material_code = t97.sap_material_code
            and t97.plant_specific_status = '20'
            and (t97.material_type = 'ROH' and t97.mars_semi_finished_prdct_flag = 'X')
        )         
    ) t02,
    (
      select distinct t13.sap_material_code as matl_code,
        t14.vendor_code as vndr_code,
        t14.vendor_name_01 as vndr_name,
        t14.company_code as sales_org,
        t13.plant_code as plant,
        t13.src_list_valid_from as eff_start_date,
        t13.src_list_valid_to as eff_end_date
      from bds_refrnc_purchasing_src t13,
        bds_vend_comp t14        
      where t13.vendor_code = t14.vendor_code
        and t14.deletion_flag is null
    ) t03
  where t01.sap_material_code = t02.matl_code(+)
    and t01.sap_material_code = t03.matl_code(+)
    and t01.plant_specific_status = '20'
    and t01.material_type in ('ROH', 'VERP')
    and t03.sales_org(+) = '147'
    and sysdate between t03.eff_start_date(+) and t03.eff_end_date(+)    
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
    ltrim(t01.regional_code_17,'0') as rgnl_code_nmbr,
    t01.base_uom as base_uom,
    t03.uom_code as altrntv_uom,
    t01.net_weight as net_wght,
    decode(length(t01.interntl_article_no), 13, 1 || t01.interntl_article_no, t01.interntl_article_no) as ean_code,
    t01.total_shelf_life as shelf_life,
    t01.mars_traded_unit_flag as trdd_unit,
    t01.mars_semi_finished_prdct_flag as semi_fnshd_prdct,
    null as vndr_code,
    null as vndr_name,
    t02.crtns_per_pllt as crtns_per_pllt
  from bds_material_plant_mfanz t01,
    (
      select t12.sap_material_code as matl_code,
        t12.target_qty as crtns_per_pllt,
        t12.rounding_qty as crtns_per_layer,
        t12.uom as uom_qty,
        t12.hu_total_weight as total_wght_hndlng_unit,
        t12.pkg_instr_start_date as start_date,
        t12.pkg_instr_end_date as end_date
      from bds_material_pkg_instr_det t12
      where t12.sap_material_code = t12.component
        and t12.pkg_instr_start_date =
        (
          select max(t98.pkg_instr_start_date)
          from bds_material_pkg_instr_det t98
          where t12.sap_material_code = t98.sap_material_code
            and t98.pkg_instr_start_date <= sysdate
            and t98.pkg_instr_table = '505'
            and t98.sales_organisation = '147'            
        )
        and exists
        (
          select 1
          from bds_material_plant_mfanz t97
          where t12.sap_material_code = t97.sap_material_code
            and t97.plant_specific_status = '20'
            and (t97.material_type = 'FERT' and t97.mars_traded_unit_flag = 'X')
        )         
    ) t02,
    bds_material_uom t03
  where t01.sap_material_code = t02.matl_code(+)
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
grant select on manu.pet_matl_plt_labl to bds_app with grant option;
grant select on manu.pet_matl_plt_labl to pt_app with grant option;
grant select on manu.pet_matl_plt_labl to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym pet_matl_plt_labl for manu.pet_matl_plt_labl;      