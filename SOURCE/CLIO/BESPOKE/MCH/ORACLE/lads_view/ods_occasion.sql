/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_occasion
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Occasion View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_occasion
   (sap_occsn_code,
    occsn_abbrd_desc,
    occsn_desc) as
   select substr(t01.z_data,4,2),
          substr(t01.z_data,6,12),
          substr(t01.z_data,18,30)
     from lads_ref_dat t01
    where t01.z_tabname = '/MARS/MD_CHC011';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_occasion to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_occasion for lads.ods_occasion;
