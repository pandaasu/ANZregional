/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : material_list_price
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Material List Price View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.material_list_price as
   select * from ods_material_list_price;

/*-*/
/* Authority
/*-*/
grant select on od.material_list_price to od_app with grant option;
grant select on od.material_list_price to od_user;
grant select on od.material_list_price to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym material_list_price for od.material_list_price;

