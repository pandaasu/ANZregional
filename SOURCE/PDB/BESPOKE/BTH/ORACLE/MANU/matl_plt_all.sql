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
create or replace force view manu.matl_plt_all as
  select ltrim(t01.sap_material_code,'0') as matl_code,
    t01.bds_material_desc_en as matl_desc,
    t02.crtns_per_pllt as crtns_per_pllt,
    t02.crtns_per_layer as crtns_per_layer,
    t02.uom_qty as uom_qty,
    t01.material_type as matl_type,
    t01.mars_traded_unit_flag as trdd_unit,
    t01.mars_semi_finished_prdct_flag as semi_fnshd_prdct,
    t01.total_shelf_life as shelf_life
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
    ) t02
  where t01.sap_material_code = t02.matl_code (+)
    and t01.plant_specific_status = '20'
    and t01.plant_code in ('AU15', 'AU16', 'AU17', 'AU18', 'AU19', 'AU20', 'AU21', 'AU22',
        'AU23', 'AU24', 'AU25', 'AU30', 'AU31', 'AU35', 'AU36', 'AU37',
        'AU38', 'AU39', 'AU43', 'AU59', 'AU74', 'AU75', 'AU76', 'AU77',
        'AU78', 'AU79', 'AU81')
    and 
    (
      (t01.material_type = 'FERT' and t01.mars_traded_unit_flag = 'X')
      or (t01.material_type = 'ROH' and t01.mars_semi_finished_prdct_flag = 'X')
    )
  group by t01.sap_material_code,
    t01.bds_material_desc_en,
    t02.crtns_per_pllt,
    t02.crtns_per_layer,
    t02.uom_qty,
    t01.material_type,
    t01.mars_traded_unit_flag,
    t01.mars_semi_finished_prdct_flag,
    t01.total_shelf_life;
  
/**/
/* Authority 
/**/
grant select on manu.matl_plt_all to bds_app with grant option;
grant select on manu.matl_plt_all to pt_app with grant option;
grant select on manu.matl_plt_all to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym matl_plt_all for manu.matl_plt_all;      