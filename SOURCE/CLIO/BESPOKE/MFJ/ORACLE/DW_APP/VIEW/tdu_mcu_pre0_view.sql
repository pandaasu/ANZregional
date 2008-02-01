/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : tdu_mcu_pre0_view
 Owner  : dw_app

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
create or replace force view tdu_mcu_pre0_view
   (TDU_SAP_CODE,
    TDU_DESC,
    TDU_JAN,
    TDU_NET_WGT,
    TDU_WGT_UNIT, 
    TDU_TO_MCU_QTY,
    MCU_SAP_CODE,
    MCU_DESC,
    MCU_JAN,
    MCU_NET_WGT, 
    MCU_WGT_UNIT,
    MCU_TO_RSU_QTY,
    RSU_SAP_CODE,
    RSU_DESC,
    RSU_JAN, 
    RSU_NET_WGT,
    RSU_WGT_UNIT) AS 
   SELECT A.SAP_MATERIAL_CODE AS TDU_SAP_CODE, 
          A.MATERIAL_DESC_JA AS TDU_DESC, 
          A.EAN_UPC AS TDU_JAN, 
          A.NET_WGT AS TDU_NET_WGT, 
          A.SAP_WGT_UNIT_CODE AS TDU_WGT_UNIT, 
          (C.CMPNT_QTY/1000) AS TDU_TO_MCU_QTY,
          B.SAP_MATERIAL_CODE AS MCU_SAP_CODE, 
          B.MATERIAL_DESC_JA AS MCU_DESC, 
          B.EAN_UPC AS MCU_JAN, 
          B.NET_WGT AS MCU_NET_WGT, 
          B.SAP_WGT_UNIT_CODE AS MCU_WGT_UNIT,
          0 AS MCU_TO_RSU_QTY,
          NULL AS RSU_SAP_CODE,
          NULL AS RSU_DESC,
          NULL AS RSU_JAN,
          0 AS RSU_NET_WGT,
          0 AS RSU_WGT_UNIT
     FROM (SELECT T1.SAP_MATERIAL_CODE, 
                  T1.MATERIAL_DESC_JA, 
                  T1.EAN_UPC, 
                  T1.NET_WGT, 
                  T1.SAP_WGT_UNIT_CODE 
             FROM DW_APP.TDU_PRE0_VIEW T1) A, 
          (SELECT T2.SAP_MATERIAL_CODE, 
                  T2.MATERIAL_DESC_JA, 
                  T2.EAN_UPC, 
                  T2.NET_WGT, 
                  T2.SAP_WGT_UNIT_CODE 
             FROM DW_APP.MCU_PRE0_VIEW T2) B, 
          DW_APP.MATERIAL_CHAIN_PRE0_VIEW C 
    WHERE A.SAP_MATERIAL_CODE = C.SAP_MATERIAL_CODE AND 
          C.CMPNT_MATERIAL_CODE = B.SAP_MATERIAL_CODE 
    GROUP BY A.SAP_MATERIAL_CODE, 
             A.MATERIAL_DESC_JA, 
             A.EAN_UPC, 
             A.NET_WGT, 
             A.SAP_WGT_UNIT_CODE, 
             (C.CMPNT_QTY/1000),
             B.SAP_MATERIAL_CODE, 
             B.MATERIAL_DESC_JA, 
             B.EAN_UPC, 
             B.NET_WGT, 
             B.SAP_WGT_UNIT_CODE;

/*-*/
/* Authority
/*-*/
grant select on dw_app.tdu_mcu_pre0_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym tdu_mcu_pre0_view for dw_app.tdu_mcu_pre0_view;

