/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : material_moe
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Material Mars Organisational Entity View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.material_moe as
   select * from ods_material_moe;

/*-*/
/* Authority
/*-*/
grant select on od.material_moe to od_app with grant option;
grant select on od.material_moe to od_user;
grant select on od.material_moe to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym material_moe for od.material_moe;

