/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : kpi_invoice_summary_mth_view
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
create or replace force view dw_app.kpi_invoice_summary_mth_view
   (BILLING_YYYY,
    BILLING_MM,
    SAP_SALES_ORG_CODE,
    SAP_DISTBN_CHNL_CODE,
    SAP_DIVISION_CODE, 
    SAP_PLANT_CODE,
    SAP_ORDER_TYPE_CODE,
    SAP_CUST_DISTBN_ROLE_CODE,
    CRPC_PRICE_BAND,
    SALES_AREA, 
    PLANT_DESC,
    ORDER_TYPE_DESC,
    CUST_DISTBN_ROLE_DESC,
    INV_COUNT,
    INV_LINES, 
    INV_ITEMS,
    INV_BASE_UOM_QTY,
    INV_BPS,
    INV_SHIP_TOS) AS 
   SELECT MAIN.BILLING_YYYY, 
          MAIN.BILLING_MM, 
          MAIN.SAP_SALES_DTL_SALES_ORG_CODE AS SAP_SALES_ORG_CODE, 
          MAIN.SAP_SALES_DTL_DISTBN_CHNL_CODE AS SAP_DISTBN_CHNL_CODE, 
          MAIN.SAP_SALES_DTL_DIVISION_CODE AS SAP_DIVISION_CODE, 
          MAIN.SAP_PLANT_CODE, 
          MAIN.SAP_ORDER_TYPE_CODE, 
          MAIN.SAP_CUST_DISTBN_ROLE_CODE, 
          MAIN.CRPC_PRICE_BAND, 
          NVL(SO.SALES_ORG_DESC, 'UNKNOWN') || ' - ' || NVL(DC.DISTBN_CHNL_DESC, 'UNKNOWN') || ' - ' || NVL(DV.DIVISION_DESC, 'UNKNOWN') AS SALES_AREA, 
          PT.PLANT_DESC, 
          OT.ORDER_TYPE_DESC, 
          MAIN.CUST_DISTBN_ROLE_DESC, 
          MAIN.INV_COUNT, 
          MAIN.INV_LINES, 
          MAIN.INV_ITEMS, 
          MAIN.BASE_UOM AS INV_BASE_UOM_QTY, 
          MAIN.BPS AS INV_BPS, 
          MAIN.INV_SHIP_TOS
     FROM PLANT_DIM PT,
          ORDER_TYPE_DIM OT, 
          SALES_ORG_DIM SO, 
          DISTBN_CHNL_DIM DC, 
          DIVISION_DIM DV,
          (SELECT BILLING_YYYY, 
                  BILLING_MM, 
                  SAP_SALES_DTL_SALES_ORG_CODE, 
                  SAP_SALES_DTL_DISTBN_CHNL_CODE, 
                  SAP_SALES_DTL_DIVISION_CODE, 
                  SAP_PLANT_CODE, 
                  SAP_ORDER_TYPE_CODE, 
                  SAP_CUST_DISTBN_ROLE_CODE, 
                  CUST_DISTBN_ROLE_DESC, 
                  CRPC_PRICE_BAND, 
                  SUM(NVL(INV_COUNT,0)) AS INV_COUNT, 
                  SUM(NVL(INV_LINES,0)) AS INV_LINES, 
                  SUM(NVL(INV_ITEMS,0)) AS INV_ITEMS, 
                  SUM(NVL(BASE_UOM,0)) AS BASE_UOM, 
                  SUM(NVL(BPS,0)) AS BPS, 
                  SUM(NVL(INV_SHIP_TOS,0)) AS INV_SHIP_TOS
             FROM (SELECT MD.YEAR_NUM AS BILLING_YYYY, 
                          MD.MONTH_NUM AS BILLING_MM, 
                          SF.SAP_SALES_DTL_SALES_ORG_CODE, 
                          SF.SAP_SALES_DTL_DISTBN_CHNL_CODE, 
                          SF.SAP_SALES_DTL_DIVISION_CODE, 
                          SF.SAP_PLANT_CODE, 
                          SF.SAP_ORDER_TYPE_CODE, 
                          CU.SAP_CUST_DISTBN_ROLE_CODE, 
                          CU.CUST_DISTBN_ROLE_DESC, 
                          SF.CRPC_PRICE_BAND, 
                          0 AS INV_COUNT, 
                          COUNT(*) AS INV_LINES, 
                          0 AS INV_ITEMS, 
                          SUM(SF.BASE_UOM_BILLED_QTY) AS BASE_UOM, 
                          SUM(SF.SALES_DTL_PRICE_VALUE_2) AS BPS, 
                          0 AS INV_SHIP_TOS 
                     FROM (SELECT * FROM SALES_FACT WHERE BILLING_YYYYPPDD >= 20040101) SF, 
                          MARS_DATE MD, 
                          CUST_DIM CU 
                    WHERE SF.BILLING_DATE = MD.CALENDAR_DATE (+) AND 
                          --SF.BILLING_YYYYPPDD >= 20040101 AND 
                          SF.SAP_SHIP_TO_CUST_CODE = CU.SAP_CUST_CODE (+) 
                    GROUP BY MD.YEAR_NUM, 
                             MD.MONTH_NUM, 
                             SF.SAP_SALES_DTL_SALES_ORG_CODE, 
                             SF.SAP_SALES_DTL_DISTBN_CHNL_CODE, 
                             SF.SAP_SALES_DTL_DIVISION_CODE, 
                             SF.SAP_PLANT_CODE, 
                             SF.SAP_ORDER_TYPE_CODE, 
                             CU.SAP_CUST_DISTBN_ROLE_CODE, 
                             CU.CUST_DISTBN_ROLE_DESC, 
                             SF.CRPC_PRICE_BAND 
                    UNION 
                   SELECT BILLING_YYYY, 
                          BILLING_MM, 
                          SAP_SALES_DTL_SALES_ORG_CODE, 
                          SAP_SALES_DTL_DISTBN_CHNL_CODE, 
                          SAP_SALES_DTL_DIVISION_CODE, 
                          SAP_PLANT_CODE, 
                          SAP_ORDER_TYPE_CODE, 
                          SAP_CUST_DISTBN_ROLE_CODE, 
                          CUST_DISTBN_ROLE_DESC, 
                          CRPC_PRICE_BAND, 
                          0 AS INV_COUNT, 
                          0 AS INV_LINES, 
                          COUNT(SAP_MATERIAL_CODE) AS INV_ITEMS, 
                          0 AS BASE_UOM, 
                          0 AS BPS, 
                          0 AS INV_SHIP_TOS 
                     FROM (SELECT DISTINCT 
                                  MD.YEAR_NUM AS BILLING_YYYY, 
                                  MD.MONTH_NUM AS BILLING_MM, 
                                  SF.SAP_SALES_DTL_SALES_ORG_CODE, 
                                  SF.SAP_SALES_DTL_DISTBN_CHNL_CODE, 
                                  SF.SAP_SALES_DTL_DIVISION_CODE, 
                                  SF.SAP_PLANT_CODE, 
                                  SF.SAP_ORDER_TYPE_CODE, 
                                  CU.SAP_CUST_DISTBN_ROLE_CODE, 
                                  CU.CUST_DISTBN_ROLE_DESC, 
                                  SF.CRPC_PRICE_BAND, 
                                  SF.SAP_MATERIAL_CODE 
                             FROM (SELECT * FROM SALES_FACT WHERE BILLING_YYYYPPDD >= 20040101) SF, 
                                  MARS_DATE MD, 
                                  CUST_DIM CU 
                            WHERE SF.BILLING_DATE = MD.CALENDAR_DATE (+) AND 
                                  --SF.BILLING_YYYYPPDD >= 20040101 AND 
                                  SF.SAP_SHIP_TO_CUST_CODE = CU.SAP_CUST_CODE (+) 
                            GROUP BY MD.YEAR_NUM, 
                                     MD.MONTH_NUM, 
                                     SF.SAP_SALES_DTL_SALES_ORG_CODE, 
                                     SF.SAP_SALES_DTL_DISTBN_CHNL_CODE, 
                                     SF.SAP_SALES_DTL_DIVISION_CODE, 
                                     SF.SAP_PLANT_CODE, 
                                     SF.SAP_ORDER_TYPE_CODE, 
                                     CU.SAP_CUST_DISTBN_ROLE_CODE, 
                                     CU.CUST_DISTBN_ROLE_DESC, 
                                     SF.CRPC_PRICE_BAND, 
                                     SF.SAP_MATERIAL_CODE) 
            GROUP BY BILLING_YYYY, 
                     BILLING_MM, 
                     SAP_SALES_DTL_SALES_ORG_CODE, 
                     SAP_SALES_DTL_DISTBN_CHNL_CODE, 
                     SAP_SALES_DTL_DIVISION_CODE, 
                     SAP_PLANT_CODE, 
                     SAP_ORDER_TYPE_CODE, 
                     SAP_CUST_DISTBN_ROLE_CODE, 
                     CUST_DISTBN_ROLE_DESC, 
                     CRPC_PRICE_BAND 
            UNION 
           SELECT BILLING_YYYY, 
                  BILLING_MM, 
                  SAP_SALES_DTL_SALES_ORG_CODE, 
                  SAP_SALES_DTL_DISTBN_CHNL_CODE, 
                  SAP_SALES_DTL_DIVISION_CODE, 
                  SAP_PLANT_CODE, 
                  SAP_ORDER_TYPE_CODE, 
                  SAP_CUST_DISTBN_ROLE_CODE, 
                  CUST_DISTBN_ROLE_DESC, 
                  CRPC_PRICE_BAND, 
                  0 AS INV_COUNT, 
                  0 AS INV_LINES, 
                  0 AS INV_ITEMS, 
                  0 AS BASE_UOM, 
                  0 AS BPS, 
                  COUNT(SAP_SHIP_TO_CUST_CODE) AS INV_SHIP_TOS 
             FROM (SELECT DISTINCT 
                          MD.YEAR_NUM AS BILLING_YYYY, 
                          MD.MONTH_NUM AS BILLING_MM, 
                          SF.SAP_SALES_DTL_SALES_ORG_CODE, 
                          SF.SAP_SALES_DTL_DISTBN_CHNL_CODE, 
                          SF.SAP_SALES_DTL_DIVISION_CODE, 
                          SF.SAP_PLANT_CODE, 
                          SF.SAP_ORDER_TYPE_CODE, 
                          CU.SAP_CUST_DISTBN_ROLE_CODE, 
                          CU.CUST_DISTBN_ROLE_DESC, 
                          SF.CRPC_PRICE_BAND, 
                          SF.SAP_SHIP_TO_CUST_CODE 
                     FROM (SELECT * FROM SALES_FACT WHERE BILLING_YYYYPPDD >= 20040101) SF, 
                          MARS_DATE MD, 
                          CUST_DIM CU 
                    WHERE SF.BILLING_DATE = MD.CALENDAR_DATE (+) AND 
                          --SF.BILLING_YYYYPPDD >= 20040101 AND 
                          SF.SAP_SHIP_TO_CUST_CODE = CU.SAP_CUST_CODE (+) 
                    GROUP BY MD.YEAR_NUM, 
                             MD.MONTH_NUM, 
                             SF.SAP_SALES_DTL_SALES_ORG_CODE, 
                             SF.SAP_SALES_DTL_DISTBN_CHNL_CODE, 
                             SF.SAP_SALES_DTL_DIVISION_CODE, 
                             SF.SAP_PLANT_CODE, 
                             SF.SAP_ORDER_TYPE_CODE, 
                             CU.SAP_CUST_DISTBN_ROLE_CODE, 
                             CU.CUST_DISTBN_ROLE_DESC, 
                             SF.CRPC_PRICE_BAND, 
                             SF.SAP_SHIP_TO_CUST_CODE) 
            GROUP BY BILLING_YYYY, 
                     BILLING_MM, 
                     SAP_SALES_DTL_SALES_ORG_CODE, 
                     SAP_SALES_DTL_DISTBN_CHNL_CODE, 
                     SAP_SALES_DTL_DIVISION_CODE, 
                     SAP_PLANT_CODE, 
                     SAP_ORDER_TYPE_CODE, 
                     SAP_CUST_DISTBN_ROLE_CODE, 
                     CUST_DISTBN_ROLE_DESC, 
                     CRPC_PRICE_BAND) 
    GROUP BY BILLING_YYYY, 
             BILLING_MM, 
             SAP_SALES_DTL_SALES_ORG_CODE, 
             SAP_SALES_DTL_DISTBN_CHNL_CODE, 
             SAP_SALES_DTL_DIVISION_CODE, 
             SAP_PLANT_CODE, 
             SAP_ORDER_TYPE_CODE, 
             SAP_CUST_DISTBN_ROLE_CODE, 
             CUST_DISTBN_ROLE_DESC, 
             CRPC_PRICE_BAND) MAIN 
    WHERE MAIN.SAP_PLANT_CODE = PT.SAP_PLANT_CODE (+) AND 
          MAIN.SAP_SALES_DTL_DISTBN_CHNL_CODE=DC.SAP_DISTBN_CHNL_CODE (+) AND 
          MAIN.SAP_SALES_DTL_SALES_ORG_CODE=SO.SAP_SALES_ORG_CODE (+) AND 
          MAIN.SAP_SALES_DTL_DIVISION_CODE = DV.SAP_DIVISION_CODE (+) AND 
          --SO.SAP_SALES_ORG_CODE  =  '131' AND 
          --DC.SAP_DISTBN_CHNL_CODE  =  '11' AND 
          -- DV.SAP_DIVISION_CODE  =  '51' AND 
          MAIN.SAP_ORDER_TYPE_CODE = OT.SAP_ORDER_TYPE_CODE (+);

/*-*/
/* Authority
/*-*/
grant select on dw_app.kpi_invoice_summary_mth_view to public;

/*-*/
/* Synonym
/*-*/
create or replace public synonym kpi_invoice_summary_mth_view for dw_app.kpi_invoice_summary_mth_view;

