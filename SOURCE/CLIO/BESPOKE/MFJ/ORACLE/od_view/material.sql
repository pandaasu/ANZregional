/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : material
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Material View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.material as
   select * from ods_material;

/*-*/
/* Authority
/*-*/
grant select on od.material to od_app with grant option;
grant select on od.material to od_user;
grant select on od.material to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym material for od.material;

