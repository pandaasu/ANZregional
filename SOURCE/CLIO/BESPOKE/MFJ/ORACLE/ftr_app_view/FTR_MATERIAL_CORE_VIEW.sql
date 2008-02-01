/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : ftr_material_core_view
 Owner  : ftr_app

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
create or replace force view ftr_app.ftr_material_core_view
   (TDU_SAP_CODE, TDU_EAN_UPC, RSU_SAP_CODE, 
 RSU_EAN_UPC, VALID_FROM_DATE)
AS 
SELECT
    VV1.SAP_MATERIAL_CODE AS TDU_SAP_CODE,
    VV1.EAN_UPC           AS TDU_EAN_UPC,
    VV2.SAP_MATERIAL_CODE AS RSU_SAP_CODE,
    VV2.EAN_UPC           AS RSU_EAN_UPC,
    VV3.MATERIAL_CHAIN_VALID_FROM_DATE AS VALID_FROM_DATE
FROM
    (SELECT
        V1.SAP_MATERIAL_CODE,
        V1.EAN_UPC
    FROM
        MATERIAL_DIM V1
    WHERE
        V1.MATERIAL_TYPE_FLAG_TDU = 'Y' AND
        V1.MATERIAL_TYPE_FLAG_RSU = 'N' AND
        V1.MATERIAL_TYPE_FLAG_REP = 'N' AND
        V1.SAP_REP_ITEM_CODE IS NOT NULL AND
        V1.MATERIAL_DESC_JA IS NOT NULL
    ) VV1,
    (SELECT
        V2.SAP_MATERIAL_CODE,
        V2.EAN_UPC
    FROM
        MATERIAL_DIM V2
    WHERE
        V2.MATERIAL_TYPE_FLAG_RSU = 'Y' AND
        V2.MATERIAL_DESC_JA IS NOT NULL AND
        V2.EAN_UPC IS NOT NULL
    ) VV2,
    MATERIAL_CHAIN VV3
WHERE
    VV1.SAP_MATERIAL_CODE = VV3.SAP_MATERIAL_CODE AND
    VV2.SAP_MATERIAL_CODE = VV3.CMPNT_MATERIAL_CODE
WITH READ ONLY;

/*-*/
/* Authority
/*-*/
grant select on ftr_app.ftr_material_core_view to ftr_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ftr_material_core_view for ftr_app.ftr_material_core_view;