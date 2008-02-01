/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : tdu_mcu_rsu_pre2_view
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
create or replace force view tdu_mcu_rsu_pre2_view
   (TDU_SAP_CODE,
    TDU_DESC,
    TDU_JAN,
    TDU_NET_WGT,
    TDU_WGT_UNIT,
    MCU_SAP_CODE,
    MCU_DESC,
    MCU_JAN,
    MCU_NET_WGT,
    MCU_WGT_UNIT, 
    TDU_TO_MCU_QTY,
    RSU_SAP_CODE,
    RSU_DESC,
    RSU_JAN,
    RSU_NET_WGT, 
    RSU_WGT_UNIT,
    TDU_TO_RSU_QTY) AS 
   SELECT T4.TDU_SAP_CODE,
          T4.TDU_DESC,
          T4.TDU_JAN,
          T4.TDU_NET_WGT,
          T4.TDU_WGT_UNIT,
          T4.MCU_SAP_CODE,
          T4.MCU_DESC,
          T4.MCU_JAN,
          T4.MCU_NET_WGT,
          T4.MCU_WGT_UNIT,
          T4.TDU_TO_MCU_QTY,
          T4.RSU_SAP_CODE,
          T4.RSU_DESC,
          T4.RSU_JAN,
          T4.RSU_NET_WGT,
          T4.RSU_WGT_UNIT,
          T4.TDU_TO_RSU_QTY
     FROM DW_APP.TDU_MCU_RSU_PRE0_VIEW T4
    WHERE T4.TDU_SAP_CODE IN (SELECT T3.SAP_MATERIAL_CODE
                                FROM DD.MATERIAL_DIM T3
                               WHERE T3.SAP_MATERIAL_CODE IN (SELECT TDU_SAP_CODE
                                                                FROM DW_APP.TDU_MCU_RSU_PRE0_VIEW) AND
                                     ((T3.MATERIAL_TYPE_FLAG_TDU  = 'Y' AND T3.MATERIAL_TYPE_FLAG_RSU != 'Y') OR
                                      (T3.MATERIAL_TYPE_FLAG_TDU != 'Y' AND T3.MATERIAL_TYPE_FLAG_RSU  = 'Y')));

/*-*/
/* Authority
/*-*/
grant select on dw_app.tdu_mcu_rsu_pre2_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym tdu_mcu_rsu_pre2_view for dw_app.tdu_mcu_rsu_pre2_view;

