/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : ref_bus_sgmnt
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Reference Business Segment View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/08   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu.ref_bus_sgmnt as
  select t01.sap_charistic_value_code as bus_sgmnt_code,
    t01.sap_charistic_value_shrt_desc as bus_sgmnt_short_desc,
    t01.sap_charistic_value_long_desc as bus_sgmnt_long_desc
  from bds_refrnc_charistic t01
  where t01.sap_charistic_code = '/MARS/MD_CHC001';
    
/**/
/* Authority 
/**/
grant select on manu.ref_bus_sgmnt to bds_app with grant option;
grant select on manu.ref_bus_sgmnt to pt_app with grant option;
grant select on manu.ref_bus_sgmnt to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym ref_bus_sgmnt for manu.ref_bus_sgmnt;    