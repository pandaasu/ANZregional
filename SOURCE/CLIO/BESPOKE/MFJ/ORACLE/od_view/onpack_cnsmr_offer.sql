/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : onpack_cnsmr_offer
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Onpack Consumer Offer View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.onpack_cnsmr_offer as
   select * from ods_onpack_cnsmr_offer;

/*-*/
/* Authority
/*-*/
grant select on od.onpack_cnsmr_offer to od_app with grant option;
grant select on od.onpack_cnsmr_offer to od_user;
grant select on od.onpack_cnsmr_offer to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym onpack_cnsmr_offer for od.onpack_cnsmr_offer;

