/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : prdct_size_grp_grd  
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Product Size Group View (GRD) 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.prdct_size_grp_grd as
select trim(substr(t01.z_data,4,2)) as prdct_size_grp_code, -- SAP Product Size Group Code  
  substr(t01.z_data,6,12) as prdct_size_grp_abbrd_desc,     -- Product Size Group Abbreviated Description   
  substr(t01.z_data,18,30) as prdct_size_grp_desc,          -- Product Size Group Description 
  t02.objek 
from sap_ref_dat t01,
  grd_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC018'
  and t02.atnam (+) = 'CLFFERT18'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 2));

/*-*/
/* Authority
/*-*/
grant select on ods.prdct_size_grp_grd to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym prdct_size_grp_grd for ods.prdct_size_grp_grd;