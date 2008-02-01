/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_prdct_type
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Product Type View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_prdct_type
   (sap_prdct_type_code,
    prdct_type_abbrd_desc,
    prdct_type_desc) as
   select substr(t01.z_data,4,3),
          substr(t01.z_data,7,12),
          substr(t01.z_data,19,30)
     from lads_ref_dat t01
    where t01.z_tabname = '/MARS/MD_CHC013';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_prdct_type to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_prdct_type for lads.ods_prdct_type;

