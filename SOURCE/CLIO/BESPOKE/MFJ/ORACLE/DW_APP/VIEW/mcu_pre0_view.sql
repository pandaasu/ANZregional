/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : mcu_pre0_view
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
create or replace force view mcu_pre0_view
   (SAP_MATERIAL_CODE,
    MATERIAL_DESC_JA,
    EAN_UPC, NET_WGT, 
    SAP_WGT_UNIT_CODE) AS 
   SELECT SAP_MATERIAL_CODE, 
          MATERIAL_DESC_JA, 
          EAN_UPC, 
          NET_WGT, 
          SAP_WGT_UNIT_CODE 
     FROM MATERIAL_DIM
    WHERE MATERIAL_TYPE_FLAG_MCU = 'Y'
      AND MATERIAL_DESC_JA IS NOT NULL
    GROUP BY SAP_MATERIAL_CODE, 
             MATERIAL_DESC_JA, 
             EAN_UPC, 
             NET_WGT, 
             SAP_WGT_UNIT_CODE;

/*-*/
/* Authority
/*-*/
grant select on dw_app.mcu_pre0_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym mcu_pre0_view for dw_app.mcu_pre0_view;
