/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : ftr_chain_list_view
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
create or replace force view ftr_app.ftr_chain_list_view
   (SAP_MATERIAL_CODE_TDU, EAN_UPC_TDU, MATERIAL_DESC_TDU, SAP_MATERIAL_CODE_MCU, EAN_UPC_MCU, 
 MATERIAL_DESC_MCU, QTY_TDU_MCU, SAP_MATERIAL_CODE_RSU, EAN_UPC_RSU, MATERIAL_DESC_RSU, 
 QTY_TDU_RSU, SAP_BRAND_S_FLAG_CODE, BRAND_FLAG_S_DESC, SAP_CNS_SIZE_QTY_CODE, CNS_SIZE_QTY_DESC, 
 SAP_FNC_ING_VRTY_CODE, FNC_ING_VRTY_DESC, SAP_CTGRY_SUPPLY_CODE, PRDCT_CTGRY_SUPPLY_DESC, SAP_MKT_SGMNT_CODE, 
 MKT_SGMNT_DESC, SAP_BUS_SGMNT_CODE, BUS_SGMNT_DESC, VALID_FROM_DATE)
AS 
SELECT
    TDU_DIM.SAP_MATERIAL_CODE AS SAP_MATERIAL_CODE_TDU,
    TDU_DIM.EAN_UPC AS EAN_UPC_TDU,
    TDU_DIM.MATERIAL_DESC_JA AS MATERIAL_DESC_TDU,
    MCU_DIM.SAP_MATERIAL_CODE AS SAP_MATERIAL_CODE_MCU,
    MCU_DIM.EAN_UPC AS EAN_UPC_MCU,
    MCU_DIM.MATERIAL_DESC_JA AS MATERIAL_DESC_MCU,
    ATMP.TM_QTY AS QTY_TDU_MCU,
    RSU_DIM.SAP_MATERIAL_CODE AS SAP_MATERIAL_CODE_RSU,
    RSU_DIM.EAN_UPC AS EAN_UPC_RSU,
    RSU_DIM.MATERIAL_DESC_JA AS MATERIAL_DESC_RSU,
    ATMP.TR_QTY AS QTY_TDU_RSU,
    SUBSTRB(
         NVL(TDU_DIM.SAP_BRAND_FLAG_CODE, '000') || 
         NVL(TDU_DIM.SAP_BRAND_SUB_FLAG_CODE, '000'), 1, 8) AS SAP_BRAND_S_FLAG_CODE,
    NVL(SUBSTRB(
         RTRIM(LTRIM(REPLACE(RTRIM(TDU_DIM.BRAND_FLAG_DESC), 'Not Applicable', '') || 
         ' ' || 
         REPLACE(RTRIM(TDU_DIM.BRAND_SUB_FLAG_DESC), 'Not Applicable', ''))), 1, 60), 'Not Applicable') AS BRAND_FLAG_S_DESC,
    SUBSTRB(
         NVL(TDU_DIM.SAP_CNSMR_PACK_FRMT_CODE, '000') || 
         NVL(TDU_DIM.SAP_PRDCT_PACK_SIZE_CODE, '000') || 
         NVL(TDU_DIM.SAP_MULTI_PACK_QTY_CODE, '00'), 1, 8) AS SAP_CNS_SIZE_QTY_CODE,
    NVL(SUBSTRB(
         RTRIM(LTRIM(REPLACE(RTRIM(TDU_DIM.CNSMR_PACK_FRMT_DESC), 'Not Applicable', '') || 
         ' ' || 
         REPLACE(RTRIM(TDU_DIM.PRDCT_PACK_SIZE_DESC), 'Not Applicable', '') || 
         ' ' || 
         REPLACE(RTRIM(TDU_DIM.MULTI_PACK_QTY_DESC), 'Not Applicable', ''))), 1, 60), 'Not Applicable') AS CNS_SIZE_QTY_DESC,
    SUBSTRB(
        NVL(TDU_DIM.SAP_FUNCL_VRTY_CODE, '000') || 
        NVL(TDU_DIM.SAP_INGRED_VRTY_CODE, '0000'), 1, 8) AS SAP_FNC_ING_VRTY_CODE,
    NVL(SUBSTRB(
        RTRIM(LTRIM(REPLACE(RTRIM(TDU_DIM.FUNCL_VRTY_DESC), 'Not Applicable', '') || 
         ' ' || 
        REPLACE(RTRIM(TDU_DIM.INGRED_VRTY_DESC), 'Not Applicable', ''))), 1, 60), 'Not Applicable') AS FNC_ING_VRTY_DESC,
    SUBSTRB(
         NVL(TDU_DIM.SAP_MKT_SGMNT_CODE, '00') || 
         NVL(TDU_DIM.SAP_PRDCT_CTGRY_CODE, '000') || 
         NVL(TDU_DIM.SAP_SUPPLY_SGMNT_CODE, '000'), 1, 8) AS SAP_CTGRY_SUPPLY_CODE,
    NVL(SUBSTRB(
         RTRIM(LTRIM(REPLACE(RTRIM(TDU_DIM.MKT_SGMNT_DESC), 'Not Applicable', '') || 
         ' ' || 
         REPLACE(RTRIM(TDU_DIM.PRDCT_CTGRY_DESC), 'Not Applicable', '') || 
         ' ' || 
         REPLACE(RTRIM(TDU_DIM.SUPPLY_SGMNT_DESC), 'Not Applicable', ''))), 1, 60), 'Not Applicable') AS PRDCT_CTGRY_SUPPLY_DESC,
    NVL(TDU_DIM.SAP_MKT_SGMNT_CODE, '00') AS SAP_MKT_SGMNT_CODE,
    NVL(TDU_DIM.MKT_SGMNT_DESC, 'Not Applicable') AS MKT_SGMNT_DESC,
    NVL(TDU_DIM.SAP_BUS_SGMNT_CODE, '00') AS SAP_BUS_SGMNT_CODE,
    NVL(TDU_DIM.BUS_SGMNT_DESC, 'Not Applicable') AS BUS_SGMNT_DESC,
    TO_NUMBER(TO_CHAR(ATMP.VALID_FROM_DATE, 'YYYYMMDD')) AS VALID_FROM_DATE
