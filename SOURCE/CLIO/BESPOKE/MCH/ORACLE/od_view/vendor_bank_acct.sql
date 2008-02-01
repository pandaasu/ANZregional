/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Package : vendor_bank_acct
 Owner   : od

 DESCRIPTION
 -----------
 Operational Data Store - Vendor Bank Account View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.vendor_bank_acct as
   select * from ods_vendor_bank_acct;

/*-*/
/* Authority
/*-*/
grant select on od.vendor_bank_acct to od_app with grant option;
grant select on od.vendor_bank_acct to od_user;
grant select on od.vendor_bank_acct to pld_rep_app;

/*-*/
/* Synonym
/*-*/
create public synonym vendor_bank_acct for od.vendor_bank_acct;

