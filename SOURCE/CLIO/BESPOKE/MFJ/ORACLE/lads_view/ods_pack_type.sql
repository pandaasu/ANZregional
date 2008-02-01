/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_pack_type
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Pack Type View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_pack_type
   (sap_pack_type_code,
    pack_type_abbrd_desc,
    pack_type_desc) as
   select substr(t01.z_data,4,2),
          substr(t01.z_data,6,12),
          substr(t01.z_data,18,30)
     from lads_ref_dat t01
    where t01.z_tabname = '/MARS/MD_CHC017';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_pack_type to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_pack_type for lads.ods_pack_type;

