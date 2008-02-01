/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : cust
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Customer View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.cust as
   select * from ods_cust;

/*-*/
/* Authority
/*-*/
grant select on od.cust to od_app with grant option;
grant select on od.cust to od_user;
grant select on od.cust to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym cust for od.cust;

