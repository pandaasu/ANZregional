/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : cntl_rec_mpi_val 
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Control Recipe MPI Value

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/06   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu.cntl_rec_mpi_val as
  select recipe_src_value_id as cntl_rec_mpi_val_id, 
    proc_order,
    operation as opertn, 
    phase, 
    seq, 
    src_tag as mpi_tag,
    src_desc as mpi_desc, 
    src_val as mpi_val, 
    src_uom as mpi_uom,
    machine_code as mc_code, 
    detail_desc as dtl_desc, 
    plant_code as plant
  from bds_recipe_src_value
  where plant_code = 'AU30';
   
/**/
/* Authority 
/**/
grant select on manu.cntl_rec_mpi_val to appsupport;
grant select on manu.cntl_rec_mpi_val to bthsupport;
grant select on manu.cntl_rec_mpi_val to manu_app with grant option;
grant select on manu.cntl_rec_mpi_val to manu_maint;
grant select on manu.cntl_rec_mpi_val to manu_user;

/**/
/* Synonym 
/**/   
create or replace public synonym cntl_rec_mpi_val for manu.cntl_rec_mpi_val;