/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : uom  
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - UOM View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.uom as
select trim(substr(t02.z_data, 4, 3)) as uom_code,
  trim(decode(substr(t02.z_data, 62, 3), '   ', '<EMPTY>', substr(t02.z_data, 62, 3))) as uom_abbrd_desc,
  trim(substr(t02.z_data, 16, 6)) as uom_desc,
  'n/a' as uom_dim,
  t01.valdtn_status as valdtn_status
from
  sap_ref_hdr t01,
  sap_ref_dat t02
where t01.z_tabname = t02.z_tabname 
  and t02.z_tabname = 'T006' 

union

select trim(decode(substr(t02.z_data, 62, 3), '   ', null, substr(t02.z_data, 62, 3))) as uom_code,
  trim(decode(substr(t02.z_data, 62, 3), '   ', null, substr(t02.z_data, 62, 3))) as uom_abbrd_desc,
  trim(substr(t02.z_data, 16, 6)) as uom_desc,
  'n/a' as uom_dim,
  t01.valdtn_status as valdtn_status
from sap_ref_hdr t01,
  sap_ref_dat t02
where t01.z_tabname = t02.z_tabname
  and t02.z_tabname = 'T006'
  and trim(decode(substr(t02.z_data, 62, 3), '   ', null, substr(t02.z_data, 62, 3))) is not null
  and trim(substr(t02.z_data, 62, 3)) not in
  (
    select trim(substr(t03.z_data, 4, 3))
    from sap_ref_dat t03
    where t03.z_tabname = 'T006'
  )
order by uom_code;

/*-*/
/* Authority 
/*-*/
grant select on ods.uom to ods_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym uom for ods.uom;