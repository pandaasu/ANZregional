/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_trad_unit_config
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Trade Unit Configuration View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_trad_unit_config
   (sap_trad_unit_config_code,
    trad_unit_config_abbrd_desc,
    trad_unit_config_desc) as
   select substr(t01.z_data,4,3),
          substr(t01.z_data,7,12),
          substr(t01.z_data,19,30)
     from lads_ref_dat t01
    where t01.z_tabname = '/MARS/MD_CHC021';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_trad_unit_config to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_trad_unit_config for lads.ods_trad_unit_config;

