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
create or replace force view bds_app.matl_plt_ics as
  select ltrim(t01.sap_material_code,'0') as matl_code,
    t01.plant_code as plant,
    t01.plant_specific_status_valid as plant_sts_start,
    t03.valid_from_date as units_per_case_date,
    t03.rsu_ean as apn,
    t03.rsus_per_tdu as units_per_case,
    t04.valid_from_date as inners_per_case_date,
    t04.mcus_per_tdu as inners_per_case,
    t02.start_date as pi_start_date,
    t02.end_date as pi_end_date,
    t02.total_wght_hndlng_unit as pllt_gross_wght,
    t02.crtns_per_pllt as crtns_per_pllt,
    t02.crtns_per_layer as crtns_per_layer,
    t02.uom_qty as uom_qty
  from bds_material_plant_mfanz t01,
    (
      select t12.sap_material_code as matl_code,
        t12.target_qty as crtns_per_pllt,
        t12.rounding_qty as crtns_per_layer,
        t12.uom as uom_qty,
        t12.hu_total_weight as total_wght_hndlng_unit,
        t12.pkg_instr_start_date as start_date,
        t12.pkg_instr_end_date as end_date
      from bds_material_pkg_instr_det_t t12
      where t12.sap_material_code = t12.component
        and t12.pkg_instr_start_date =
        (
          select max(t98.pkg_instr_start_date)
          from bds_material_pkg_instr_det_t t98
          where t12.sap_material_code = t98.sap_material_code
            and t98.pkg_instr_start_date <= sysdate
            and t98.pkg_instr_table = '505'
            and t98.sales_organisation = '147'            
        )    
    ) t02,
    (
      select t11.tdu_matl_code, 
        t11.rsus_per_tdu, 
        t11.rsu_ean,
        max(t11.valid_from_date) as valid_from_date
      from
      (
        select t99.parent_material_code as tdu_matl_code,
          t99.child_per_parent as rsus_per_tdu,
          t99.child_ian as rsu_ean,
          decode(t99.bom_eff_date, null, to_date('19000101', 'yyyymmdd'), t99.bom_eff_date) as valid_from_date,
          t99.bom_plant as plant
        from bds_material_bom_all t99
        where t99.parent_tdu_flag = 'X'
          and t99.parent_material_type = 'FERT'
          and t99.bom_plant = '*NONE'
          and t99.bom_alternative = 1
          and t99.bom_status = 1
          and t99.bom_usage = 5
          and t99.child_material_type = 'FERT'
          and t99.child_rsu_flag = 'X'
      ) t11
      where t11.valid_from_date < sysdate        
      group by t11.tdu_matl_code, 
        t11.rsus_per_tdu, 
        t11.rsu_ean
    ) t03,
    (
      select t12.tdu_matl_code, 
        t12.mcus_per_tdu, 
        max(t12.valid_from_date) as valid_from_date
      from
      (
        select t98.parent_material_code as tdu_matl_code,
          t98.child_per_parent as mcus_per_tdu,
          t98.bom_eff_date as valid_from_date
        from bds_material_bom_all t98
        where t98.parent_tdu_flag = 'X'
          and t98.parent_material_type = 'FERT'
          and t98.bom_plant = '*NONE'
          and t98.bom_alternative = 1
          and t98.bom_status in (1, 7)
          and t98.bom_usage = 1
          and t98.child_material_type = 'FERT'
          and t98.child_mcu_flag = 'X'
      ) t12
      where t12.valid_from_date < sysdate
      group by t12.tdu_matl_code, 
        t12.mcus_per_tdu
    ) t04
  where t01.sap_material_code = t02.matl_code (+)
    and t01.sap_material_code = t03.tdu_matl_code
    and t01.sap_material_code = t04.tdu_matl_code (+)
    and t01.material_type = 'FERT'
    and t01.plant_code in ('AU30')
    and t01.plant_specific_status_valid < sysdate
    and t01.mars_traded_unit_flag = 'X';

/**/
/* Authority 
/**/
--grant select on bds_app.matl_plt_ics to bds_app with grant option;
grant select on bds_app.matl_plt_ics to pt_app with grant option;
grant select on bds_app.matl_plt_ics to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym matl_plt_ics for bds_app.matl_plt_ics;     