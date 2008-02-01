/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_funcl_vrty
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Functional Variety View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_funcl_vrty
   (sap_funcl_vrty_code,
    funcl_vrty_abbrd_desc,
    funcl_vrty_desc) as
   select substr(t01.z_data,4,3),
          substr(t01.z_data,7,12),
          substr(t01.z_data,19,30)
     from lads_ref_dat t01
    where t01.z_tabname = '/MARS/MD_CHC007';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_funcl_vrty to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_funcl_vrty for lads.ods_funcl_vrty;

