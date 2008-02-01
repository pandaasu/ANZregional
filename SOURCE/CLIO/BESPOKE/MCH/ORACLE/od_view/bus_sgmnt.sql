/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : bus_sgmnt
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Business Segment View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.bus_sgmnt as
   select * from ods_bus_sgmnt;

/*-*/
/* Authority
/*-*/
grant select on od.bus_sgmnt to od_app with grant option;
grant select on od.bus_sgmnt to od_user;
grant select on od.bus_sgmnt to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym bus_sgmnt for od.bus_sgmnt;