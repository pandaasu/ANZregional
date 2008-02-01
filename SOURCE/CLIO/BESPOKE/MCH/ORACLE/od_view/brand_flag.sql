/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : brand_flag
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Brand Flag View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.brand_flag as
   select * from ods_brand_flag;

/*-*/
/* Authority
/*-*/
grant select on od.brand_flag to od_app with grant option;
grant select on od.brand_flag to od_user;
grant select on od.brand_flag to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym brand_flag for od.brand_flag;

