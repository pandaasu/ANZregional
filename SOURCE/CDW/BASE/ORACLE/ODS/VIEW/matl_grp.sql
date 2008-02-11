/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : matl_grp  
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Material Group View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/12   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.matl_grp as
select distinct trim(substr(z_data, 5, 9)) as matl_grp_code,
  trim(substr(z_data, 33, 60)) as matl_grp_desc
from sap_ref_dat
where z_tabname = 'T023T'
  and substr(z_data, 4, 1) = 'E';
  
/*-*/
/* Authority
/*-*/
grant select on ods.matl_grp to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym matl_grp for ods.matl_grp;