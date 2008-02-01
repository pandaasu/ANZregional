/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_brand_flag
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Brand Flag View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_brand_flag
   (sap_brand_flag_code,
    brand_flag_abbrd_desc,
    brand_flag_desc) as
   select substr(t01.z_data,4,3),
          substr(t01.z_data,7,12),
          substr(t01.z_data,19,30)
     from lads_ref_dat t01
    where t01.z_tabname = '/MARS/MD_CHC003';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_brand_flag to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_brand_flag for lads.ods_brand_flag;

