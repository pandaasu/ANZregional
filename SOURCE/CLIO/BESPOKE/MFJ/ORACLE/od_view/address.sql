/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : address
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Address View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.address as
   select * from ods_address;

/*-*/
/* Authority
/*-*/
grant select on od.address to od_app with grant option;
grant select on od.address to od_user;
grant select on od.address to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym address for od.address;

