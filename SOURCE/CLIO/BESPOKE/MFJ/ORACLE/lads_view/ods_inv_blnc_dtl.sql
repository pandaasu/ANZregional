/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_inv_blnc_dtl
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Inventory Balance Detail View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created
 2006/04   Steve Gregan   Added MFANZ material cross reference
 2006/05   Steve Gregan   Changed CHARG to VFDAT for Atlas 3.1 upgrade

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_inv_blnc_dtl
   (sap_company_code,
    sap_plant_code,
    sap_storage_locn_code,
    blnc_date,
    blnc_time,
    inv_blnc_dtl_seq,
    sap_material_code,
    inv_level,
    material_batch_desc,
    sap_stock_type_code,
    sap_inv_blnc_uom_code,
    sap_special_stock_type_code,
    sap_cust_vendor_code) as
   select t01.bukrs,
          t01.werks,
          t01.lgort,
          lads_to_date(t01.budat,'yyyymmdd'),
          timlo,
          detseq,
          decode(t01.werks,'JP01',decode(t02.xrf_source,null,lads_trim_code(t01.matnr),t02.xrf_source)
                          ,decode(t01.lgort,'INTR',decode(t02.xrf_source,null,lads_trim_code(t01.matnr),t02.xrf_source)
                                                  ,lads_trim_code(t01.matnr))),
          t01.menga,
          to_char(lads_to_date(t01.vfdat,'yyyymmdd'),'ddmmyyyy'),
          t01.insmk,
          t01.altme,
          t01.sobkz,
          lads_trim_code(t01.kunnr)
     from lads_stk_bal_det t01,
          lads_xrf_det t02
    where lads_trim_code(t01.matnr) = t02.xrf_target(+)
          and 'MFJ_MFANZ_MATERIAL' = t02.xrf_code(+);

/*-*/
/* Authority
/*-*/
grant select on lads.ods_inv_blnc_dtl to od with grant option;
grant select on lads.ods_inv_blnc_dtl to dw_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_inv_blnc_dtl for lads.ods_inv_blnc_dtl;

