/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : multi_pack_qty
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Multi-Pack Quantity View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.multi_pack_qty as
   select * from ods_multi_pack_qty;

/*-*/
/* Authority
/*-*/
grant select on od.multi_pack_qty to od_app with grant option;
grant select on od.multi_pack_qty to od_user;
grant select on od.multi_pack_qty to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym multi_pack_qty for od.multi_pack_qty;

