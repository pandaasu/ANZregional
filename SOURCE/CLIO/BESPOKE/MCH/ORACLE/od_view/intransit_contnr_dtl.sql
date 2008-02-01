/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : intransit_contnr_dtl
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Intransit Container Detail View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.intransit_contnr_dtl as
   select * from ods_intransit_contnr_dtl;

/*-*/
/* Authority
/*-*/
grant select on od.intransit_contnr_dtl to od_app with grant option;
grant select on od.intransit_contnr_dtl to od_user;
grant select on od.intransit_contnr_dtl to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym intransit_contnr_dtl for od.intransit_contnr_dtl;

