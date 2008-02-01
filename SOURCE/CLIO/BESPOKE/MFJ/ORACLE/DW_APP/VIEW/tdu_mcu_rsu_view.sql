/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : tdu_mcu_rsu_view
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
create or replace force view tdu_mcu_rsu_view
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
   SELECT PRE2.TDU_SAP_CODE,
          PRE2.TDU_DESC,
          PRE2.TDU_JAN,
          PRE2.TDU_NET_WGT,
          PRE2.TDU_WGT_UNIT,
          PRE2.MCU_SAP_CODE,
          PRE2.MCU_DESC,
          PRE2.MCU_JAN,
          PRE2.MCU_NET_WGT,
          PRE2.MCU_WGT_UNIT,
          PRE2.TDU_TO_MCU_QTY,
          PRE2.RSU_SAP_CODE,
          PRE2.RSU_DESC,
          PRE2.RSU_JAN,
          PRE2.RSU_NET_WGT,
          PRE2.RSU_WGT_UNIT,
          PRE2.TDU_TO_RSU_QTY
     FROM DW_APP.TDU_MCU_RSU_PRE2_VIEW PRE2
    UNION ALL
   SELECT PRE1.TDU_SAP_CODE,
          PRE1.TDU_DESC,
          PRE1.TDU_JAN,
          PRE1.TDU_NET_WGT,
          PRE1.TDU_WGT_UNIT,
          PRE1.MCU_SAP_CODE,
          PRE1.MCU_DESC,
          PRE1.MCU_JAN,
          PRE1.MCU_NET_WGT,
          PRE1.MCU_WGT_UNIT,
          PRE1.TDU_TO_MCU_QTY,
          PRE1.RSU_SAP_CODE,
          PRE1.RSU_DESC,
          PRE1.RSU_JAN,
          PRE1.RSU_NET_WGT,
          PRE1.RSU_WGT_UNIT,
          PRE1.TDU_TO_RSU_QTY
     FROM DW_APP.TDU_MCU_RSU_PRE1_VIEW PRE1;

/*-*/
/* Authority
/*-*/
grant select on dw_app.tdu_mcu_rsu_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym tdu_mcu_rsu_view for dw_app.tdu_mcu_rsu_view;

