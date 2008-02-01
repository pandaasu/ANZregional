/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : tdu_rsu_pst0_view
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
create or replace force view tdu_rsu_pst0_view
   (TDU_SAP_CODE,
    TDU_DESC,
    TDU_JAN,
    TDU_NET_WGT,
    TDU_TO_MCU_QTY, 
    MCU_SAP_CODE,
    MCU_DESC,
    MCU_JAN,
    MCU_NET_WGT,
    MCU_TO_RSU_QTY, 
    RSU_SAP_CODE,
    RSU_DESC,
    RSU_JAN,
    RSU_NET_WGT,
    RSU_WGT_UNIT, 
    MATERIAL_CHAIN_LUPDT) AS 
   SELECT TDU_SAP_CODE,
          TDU_DESC,
          TDU_JAN,
          TDU_NET_WGT,
          TDU_TO_MCU_QTY,
          MCU_SAP_CODE,
          MCU_DESC,
          MCU_JAN,
          MCU_NET_WGT,
          MCU_TO_RSU_QTY,
          RSU_SAP_CODE, 
          RSU_DESC, 
          RSU_JAN, 
          RSU_NET_WGT, 
          RSU_WGT_UNIT, 
          MAX(MATERIAL_CHAIN_LUPDT) AS MATERIAL_CHAIN_LUPDT
     FROM (SELECT D.SAP_MATERIAL_CODE AS TDU_SAP_CODE,
                  D.MATERIAL_DESC_JA AS TDU_DESC, 
                  D.EAN_UPC AS TDU_JAN, 
                  D.NET_WGT AS TDU_NET_WGT, 
                  D.SAP_WGT_UNIT_CODE AS TDU_WGT_UNIT, 
                  0 AS TDU_TO_MCU_QTY,
                  NULL AS MCU_SAP_CODE,
                  NULL AS MCU_DESC,
                  NULL AS MCU_JAN,
                  0 AS MCU_NET_WGT,
                  0 AS MCU_WGT_UNIT,
                  0 AS MCU_TO_RSU_QTY,
                  E.SAP_MATERIAL_CODE AS RSU_SAP_CODE, 
                  E.MATERIAL_DESC_JA AS RSU_DESC, 
                  E.EAN_UPC AS RSU_JAN, 
                  E.NET_WGT AS RSU_NET_WGT, 
                  E.SAP_WGT_UNIT_CODE AS RSU_WGT_UNIT, 
                  (F.CMPNT_QTY)/1000 AS TDU_TO_RSU_QTY,
                  MAX(F.MATERIAL_CHAIN_LUPDT) AS MATERIAL_CHAIN_LUPDT
             FROM (SELECT T3.MATERIAL_CODE, 
                          T3.SAP_MATERIAL_CODE, 
                          T3.MATERIAL_DESC_JA, 
                          T3.EAN_UPC, 
                          T3.NET_WGT, 
                          T3.SAP_WGT_UNIT_CODE 
                     FROM DW_APP.TDU_PRE0_VIEW T3) D, 
                  (SELECT T4.MATERIAL_CODE, 
                          T4.SAP_MATERIAL_CODE, 
                          T4.MATERIAL_DESC_JA, 
                          T4.EAN_UPC, 
                          T4.NET_WGT, 
                          T4.SAP_WGT_UNIT_CODE 
                     FROM DW_APP.RSU_PRE0_VIEW T4) E, 
                  DW_APP.MATERIAL_CHAIN_PRE0_VIEW F 
            WHERE D.MATERIAL_CODE = F.MATERIAL_CHAIN_CODE AND 
                  F.CMPNT_MATERIAL_CODE = E.MATERIAL_CODE
         GROUP BY D.SAP_MATERIAL_CODE, 
                   D.MATERIAL_DESC_JA, 
                  D.EAN_UPC, 
                  D.NET_WGT, 
                  D.SAP_WGT_UNIT_CODE, 
                  E.SAP_MATERIAL_CODE, 
                  E.MATERIAL_DESC_JA, 
                  E.EAN_UPC, 
                  E.NET_WGT, 
                  E.SAP_WGT_UNIT_CODE,
                  (F.CMPNT_QTY)/1000)
    GROUP BY TDU_SAP_CODE,
             TDU_DESC,
             TDU_JAN,
             TDU_NET_WGT,
             TDU_TO_MCU_QTY,
             MCU_SAP_CODE,
             MCU_DESC,
             MCU_JAN,
             MCU_NET_WGT,
             MCU_TO_RSU_QTY,
             RSU_SAP_CODE, 
             RSU_DESC, 
             RSU_JAN, 
             RSU_NET_WGT, 
             RSU_WGT_UNIT;

/*-*/
/* Authority
/*-*/
grant select on dw_app.tdu_rsu_pst0_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym tdu_rsu_pst0_view for dw_app.tdu_rsu_pst0_view;



