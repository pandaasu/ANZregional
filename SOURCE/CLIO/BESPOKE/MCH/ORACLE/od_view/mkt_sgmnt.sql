/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : mkt_sgmnt
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Market Segment View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.mkt_sgmnt as
   select * from ods_mkt_sgmnt;

/*-*/
/* Authority
/*-*/
grant select on od.mkt_sgmnt to od_app with grant option;
grant select on od.mkt_sgmnt to od_user;
grant select on od.mkt_sgmnt to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym mkt_sgmnt for od.mkt_sgmnt;

