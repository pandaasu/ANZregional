/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : ftr_chain_core_view
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
create or replace force view ftr_app.ftr_chain_core_view
   (TDU_SAP_CODE, MCU_SAP_CODE, TM_QTY, RSU_SAP_CODE, TR_QTY, 
 VALID_FROM_DATE)
AS 
SELECT
    RSU_TEMP.TDU_SAP_CODE,
    MCU_TEMP.MCU_SAP_CODE,
    MCU_TEMP.TM_QTY,
    RSU_TEMP.RSU_SAP_CODE,
    RSU_TEMP.TR_QTY,
    RSU_TEMP.VALID_FROM_DATE
FROM
    (SELECT DISTINCT
        MCU_M_TEMP.TDU_SAP_CODE,
        MCU_M_TEMP.MCU_SAP_CODE,
        MCH.CMPNT_QTY AS TM_QTY
    FROM
        MATERIAL_CHAIN MCH,
        (SELECT
            VV1.SAP_MATERIAL_CODE     AS TDU_SAP_CODE,
            VV2.SAP_MATERIAL_CODE     AS MCU_SAP_CODE,
            MAX(VV3.MATERIAL_CHAIN_VALID_FROM_DATE) AS VALID_FROM_DATE
        FROM
            (SELECT
                V1.SAP_MATERIAL_CODE
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
                V2.SAP_MATERIAL_CODE
            FROM
                MATERIAL_DIM V2
            WHERE
                V2.MATERIAL_TYPE_FLAG_MCU = 'Y' AND
                V2.MATERIAL_DESC_JA IS NOT NULL AND
                V2.EAN_UPC IS NOT NULL
            ) VV2,
            MATERIAL_CHAIN VV3
        WHERE
            VV1.SAP_MATERIAL_CODE = VV3.SAP_MATERIAL_CODE AND
            VV2.SAP_MATERIAL_CODE = VV3.CMPNT_MATERIAL_CODE
        GROUP BY 
            VV1.SAP_MATERIAL_CODE,
            VV2.SAP_MATERIAL_CODE
    ) MCU_M_TEMP
    WHERE
        MCH.SAP_MATERIAL_CODE = MCU_M_TEMP.TDU_SAP_CODE AND
        MCH.CMPNT_MATERIAL_CODE = MCU_M_TEMP.MCU_SAP_CODE AND
        MCH.MATERIAL_CHAIN_VALID_FROM_DATE = VALID_FROM_DATE
    ) MCU_TEMP,
    (SELECT DISTINCT
        RSU_M_TEMP.TDU_SAP_CODE,
        RSU_M_TEMP.RSU_SAP_CODE,
        MCH.CMPNT_QTY AS TR_QTY,
        RSU_M_TEMP.VALID_FROM_DATE
    FROM
        MATERIAL_CHAIN MCH,
        (SELECT
            VV1.SAP_MATERIAL_CODE     AS TDU_SAP_CODE,
            VV2.SAP_MATERIAL_CODE     AS RSU_SAP_CODE,
            MAX(VV3.MATERIAL_CHAIN_VALID_FROM_DATE) AS VALID_FROM_DATE
        FROM
            (SELECT
                V1.SAP_MATERIAL_CODE
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
                V2.SAP_MATERIAL_CODE
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
        GROUP BY 
            VV1.SAP_MATERIAL_CODE,
            VV2.SAP_MATERIAL_CODE
        ) RSU_M_TEMP
    WHERE
        MCH.SAP_MATERIAL_CODE = RSU_M_TEMP.TDU_SAP_CODE AND
        MCH.CMPNT_MATERIAL_CODE = RSU_M_TEMP.RSU_SAP_CODE AND
        MCH.MATERIAL_CHAIN_VALID_FROM_DATE = VALID_FROM_DATE
    ) RSU_TEMP
WHERE
    RSU_TEMP.TDU_SAP_CODE = MCU_TEMP.TDU_SAP_CODE(+)
WITH READ ONLY;

/*-*/
/* Authority
/*-*/
grant select on ftr_app.ftr_chain_core_view to ftr_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ftr_chain_core_view for ftr_app.ftr_chain_core_view;