/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : sales_summary_dtl
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Sales Summary Detail View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.sales_summary_dtl as
   select * from ods_sales_summary_dtl;

/*-*/
/* Authority
/*-*/
grant select on od.sales_summary_dtl to od_app with grant option;
grant select on od.sales_summary_dtl to od_user;
grant select on od.sales_summary_dtl to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym sales_summary_dtl for od.sales_summary_dtl;

