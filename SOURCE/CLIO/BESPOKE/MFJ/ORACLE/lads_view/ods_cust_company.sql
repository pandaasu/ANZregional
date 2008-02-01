/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_cust_company
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Customer Company View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_cust_company
   (sap_cust_code,
    sap_company_code) as 
   select lads_trim_code(t01.kunnr),
          t01.bukrs
     from lads_cus_cud t01;

/*-*/
/* Authority
/*-*/
grant select on lads.ods_cust_company to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_cust_company for lads.ods_cust_company;

