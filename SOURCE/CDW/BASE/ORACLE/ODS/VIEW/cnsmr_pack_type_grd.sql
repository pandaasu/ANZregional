/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : cnsmr_pack_type_grd  
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Consumer Pack Type View (GRD) 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.cnsmr_pack_type_grd as
select trim(substr(t01.z_data,4,2)) as cnsmr_pack_type_code,  -- SAP Consumer Pack Type Code  
  substr(t01.z_data,6,12) as cnsmr_pack_type_abbrd_desc,      -- Consumer Pack Type Abbreviated Description   
  substr(t01.z_data,18,30) as cnsmr_pack_type_desc,           -- Consumer Pack Type Description  
  t02.objek 
from sap_ref_dat t01,
  grd_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC017'
  and t02.atnam (+) = 'CLFFERT17'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 2));

/*-*/
/* Authority
/*-*/
grant select on ods.cnsmr_pack_type_grd to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym cnsmr_pack_type_grd for ods.cnsmr_pack_type_grd;