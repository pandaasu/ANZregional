/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_major_pack
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Major Pack View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_major_pack
   (sap_major_pack_code,
    major_pack_abbrd_desc,
    major_pack_desc) as
   select substr(t01.z_data,4,2),
          substr(t01.z_data,6,12),
          substr(t01.z_data,18,30)
     from lads_ref_dat t01
    where t01.z_tabname = '/MARS/MD_CHC008';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_major_pack to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_major_pack for lads.ods_major_pack;

