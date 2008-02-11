/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : ingred_vrty_grd 
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Ingredient Variety View (GRD) 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.ingred_vrty_grd as
select trim(substr(t01.z_data,4,4)) as ingred_vrty_code,  -- SAP Ingredient Variety Code 
  substr(t01.z_data,8,12) as ingred_vrty_abbrd_desc,      -- Ingredient Variety Abbreviated Description 
  substr(t01.z_data,20,30) as ingred_vrty_desc,           -- Ingredient Variety Description 
  t02.objek 
from sap_ref_dat t01,
  grd_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC006'
  and t02.atnam (+) = 'CLFFERT06'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 4));

/*-*/
/* Authority
/*-*/
grant select on ods.ingred_vrty_grd to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ingred_vrty_grd for ods.ingred_vrty_grd;