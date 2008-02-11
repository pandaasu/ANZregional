/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : trad_unit_frmt_grd  
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Traded Unit Format View (GRD) 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.trad_unit_frmt_grd as
select trim(substr(t01.z_data,4,2)) as trad_unit_frmt_code, -- SAP Traded Unit Format Code  
  substr(t01.z_data,6,12) as trad_unit_frmt_abbrd_desc,     -- Traded Unit Format Abbreviated Description   
  substr(t01.z_data,18,30) as trad_unit_frmt_desc,          -- Traded Unit Format Description  
  t02.objek 
from sap_ref_dat t01,
  grd_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC020'
  and t02.atnam (+) = 'CLFFERT20'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 2));

/*-*/
/* Authority
/*-*/
grant select on ods.trad_unit_frmt_grd to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym trad_unit_frmt_grd for ods.trad_unit_frmt_grd;
