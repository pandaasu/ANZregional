/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : m_list_price_p_drink_view
 Owner  : dw_app

 DESCRIPTION
 -----------
 Data Warehouse - M List Price P Drink

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view dw_app.M_LIST_PRICE_P_DRINK_VIEW
   (SAP_MATERIAL_CODE,
    SAP_CNDTN_TYPE_CODE,
    SAP_SALES_ORG_CODE,
    SAP_DISTBN_CHNL_CODE,
    YEAR_FROM, 
    MONTH_FROM,
    DAY_FROM,
    YEAR_TO,
    MONTH_TO,
    DAY_TO, 
    MATERIAL_LIST_PRICE,
    SAP_CURRCY_CODE,
    MATERIAL_LIST_PRICE_PER_UNITS,
    SAP_UOM_CODE,
    PIECES_PER_BASE_UOM) AS
   SELECT SAP_MATERIAL_CODE, 
          SAP_CNDTN_TYPE_CODE, 
          SAP_SALES_ORG_CODE, 
          SAP_DISTBN_CHNL_CODE, 
          YEAR_FROM, 
          MONTH_FROM, 
          DAY_FROM, 
          YEAR_TO, 
          MONTH_TO, 
          DAY_TO, 
          MATERIAL_LIST_PRICE, 
          MATERIAL_LIST_PRICE_CRRCY_CODE, 
          MATERIAL_LIST_PRICE_PER_UNITS, 
          MATERIAL_LIST_PRICE_UOM_CODE, 
          SUM(PIECES_PER_BASE_UOM) AS PIECES_PER_BASE_UOM 
    FROM (SELECT T1.SAP_MATERIAL_CODE, 
                 T2.SAP_CNDTN_TYPE_CODE, 
                 T2.SAP_SALES_ORG_CODE, 
                 T2.SAP_DISTBN_CHNL_CODE, 
                 TO_CHAR(T2.MATERIAL_LIST_PRICE_VALID_FROM,'YYYY') AS YEAR_FROM, 
                 TO_CHAR(T2.MATERIAL_LIST_PRICE_VALID_FROM,'MM') AS MONTH_FROM, 
                 TO_CHAR(T2.MATERIAL_LIST_PRICE_VALID_FROM,'DD') AS DAY_FROM, 
                 TO_CHAR(T2.MATERIAL_LIST_PRICE_VALID_TO,'YYYY') AS YEAR_TO, 
                 TO_CHAR(T2.MATERIAL_LIST_PRICE_VALID_TO,'MM') AS MONTH_TO, 
                 TO_CHAR(T2.MATERIAL_LIST_PRICE_VALID_TO,'DD') AS DAY_TO, 
                 T2.MATERIAL_LIST_PRICE, 
                 T2.MATERIAL_LIST_PRICE_CRRCY_CODE, 
                 T2.MATERIAL_LIST_PRICE_PER_UNITS, 
                 T2.MATERIAL_LIST_PRICE_UOM_CODE, 
                 T8.DENOMINATOR_X_CONV/T8.NUMERATOR_Y_CONV AS PIECES_PER_BASE_UOM 
            FROM MATERIAL_DIM T1, 
                 MATERIAL_LIST_PRICE T2, 
                 MATERIAL_UOM T8,
                 (SELECT T121.SAP_MATERIAL_CODE AS SAP_MATERIAL_CODE,
                         MAX(T121.MATERIAL_LIST_PRICE_VALID_FROM) AS MATERIAL_LIST_PRICE_VALID_FROM
                    FROM MATERIAL_LIST_PRICE T121 
                   GROUP BY T121.SAP_MATERIAL_CODE) T12
           WHERE T2.SAP_MATERIAL_CODE = DECODE(T1.SAP_REP_ITEM_CODE,NULL,T1.SAP_MATERIAL_CODE,T1.SAP_REP_ITEM_CODE) AND  
                 T1.SAP_MATERIAL_CODE = T8.SAP_MATERIAL_CODE (+) AND
                 T8.ALT_UOM_CODE = 'PCE' AND 
                 NOT(T1.MATERIAL_DESC_JA IS NULL) AND
                 T2.SAP_SALES_ORG_CODE IN ('131','132') AND 
                 T1.SAP_BUS_SGMNT_CODE IN ('01','02','03','05') AND 
                 T1.MATERIAL_TYPE_FLAG_TDU = 'Y' AND 
                 SYSDATE BETWEEN T2.MATERIAL_LIST_PRICE_VALID_FROM AND T2.MATERIAL_LIST_PRICE_VALID_TO AND
                 T2.SAP_MATERIAL_CODE = T12.SAP_MATERIAL_CODE AND
                 T2.MATERIAL_LIST_PRICE_VALID_FROM = T12.MATERIAL_LIST_PRICE_VALID_FROM 
           UNION ALL 
          SELECT T1.SAP_MATERIAL_CODE, 
                 T2.SAP_CNDTN_TYPE_CODE, 
                 T2.SAP_SALES_ORG_CODE, 
                 T2.SAP_DISTBN_CHNL_CODE, 
                 TO_CHAR(T2.MATERIAL_LIST_PRICE_VALID_FROM,'YYYY') AS YEAR_FROM, 
                 TO_CHAR(T2.MATERIAL_LIST_PRICE_VALID_FROM,'MM') AS MONTH_FROM, 
                 TO_CHAR(T2.MATERIAL_LIST_PRICE_VALID_FROM,'DD') AS DAY_FROM, 
                 TO_CHAR(T2.MATERIAL_LIST_PRICE_VALID_TO,'YYYY') AS YEAR_TO, 
                 TO_CHAR(T2.MATERIAL_LIST_PRICE_VALID_TO,'MM') AS MONTH_TO, 
                 TO_CHAR(T2.MATERIAL_LIST_PRICE_VALID_TO,'DD') AS DAY_TO, 
                 T2.MATERIAL_LIST_PRICE, 
                 T2.MATERIAL_LIST_PRICE_CRRCY_CODE, 
                 T2.MATERIAL_LIST_PRICE_PER_UNITS, 
                 T2.MATERIAL_LIST_PRICE_UOM_CODE, 
                 0 AS PIECES_PER_BASE_UOM 
            FROM MATERIAL_DIM T1, 
                 MATERIAL_LIST_PRICE T2, 
                 MATERIAL_UOM T8,
                 (SELECT T121.SAP_MATERIAL_CODE AS SAP_MATERIAL_CODE,
                         MAX(T121.MATERIAL_LIST_PRICE_VALID_FROM) AS MATERIAL_LIST_PRICE_VALID_FROM
                    FROM MATERIAL_LIST_PRICE T121 
                   GROUP BY T121.SAP_MATERIAL_CODE) T12
           WHERE T2.SAP_MATERIAL_CODE = DECODE(T1.SAP_REP_ITEM_CODE,NULL,T1.SAP_MATERIAL_CODE,T1.SAP_REP_ITEM_CODE) AND  
                 T1.SAP_MATERIAL_CODE = T8.SAP_MATERIAL_CODE (+) AND  
                 T8.ALT_UOM_CODE <> 'PCE' AND 
                 NOT(T1.MATERIAL_DESC_JA IS NULL) AND
                 T2.SAP_SALES_ORG_CODE IN ('131','132') AND 
                 T1.SAP_BUS_SGMNT_CODE IN ('01','02','03','05') AND 
                 T1.MATERIAL_TYPE_FLAG_TDU = 'Y' AND 
                 SYSDATE BETWEEN T2.MATERIAL_LIST_PRICE_VALID_FROM AND T2.MATERIAL_LIST_PRICE_VALID_TO AND 
                 T2.SAP_MATERIAL_CODE = T12.SAP_MATERIAL_CODE AND
                 T2.MATERIAL_LIST_PRICE_VALID_FROM = T12.MATERIAL_LIST_PRICE_VALID_FROM)
    GROUP BY SAP_MATERIAL_CODE, 
             SAP_CNDTN_TYPE_CODE, 
             SAP_SALES_ORG_CODE, 
             SAP_DISTBN_CHNL_CODE, 
             YEAR_FROM, 
             MONTH_FROM, 
             DAY_FROM, 
             YEAR_TO, 
             MONTH_TO, 
             DAY_TO, 
             MATERIAL_LIST_PRICE, 
             MATERIAL_LIST_PRICE_CRRCY_CODE, 
             MATERIAL_LIST_PRICE_PER_UNITS, 
             MATERIAL_LIST_PRICE_UOM_CODE;

/*-*/
/* Authority
/*-*/
grant select on dw_app.m_list_price_p_drink_view to bo_user;

/*-*/
/* Synonym
/*-*/
create public synonym m_list_price_p_drink_view for dw_app.m_list_price_p_drink_view;


