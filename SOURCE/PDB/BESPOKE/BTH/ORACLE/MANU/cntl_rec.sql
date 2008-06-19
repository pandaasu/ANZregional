/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : cntl_rec
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Control Recipe

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/06   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu.cntl_rec as
  select max (proc_order) as proc_order, 
    cntl_rec_id,
    max (plant_code) as plant, 
    max (cntl_rec_status) as cntl_rec_stat,
    max (test_flag) as test_flag, 
    max (recipe_text) as recpe_text,
    max (material) as matl_code, 
    max (material_text) as matl_text,
    max (quantity) as qty, 
    max (insplot) as insplot, 
    max (uom) as uom,
    max (batch) as batch,
    max (sched_start_datime) as sched_start_datime,
    max (run_start_datime) as run_start_datime,
    max (run_end_datime) as run_end_datime, 
    max (version) as vrsn,
    max (upd_datime) as upd_datime,
    max (cntl_rec_xfer) as cntl_rec_xfer,
    max (teco_status) as teco_stat, 
    max (storage_locn) as strge_locn,
    max (idoc_timestamp) as idoc_timestamp
  from bds_recipe_header
  where plant_code = 'AU30'
  group by cntl_rec_id;

/**/
/* Authority 
/**/
grant select on manu.cntl_rec to appsupport with grant option;
grant select on manu.cntl_rec to manu_app with grant option;
grant select on manu.cntl_rec to manu_maint;
grant select on manu.cntl_rec to manu_user;
grant select on manu.cntl_rec to pt_app;

/**/
/* Synonym 
/**/
create or replace public synonym cntl_rec for manu.cntl_rec;