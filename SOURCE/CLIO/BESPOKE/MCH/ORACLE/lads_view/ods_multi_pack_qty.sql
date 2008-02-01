/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_multi_pack_qty
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Multi-Pack Quantity View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_multi_pack_qty
   (sap_multi_pack_qty_code,
    multi_pack_qty_abbrd_desc,
    multi_pack_qty_desc) as
   select substr(t01.z_data,4,2),
          substr(t01.z_data,6,12),
          substr(t01.z_data,18,30)
     from lads_ref_dat t01
    where t01.z_tabname = '/MARS/MD_CHC010';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_multi_pack_qty to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_multi_pack_qty for lads.ods_multi_pack_qty;

