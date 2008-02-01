/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : pack_type
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Pack Type View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.pack_type as
   select * from ods_pack_type;

/*-*/
/* Authority
/*-*/
grant select on od.pack_type to od_app with grant option;
grant select on od.pack_type to od_user;
grant select on od.pack_type to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym pack_type for od.pack_type;

