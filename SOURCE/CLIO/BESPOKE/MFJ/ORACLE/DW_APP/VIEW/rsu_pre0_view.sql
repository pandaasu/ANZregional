/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : rsu_pre0_view
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
create or replace force view rsu_pre0_view
   (SAP_MATERIAL_CODE,
    MATERIAL_DESC_JA,
    EAN_UPC,
    NET_WGT, 
    SAP_WGT_UNIT_CODE) AS 
   SELECT T1.SAP_MATERIAL_CODE, 
          T1.MATERIAL_DESC_JA, 
          T1.EAN_UPC, 
          T1.NET_WGT, 
          T1.SAP_WGT_UNIT_CODE 
     FROM MATERIAL_DIM T1
    WHERE T1.MATERIAL_TYPE_FLAG_RSU = 'Y'
      AND T1.MATERIAL_TYPE_FLAG_MCU != 'Y'
      AND T1.MATERIAL_TYPE_FLAG_TDU != 'Y'
      AND T1.MATERIAL_DESC_JA IS NOT NULL
    GROUP BY T1.SAP_MATERIAL_CODE, 
             T1.MATERIAL_DESC_JA, 
             T1.EAN_UPC, 
             T1.NET_WGT, 
             T1.SAP_WGT_UNIT_CODE;

/*-*/
/* Authority
/*-*/
grant select on dw_app.rsu_pre0_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym rsu_pre0_view for dw_app.rsu_pre0_view;