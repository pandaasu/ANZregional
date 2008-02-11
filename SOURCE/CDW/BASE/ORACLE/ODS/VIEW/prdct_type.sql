/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : prdct_type 
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Product Type View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.prdct_type as
select trim(substr(t01.z_data,4,3)) as prdct_type_code, -- SAP Product Type Code 
  substr(t01.z_data,7,12) as prdct_type_abbrd_desc,     -- Product Type Abbreviated Description 
  substr(t01.z_data,19,30) as prdct_type_desc,          -- Product Type Description 
  t02.objek 
from sap_ref_dat t01,
  sap_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC013'
  and t02.atnam (+) = 'CLFFERT13'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 3));

/*-*/
/* Authority
/*-*/
grant select on ods.prdct_type to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym prdct_type for ods.prdct_type;