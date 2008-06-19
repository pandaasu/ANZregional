/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : matl_plt
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Material Pallet View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/06   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu.matl_plt_ics as
  select ltrim(t01.sap_material_code,'0') as matl_code,
    t01.plant_code as plant,
    t01.plant_specific_status_valid as plant_sts_start,
    t03.bom_eff_date as units_per_case_date,
    t01.mars_pce_interntl_article_no as apn,
    t01.bds_pce_factor_from_base_uom as units_per_case,
    t03.bom_eff_date as inners_per_case_date,
    t01.bds_sb_factor_from_base_uom as inners_per_case,    
    t02.pkg_instr_start_date as pi_start_date,
    t02.pkg_instr_end_date as pi_end_date,
    t02.hu_total_weight as pllt_gross_wght,
    t02.target_qty as crtns_per_pllt,
    t02.rounding_qty as crtns_per_layer,
    t02.uom as uom_qty
  from bds_material_plant_mfanz_test t01,
    bds_material_pkg_instr_det_t t02,
    bds_material_bom_hdr t03
  where t01.sap_material_code = t02.sap_material_code (+)
    and t01.sap_material_code = t03.parent_material_code (+)
    and t01.plant_code in ('AU20', 'AU21', 'AU22', 'AU23', 'AU24', 'AU25')
  group by t01.sap_material_code,
    t01.plant_code,
    t01.plant_specific_status_valid,
    t03.bom_eff_date,
    t01.mars_pce_interntl_article_no,
    t01.bds_pce_factor_from_base_uom,    
    t01.bds_sb_factor_from_base_uom,  
    t02.pkg_instr_start_date,
    t02.pkg_instr_end_date,
    t02.hu_total_weight,
    t02.target_qty,
    t02.rounding_qty,
    t02.uom;

/**/
/* Authority 
/**/
grant select on manu.matl_plt_ics to bds_app with grant option;
grant select on manu.matl_plt_ics to pt_app with grant option;
grant select on manu.matl_plt_ics to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym matl_plt_ics for manu.matl_plt_ics;     