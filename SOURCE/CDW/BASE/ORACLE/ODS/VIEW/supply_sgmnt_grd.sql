/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : supply_sgmnt_grd  
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Supply Segment View (GRD) 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.supply_sgmnt_grd as
select trim(substr(t01.z_data,4,3)) as supply_sgmnt_code, -- SAP Supply Segment Code 
  substr(t01.z_data,7,12) as supply_sgmnt_abbrd_desc,     -- Supply Segment Abbreviated Description 
  substr(t01.z_data,19,30) as supply_sgmnt_desc,          -- Supply Segment Description 
  t02.objek 
from sap_ref_dat t01,
  grd_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC005'
  and t02.atnam (+) = 'CLFFERT05'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 3));

/*-*/
/* Authority
/*-*/
grant select on ods.supply_sgmnt_grd to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym supply_sgmnt_grd for ods.supply_sgmnt_grd;