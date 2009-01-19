/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : material_mrp 
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Material MRP View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/06   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu.material_mrp_ics as
  select ltrim(sap_material_code,'0') as material,
    plant_code as plant,
    mrp_controller as mrp_cntrllr
  from bds_material_plant_mfanz t01
  where plant_code = 'NZ01';
    
/**/
/* Authority 
/**/
grant select on manu.material_mrp_ics to bds_app with grant option;
grant select on manu.material_mrp_ics to pt_app with grant option;
grant select on manu.material_mrp_ics to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym material_mrp_ics for manu.material_mrp_ics;    