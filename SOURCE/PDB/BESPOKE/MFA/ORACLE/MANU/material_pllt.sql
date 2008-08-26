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
 Manufacturing - Material Pallet View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/08   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view bds_app.material_pllt_ics as
  select t01.matl_code,
    t01.units_per_case_date,
    t01.apn_code,
    t01.units_per_case,
    t01.inners_per_case_date,
    t01.inners_per_case,
    t01.pi_start_date,
    t01.pi_end_date,
    t01.pllt_gross_wght,
    t01.crtns_per_pllt,
    t01.crtns_per_layer,
    t01.uom_qty
  from
  (
    select ltrim(t01.sap_material_code,'0') as matl_code,
      decode(t01.bds_pce_factor_from_base_uom,1,to_date('19000101','yyyymmdd'),t03.bom_eff_date) as units_per_case_date,
      t01.mars_pce_interntl_article_no as apn_code,
      t01.bds_pce_factor_from_base_uom as units_per_case,
      decode(t01.bds_sb_factor_from_base_uom,null,null,t03.bom_eff_date) as inners_per_case_date,
      t01.bds_sb_factor_from_base_uom as inners_per_case,    
      t02.pkg_instr_start_date as pi_start_date,
      t02.pkg_instr_end_date as pi_end_date,
      t02.hu_total_weight as pllt_gross_wght,
      t02.target_qty as crtns_per_pllt,
      t02.rounding_qty as crtns_per_layer,
      t02.uom as uom_qty,
      rank () over (partition by t01.sap_material_code order by t02.pkg_instr_start_date, t02.hu_total_weight) as rnkseq
    from bds_material_plant_mfanz t01,
      bds_material_pkg_instr_det_t t02,
      bds_material_bom_hdr t03
    where t01.sap_material_code = t02.sap_material_code
      and t01.sap_material_code = t03.parent_material_code (+)
      and t01.plant_code = 'AU10'
      and t01.plant_specific_status = '20'
      and t01.material_type = 'FERT'
      and t01.mars_traded_unit_flag = 'X'
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
      t02.uom
  ) t01
  where t01.rnkseq = 1;
  
/**/
/* Authority 
/**/
--grant select on bds_app.material_pllt_ics to bds_app with grant option;
grant select on bds_app.material_pllt_ics to pt_app with grant option;
grant select on bds_app.material_pllt_ics to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym material_pllt_ics for bds_app.material_pllt_ics;