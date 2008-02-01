/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_vendor
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Vendor View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_vendor
   (sap_company_code,
    sap_vendor_code,
    vendor_name,
    sap_addr_type_code,
    vendor_lupdt) as 
   select max(t02.bukrs),
          lads_trim_code(t01.lifnr),
          max(t01.name1),
          'LFA1',
          max(t01.lads_date)
     from lads_ven_hdr t01,
          lads_ven_ccd t02
    where t01.lifnr = t02.lifnr(+)
      and t01.lads_status = '1'
    group by t01.lifnr;

/*-*/
/* Authority
/*-*/
grant select on lads.ods_vendor to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_vendor for lads.ods_vendor;

