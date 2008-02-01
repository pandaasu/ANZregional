/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : ftr_material_hier_view1
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
create or replace force view ftr_app.ftr_material_hier_view1
   (BUS_SGMNT_CODE, BUS_SGMNT_DESC, BUS_SGMNT_ABBRD_DESC, MKT_SGMNT_CODE, MKT_SGMNT_DESC, 
 MKT_SGMNT_ABBRD_DESC, PRD_CATE_CODE, PRD_CATE_DESC, PRD_CATE_ABBRD_DESC, BRAND_CODE, 
 BRAND_DESC, BRAND_ABBRD_DESC, PACK_SIZE_CODE, PACK_SIZE_DESC, PACK_SIZE_ABBRD_DESC, 
 VARIETY_CODE, VARIETY_DESC, VARIETY_ABBRD_DESC, TDU_MATERIAL_CODE, 
 TDU_MATERIAL_DESC, TDU_MATERIAL_DESC_EN, TDU_EAN_UPC, RSU_MATERIAL_CODE, 
 RSU_MATERIAL_DESC, RSU_MATERIAL_DESC_EN, RSU_EAN_UPC, RSU_GROSS_WGT, RSU_VOL)
AS 
SELECT
    NVL(MD_TDU.SAP_BUS_SGMNT_CODE, '00') AS BUS_SGMNT_CODE,
    NVL(MD_TDU.BUS_SGMNT_DESC, 'Not Applicable') AS BUS_SGMNT_DESC,
    NVL(MD_TDU.BUS_SGMNT_ABBRD_DESC, 'NA') AS BUS_SGMNT_ABBRD_DESC,
    NVL(MD_TDU.SAP_MKT_SGMNT_CODE, '00') AS MKT_SGMNT_CODE,
    NVL(MD_TDU.MKT_SGMNT_DESC, 'Not Applicable') AS MKT_SGMNT_DESC,
    NVL(MD_TDU.MKT_SGMNT_ABBRD_DESC, 'NA') AS MKT_SGMNT_ABBRD_DESC,
    SUBSTRB(
         NVL(MD_TDU.SAP_MKT_SGMNT_CODE, '00') || 
         NVL(MD_TDU.SAP_PRDCT_CTGRY_CODE, '000') || 
         NVL(MD_TDU.SAP_SUPPLY_SGMNT_CODE, '000'), 1, 8) AS PRD_CATE_CODE,
    NVL(SUBSTRB(
         RTRIM(LTRIM(REPLACE(RTRIM(MD_TDU.MKT_SGMNT_DESC), 'Not Applicable', '') || 
         ' ' || 
         REPLACE(RTRIM(MD_TDU.PRDCT_CTGRY_DESC), 'Not Applicable', '') || 
         ' ' || 
         REPLACE(RTRIM(MD_TDU.SUPPLY_SGMNT_DESC), 'Not Applicable', ''))), 1, 60), 'Not Applicable') AS PRD_CATE_DESC,
    NVL(SUBSTRB(
         RTRIM(LTRIM(REPLACE(RTRIM(MD_TDU.MKT_SGMNT_ABBRD_DESC), 'NA', '') || 
         ' ' || 
         REPLACE(RTRIM(MD_TDU.PRDCT_CTGRY_ABBRD_DESC), 'NA', '') || 
         ' ' || 
         REPLACE(RTRIM(MD_TDU.SUPPLY_SGMNT_ABBRD_DESC), 'NA', ''))), 1, 24), 'NA') AS PRD_CATE_ABBRD_DESC,
    SUBSTRB(
         NVL(MD_TDU.SAP_BRAND_FLAG_CODE, '000') || 
         NVL(MD_TDU.SAP_BRAND_SUB_FLAG_CODE, '000'), 1, 8) AS BRAND_CODE,
    NVL(SUBSTRB(
         RTRIM(LTRIM(REPLACE(RTRIM(MD_TDU.BRAND_FLAG_DESC), 'Not Applicable', '') || 
         ' ' || 
         REPLACE(RTRIM(MD_TDU.BRAND_SUB_FLAG_DESC), 'Not Applicable', ''))), 1, 60), 'Not Applicable') AS BRAND_DESC,
    NVL(SUBSTRB(
         RTRIM(LTRIM(REPLACE(RTRIM(MD_TDU.BRAND_FLAG_ABBRD_DESC), 'NA', '') || 
         ' ' || 
         REPLACE(RTRIM(MD_TDU.BRAND_SUB_FLAG_ABBRD_DESC), 'NA', ''))), 1, 24), 'NA') AS BRAND_ABBRD_DESC,
    SUBSTRB(
         NVL(MD_TDU.SAP_CNSMR_PACK_FRMT_CODE, '000') || 
         NVL(MD_TDU.SAP_PRDCT_PACK_SIZE_CODE, '000') || 
         NVL(MD_TDU.SAP_MULTI_PACK_QTY_CODE, '00'), 1, 8) AS PACK_SIZE_CODE,
    NVL(SUBSTRB(
         RTRIM(LTRIM(REPLACE(RTRIM(MD_TDU.CNSMR_PACK_FRMT_DESC), 'Not Applicable', '') || 
         ' ' || 
         REPLACE(RTRIM(MD_TDU.PRDCT_PACK_SIZE_DESC), 'Not Applicable', '') || 
         ' ' || 
         REPLACE(RTRIM(MD_TDU.MULTI_PACK_QTY_DESC), 'Not Applicable', ''))), 1, 60), 'Not Applicable') AS PACK_SIZE_DESC,
    NVL(SUBSTRB(
         RTRIM(LTRIM(REPLACE(RTRIM(MD_TDU.CNSMR_PACK_FRMT_ABBRD_DESC), 'NA', '') || 
         ' ' || 
         REPLACE(RTRIM(MD_TDU.PRDCT_PACK_SIZE_ABBRD_DESC), 'NA', '') || 
         ' ' || 
         REPLACE(RTRIM(MD_TDU.MULTI_PACK_QTY_ABBRD_DESC), 'NA', ''))), 1, 24), 'NA') AS PACK_SIZE_ABBRD_DESC,
    SUBSTRB(
        NVL(MD_TDU.SAP_FUNCL_VRTY_CODE, '000') || 
        NVL(MD_TDU.SAP_INGRED_VRTY_CODE, '0000'), 1, 8) AS VARIETY_CODE,
    NVL(SUBSTRB(
        RTRIM(LTRIM(REPLACE(RTRIM(MD_TDU.FUNCL_VRTY_DESC), 'Not Applicable', '') || 
         ' ' || 
        REPLACE(RTRIM(MD_TDU.INGRED_VRTY_DESC), 'Not Applicable', ''))), 1, 60), 'Not Applicable') AS VARIETY_DESC,
    NVL(SUBSTRB(
        RTRIM(LTRIM(REPLACE(RTRIM(MD_TDU.FUNCL_VRTY_ABBRD_DESC), 'NA', '') || 
         ' ' || 
        REPLACE(RTRIM(MD_TDU.INGRED_VRTY_ABBRD_DESC), 'NA', ''))), 1, 24), 'NA') AS VARIETY_ABBRD_DESC,
    MD_TDU.SAP_MATERIAL_CODE AS TDU_MATERIAL_CODE,
    MD_TDU.MATERIAL_DESC_JA AS TDU_MATERIAL_DESC,
    MD_TDU.MATERIAL_DESC_EN AS TDU_MATERIAL_DESC_EN,
    MD_TDU.EAN_UPC AS TDU_EAN_UPC,
    MD_RSU.SAP_MATERIAL_CODE AS RSU_MATERIAL_CODE,
    MD_RSU.MATERIAL_DESC_JA AS RSU_MATERIAL_DESC,
    MD_RSU.MATERIAL_DESC_EN AS RSU_MATERIAL_DESC_EN,
    MD_RSU.EAN_UPC AS RSU_EAN_UPC,
    MD_RSU.GROSS_WGT AS RSU_GROSS_WGT,
    MD_RSU.VOL AS RSU_VOL
