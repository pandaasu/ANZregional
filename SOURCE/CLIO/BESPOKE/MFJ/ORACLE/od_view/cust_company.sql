/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : cust_company
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Customer Company View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.cust_company as
   select * from ods_cust_company;

/*-*/
/* Authority
/*-*/
grant select on od.cust_company to od_app with grant option;
grant select on od.cust_company to od_user;
grant select on od.cust_company to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym cust_company for od.cust_company;

