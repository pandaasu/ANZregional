/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : cnsmr_pack_frmt  
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Consumer Pack Format View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.cnsmr_pack_frmt as
select trim(substr(t01.z_data,4,2)) as cnsmr_pack_frmt_code,  -- SAP Consumer Pack Format Code 
  substr(t01.z_data,6,12) as cnsmr_pack_frmt_abbrd_desc,      -- Consumer Pack Format Abbreviated Description   
  substr(t01.z_data,18,30) as cnsmr_pack_frmt_desc,           -- Consumer Pack Format Description  
  t02.objek 
from sap_ref_dat t01,
  sap_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC025'
  and t02.atnam (+) = 'CLFFERT25'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 2));

/*-*/
/* Authority
/*-*/
grant select on ods.cnsmr_pack_frmt to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym cnsmr_pack_frmt for ods.cnsmr_pack_frmt;