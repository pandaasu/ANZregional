/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_vendor_bank_acct
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Vendor Bank Account View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_vendor_bank_acct
   (sap_vendor_code,
    vendor_bank_name,
    vendor_bank_brnch_name,
    vendor_bank_acct_type_code,
    vendor_bank_acct_num,
    sap_cntry_code,
    bank_key) as 
   select lads_trim_code(t01.lifnr),
          t01.banka,
          t01.brnch,
          t01.bkont,
          t01.bankn,
          t01.banks,
          t01.bankl
     from lads_ven_bnk t01;

/*-*/
/* Authority
/*-*/
grant select on lads.ods_vendor_bank_acct to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_vendor_bank_acct for lads.ods_vendor_bank_acct;

