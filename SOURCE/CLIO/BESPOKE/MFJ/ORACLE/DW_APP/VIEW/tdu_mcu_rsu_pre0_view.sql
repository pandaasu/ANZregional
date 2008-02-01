/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : tdu_mcu_rsu_pre0_view
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
create or replace force view tdu_mcu_rsu_pre0_view
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
   SELECT T1.TDU_SAP_CODE,
          T1.TDU_DESC,
          T1.TDU_JAN,
          T1.TDU_NET_WGT,
          T1.TDU_WGT_UNIT,
          T2.MCU_SAP_CODE,
          T2.MCU_DESC,
          T2.MCU_JAN,
          T2.MCU_NET_WGT,
          T2.MCU_WGT_UNIT,
          T2.TDU_TO_MCU_QTY,
          T3.RSU_SAP_CODE,
          T3.RSU_DESC,
          T3.RSU_JAN,
          T3.RSU_NET_WGT,
          T3.RSU_WGT_UNIT,
          T3.TDU_TO_RSU_QTY
     FROM DW_APP.TDU_VIEW T1,
          DW_APP.TDU_MCU_VIEW T2,
          DW_APP.TDU_RSU_VIEW T3
    WHERE T1.TDU_SAP_CODE=T2.TDU_SAP_CODE(+)
      AND T1.TDU_SAP_CODE=T3.TDU_SAP_CODE(+);

/*-*/
/* Authority
/*-*/
grant select on dw_app.tdu_mcu_rsu_pre0_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym tdu_mcu_rsu_pre0_view for dw_app.tdu_mcu_rsu_pre0_view;

