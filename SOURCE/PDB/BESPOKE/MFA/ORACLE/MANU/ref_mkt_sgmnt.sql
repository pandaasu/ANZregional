/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : ref_mkt_sgmnt
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Reference Market Segment View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/08   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu.ref_mkt_sgmnt as
  select t01.sap_charistic_value_code as mkt_sgmnt_code,
    t01.sap_charistic_value_shrt_desc as mkt_sgmnt_short_desc,
    t01.sap_charistic_value_long_desc as mkt_sgmnt_long_desc
  from bds_refrnc_charistic t01
  where t01.sap_charistic_code = '/MARS/MD_CHC002';
      
/**/
/* Authority 
/**/
grant select on manu.ref_mkt_sgmnt to bds_app with grant option;
grant select on manu.ref_mkt_sgmnt to pt_app with grant option;
grant select on manu.ref_mkt_sgmnt to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym ref_mkt_sgmnt for manu.ref_mkt_sgmnt;    