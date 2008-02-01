/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : sales_summary_hdr
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Sales Summary Header View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.sales_summary_hdr as
   select * from ods_sales_summary_hdr;

/*-*/
/* Authority
/*-*/
grant select on od.sales_summary_hdr to od_app with grant option;
grant select on od.sales_summary_hdr to od_user;
grant select on od.sales_summary_hdr to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym sales_summary_hdr for od.sales_summary_hdr;

