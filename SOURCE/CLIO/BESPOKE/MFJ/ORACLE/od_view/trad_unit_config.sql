/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : trad_unit_config
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Trade Unit Configuration View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.trad_unit_config as
   select * from ods_trad_unit_config;

/*-*/
/* Authority
/*-*/
grant select on od.trad_unit_config to od_app with grant option;
grant select on od.trad_unit_config to od_user;
grant select on od.trad_unit_config to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym trad_unit_config for od.trad_unit_config;

