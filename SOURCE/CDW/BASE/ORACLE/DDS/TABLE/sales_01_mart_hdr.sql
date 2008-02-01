/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 View    : sales_01_mart_hdr
 Owner   : dds
 Author  : Steve Gregan

 Description
 -----------
 Dimensional Data Store - Sales Mart 01 Header

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/09   Steve Gregan   Created

*******************************************************************************/

/**/
/* View creation
/**/
create or replace force view dds.sales_01_mart_hdr as
   select t01.*
     from sales_01_mart_t01 t01;

/*-*/
/* Authority
/*-*/
grant select on sales_01_mart_hdr to public with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym sales_01_mart_hdr for dds.sales_01_mart_hdr;