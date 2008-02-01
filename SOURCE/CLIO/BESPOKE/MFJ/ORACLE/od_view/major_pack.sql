/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : major_pack
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Major Pack View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.major_pack as
   select * from ods_major_pack;

/*-*/
/* Authority
/*-*/
grant select on od.major_pack to od_app with grant option;
grant select on od.major_pack to od_user;
grant select on od.major_pack to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym major_pack for od.major_pack;

