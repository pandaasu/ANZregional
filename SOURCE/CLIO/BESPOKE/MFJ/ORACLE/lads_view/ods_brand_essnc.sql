/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_brand_essnc
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Brand Essence View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_brand_essnc
   (sap_brand_essnc_code,
    brand_essnc_abbrd_desc,
    brand_essnc_desc) as
   select substr(t01.z_data,4,3),
          substr(t01.z_data,7,12),
          substr(t01.z_data,19,30)
     from lads_ref_dat t01
    where t01.z_tabname = '/MARS/MD_CHC016';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_brand_essnc to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_brand_essnc for lads.ods_brand_essnc;

