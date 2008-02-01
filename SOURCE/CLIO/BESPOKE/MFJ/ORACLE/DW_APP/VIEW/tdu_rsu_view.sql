/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : tdu_rsu_view
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
create or replace force view tdu_rsu_view
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
    RSU_DESC, RSU_JAN, 
    RSU_NET_WGT,
    RSU_WGT_UNIT,
    TDU_TO_RSU_QTY) AS 
   SELECT T1.TDU_SAP_CODE,
          T1.TDU_DESC,
          T1.TDU_JAN,
          T1.TDU_NET_WGT,
          T1.TDU_WGT_UNIT,
          T1.TDU_TO_MCU_QTY,
          T1.MCU_SAP_CODE,
          T1.MCU_DESC,
          T1.MCU_JAN,
          T1.MCU_NET_WGT,
          T1.MCU_WGT_UNIT,
          T1.MCU_TO_RSU_QTY,
          T1.RSU_SAP_CODE,
          T1.RSU_DESC,
          T1.RSU_JAN,
          T1.RSU_NET_WGT,
          T1.RSU_WGT_UNIT,
          T1.TDU_TO_RSU_QTY
     FROM DW_APP.TDU_RSU_PRE0_VIEW T1;

/*-*/
/* Authority
/*-*/
grant select on dw_app.tdu_rsu_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym tdu_rsu_view for dw_app.tdu_rsu_view;
