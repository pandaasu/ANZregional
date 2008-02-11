/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : brand_essnc_grd   
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Brand Essence View (GRD) 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.brand_essnc_grd as
select trim(substr(t01.z_data,4,3)) as brand_essnc_code,  -- SAP Brand Essence Code  
  substr(t01.z_data,7,12) as brand_essnc_abbrd_desc,      -- Brand Essence Abbreviated Description 
  substr(t01.z_data,19,30) as brand_essnc_desc,           -- Brand Essence Description
  t02.objek 
from sap_ref_dat t01,
  grd_cla_chr t02
where t01.z_tabname (+) = '/MARS/MD_CHC016'
  and t02.atnam (+) = 'CLFFERT16'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 3));

/*-*/
/* Authority
/*-*/
grant select on ods.brand_essnc_grd to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym brand_essnc_grd for ods.brand_essnc_grd;