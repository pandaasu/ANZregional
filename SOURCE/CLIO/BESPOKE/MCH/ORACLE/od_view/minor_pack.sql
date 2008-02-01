/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : minor_pack
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Minor Pack View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.minor_pack as
   select * from ods_minor_pack;

/*-*/
/* Authority
/*-*/
grant select on od.minor_pack to od_app with grant option;
grant select on od.minor_pack to od_user;
grant select on od.minor_pack to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym minor_pack for od.minor_pack;

