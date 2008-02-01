/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : kpi_pd_items_vw
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
create or replace force view dw_app.kpi_pd_items_vw
   (SALES_AREA,
    BILLING_YEAR,
    BILLING_PERIOD,
    DIST_INV_ITEMS) AS 
   SELECT NVL(SO.SALES_ORG_DESC, 'UNKNOWN') || ' - ' || NVL(DC.DISTBN_CHNL_DESC, 'UNKNOWN') || ' - ' || NVL(DV.DIVISION_DESC, 'UNKNOWN') AS SALES_AREA, 
          MAIN.BILLING_YEAR, 
          MAIN.BILLING_PERIOD, 
          COUNT(SAP_MATERIAL_CODE) AS DIST_INV_ITEMS 
    FROM SALES_ORG_DIM SO, 
         DISTBN_CHNL_DIM DC, 
         DIVISION_DIM DV, 
        (SELECT DISTINCT SF.SAP_SALES_DTL_SALES_ORG_CODE AS SAP_SALES_ORG_CODE, 
                SF.SAP_SALES_DTL_DISTBN_CHNL_CODE AS SAP_DISTBN_CHNL_CODE, 
                SF.SAP_SALES_DTL_DIVISION_CODE AS SAP_DIVISION_CODE, 
                MD.MARS_YEAR AS BILLING_YEAR, 
                MD.PERIOD_NUM AS BILLING_PERIOD, 
                SF.SAP_MATERIAL_CODE 
           FROM SALES_FACT SF, 
                MARS_DATE MD 
          WHERE SF.BILLING_YYYYPPDD = MD.MARS_YYYYPPDD) MAIN 
    WHERE MAIN.SAP_DISTBN_CHNL_CODE=DC.SAP_DISTBN_CHNL_CODE (+) AND 
          MAIN.SAP_SALES_ORG_CODE=SO.SAP_SALES_ORG_CODE (+) AND 
          MAIN.SAP_DIVISION_CODE = DV.SAP_DIVISION_CODE (+) 
    GROUP BY SO.SALES_ORG_DESC, 
             DC.DISTBN_CHNL_DESC, 
             DV.DIVISION_DESC, 
             MAIN.BILLING_YEAR, 
             MAIN.BILLING_PERIOD;

/*-*/
/* Authority
/*-*/
grant select on dw_app.kpi_pd_items_vw to public;

/*-*/
/* Synonym
/*-*/
create or replace public synonym kpi_pd_items_vw for dw_app.kpi_pd_items_vw;