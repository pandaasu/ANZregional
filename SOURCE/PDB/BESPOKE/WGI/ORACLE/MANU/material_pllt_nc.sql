/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : material_pllt_nc 
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Materials Pallet NC View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/06   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu.material_pllt_nc_ics as
  select ltrim(t01.sap_material_code,'0') as matl_code,
    t03.bom_eff_date as units_per_case_date,
    t01.mars_pce_interntl_article_no as apn_code,
    t01.bds_pce_factor_from_base_uom as units_per_case,
    t03.bom_eff_date as inners_per_case_date,
    t01.bds_sb_factor_from_base_uom as inners_per_case,
    t02.pkg_instr_start_date as pi_start_date,
    t02.pkg_instr_end_date as pi_end_date,
    t02.hu_total_weight as pllt_gross_wght,
    t02.target_qty as crtns_per_pllt,
    t02.rounding_qty as crtns_per_layer,
    t02.uom as uom_qty,
    ltrim(t01.mars_pce_item_code,'0') as rsu_code
  from bds_material_plant_mfanz t01,
    bds_material_pkg_instr_det t02,
    bds_material_bom_hdr t03
  where t01.sap_material_code = t02.sap_material_code (+)
    and t01.sap_material_code = t03.parent_material_code (+)
    and t01.material_type = 'FERT'
    and t01.plant_code = 'NZ01'
    and t01.plant_specific_status <> '20'
    and (t01.mars_traded_unit_flag = 'X' or t01.mars_intrmdt_prdct_compnt_flag = 'X')  
    and (t02.sales_organisation is null or t02.sales_organisation = '149')
  group by t01.sap_material_code,
    t03.bom_eff_date,
    t01.mars_pce_interntl_article_no,
    t01.bds_pce_factor_from_base_uom,
    t03.bom_eff_date,
    t01.bds_sb_factor_from_base_uom,
    t02.pkg_instr_start_date,
    t02.pkg_instr_end_date,
    t02.hu_total_weight,
    t02.target_qty,
    t02.rounding_qty,
    t02.uom,
    t01.mars_pce_item_code,
    t02.sales_organisation
  order by matl_code;

/**/
/* Authority 
/**/
grant select on manu.material_pllt_nc_ics to bds_app with grant option;
grant select on manu.material_pllt_nc_ics to pt_app with grant option;
grant select on manu.material_pllt_nc_ics to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym material_pllt_nc_ics for manu.material_pllt_nc_ics;