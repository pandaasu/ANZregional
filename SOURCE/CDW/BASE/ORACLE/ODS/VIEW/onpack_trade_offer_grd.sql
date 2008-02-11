/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : onpack_trade_offer_grd  
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - On-pack Trade Offer View (GRD) 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.onpack_trade_offer_grd as
select trim(substr(t01.z_data,4,2)) as onpack_trade_offer_code, -- SAP On-pack Trade Offer Code  
  substr(t01.z_data,6,12) as onpack_trade_offer_abbrd_desc,     -- On-pack Trade Offer Abbreviated Description   
  substr(t01.z_data,18,30) as onpack_trade_offer_desc,          -- On-pack Trade Offer Description  
  t02.objek 
from sap_ref_dat t01,
  grd_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC024'
  and t02.atnam (+) = 'CLFFERT24'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 2));

/*-*/
/* Authority
/*-*/
grant select on ods.onpack_trade_offer_grd to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym onpack_trade_offer_grd for ods.onpack_trade_offer_grd;