/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_inv_blnc_hdr
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Inventory Balance Header View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_inv_blnc_hdr
   (sap_company_code,
    sap_plant_code,
    sap_storage_locn_code,
    blnc_date,
    blnc_time,
    idoc_creatn_date,
    idoc_creatn_time,
    inv_blnc_hdr_lupdp,
    inv_blnc_hdr_lupdt) as 
   select t01.bukrs,
          t01.werks,
          t01.lgort,
          lads_to_date(t01.budat,'yyyymmdd'),
          timlo,
          lads_to_date(t01.credat,'yyyymmdd'),
          t01.cretim,
          'LADS',
          t01.lads_date
     from lads_stk_bal_hdr t01
    where t01.lads_status = '1';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_inv_blnc_hdr to od with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_inv_blnc_hdr for lads.ods_inv_blnc_hdr;

