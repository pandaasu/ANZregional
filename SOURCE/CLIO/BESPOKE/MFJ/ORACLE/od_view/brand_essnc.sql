/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : brand_essnc
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Brand Essence View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.brand_essnc as
   select * from ods_brand_essnc;

/*-*/
/* Authority
/*-*/
grant select on od.brand_essnc to od_app with grant option;
grant select on od.brand_essnc to od_user;
grant select on od.brand_essnc to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym brand_essnc for od.brand_essnc;

