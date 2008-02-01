/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : onpack_trade_offer
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Onpack Trade Offer View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.onpack_trade_offer as
   select * from ods_onpack_trade_offer;

/*-*/
/* Authority
/*-*/
grant select on od.onpack_trade_offer to od_app with grant option;
grant select on od.onpack_trade_offer to od_user;
grant select on od.onpack_trade_offer to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym onpack_trade_offer for od.onpack_trade_offer;

