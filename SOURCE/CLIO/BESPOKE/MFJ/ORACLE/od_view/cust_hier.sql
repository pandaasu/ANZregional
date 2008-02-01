/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : cust_hier
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Customer Hierarchy View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.cust_hier as
   select * from ods_cust_hier;

/*-*/
/* Authority
/*-*/
grant select on od.cust_hier to od_app with grant option;
grant select on od.cust_hier to od_user;
grant select on od.cust_hier to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym cust_hier for od.cust_hier;

