/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : kpi_invoice_hdr_summary_mth_vw
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
create or replace force view dw_app.kpi_invoice_hdr_summary_mth_vw
   (BILLING_YYYY,
    BILLING_MM,
    INV_COUNT) AS 
   SELECT TO_NUMBER(MAIN.BILLING_YYYY) AS BILLING_YYYY, 
          TO_NUMBER(MAIN.BILLING_MM) AS BILLING_MM, 
          COUNT(MAIN.INVC_NUM) AS INV_COUNT 
     FROM (SELECT DISTINCT
                  YEAR_NUM AS BILLING_YYYY, 
                  MONTH_NUM AS BILLING_MM, 
                  SF.INVC_NUM 
             FROM (SELECT * FROM SALES_FACT WHERE BILLING_YYYYPPDD >= 20040101) SF, 
          MARS_DATE MD 
    WHERE SF.BILLING_DATE = MD.CALENDAR_DATE) MAIN 
    GROUP BY BILLING_YYYY, 
             BILLING_MM;

/*-*/
/* Authority
/*-*/
grant select on dw_app.kpi_invoice_hdr_summary_mth_vw to public;

/*-*/
/* Synonym
/*-*/
create or replace public synonym kpi_invoice_hdr_summary_mth_vw for dw_app.kpi_invoice_hdr_summary_mth_vw;