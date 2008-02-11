/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : brand_flag   
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Brand Flag View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.brand_flag as
select trim(substr(t01.z_data,4,3)) as brand_flag_code, -- SAP Brand Flag Code 
  substr(t01.z_data,7,12) as brand_flag_abbrd_desc,     -- Brand Flag Abbreviated Description 
  substr(t01.z_data,19,30) as brand_flag_desc,          -- Brand Flag Description
  t02.objek  
from sap_ref_dat t01,
  sap_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC003'
  and t02.atnam (+) = 'CLFFERT03'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 3));

/*-*/
/* Authority
/*-*/
grant select on ods.brand_flag to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym brand_flag for ods.brand_flag;