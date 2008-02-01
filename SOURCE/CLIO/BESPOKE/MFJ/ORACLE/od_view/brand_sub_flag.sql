/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : brand_sub_flag
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Brand Sub Flag View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.brand_sub_flag as
   select * from ods_brand_sub_flag;

/*-*/
/* Authority
/*-*/
grant select on od.brand_sub_flag to od_app with grant option;
grant select on od.brand_sub_flag to od_user;
grant select on od.brand_sub_flag to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym brand_sub_flag for od.brand_sub_flag;

