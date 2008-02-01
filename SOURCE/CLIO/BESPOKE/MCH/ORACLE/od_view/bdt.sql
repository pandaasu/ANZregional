/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : bdt
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - BDT View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/05   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.bdt as
   select * from ods_bdt;

/*-*/
/* Authority
/*-*/
grant select on od.bdt to od_app with grant option;
grant select on od.bdt to dw_app with grant option;
grant select on od.bdt to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym bdt for od.bdt;

