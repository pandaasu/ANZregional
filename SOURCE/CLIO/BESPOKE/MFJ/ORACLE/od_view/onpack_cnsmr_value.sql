/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : onpack_cnsmr_value
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Onpack Consumer Value View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.onpack_cnsmr_value as
   select * from ods_onpack_cnsmr_value;

/*-*/
/* Authority
/*-*/
grant select on od.onpack_cnsmr_value to od_app with grant option;
grant select on od.onpack_cnsmr_value to od_user;
grant select on od.onpack_cnsmr_value to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym onpack_cnsmr_value for od.onpack_cnsmr_value;

