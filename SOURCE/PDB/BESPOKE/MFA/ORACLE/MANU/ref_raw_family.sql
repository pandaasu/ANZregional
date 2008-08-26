/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : ref_raw_family
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Reference Raw Family View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/08   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view bds_app.ref_raw_family_ics as
  select t01.sap_charistic_value_code as raw_fmly_code,
    t01.sap_charistic_value_long_desc as raw_fmly_long_desc
  from bds_refrnc_charistic t01
  where t01.sap_charistic_code = '/MARS/MD_ROH01';
  
/**/
/* Authority 
/**/
--grant select on bds_app.ref_raw_family_ics to bds_app with grant option;
grant select on bds_app.ref_raw_family_ics to pt_app with grant option;
grant select on bds_app.ref_raw_family_ics to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym ref_raw_family_ics for bds_app.ref_raw_family_ics;