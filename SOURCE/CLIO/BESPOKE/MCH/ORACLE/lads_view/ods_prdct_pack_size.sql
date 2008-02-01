/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_prdct_pack_size
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Product Pack Size View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_prdct_pack_size
   (sap_prdct_pack_size_code,
    prdct_pack_size_abbrd_desc,
    prdct_pack_size_desc) as 
   select substr(t01.z_data,4,3),
          substr(t01.z_data,7,12),
          substr(t01.z_data,19,30)
     from lads_ref_dat t01
    where t01.z_tabname = '/MARS/MD_CHC014';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_prdct_pack_size to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_prdct_pack_size for lads.ods_prdct_pack_size;

