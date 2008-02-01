/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : intransit_contnr_hdr
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Intransit Container Header View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.intransit_contnr_hdr as
   select * from ods_intransit_contnr_hdr;

/*-*/
/* Authority
/*-*/
grant select on od.intransit_contnr_hdr to od_app with grant option;
grant select on od.intransit_contnr_hdr to od_user;
grant select on od.intransit_contnr_hdr to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym intransit_contnr_hdr for od.intransit_contnr_hdr;

