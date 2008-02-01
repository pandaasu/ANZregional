/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 View    : sales_01_mart_det_gsv
 Owner   : dds
 Author  : Steve Gregan

 Description
 -----------
 Dimensional Data Store - Sales Mart 01 Detail (GSV)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/09   Steve Gregan   Created

*******************************************************************************/

/**/
/* View creation
/**/
create or replace force view dds.sales_01_mart_det_gsv as
   select t01.*,
     from sales_01_mart_det
    where t01.data_type = '*GSV';

/*-*/
/* Authority
/*-*/
grant select on sales_01_mart_det_gsv to public with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym sales_01_mart_det_gsv for dds.sales_01_mart_det_gsv;