/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : mktg_concept_grd  
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Marketing Concept View (GRD) 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.mktg_concept_grd as
select trim(substr(t01.z_data,4,3)) as mktg_concept_code, -- SAP Marketing Concept Code  
  substr(t01.z_data,7,12) as mktg_concept_abbrd_desc,     -- Marketing Concept Abbreviated Description   
  substr(t01.z_data,19,30) as mktg_concept_desc,          -- Marketing Concept Description  
  t02.objek 
from sap_ref_dat t01,
  grd_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC009'
  and t02.atnam (+) = 'CLFFERT09'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 3));

/*-*/
/* Authority
/*-*/
grant select on ods.mktg_concept_grd to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym mktg_concept_grd for ods.mktg_concept_grd;
