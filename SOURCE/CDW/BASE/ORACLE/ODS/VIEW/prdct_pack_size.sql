/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : prdct_pack_size   
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Product Pack Size View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.prdct_pack_size as
select trim(substr(t01.z_data,4,3)) as prdct_pack_size_code,  -- SAP Product Pack Size Code  
  substr(t01.z_data,7,12) as prdct_pack_size_abbrd_desc,      -- Product Pack Size Abbreviated Description    
  substr(t01.z_data,19,30) as prdct_pack_size_desc,           -- Product Pack Size Description  
  t02.objek 
from sap_ref_dat t01,
  sap_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC014'
  and t02.atnam (+) = 'CLFFERT14'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 3));

/*-*/
/* Authority
/*-*/
grant select on ods.prdct_pack_size to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym prdct_pack_size for ods.prdct_pack_size;