/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : brand_sub_flag_grd  
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Brand Sub-Flag View (GRD) 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.brand_sub_flag_grd as
select trim(substr(t01.z_data,4,3)) as brand_sub_flag_code, -- SAP Brand Sub-Flag Code 
  substr(t01.z_data,7,12) as brand_sub_flag_abbrd_desc,     -- Brand Sub-Flag Abbreviated Description 
  substr(t01.z_data,19,30) as brand_sub_flag_desc,          -- Brand Sub-Flag Description 
  t02.objek  
from sap_ref_dat t01,
  grd_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC004'
  and t02.atnam (+) = 'CLFFERT04'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 3));

/*-*/
/* Authority
/*-*/
grant select on ods.brand_sub_flag_grd to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym brand_sub_flag_grd for ods.brand_sub_flag_grd;
