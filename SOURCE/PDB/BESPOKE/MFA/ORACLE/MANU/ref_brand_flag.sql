/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : ref_brand_flag
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Reference Brand Flag View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/08   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu.ref_brand_flag as
  select t01.sap_charistic_value_code as brand_flag_code,
    t01.sap_charistic_value_shrt_desc as brand_flag_short_desc,
    t01.sap_charistic_value_long_desc as brand_flag_long_desc
  from bds_refrnc_charistic t01
  where t01.sap_charistic_code = '/MARS/MD_CHC003';
    
/**/
/* Authority 
/**/
grant select on manu.ref_brand_flag to bds_app with grant option;
grant select on manu.ref_brand_flag to pt_app with grant option;
grant select on manu.ref_brand_flag to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym ref_brand_flag for manu.ref_brand_flag;    