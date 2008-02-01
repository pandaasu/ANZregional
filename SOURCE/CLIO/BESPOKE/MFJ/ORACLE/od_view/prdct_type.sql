/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : prdct_type
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Product Type View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.prdct_type as
   select * from ods_prdct_type;

/*-*/
/* Authority
/*-*/
grant select on od.prdct_type to od_app with grant option;
grant select on od.prdct_type to od_user;
grant select on od.prdct_type to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym prdct_type for od.prdct_type;

