/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : ftr_material_hier_view2
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
create or replace force view ftr_app.ftr_material_hier_view2
   (BUS_SGMNT_CODE, BUS_SGMNT_DESC, BUS_SGMNT_ABBRD_DESC, MKT_SGMNT_CODE, MKT_SGMNT_DESC, 
 MKT_SGMNT_ABBRD_DESC, PRD_CATE_CODE, PRD_CATE_DESC, PRD_CATE_ABBRD_DESC, BRAND_CODE, 
 BRAND_DESC, BRAND_ABBRD_DESC, PACK_SIZE_CODE, PACK_SIZE_DESC, PACK_SIZE_ABBRD_DESC, 
 VARIETY_CODE, VARIETY_DESC, VARIETY_ABBRD_DESC, TDU_MATERIAL_CODE, 
 TDU_MATERIAL_DESC, TDU_MATERIAL_DESC_EN, TDU_EAN_UPC, RSU_MATERIAL_CODE, 
 RSU_MATERIAL_DESC, RSU_MATERIAL_DESC_EN, RSU_EAN_UPC, RSU_GROSS_WGT, RSU_VOL)
AS 
SELECT
    NVL(DMD3.SAP_BUS_SGMNT_CODE, '00') AS BUS_SGMNT_CODE,
    NVL(DMD3.BUS_SGMNT_DESC, 'Not Applicable') AS BUS_SGMNT_DESC,
    NVL(DMD3.BUS_SGMNT_ABBRD_DESC, 'NA') AS BUS_SGMNT_ABBRD_DESC,
    NVL(DMD3.SAP_MKT_SGMNT_CODE, '00') AS MKT_SGMNT_CODE,
    NVL(DMD3.MKT_SGMNT_DESC, 'Not Applicable') AS MKT_SGMNT_DESC,
    NVL(DMD3.MKT_SGMNT_ABBRD_DESC, 'NA') AS MKT_SGMNT_ABBRD_DESC,
    SUBSTRB(
         NVL(DMD3.SAP_MKT_SGMNT_CODE, '00') || 
         NVL(DMD3.SAP_PRDCT_CTGRY_CODE, '000') || 
         NVL(DMD3.SAP_SUPPLY_SGMNT_CODE, '000'), 1, 8) AS PRD_CATE_CODE,
    NVL(SUBSTRB(
         RTRIM(LTRIM(REPLACE(RTRIM(DMD3.MKT_SGMNT_DESC), 'Not Applicable', '') || 
         ' ' || 
         REPLACE(RTRIM(DMD3.PRDCT_CTGRY_DESC), 'Not Applicable', '') || 
         ' ' || 
         REPLACE(RTRIM(DMD3.SUPPLY_SGMNT_DESC), 'Not Applicable', ''))), 1, 60), 'Not Applicable') AS PRD_CATE_DESC,
    NVL(SUBSTRB(
         RTRIM(LTRIM(REPLACE(RTRIM(DMD3.MKT_SGMNT_ABBRD_DESC), 'NA', '') || 
         ' ' || 
         REPLACE(RTRIM(DMD3.PRDCT_CTGRY_ABBRD_DESC), 'NA', '') || 
         ' ' || 
         REPLACE(RTRIM(DMD3.SUPPLY_SGMNT_ABBRD_DESC), 'NA', ''))), 1, 24), 'NA') AS PRD_CATE_ABBRD_DESC,
    SUBSTRB(
         NVL(DMD3.SAP_BRAND_FLAG_CODE, '000') || 
         NVL(DMD3.SAP_BRAND_SUB_FLAG_CODE, '000'), 1, 8) AS BRAND_CODE,
    NVL(SUBSTRB(
         RTRIM(LTRIM(REPLACE(RTRIM(DMD3.BRAND_FLAG_DESC), 'Not Applicable', '') || 
         ' ' || 
         REPLACE(RTRIM(DMD3.BRAND_SUB_FLAG_DESC), 'Not Applicable', ''))), 1, 60), 'Not Applicable') AS BRAND_DESC,
    NVL(SUBSTRB(
         RTRIM(LTRIM(REPLACE(RTRIM(DMD3.BRAND_FLAG_ABBRD_DESC), 'NA', '') || 
         ' ' || 
         REPLACE(RTRIM(DMD3.BRAND_SUB_FLAG_ABBRD_DESC), 'NA', ''))), 1, 24), 'NA') AS BRAND_ABBRD_DESC,
    SUBSTRB(
         NVL(DMD3.SAP_CNSMR_PACK_FRMT_CODE, '000') || 
         NVL(DMD3.SAP_PRDCT_PACK_SIZE_CODE, '000') || 
         NVL(DMD3.SAP_MULTI_PACK_QTY_CODE, '00'), 1, 8) AS PACK_SIZE_CODE,
    NVL(SUBSTRB(
         RTRIM(LTRIM(REPLACE(RTRIM(DMD3.CNSMR_PACK_FRMT_DESC), 'Not Applicable', '') || 
         ' ' || 
         REPLACE(RTRIM(DMD3.PRDCT_PACK_SIZE_DESC), 'Not Applicable', '') || 
         ' ' || 
         REPLACE(RTRIM(DMD3.MULTI_PACK_QTY_DESC), 'Not Applicable', ''))), 1, 60), 'Not Applicable') AS PACK_SIZE_DESC,
    NVL(SUBSTRB(
         RTRIM(LTRIM(REPLACE(RTRIM(DMD3.CNSMR_PACK_FRMT_ABBRD_DESC), 'NA', '') || 
         ' ' || 
         REPLACE(RTRIM(DMD3.PRDCT_PACK_SIZE_ABBRD_DESC), 'NA', '') || 
         ' ' || 
         REPLACE(RTRIM(DMD3.MULTI_PACK_QTY_ABBRD_DESC), 'NA', ''))), 1, 24), 'NA') AS PACK_SIZE_ABBRD_DESC,
    SUBSTRB(
        NVL(DMD3.SAP_FUNCL_VRTY_CODE, '000') || 
        NVL(DMD3.SAP_INGRED_VRTY_CODE, '0000'), 1, 8) AS VARIETY_CODE,
    NVL(SUBSTRB(
        RTRIM(LTRIM(REPLACE(RTRIM(DMD3.FUNCL_VRTY_DESC), 'Not Applicable', '') || 
         ' ' || 
        REPLACE(RTRIM(DMD3.INGRED_VRTY_DESC), 'Not Applicable', ''))), 1, 60), 'Not Applicable') AS VARIETY_DESC,
    NVL(SUBSTRB(
        RTRIM(LTRIM(REPLACE(RTRIM(DMD3.FUNCL_VRTY_ABBRD_DESC), 'NA', '') || 
         ' ' || 
        REPLACE(RTRIM(DMD3.INGRED_VRTY_ABBRD_DESC), 'NA', ''))), 1, 24), 'NA') AS VARIETY_ABBRD_DESC,
    DMD3.SAP_MATERIAL_CODE AS TDU_MATERIAL_CODE,
    DMD3.MATERIAL_DESC_JA AS TDU_MATERIAL_DESC,
    DMD3.MATERIAL_DESC_EN AS TDU_MATERIAL_DESC_EN,
    DMD3.EAN_UPC AS TDU_EAN_UPC,
    DMD3.SAP_MATERIAL_CODE AS RSU_MATERIAL_CODE,
    DMD3.MATERIAL_DESC_JA AS RSU_MATERIAL_DESC,
    DMD3.MATERIAL_DESC_EN AS RSU_MATERIAL_DESC_EN,
    DMD3.EAN_UPC AS RSU_EAN_UPC,
    DMD3.GROSS_WGT AS RSU_GROSS_WGT,
    DMD3.VOL AS RSU_VOL
FROM
    DD.MATERIAL_DIM DMD3,
    (SELECT
        VT1.TDU_SAP_CODE,
        VT1.TDU_EAN_UPC
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
        ) V2,
        (SELECT
            MAX(V1.TDU_SAP_CODE) AS TDU_SAP_CODE,
            V1.TDU_EAN_UPC
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
            ) V1
        GROUP BY
            V1.TDU_EAN_UPC
        ) VT1
    WHERE
        V2.TDU_SAP_CODE = VT1.TDU_SAP_CODE
    GROUP BY
        VT1.TDU_SAP_CODE,
        VT1.TDU_EAN_UPC
    ) VT2
WHERE
    DMD3.SAP_MATERIAL_CODE = VT2.TDU_SAP_CODE AND
    DMD3.SAP_BUS_SGMNT_CODE = '05'
WITH READ ONLY;

/*-*/
/* Authority
/*-*/
grant select on ftr_app.ftr_material_hier_view2 to ftr_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ftr_material_hier_view2 for ftr_app.ftr_material_hier_view2;