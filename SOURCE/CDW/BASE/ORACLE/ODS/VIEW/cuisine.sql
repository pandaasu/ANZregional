/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : cuisine  
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Cuisine View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.cuisine as
select trim(substr(t01.z_data,4,2)) as cuisine_code,  -- SAP Cuisine Code  
  substr(t01.z_data,6,12) as cuisine_abbrd_desc,      -- Cuisine Abbreviated Description   
  substr(t01.z_data,18,30) as cuisine_desc,           -- Cuisine Description  
  t02.objek 
from sap_ref_dat t01,
  sap_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC040'
  and t02.atnam (+) = 'CLFFERT40'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 2));

/*-*/
/* Authority
/*-*/
grant select on ods.cuisine to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym cuisine for ods.cuisine;