/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : cntl_rec_mpi_txt
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Control Recipe MPI Text

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/06   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu.cntl_rec_mpi_txt as
  select recipe_src_text_id as cntl_rec_mpi_txt_id, 
    proc_order, 
    operation as opertn,
    phase, 
    seq, 
    src_text as mpi_text, 
    src_type as mpi_type,
    machine_code as mc_code, 
    detail_desc as dtl_desc, 
    plant_code as plant
  from bds_recipe_src_text
  where plant_code = 'AU30';

/**/
/* Authority 
/**/
grant select on manu.cntl_rec_mpi_txt to appsupport;
grant select on manu.cntl_rec_mpi_txt to bthsupport;
grant select on manu.cntl_rec_mpi_txt to manu_app with grant option;
grant select on manu.cntl_rec_mpi_txt to manu_maint;
grant select on manu.cntl_rec_mpi_txt to manu_user;

/**/
/* Synonym 
/**/
create or replace public synonym cntl_rec_mpi_txt for manu.cntl_rec_mpi_txt;


































