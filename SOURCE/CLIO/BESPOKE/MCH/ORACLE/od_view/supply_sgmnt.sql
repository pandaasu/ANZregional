/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : supply_sgmnt
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Supply Segment View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.supply_sgmnt as
   select * from ods_supply_sgmnt;

/*-*/
/* Authority
/*-*/
grant select on od.supply_sgmnt to od_app with grant option;
grant select on od.supply_sgmnt to od_user;
grant select on od.supply_sgmnt to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym supply_sgmnt for od.supply_sgmnt;

