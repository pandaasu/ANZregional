/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : division  
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Division View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/02   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.division as
select trim(substr(t01.z_data,5,2)) as division_code, -- SAP Division Code  
  substr(t01.z_data,4,1) as division_lang,            -- Division Language 
  substr(t01.z_data,7,20) as division_desc,           -- Division Description
  t02.valdtn_status as valdtn_status
from sap_ref_dat t01, 
  sap_ref_hdr t02
where t01.z_tabname = 'TSPAT' 
  and t01.z_tabname = t02.z_tabname(+)
order by division_lang, 
  division_code;

/*-*/
/* Authority
/*-*/
grant select on ods.division to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym division for ods.division;


