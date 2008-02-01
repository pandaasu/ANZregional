/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : prdct_pack_size
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Product Pack Size View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.prdct_pack_size as
   select * from ods_prdct_pack_size;

/*-*/
/* Authority
/*-*/
grant select on od.prdct_pack_size to od_app with grant option;
grant select on od.prdct_pack_size to od_user;
grant select on od.prdct_pack_size to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym prdct_pack_size for od.prdct_pack_size;

