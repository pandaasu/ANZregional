/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : bom  
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Bill of Materials View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/06   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view bds_app.bom_ics as
  select t01.bom_plant as plant,
    ltrim(t01.bom_number,'0') as bom_code,
    t01.bom_alternative as alt,
    t01.bom_material_code as matl_code,
    t01.bom_base_qty as batch_qty,
    t01.bom_base_uom as batch_uom,
    decode(t01.bom_eff_from_date, null, t01.item_eff_from_date, t01.bom_eff_from_date) as eff_start_date,
    t01.bom_eff_to_date as eff_end_date,
    ltrim(t01.item_number,'0') as seq,
    t01.item_sequence as detseq,
    t01.item_material_code as sub_matl_code,
    t01.item_base_qty as qty,
    t01.item_base_uom as uom
  from bds_bom_all_ics t01
  where t01.bom_plant IN ('AU20', 'AU21', 'AU22', 'AU23', 'AU24', 'AU25')
    and t01.item_number is not null;

/**/
/* Authority 
/**/
--grant select on bds_app.bom_ics to bds_app with grant option;
grant select on bds_app.bom_ics to pt_app with grant option;
grant select on bds_app.bom_ics to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym bom_ics for bds_app.bom_ics;    