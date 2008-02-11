/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : bus_sgmnt_grd   
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Business Segment View (GRD) 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.bus_sgmnt_grd as
select trim(substr(t01.z_data,4,2)) as bus_sgmnt_code,  -- SAP Business Segment Code 
  substr(t01.z_data,6,12) as bus_sgmnt_abbrd_desc,      -- Business Segment Abbreviated Description 
  substr(t01.z_data,18,30) as bus_sgmnt_desc,           -- Business Segment Description 
  t02.objek  
from sap_ref_dat t01,
  grd_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC001'
  and t02.atnam (+) = 'CLFFERT01'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 2));

/*-*/
/* Authority
/*-*/
grant select on ods.bus_sgmnt_grd to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym bus_sgmnt_grd for ods.bus_sgmnt_grd;