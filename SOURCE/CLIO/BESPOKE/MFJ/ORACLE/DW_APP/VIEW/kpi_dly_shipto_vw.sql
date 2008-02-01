/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : kpi_dly_shipto_vw
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
create or replace force view dw_app.kpi_dly_shipto_vw
   (SALES_AREA,
    PLANT_DESC,
    BILLING_YYYYMMDD,
    DIST_INV_SHIPTO) AS 
   SELECT NVL(SO.SALES_ORG_DESC, 'UNKNOWN') || ' - ' || NVL(DC.DISTBN_CHNL_DESC, 'UNKNOWN') || ' - ' || NVL(DV.DIVISION_DESC, 'UNKNOWN') AS SALES_AREA, 
          PT.PLANT_DESC, 
          MAIN.BILLING_YYYYMMDD, 
          COUNT(SAP_SHIP_TO_CUST_CODE) AS DIST_INV_SHIPTO 
     FROM SALES_ORG_DIM SO, 
          DISTBN_CHNL_DIM DC, 
          DIVISION_DIM DV, 
          PLANT_DIM PT, 
          (SELECT DISTINCT SF.SAP_SALES_DTL_SALES_ORG_CODE AS SAP_SALES_ORG_CODE, 
                           SF.SAP_SALES_DTL_DISTBN_CHNL_CODE AS SAP_DISTBN_CHNL_CODE, 
                           SF.SAP_SALES_DTL_DIVISION_CODE AS SAP_DIVISION_CODE, 
                           SF.SAP_PLANT_CODE, 
                           MD.YYYYMMDD_DATE AS BILLING_YYYYMMDD, 
                           SF.SAP_SHIP_TO_CUST_CODE 
             FROM SALES_FACT SF, 
                  MARS_DATE MD 
            WHERE SF.BILLING_YYYYPPDD = MD.MARS_YYYYPPDD) MAIN 
    WHERE MAIN.SAP_DISTBN_CHNL_CODE=DC.SAP_DISTBN_CHNL_CODE (+) AND 
          MAIN.SAP_SALES_ORG_CODE=SO.SAP_SALES_ORG_CODE (+) AND 
          MAIN.SAP_DIVISION_CODE = DV.SAP_DIVISION_CODE (+) AND 
          MAIN.SAP_PLANT_CODE = PT.SAP_PLANT_CODE (+) 
    GROUP BY SO.SALES_ORG_DESC, 
             DC.DISTBN_CHNL_DESC, 
             DV.DIVISION_DESC, 
             PT.PLANT_DESC, 
             MAIN.BILLING_YYYYMMDD;

/*-*/
/* Authority
/*-*/
grant select on dw_app.kpi_dly_shipto_vw to public;

/*-*/
/* Synonym
/*-*/
create or replace public synonym kpi_dly_shipto_vw for dw_app.kpi_dly_shipto_vw;

