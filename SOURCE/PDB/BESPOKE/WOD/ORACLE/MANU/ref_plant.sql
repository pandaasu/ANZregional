/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : ref_plant
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Reference Plant View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/06   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu.ref_plant_ics as
  select t01.plant_code as plant,
    t01.plant_name as plant_name
  from bds_refrnc_plant_ics t01;
    
/**/
/* Authority 
/**/
grant select on manu.ref_plant_ics to bds_app with grant option;
grant select on manu.ref_plant_ics to pt_app with grant option;
grant select on manu.ref_plant_ics to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym ref_plant_ics for manu.ref_plant_ics;    