/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : tdu_view
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
create or replace force view tdu_view
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
   SELECT T1.SAP_MATERIAL_CODE AS TDU_SAP_CODE, 
          T1.MATERIAL_DESC_JA AS TDU_DESC, 
          T1.EAN_UPC AS TDU_JAN, 
          T1.NET_WGT AS TDU_NET_WGT, 
          T1.SAP_WGT_UNIT_CODE AS TDU_WGT_UNIT,
          0 AS TDU_TO_MCU_QTY,
          NULL AS MCU_SAP_CODE,
          NULL AS MCU_DESC,
          NULL AS MCU_JAN,
          0 AS MCU_NET_WGT,
          0 AS MCU_WGT_UNIT,
          0 AS MCU_TO_RSU_QTY,
          NULL AS RSU_SAP_CODE,
          NULL AS RSU_DESC,
          NULL AS RSU_JAN,
          0 AS RSU_NET_WGT,
          0 AS RSU_WGT_UNIT
     FROM MATERIAL_DIM T1
    WHERE t1.MATERIAL_TYPE_FLAG_TDU = 'Y'
      AND T1.MATERIAL_DESC_JA IS NOT NULL
    GROUP BY T1.SAP_MATERIAL_CODE, 
             T1.MATERIAL_DESC_JA, 
             T1.EAN_UPC, 
             T1.NET_WGT, 
             T1.SAP_WGT_UNIT_CODE;

/*-*/
/* Authority
/*-*/
grant select on dw_app.tdu_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym tdu_view for dw_app.tdu_view;


