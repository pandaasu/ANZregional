/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : multi_pack_qty  
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Multi-pack Quantity View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.multi_pack_qty as
select trim(substr(t01.z_data,4,2)) as multi_pack_qty_code,   -- SAP Multi-pack Quantity Code 
  substr(t01.z_data,6,12) as multi_pack_qty_abbrd_desc,       -- Multi-pack Quantity Abbreviated Description 
  substr(t01.z_data,18,30) as multi_pack_qty_desc,            -- Multi-pack Quantity Description 
  t02.objek 
from sap_ref_dat t01,
  sap_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC010'
  and t02.atnam (+) = 'CLFFERT10'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 2));

/*-*/
/* Authority
/*-*/
grant select on ods.multi_pack_qty to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym multi_pack_qty for ods.multi_pack_qty;