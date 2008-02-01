/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : ftr_list_price_view
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
CREATE OR REPLACE FORCE VIEW FTR_APP.FTR_LIST_PRICE_VIEW
(RSU_EAN_UPC, YEAR_FROM, MONTH_FROM, DAY_FROM, YEAR_TO, 
 MONTH_TO, DAY_TO, RSU_PRICE)
AS 
SELECT
    V4.RSU_EAN_UPC,
    TO_CHAR(MIN(V4.VALID_FROM), 'YYYY') AS YEAR_FROM,
    TO_CHAR(MIN(V4.VALID_FROM), 'MM') AS MONTH_FROM,
    TO_CHAR(MIN(V4.VALID_FROM), 'DD') AS DAY_FROM,
    CASE
        WHEN TO_CHAR(MAX(V4.VALID_TO), 'YYYYMMDD') = '99991231'
        THEN '2099'
        ELSE TO_CHAR(MAX(V4.VALID_TO), 'YYYY')
    END YEAR_TO,
    CASE
        WHEN TO_CHAR(MAX(V4.VALID_TO), 'YYYYMMDD') = '99991231'
        THEN '12'
        ELSE TO_CHAR(MAX(V4.VALID_TO), 'MM')
    END MONTH_TO,
    CASE
        WHEN TO_CHAR(MAX(V4.VALID_TO), 'YYYYMMDD') = '99991231'
        THEN '31'
        ELSE TO_CHAR(MAX(V4.VALID_TO), 'DD')
    END DAY_TO,
    V4.RSU_PRICE
FROM
    (SELECT
        V2.RSU_EAN_UPC,
        V3.VALID_FROM,
        V3.VALID_TO,
        CASE
            WHEN V3.PIECES_PER_BASE_UOM = 0 THEN V3.MATERIAL_LIST_PRICE / 1
            ELSE V3.MATERIAL_LIST_PRICE / V3.PIECES_PER_BASE_UOM
        END RSU_PRICE
    FROM
        (SELECT DISTINCT
            TDU_SAP_CODE,
            RSU_EAN_UPC
        FROM
            FTR_APP.FTR_MATERIAL_CORE_VIEW
        UNION
        SELECT DISTINCT
            DMD.SAP_MATERIAL_CODE  AS TDU_SAP_CODE,
            DMD.EAN_UPC AS RSU_EAN_UPC
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
            SAP_MATERIAL_CODE,
            SAP_CNDTN_TYPE_CODE,
            SAP_SALES_ORG_CODE,
            SAP_DISTBN_CHNL_CODE,
            VALID_FROM,
            VALID_TO,
            MATERIAL_LIST_PRICE,
            SAP_CURRCY_CODE,
            MATERIAL_LIST_PRICE_PER_UNITS,
            SAP_UOM_CODE,
            SUM(PIECES_PER_BASE_UOM) AS PIECES_PER_BASE_UOM
        FROM
            (SELECT
                T1.SAP_MATERIAL_CODE,
                T2.SAP_CNDTN_TYPE_CODE,
                T2.SAP_SALES_ORG_CODE,
                T2.SAP_DISTBN_CHNL_CODE,
                T2.MATERIAL_LIST_PRICE_VALID_FROM AS VALID_FROM,
                T2.MATERIAL_LIST_PRICE_VALID_TO AS VALID_TO,
                T2.MATERIAL_LIST_PRICE,
                T2.MATERIAL_LIST_PRICE_CRRCY_CODE AS SAP_CURRCY_CODE,
                T2.MATERIAL_LIST_PRICE_PER_UNITS,
                T2.MATERIAL_LIST_PRICE_UOM_CODE AS SAP_UOM_CODE,
                T8.DENOMINATOR_X_CONV/T8.NUMERATOR_Y_CONV AS PIECES_PER_BASE_UOM
            FROM
                MATERIAL_DIM T1,
                MATERIAL_LIST_PRICE T2,
                MATERIAL_UOM T8,
                UOM T9
            WHERE
                T2.SAP_MATERIAL_CODE = DECODE(T1.SAP_REP_ITEM_CODE,NULL,T1.SAP_MATERIAL_CODE,T1.SAP_REP_ITEM_CODE) AND
                T1.SAP_MATERIAL_CODE = T8.SAP_MATERIAL_CODE (+) AND
                T8.ALT_UOM_CODE = T9.SAP_UOM_CODE (+) AND 
                T9.SAP_UOM_CODE = 'PCE' AND 
                NOT(T1.MATERIAL_DESC_JA IS NULL) AND
                T2.SAP_SALES_ORG_CODE = '131' AND
                T1.SAP_BUS_SGMNT_CODE = '05' AND
                T1.MATERIAL_TYPE_FLAG_TDU = 'Y' AND
                T2.SAP_CNDTN_TYPE_CODE = 'PR00'
            UNION ALL
            SELECT
                T1.SAP_MATERIAL_CODE,
                T2.SAP_CNDTN_TYPE_CODE,
                T2.SAP_SALES_ORG_CODE,
                T2.SAP_DISTBN_CHNL_CODE,
                T2.MATERIAL_LIST_PRICE_VALID_FROM AS VALID_FROM,
                T2.MATERIAL_LIST_PRICE_VALID_TO AS VALID_TO,
                T2.MATERIAL_LIST_PRICE,
                T2.MATERIAL_LIST_PRICE_CRRCY_CODE AS SAP_CURRCY_CODE,
                T2.MATERIAL_LIST_PRICE_PER_UNITS,
                T2.MATERIAL_LIST_PRICE_UOM_CODE AS SAP_UOM_CODE,
                0 AS PIECES_PER_BASE_UOM
            FROM
                MATERIAL_DIM T1,
                MATERIAL_LIST_PRICE T2,
                MATERIAL_UOM T8,
                UOM T9
            WHERE
                T2.SAP_MATERIAL_CODE = DECODE(T1.SAP_REP_ITEM_CODE,NULL,T1.SAP_MATERIAL_CODE,T1.SAP_REP_ITEM_CODE) AND
                T1.SAP_MATERIAL_CODE = T8.SAP_MATERIAL_CODE (+) AND
                T8.ALT_UOM_CODE = T9.SAP_UOM_CODE (+) AND 
                T9.SAP_UOM_CODE <> 'PCE' AND 
                NOT(T1.MATERIAL_DESC_JA IS NULL) AND
                T2.SAP_SALES_ORG_CODE = '131' AND
                T1.SAP_BUS_SGMNT_CODE = '05' AND
                T1.MATERIAL_TYPE_FLAG_TDU = 'Y' AND
                T2.SAP_CNDTN_TYPE_CODE = 'PR00')
        GROUP BY
            SAP_MATERIAL_CODE,
            SAP_CNDTN_TYPE_CODE,
            SAP_SALES_ORG_CODE,
            SAP_DISTBN_CHNL_CODE,
            VALID_FROM,
            VALID_TO,
            MATERIAL_LIST_PRICE,
            SAP_CURRCY_CODE,
            MATERIAL_LIST_PRICE_PER_UNITS,
            SAP_UOM_CODE
        ) V3
    WHERE
        V2.TDU_SAP_CODE = V3.SAP_MATERIAL_CODE
    ) V4
GROUP BY
    V4.RSU_EAN_UPC,
    V4.RSU_PRICE
WITH READ ONLY;

/*-*/
/* Authority
/*-*/
grant select on ftr_app.ftr_list_price_view to ftr_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ftr_list_price_view for ftr_app.ftr_list_price_view;