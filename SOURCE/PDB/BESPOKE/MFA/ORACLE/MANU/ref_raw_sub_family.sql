/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : ref_raw_sub_family
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Reference Raw Sub Family View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/08   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu.ref_raw_sub_family as
  select t01.sap_charistic_value_code as raw_sub_fmly_code,
    t01.sap_charistic_value_long_desc as raw_sub_fmly_long_desc
  from bds_refrnc_charistic t01
  where t01.sap_charistic_code = '/MARS/MD_ROH03';

/**/
/* Authority 
/**/
grant select on manu.ref_raw_sub_family to bds_app with grant option;
grant select on manu.ref_raw_sub_family to pt_app with grant option;
grant select on manu.ref_raw_sub_family to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym ref_raw_sub_family for manu.ref_raw_sub_family;