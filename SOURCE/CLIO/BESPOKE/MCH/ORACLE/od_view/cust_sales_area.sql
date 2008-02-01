/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : cust_sales_area
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Customer Sales Area View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.cust_sales_area as
   select * from ods_cust_sales_area;

/*-*/
/* Authority
/*-*/
grant select on od.cust_sales_area to od_app with grant option;
grant select on od.cust_sales_area to od_user;
grant select on od.cust_sales_area to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym cust_sales_area for od.cust_sales_area;

