/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_sales_summary_hdr
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Sales Summary Header View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_sales_summary_hdr
   (creatn_date,
    sap_company_code,
    idoc_creation_date,
    idoc_creation_time) as 
   select lads_to_date(t01.fkdat,'yyyymmdd'),
          t01.bukrs,
          lads_to_date(t01.datum,'yyyymmdd'),
          t01.uzeit
     from lads_inv_sum_hdr t01
    where t01.lads_status = '1';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_sales_summary_hdr to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_sales_summary_hdr for lads.ods_sales_summary_hdr;