FROM
    DD.MATERIAL_DIM MD_TDU,
    DD.MATERIAL_DIM MD_RSU,
    (SELECT
        T3.M_TDU_SAP_CODE,
        T3.M_RSU_SAP_CODE,
        T3.RSU_EAN_UPC
    FROM
        (SELECT
            MAX(TV3.TDU_SAP_CODE) AS M_TDU_SAP_CODE,
            T2.M_RSU_SAP_CODE,
            T2.RSU_EAN_UPC
        FROM
            (SELECT
                T1.M_RSU_SAP_CODE,
                T1.RSU_EAN_UPC
            FROM
                (SELECT 
                    MAX(TV1.RSU_SAP_CODE) AS M_RSU_SAP_CODE,
                    TV1.RSU_EAN_UPC
                FROM
                    FTR_APP.FTR_MATERIAL_CORE_VIEW TV1
                GROUP BY
                    TV1.RSU_EAN_UPC
                ) T1,
                FTR_APP.FTR_MATERIAL_CORE_VIEW TV2
            WHERE
                TV2.RSU_SAP_CODE = T1.M_RSU_SAP_CODE AND
                TV2.RSU_EAN_UPC = T1.RSU_EAN_UPC
            GROUP BY 
                T1.M_RSU_SAP_CODE,
                T1.RSU_EAN_UPC
            ) T2,
            FTR_APP.FTR_MATERIAL_CORE_VIEW TV3
        WHERE
            TV3.RSU_SAP_CODE = T2.M_RSU_SAP_CODE AND
            TV3.RSU_EAN_UPC = T2.RSU_EAN_UPC
        GROUP BY
            T2.M_RSU_SAP_CODE,
            T2.RSU_EAN_UPC
        ) T3,
        FTR_APP.FTR_MATERIAL_CORE_VIEW TV4
    WHERE
        TV4.TDU_SAP_CODE = T3.M_TDU_SAP_CODE AND
        TV4.RSU_SAP_CODE = T3.M_RSU_SAP_CODE AND
        TV4.RSU_EAN_UPC = T3.RSU_EAN_UPC
    GROUP BY
        T3.M_TDU_SAP_CODE,
        T3.M_RSU_SAP_CODE,
        T3.RSU_EAN_UPC
    ) TV5
WHERE
    MD_TDU.SAP_MATERIAL_CODE = TV5.M_TDU_SAP_CODE AND
    MD_RSU.SAP_MATERIAL_CODE = TV5.M_RSU_SAP_CODE AND
    MD_TDU.SAP_BUS_SGMNT_CODE = '05'
WITH READ ONLY;

/*-*/
/* Authority
/*-*/
grant select on ftr_app.ftr_material_hier_view1 to ftr_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ftr_material_hier_view1 for ftr_app.ftr_material_hier_view1;