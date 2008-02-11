/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : mkt_sgmnt_grd   
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Market Segment View (GRD) 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.mkt_sgmnt_grd as
select trim(substr(t01.z_data,4,2)) as mkt_sgmnt_code,  -- SAP Market Segment Code 
  substr(t01.z_data,6,12) as mkt_sgmnt_abbrd_desc,      -- Market Segment Abbreviated Description 
  substr(t01.z_data,18,30) as mkt_sgmnt_desc,           -- Market Segment Description 
  t02.objek 
from sap_ref_dat t01,
  grd_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC002'
  and t02.atnam (+) = 'CLFFERT02'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 2));

/*-*/
/* Authority
/*-*/
grant select on ods.mkt_sgmnt_grd to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym mkt_sgmnt_grd for ods.mkt_sgmnt_grd;