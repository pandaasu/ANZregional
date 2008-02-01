/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : inv_blnc_dly_view
 Owner  : od

 DESCRIPTION
 -----------
 Data Warehouse - View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od.inv_blnc_dly_view
   (SAP_PLANT_CODE, SAP_STORAGE_LOCN_CODE, BLNC_DATE, IDOC_CREATN_DATE, IDOC_CREATN_TIME, 
 SAP_MATERIAL_CODE, INV_LEVEL, MATERIAL_BATCH_DESC, SAP_STOCK_TYPE_CODE, 
 STOCK_TYPE_DESC, SAP_UOM_CODE, UOM_ABBRD_DESC, UOM_DESC, INV_BLNC_HDR_LUPDP, INV_BLNC_HDR_LUPDT)
AS 
SELECT 
-- ************************************************************************ 
-- Please note that this view will only work if an equivelant username and 
-- password on the Data Warehouse side exists. 
-- ************************************************************************ 
  A.SAP_PLANT_CODE, 
  A.SAP_STORAGE_LOCN_CODE, 
  A.BLNC_DATE, 
  A.IDOC_CREATN_DATE, 
  A.IDOC_CREATN_TIME, 
  B.SAP_MATERIAL_CODE, 
  B.INV_LEVEL, 
  B.MATERIAL_BATCH_DESC,  
  C.SAP_STOCK_TYPE_CODE, 
  C.STOCK_TYPE_DESC,  
  D.SAP_UOM_CODE, 
  D.UOM_ABBRD_DESC, 
  D.UOM_DESC,
  A.INV_BLNC_HDR_LUPDP,
  A.INV_BLNC_HDR_LUPDT
FROM 
  INV_BLNC_HDR_IN_DW A, 
  INV_BLNC_DTL_IN_DW B, 
  STOCK_TYPE_IN_DW   C, 
  UOM_IN_DW          D 
WHERE A.sap_company_code = B.sap_company_code and
      A.sap_plant_code = B.sap_plant_code and
      A.sap_storage_locn_code = B.sap_storage_locn_code and
      A.blnc_date = B.blnc_date and
      A.blnc_time = B.blnc_time and
  B.SAP_STOCK_TYPE_CODE   = C.SAP_STOCK_TYPE_CODE AND 
  B.SAP_INV_BLNC_UOM_CODE = D.SAP_UOM_CODE;

/*-*/
/* Authority
/*-*/
grant select on od.inv_blnc_dly_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym inv_blnc_dly_view for od.inv_blnc_dly_view;