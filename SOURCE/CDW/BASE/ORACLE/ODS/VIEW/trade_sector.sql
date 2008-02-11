/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : trade_sector  
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Trade Sector View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.trade_sector as
select trim(substr(t01.z_data,4,2)) as trade_sector_code, -- SAP Trade Sector Code  
  substr(t01.z_data,6,12) as trade_sector_abbrd_desc,     -- Trade Sector Abbreviated Description   
  substr(t01.z_data,18,30) as trade_sector_desc,          -- Trade Sector Description  
  t02.objek 
from sap_ref_dat t01,
  sap_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC008'
  and t02.atnam (+) = 'CLFFERT08'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 2));

/*-*/
/* Authority
/*-*/
grant select on ods.trade_sector to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym trade_sector for ods.trade_sector;
