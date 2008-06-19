/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : cntl_rec_bom
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Control Recipe Bill Of Materials

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/06   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu.cntl_rec_bom as
  select recipe_bom_id as cntl_rec_bom_id, 
    proc_order, 
    operation as opertn, 
    phase,
    seq, 
    material_code as matl_code, 
    material_desc as matl_desc,
    material_qty as qty, 
    material_uom as uom, 
    material_prnt as prnt, 
    bf_item,
    reservation as rsrvtn, 
    plant_code as plant, 
    pan_size, 
    last_pan_size,
    pan_size_flag,
    pan_qty, 
    phantom, 
    operation_from as opertn_from
  from bds_recipe_bom
  where plant_code = 'AU30';

/**/
/* Authority 
/**/
grant select on manu.cntl_rec_bom to appsupport;
grant select on manu.cntl_rec_bom to bthsupport;
grant select on manu.cntl_rec_bom to manu_app with grant option;
grant select on manu.cntl_rec_bom to manu_maint;
grant select on manu.cntl_rec_bom to manu_user;
grant select on manu.cntl_rec_bom to pt_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym cntl_rec_bom for manu.cntl_rec_bom;







