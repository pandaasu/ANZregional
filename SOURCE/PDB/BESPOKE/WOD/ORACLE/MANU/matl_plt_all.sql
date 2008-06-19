/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : matl_plt_all
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Material Pallet All View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/06   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu.matl_plt_all_ics as
  select ltrim(t01.sap_material_code,'0') as matl_code,
    t01.bds_material_desc_en as matl_desc,
    t02.target_qty as crtns_per_pllt,
    t02.rounding_qty as crtns_per_layer,
    t02.uom as uom_qty,
    t01.material_type as matl_type,
    t01.mars_traded_unit_flag as trdd_unit,
    t01.mars_semi_finished_prdct_flag as semi_fnshd_prdct,
    t01.total_shelf_life as shelf_life
  from bds_material_plant_mfanz t01,
    bds_material_pkg_instr_det_t t02
  where t01.sap_material_code = t02.sap_material_code
    and t01.plant_code in ('AU20', 'AU21', 'AU22', 'AU23', 'AU24', 'AU25', 'AU30')
    and t02.sales_organisation = '147'
  group by t01.sap_material_code,
    t01.bds_material_desc_en,
    t02.target_qty,
    t02.rounding_qty,
    t02.uom,
    t01.material_type,
    t01.mars_traded_unit_flag,
    t01.mars_semi_finished_prdct_flag,
    t01.total_shelf_life;
  
/**/
/* Authority 
/**/
grant select on manu.matl_plt_all_ics to bds_app with grant option;
grant select on manu.matl_plt_all_ics to pt_app with grant option;
grant select on manu.matl_plt_all_ics to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym matl_plt_all_ics for manu.matl_plt_all_ics;      