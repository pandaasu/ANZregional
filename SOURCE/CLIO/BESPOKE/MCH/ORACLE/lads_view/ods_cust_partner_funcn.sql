/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_cust_partner_funcn
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Customer Partner Function View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_cust_partner_funcn
   (sap_cust_code,
    sap_sales_org_code,
    sap_distbn_chnl_code,
    sap_division_code,
    sap_partner_funcn_code,
    sap_cust_partner_code) as 
   select lads_trim_code(t01.kunnr),
          t01.vkorg,
          t01.vtweg,
          t01.spart,
          t02.parvw,
          lads_trim_code(t02.kunn2)
     from lads_cus_sad t01,
          lads_cus_pfr t02
    where t01.kunnr = t02.kunnr
      and t01.sadseq = t02.sadseq;

/*-*/
/* Authority
/*-*/
grant select on lads.ods_cust_partner_funcn to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_cust_partner_funcn for lads.ods_cust_partner_funcn;

