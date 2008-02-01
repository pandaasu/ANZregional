/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : material_desc
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Material Description View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.material_desc as
   select * from ods_material_desc;

/*-*/
/* Authority
/*-*/
grant select on od.material_desc to od_app with grant option;
grant select on od.material_desc to od_user;
grant select on od.material_desc to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym material_desc for od.material_desc;

