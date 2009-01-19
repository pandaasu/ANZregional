/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : material_pllt 
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
create or replace force view manu.material_pllt_ics as
  select ltrim(t01.sap_material_code,'0') as matl_code,
    t03.valid_from_date as units_per_case_date,
    t03.rsu_ean as apn_code,
    decode(t03.rsus_per_tdu, '', t05.piece_qty, t03.rsus_per_tdu) as units_per_case,
    t04.valid_from_date as inners_per_case_date,
    t04.mcus_per_tdu as inners_per_case,
    t02.pkg_instr_start_date as pi_start_date,
    t02.pkg_instr_end_date as pi_end_date,
    t02.hu_total_weight as pllt_gross_wght,
    t02.target_qty as crtns_per_pllt,
    t02.rounding_qty as crtns_per_layer,
    t02.uom as uom_qty,
    t03.rsu_matl_code as rsu_code
  from bds_material_plant_mfanz t01,
    bds_material_pkg_instr_det t02,
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
        where t99.parent_tdu_flag = 'X'
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
    ) t04,
    (
      select t01.sap_material_code,
        t02.bds_factor_from_base_uom as piece_qty
      from bds_material_plant_mfanz t01,
        bds_material_uom t02
      where t01.sap_material_code = t02.sap_material_code
        and t02.uom_code = 'PCE'
        and t01.plant_code = 'NZ01'
        and
        (
          length(t01.sap_material_code) > 8
          or substr(trim(t01.sap_material_code), 1, 1) <> '1'
        )
    ) t05  
  where t01.sap_material_code = t02.sap_material_code (+)
    and t01.sap_material_code = t03.tdu_matl_code (+)
    and t01.sap_material_code = t04.tdu_matl_code (+)
    and t01.sap_material_code = t05.sap_material_code (+)
    and t01.material_type = 'FERT'
    and t01.plant_code = 'NZ01'
    and t01.plant_specific_status = '20'
    and t01.plant_specific_status_valid < sysdate
    and (t01.mars_traded_unit_flag = 'X' or t01.mars_intrmdt_prdct_compnt_flag = 'X')  
    and (t02.sales_organisation is null or t02.sales_organisation = '149');

/**/
/* Authority 
/**/
grant select on manu.material_pllt_ics to bds_app with grant option;
grant select on manu.material_pllt_ics to pt_app with grant option;
grant select on manu.material_pllt_ics to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym material_pllt_ics for manu.material_pllt_ics;   