/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : disp_strg_cndtn_grd  
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Display Storage Condition View (GRD) 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.disp_strg_cndtn_grd as
select trim(substr(t01.z_data,4,2)) as disp_strg_cndtn_code,  -- SAP Display Storage Condition Code  
  substr(t01.z_data,6,12) as disp_strg_cndtn_abbrd_desc,      -- Display Storage Condition Abbreviated Description   
  substr(t01.z_data,18,30) as disp_strg_cndtn_desc,           -- Display Storage Condition Description  
  t02.objek 
from sap_ref_dat t01,
  grd_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC019'
  and t02.atnam (+) = 'CLFFERT19'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 2));

/*-*/
/* Authority
/*-*/
grant select on ods.disp_strg_cndtn_grd to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym disp_strg_cndtn_grd for ods.disp_strg_cndtn_grd;