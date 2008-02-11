/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : trad_unit_config_grd  
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Traded Unit Configuration View (GRD) 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.trad_unit_config_grd as
select trim(substr(t01.z_data,4,3)) as trad_unit_config_code, -- SAP Traded Unit Configuration Code  
  substr(t01.z_data,7,12) as trad_unit_config_abbrd_desc,     -- Traded Unit Configuration Abbreviated Description 
  substr(t01.z_data,19,30) as trad_unit_config_desc,          -- Traded Unit Configuration Description  
  t02.objek 
from sap_ref_dat t01,
  grd_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC021'
  and t02.atnam (+) = 'CLFFERT21'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 3));

/*-*/
/* Authority
/*-*/
grant select on ods.trad_unit_config_grd to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym trad_unit_config_grd for ods.trad_unit_config_grd;