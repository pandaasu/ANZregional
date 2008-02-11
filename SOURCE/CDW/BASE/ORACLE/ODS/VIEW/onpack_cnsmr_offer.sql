/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : onpack_cnsmr_offer  
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - On-pack Consumer Offer View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.onpack_cnsmr_offer as
select trim(substr(t01.z_data,4,2)) as onpack_cnsmr_offer_code, -- SAP On-pack Consumer Offer Code 
  substr(t01.z_data,6,12) as onpack_cnsmr_offer_abbrd_desc,     -- On-pack Consumer Offer Abbreviated Description   
  substr(t01.z_data,18,30) as onpack_cnsmr_offer_desc,          -- On-pack Consumer Offer Description  
  t02.objek 
from sap_ref_dat t01,
  sap_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC023'
  and t02.atnam (+) = 'CLFFERT23'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 2));

/*-*/
/* Authority
/*-*/
grant select on ods.onpack_cnsmr_offer to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym onpack_cnsmr_offer for ods.onpack_cnsmr_offer;
