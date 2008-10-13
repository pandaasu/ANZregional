/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 View   : bds_bom_all  
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_bom_all 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view bds.bds_bom_all as
  select t01.bom_material_code, 
    t01.bom_alternative, 
    t01.bom_plant,
    t01.bom_number, 
    t01.bom_msg_function, 
    t01.bom_usage,
    case
      when count = 1 and t02.bom_eff_from_date is not null
        then t02.bom_eff_from_date
      when count = 1 and t02.bom_eff_from_date is null
        then t01.bom_eff_from_date
      when count > 1 and t02.bom_eff_from_date is null
        then null
      when count > 1 and t02.bom_eff_from_date is not null
        then t02.bom_eff_from_date
    end as bom_eff_from_date,
    t01.bom_eff_to_date, 
    t01.bom_base_qty, 
    t01.bom_base_uom,
    t01.bom_status, 
    t01.item_sequence, 
    t01.item_number,
    t01.item_msg_function, 
    t01.item_material_code, 
    t01.item_category,
    t01.item_base_qty, 
    t01.item_base_uom, 
    t01.item_eff_from_date,
    t01.item_eff_to_date
  from bds_bom_det t01,
    bds_refrnc_hdr_altrnt t02,
    (
      select bom_material_code, 
      bom_plant, 
      count (*) as count
      from 
      (
        select distinct bom_material_code, 
          bom_plant,
          bom_alternative
        from bds_bom_det
      )
      group by bom_material_code, bom_plant
    ) t03
  where t01.bom_material_code = ltrim (t02.bom_material_code(+), ' 0')
    and t01.bom_alternative = ltrim (t02.bom_alternative(+), ' 0')
    and t01.bom_plant = t02.bom_plant(+)
    and t01.bom_usage = t02.bom_usage(+)
    and t01.bom_material_code = t03.bom_material_code
    and t01.bom_plant = t03.bom_plant
    and t01.bom_plant in ('AU40','AU42','AU45','AU82','AU83','AU84','AU85','AU86','AU87','AU88','AU89', 'AU90');
    
/**/
/* Authority 
/**/
grant select on bds.bds_bom_all to bds_app with grant option;
grant select on bds.bds_bom_all to pt_app with grant option;
grant select on bds.bds_bom_all to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym bds_bom_all for bds.bds_bom_all;    