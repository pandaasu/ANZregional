/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : shiftlog 
 View   : cntl_rec_bom  
 Owner   : shiftlog 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Shiftlog - Control Recipe BOM

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/08   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view shiftlog.cntl_rec_bom as
  select recipe_bom_id as cntl_rec_bom_id, 
    proc_order as proc_order, 
    operation as operation, 
    phase as phase, 
    seq as seq,
    material_code as material_code, 
    material_desc as material_desc, 
    material_qty as material_qty, 
    material_uom as material_uom,
    material_prnt as material_prnt, 
    bf_item as bf_item, 
    reservation as reservation, 
    plant as plant_code, 
    pan_size as pan_size,
    last_pan_size as last_pan_size, 
    pan_size_flag as pan_size_flag, 
    pan_qty as pan_qty, 
    phantom as phantom,
    operation_from as opertn_from
  from bds_recipe_bom
  where plant like 'CN%';
  
/**/
/* Authority 
/**/
grant select on shiftlog.cntl_rec_bom to public;

/**/
/* Synonym 
/**/
create or replace public synonym cntl_rec_bom for shiftlog.cntl_rec_bom;     