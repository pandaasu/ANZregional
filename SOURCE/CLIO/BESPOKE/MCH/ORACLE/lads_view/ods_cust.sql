/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_cust
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Customer View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_cust
   (sap_cust_code,
    sap_cust_acct_grp_code,
    sap_vendor_code,
    sap_addr_type_code,
    sap_cust_distbn_role_code,
    grp_key,
    cust_lupdt) as 
   select lads_trim_code(t01.kunnr),
          t01.ktokd,
          lads_trim_code(t01.lifnr),
          'KNA1',
          null,
          t01.konzs,
          t01.lads_date
     from lads_cus_hdr t01
    where t01.lads_status = '1';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_cust to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_cust for lads.ods_cust;

