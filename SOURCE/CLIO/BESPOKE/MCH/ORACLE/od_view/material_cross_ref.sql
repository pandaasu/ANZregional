/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : material_cross_ref
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Material Cross Reference View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.material_cross_ref as
   select * from ods_material_cross_ref;

/*-*/
/* Authority
/*-*/
grant select on od.material_cross_ref to od_app with grant option;
grant select on od.material_cross_ref to od_user;
grant select on od.material_cross_ref to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym material_cross_ref for od.material_cross_ref;

