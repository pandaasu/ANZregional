/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : prdct_ctgry_grd  
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Product Category View (GRD) 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.prdct_ctgry_grd as
select trim(substr(t01.z_data,4,2)) as prdct_ctgry_code,  -- SAP Product Category Code 
  substr(t01.z_data,6,12) as prdct_ctgry_abbrd_desc,      -- Product Category Abbreviated Description 
  substr(t01.z_data,18,30) as prdct_ctgry_desc,           -- Product Category Description 
  t02.objek 
from sap_ref_dat t01,
  grd_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC012'
  and t02.atnam (+) = 'CLFFERT12'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 2));

/*-*/
/* Authority
/*-*/
grant select on ods.prdct_ctgry_grd to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym prdct_ctgry_grd for ods.prdct_ctgry_grd;