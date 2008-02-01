/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_supply_sgmnt
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Supply Segment View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_supply_sgmnt
   (sap_supply_sgmnt_code,
    supply_sgmnt_abbrd_desc,
    supply_sgmnt_desc) as
   select substr(t01.z_data,4,3),
          substr(t01.z_data,7,12),
          substr(t01.z_data,19,30)
     from lads_ref_dat t01
    where t01.z_tabname = '/MARS/MD_CHC005';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_supply_sgmnt to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_supply_sgmnt for lads.ods_supply_sgmnt;

