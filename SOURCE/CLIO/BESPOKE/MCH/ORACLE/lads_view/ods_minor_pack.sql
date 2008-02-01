/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_minor_pack
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Minor Pack View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_minor_pack
   (sap_minor_pack_code,
    minor_pack_abbrd_desc,
    minor_pack_desc) as
   select substr(t01.z_data,4,3),
          substr(t01.z_data,7,12),
          substr(t01.z_data,19,30)
     from lads_ref_dat t01
    where t01.z_tabname = '/MARS/MD_CHC009';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_minor_pack to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_minor_pack for lads.ods_minor_pack;

