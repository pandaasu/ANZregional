/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : cntl_rec_resrce 
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Control Recipe Resources

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/06   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu.cntl_rec_resrce as
  select recipe_resource_id as cntl_rec_resrce_id, 
    proc_order, 
    operation as opertn,
    resource_code as resrce_code, 
    batch_qty, 
    batch_uom, 
    phantom,
    phantom_desc, 
    phantom_qty, 
    phantom_uom, 
    plant_code as plant
  from bds_recipe_resource
  where plant_code = 'AU30';

/**/
/* Authority 
/**/
grant select on manu.cntl_rec_resrce to appsupport;
grant select on manu.cntl_rec_resrce to bthsupport;
grant select on manu.cntl_rec_resrce to manu_app with grant option;
grant select on manu.cntl_rec_resrce to manu_maint;
grant select on manu.cntl_rec_resrce to manu_user;

/**/
/* Synonym 
/**/
create or replace public synonym cntl_rec_resrce for manu.cntl_rec_resrce;