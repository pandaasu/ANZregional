/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : matl_int_plt 
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Materials Pallet View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/06   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu.matl_int_plt as
  select ltrim(t01.sap_material_code,'0') as matl_code,
    t01.plant_code as plant,
    t01.plant_specific_status_valid as plant_sts_start,
    t02.valid_from_date as units_per_case_date,
    t02.rsu_ean as apn,
    t02.rsus_per_tdu as units_per_case,
    t03.start_date as pi_start_date,
    t03.end_date as pi_end_date,
    t03.total_wght_hndlng_unit as pllt_gross_wght,
    t03.crtns_per_pllt as crtns_per_pllt,
    t03.crtns_per_layer as crtns_per_layer,
    t03.uom_qty as uom_qty
  from bds_material_plant_mfanz t01,
    (
      select t11.tdu_matl_code, 
        t11.rsus_per_tdu, 
        t11.rsu_ean,
        max(t11.valid_from_date) as valid_from_date, 
        t11.rsu_matl_code
      from
      (
        select t99.parent_material_code as tdu_matl_code,
          t99.child_per_parent as rsus_per_tdu,
          t99.child_ian as rsu_ean,
          t99.child_material_code as rsu_matl_code,
          decode(t99.bom_eff_date, null, to_date('19000101', 'yyyymmdd'), t99.bom_eff_date) as valid_from_date
        from bds_material_bom_all t99
        where t99.parent_intr_flag = 'X'
          and t99.parent_material_type = 'FERT'
          and t99.bom_plant = '*NONE'
          and t99.bom_alternative = 1
          and t99.bom_status in (1, 7)
          and t99.bom_usage = 5
          and t99.child_material_type = 'FERT'
          and t99.child_rsu_flag = 'X'
      ) t11
      where t11.valid_from_date < sysdate
      group by t11.tdu_matl_code, 
        t11.rsus_per_tdu, 
        t11.rsu_ean, 
        t11.rsu_matl_code 
    ) t02,
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
    ) t03
  where t01.sap_material_code = t02.tdu_matl_code
    and t01.sap_material_code = t03.matl_code (+)
    and t01.plant_code in ('AU20', 'AU21', 'AU22', 'AU23', 'AU24', 'AU25')
    and t01.mars_intrmdt_prdct_compnt_flag = 'X'
    and t01.material_type = 'FERT';
  
/**/
/* Authority 
/**/
grant select on manu.matl_int_plt to bds_app with grant option;
grant select on manu.matl_int_plt to pt_app with grant option;
grant select on manu.matl_int_plt to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym matl_int_plt for manu.matl_int_plt;     