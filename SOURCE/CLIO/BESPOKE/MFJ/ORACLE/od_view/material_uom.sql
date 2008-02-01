/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : material_uom
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Material Unit Of Measure View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.material_uom as
   select * from ods_material_uom;

/*-*/
/* Authority
/*-*/
grant select on od.material_uom to od_app with grant option;
grant select on od.material_uom to od_user;
grant select on od.material_uom to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym material_uom for od.material_uom;

