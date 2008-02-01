/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_prdct_ctgry
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Product Category View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_prdct_ctgry
   (sap_prdct_ctgry_code,
    prdct_ctgry_abbrd_desc,
    prdct_ctgry_desc) as
   select substr(t01.z_data,4,2),
          substr(t01.z_data,6,12),
          substr(t01.z_data,18,30)
     from lads_ref_dat t01
    where t01.z_tabname = '/MARS/MD_CHC012';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_prdct_ctgry to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_prdct_ctgry for lads.ods_prdct_ctgry;

