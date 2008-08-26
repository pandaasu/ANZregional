/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : ref_prdct_ctgry
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Reference Product Category View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/08   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view bds_app.ref_prdct_ctgry_ics as
  select t01.sap_charistic_value_code as prdct_ctgry_code,
    t01.sap_charistic_value_shrt_desc as prdct_ctgry_short_desc,
    t01.sap_charistic_value_long_desc as prdct_ctgry_long_desc
  from bds_refrnc_charistic t01
  where t01.sap_charistic_code = '/MARS/MD_CHC012';
      
/**/
/* Authority 
/**/
--grant select on bds_app.ref_prdct_ctgry_ics to bds_app with grant option;
grant select on bds_app.ref_prdct_ctgry_ics to pt_app with grant option;
grant select on bds_app.ref_prdct_ctgry_ics to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym ref_prdct_ctgry_ics for bds_app.ref_prdct_ctgry_ics;    