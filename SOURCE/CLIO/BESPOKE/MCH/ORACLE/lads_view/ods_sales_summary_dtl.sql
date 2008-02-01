/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_sales_summary_dtl
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Sales Summary Detail View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_sales_summary_dtl
   (creatn_date,
    sap_company_code,
    billing_type_code,
    sales_doc_count,
    sales_doc_line_count,
    sales_doc_value,
    sales_summ_currcy_code) as 
   select lads_to_date(t01.fkdat,'yyyymmdd'),
          t01.bukrs,
          t01.fkart,
          t01.znumiv,
          t01.znumps,
          t01.netwr,
          t01.waerk
     from lads_inv_sum_det t01;

/*-*/
/* Authority
/*-*/
grant select on lads.ods_sales_summary_dtl to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_sales_summary_dtl for lads.ods_sales_summary_dtl;

