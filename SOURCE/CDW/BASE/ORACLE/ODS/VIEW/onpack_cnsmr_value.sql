/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : onpack_cnsmr_value   
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - On-pack Consumer Value View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.onpack_cnsmr_value as
select trim(substr(t01.z_data,4,2)) as onpack_cnsmr_value_code, -- SAP On-pack Consumer Value Code  
  substr(t01.z_data,6,12) as onpack_cnsmr_value_abbrd_desc,     -- On-pack Consumer Value Abbreviated Description   
  substr(t01.z_data,18,30) as onpack_cnsmr_value_desc,          -- On-pack Consumer Value Description  
  t02.objek 
from sap_ref_dat t01,
  sap_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC022'
  and t02.atnam (+) = 'CLFFERT22'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 2));

/*-*/
/* Authority
/*-*/
grant select on ods.onpack_cnsmr_value to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym onpack_cnsmr_value for ods.onpack_cnsmr_value;