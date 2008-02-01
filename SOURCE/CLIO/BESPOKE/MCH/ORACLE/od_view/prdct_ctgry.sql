/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : prdct_ctgry
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Product Category View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.prdct_ctgry as
   select * from ods_prdct_ctgry;

/*-*/
/* Authority
/*-*/
grant select on od.prdct_ctgry to od_app with grant option;
grant select on od.prdct_ctgry to od_user;
grant select on od.prdct_ctgry to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym prdct_ctgry for od.prdct_ctgry;

