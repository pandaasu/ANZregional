/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : matl_clssfctn_raw 
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Material Classification Raw View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/06   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view bds_app.matl_clssfctn_raw_ics as
  select ltrim(t01.sap_material_code,'0') as matl_code,
    t01.sap_raw_family_code as raw_fmly_code,
    t01.sap_raw_sub_family_code as raw_sub_fmly_code,
    t01.sap_raw_group_code as raw_group_code,
    t01.sap_animal_parts_code as anml_parts_code,
    t01.sap_physical_condtn_code as phuyscl_cndtn_code
  from bds_material_classfctn_ics t01,
    bds_material_plant_mfanz_test t02
  where t01.sap_material_code = t02.sap_material_code
    and t02.material_type = 'ROH'
  group by t01.sap_material_code,
    t01.sap_raw_family_code,
    t01.sap_raw_sub_family_code,
    t01.sap_raw_group_code,
    t01.sap_animal_parts_code,
    t01.sap_physical_condtn_code;
  
/**/
/* Authority 
/**/
--grant select on bds_app.matl_clssfctn_raw_ics to bds_app with grant option;
grant select on bds_app.matl_clssfctn_raw_ics to pt_app with grant option;
grant select on bds_app.matl_clssfctn_raw_ics to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym matl_clssfctn_raw_ics for bds_app.matl_clssfctn_raw_ics;       