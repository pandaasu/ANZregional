/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : rep_item_view
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
create or replace force view rep_item_view
   (SAP_MATERIAL_CODE,
    MATERIAL_DESC_JA,
    SAP_REP_ITEM_CODE,
    REP_ITEM_DESC_JA, 
    TDU_SAP_CODE,
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
   SELECT T1.SAP_MATERIAL_CODE,
          T1.MATERIAL_DESC_JA,
          T1.SAP_REP_ITEM_CODE,
          T1.REP_ITEM_DESC_JA,
          T2.TDU_SAP_CODE,
          T2.TDU_DESC,
          T2.TDU_JAN,
          T2.TDU_NET_WGT,
          T2.TDU_WGT_UNIT,
          T2.MCU_SAP_CODE,
          T2.MCU_DESC,
          T2.MCU_JAN,
          T2.MCU_NET_WGT,
          T2.MCU_WGT_UNIT,
          T2.TDU_TO_MCU_QTY,
          T2.RSU_SAP_CODE,
          T2.RSU_DESC,
          T2.RSU_JAN,
          T2.RSU_NET_WGT,
          T2.RSU_WGT_UNIT,
          T2.TDU_TO_RSU_QTY
     FROM DD.MATERIAL_DIM T1,
          DW_APP.TDU_MCU_RSU_VIEW T2
    WHERE T1.SAP_REP_ITEM_CODE(+) = T2.TDU_SAP_CODE;

/*-*/
/* Authority
/*-*/
grant select on dw_app.rep_item_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym rep_item_view for dw_app.rep_item_view;

