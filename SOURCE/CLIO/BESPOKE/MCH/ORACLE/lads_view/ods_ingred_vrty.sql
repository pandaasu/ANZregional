/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_ingred_vrty
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Ingredient Variety View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_ingred_vrty
   (sap_ingred_vrty_code,
    ingred_vrty_abbrd_desc,
    ingred_vrty_desc) as
   select substr(t01.z_data,4,4),
          substr(t01.z_data,8,12),
          substr(t01.z_data,20,30)
     from lads_ref_dat t01
    where t01.z_tabname = '/MARS/MD_CHC006';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_ingred_vrty to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_ingred_vrty for lads.ods_ingred_vrty;