FROM
    DD.MATERIAL_DIM TDU_DIM,
    DD.MATERIAL_DIM MCU_DIM,
    DD.MATERIAL_DIM RSU_DIM,
    (SELECT
        TDU_SAP_CODE,
        MCU_SAP_CODE,
        CASE
            WHEN TM_QTY >= 1000 THEN TM_QTY /1000
            ELSE TM_QTY
        END TM_QTY,
        RSU_SAP_CODE,
        CASE
            WHEN TR_QTY >= 1000 THEN TR_QTY / 1000
            ELSE TR_QTY
        END TR_QTY,
        VALID_FROM_DATE
    FROM
        FTR_APP.FTR_CHAIN_CORE_VIEW
    UNION
    SELECT
        V1.TDU_SAP_CODE,
        NULL AS MCU_SAP_CODE,
        TO_NUMBER(NULL) AS TM_QTY,
        V1.TDU_SAP_CODE AS RSU_SAP_CODE,
        TO_NUMBER(1) AS TR_QTY,
        ODM.MATERIAL_LUPDT AS VALID_FROM_DATE
    FROM
        (SELECT
            DMD.SAP_MATERIAL_CODE  AS TDU_SAP_CODE,
            DMD.EAN_UPC            AS TDU_EAN_UPC
        FROM
            DD.MATERIAL_DIM DMD
        WHERE
            DMD.MATERIAL_TYPE_FLAG_TDU = 'Y' AND
            DMD.MATERIAL_TYPE_FLAG_RSU = 'Y' AND
            DMD.MATERIAL_TYPE_FLAG_REP = 'N' AND
            DMD.SAP_REP_ITEM_CODE IS NOT NULL AND
            DMD.EAN_UPC IS NOT NULL AND
            DMD.MATERIAL_DESC_JA IS NOT NULL
        ) V1,
        OD.MATERIAL ODM
    WHERE
        ODM.SAP_MATERIAL_CODE = V1.TDU_SAP_CODE
    ) ATMP
WHERE
    TDU_DIM.SAP_MATERIAL_CODE = ATMP.TDU_SAP_CODE AND
    MCU_DIM.SAP_MATERIAL_CODE(+) = ATMP.MCU_SAP_CODE AND
    RSU_DIM.SAP_MATERIAL_CODE = ATMP.RSU_SAP_CODE AND
    TDU_DIM.SAP_BUS_SGMNT_CODE = '05'
WITH READ ONLY;

/*-*/
/* Authority
/*-*/
grant select on ftr_app.ftr_chain_list_view to ftr_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ftr_chain_list_view for ftr_app.ftr_chain_list_view;