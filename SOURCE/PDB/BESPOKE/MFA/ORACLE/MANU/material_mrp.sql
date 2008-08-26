/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : material_mrp
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Material MRP View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/08   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view bds_app.material_mrp_ics as
  select ltrim(t01.sap_material_code,'0') as material,
    t01.plant_code as plant,
    t01.mrp_controller as mrp_cntrllr
  from bds_material_plant_mfanz t01
  where t01.plant_code = 'AU10';

/**/
/* Authority 
/**/
--grant select on bds_app.material_mrp_ics to bds_app with grant option;
grant select on bds_app.material_mrp_ics to pt_app with grant option;
grant select on bds_app.material_mrp_ics to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym material_mrp_ics for bds_app.material_mrp_ics;  