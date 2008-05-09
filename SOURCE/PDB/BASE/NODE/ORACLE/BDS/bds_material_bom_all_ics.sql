/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 View   : bds_material_bom_all_ics  
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_material_bom_all_ics 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view bds.bds_material_bom_all_ics as
  select t01.sap_bom,
    t01.bom_alternative,
    t01.bom_plant,
    t01.bom_usage,
    t01.bom_status,
    t01.bom_eff_date,
    t01.parent_material_code,
    t01.parent_base_qty,
    t01.parent_base_uom,
    t01.parent_material_type,
    t01.parent_ian,
    t01.parent_plan_flag,
    t01.parent_intr_flag,
    t01.parent_mcu_flag,
    t01.parent_prom_flag,
    t01.parent_rsu_flag,
    t01.parent_ship_cont,
    t01.parent_semi_finished,
    t01.parent_tdu_flag,
    t01.parent_rep_flag,
    t01.child_material_code,
    t01.child_base_qty,
    t01.child_base_uom,
    t01.child_per_parent,
    t01.child_material_type,
    t01.child_ian,
    t01.child_plan_flag,
    t01.child_intr_flag,
    t01.child_mcu_flag,
    t01.child_prom_flag,
    t01.child_rsu_flag,
    t01.child_ship_cont,
    t01.child_semi_finished,
    t01.child_tdu_flag,
    t01.child_rep_flag
  from
  (
    select t01.sap_bom as sap_bom, 
      t01.sap_bom_alternative as bom_alternative, 
      t01.bom_plant as bom_plant, 
      t01.bom_usage as bom_usage,
      t01.bom_status as bom_status, 
      t01.bom_eff_date as bom_eff_date, 
      t01.parent_material_code as parent_material_code,
      t01.parent_base_qty as parent_base_qty, 
      t01.parent_base_uom as parent_base_uom, 
      t03.material_type as parent_material_type,
      t03.interntl_article_no as parent_ian, 
      t03.mars_plan_item_flag as parent_plan_flag,
      t03.mars_intrmdt_prdct_compnt_flag as parent_intr_flag, 
      t03.mars_merchandising_unit_flag as parent_mcu_flag,
      t03.mars_prmotional_material_flag as parent_prom_flag, 
      t03.mars_retail_sales_unit_flag as parent_rsu_flag,
      t03.mars_shpping_contnr_flag as parent_ship_cont, 
      t03.mars_semi_finished_prdct_flag as parent_semi_finished,
      t03.mars_traded_unit_flag as parent_tdu_flag, 
      t03.mars_rprsnttv_item_flag as parent_rep_flag,
      t02.child_material_code as child_material_code, 
      t02.child_base_qty as child_base_qty,
      t02.child_base_uom as child_base_uom,
      decode (t01.parent_base_qty, 0, 0,
        ( 
          (t02.child_base_qty / t01.parent_base_qty) * nvl (t05.bds_factor_to_base_uom, 1)
        )
      ) as child_per_parent,
      t04.material_type as child_material_type,
      t04.interntl_article_no as child_ian,
      t04.mars_plan_item_flag as child_plan_flag,
      t04.mars_intrmdt_prdct_compnt_flag as child_intr_flag,
      t04.mars_merchandising_unit_flag as child_mcu_flag,
      t04.mars_prmotional_material_flag as child_prom_flag,
      t04.mars_retail_sales_unit_flag as child_rsu_flag,
      t04.mars_shpping_contnr_flag as child_ship_cont,
      t04.mars_semi_finished_prdct_flag as child_semi_finished,
      t04.mars_traded_unit_flag as child_tdu_flag,
      t04.mars_rprsnttv_item_flag as child_rep_flag
    from bds_material_bom_hdr t01,
      bds_material_bom_det t02,
      bds_material_plant_mfanz_test t03,
      bds_material_plant_mfanz_test t04,
      bds_material_uom t05
    where t01.sap_bom = t02.sap_bom
      and t01.sap_bom_alternative = t02.sap_bom_alternative
      and t01.parent_material_code = t03.sap_material_code
      and t02.child_material_code = t04.sap_material_code
      and t02.child_material_code = t05.sap_material_code
      and t02.child_base_uom = t05.uom_code
    union all
    select '*NONE' as sap_bom, 
      '01' as bom_alternative,
      '*NONE' as bom_plant,
      '5' as bom_usage, 
      1 as bom_status,
      to_date ('19000101', 'yyyymmdd') as bom_eff_date,
      t01.sap_material_code as parent_material_code, 
      1 as parent_base_qty,
      'EA' as parent_base_uom, 
      t01.material_type as parent_material_type,
      t01.interntl_article_no as parent_ian,
      t01.mars_plan_item_flag as parent_plan_flag, 
      t01.mars_intrmdt_prdct_compnt_flag as parent_intr_flag,
      t01.mars_merchandising_unit_flag as parent_mcu_flag, 
      t01.mars_prmotional_material_flag as parent_prom_flag,
      t01.mars_retail_sales_unit_flag as parent_rsu_flag, 
      t01.mars_shpping_contnr_flag as parent_ship_cont,
      t01.mars_semi_finished_prdct_flag as parent_semi_finished, 
      t01.mars_traded_unit_flag as parent_tdu_flag,
      t01.mars_rprsnttv_item_flag as parent_rep_flag,
      t01.sap_material_code as child_material_code, 
      1 as child_base_qty,
      'EA' as child_base_uom,
      1 as child_per_parent,
      t01.material_type as child_material_type,
      t01.interntl_article_no as child_ian,
      t01.mars_plan_item_flag as child_plan_flag,
      t01.mars_intrmdt_prdct_compnt_flag as child_intr_flag,
      t01.mars_merchandising_unit_flag as child_mcu_flag,
      t01.mars_prmotional_material_flag as child_prom_flag,
      t01.mars_retail_sales_unit_flag as child_rsu_flag,
      t01.mars_shpping_contnr_flag as child_ship_cont,
      t01.mars_semi_finished_prdct_flag as child_semi_finished,
      t01.mars_traded_unit_flag as child_tdu_flag,
      t01.mars_rprsnttv_item_flag as child_rep_flag
    from bds_material_plant_mfanz_test t01,
      (
        select parent_material_code
        from bds_material_bom_hdr
        where bom_plant = '*NONE'
          and bom_status in (1, 7)
          and bom_usage = '5'
          and sap_bom_alternative = '01'
      ) t02
    where t01.material_type = 'FERT'
      and 
      (   
        t01.mars_traded_unit_flag = 'X'
        or t01.mars_intrmdt_prdct_compnt_flag = 'X'
      )
      and t01.mars_retail_sales_unit_flag = 'X'
      and t01.sap_material_code = t02.parent_material_code(+)
      and t02.parent_material_code(+) is null
  ) t01
  where bom_plant = '*NONE'                                                   
    and bom_status in (1, 7)
    and exists 
    (
      select 1
      from bds_material_plant_mfanz_test t02
      where t01.parent_material_code = t02.sap_material_code
        and 
        (
          t02.plant_code like 'AU%'
          or t02.plant_code like 'NZ%'
        )
    )
  group by t01.sap_bom,
    t01.bom_alternative,
    t01.bom_plant,
    t01.bom_usage,
    t01.bom_status,
    t01.bom_eff_date,
    t01.parent_material_code,
    t01.parent_base_qty,
    t01.parent_base_uom,
    t01.parent_material_type,
    t01.parent_ian,
    t01.parent_plan_flag,
    t01.parent_intr_flag,
    t01.parent_mcu_flag,
    t01.parent_prom_flag,
    t01.parent_rsu_flag,
    t01.parent_ship_cont,
    t01.parent_semi_finished,
    t01.parent_tdu_flag,
    t01.parent_rep_flag,
    t01.child_material_code,
    t01.child_base_qty,
    t01.child_base_uom,
    t01.child_per_parent,
    t01.child_material_type,
    t01.child_ian,
    t01.child_plan_flag,
    t01.child_intr_flag,
    t01.child_mcu_flag,
    t01.child_prom_flag,
    t01.child_rsu_flag,
    t01.child_ship_cont,
    t01.child_semi_finished,
    t01.child_tdu_flag,
    t01.child_rep_flag; 

/**/
/* Authority 
/**/
grant select on bds.bds_material_bom_all_ics to bds_app with grant option;
grant select on bds.bds_material_bom_all_ics to manu_app with grant option;
grant select on bds.bds_material_bom_all_ics to pt_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym bds_material_bom_all_ics for bds.bds_material_bom_all_ics;

