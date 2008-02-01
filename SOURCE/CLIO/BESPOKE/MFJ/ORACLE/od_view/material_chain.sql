/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : material_chain
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Material Chain View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.material_chain as
   select * from ods_material_chain;

/*-*/
/* Authority
/*-*/
grant select on od.material_chain to od_app with grant option;
grant select on od.material_chain to od_user;
grant select on od.material_chain to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym material_chain for od.material_chain;

