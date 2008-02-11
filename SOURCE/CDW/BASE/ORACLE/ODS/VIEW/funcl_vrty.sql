/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : funcl_vrty 
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Functional Variety View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.funcl_vrty as
select trim(substr(t01.z_data,4,3)) as funcl_vrty_code,   -- SAP Functional Variety Code 
  substr(t01.z_data,7,12) as funcl_vrty_abbrd_desc,       -- Functional Variety Abbreviated Description 
  substr(t01.z_data,19,30) as funcl_vrty_desc,            -- Functional Variety Description 
  t02.objek 
from sap_ref_dat t01,
  sap_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC007'
  and t02.atnam (+) = 'CLFFERT07'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 3));

/*-*/
/* Authority
/*-*/
grant select on ods.funcl_vrty to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym funcl_vrty for ods.funcl_vrty;