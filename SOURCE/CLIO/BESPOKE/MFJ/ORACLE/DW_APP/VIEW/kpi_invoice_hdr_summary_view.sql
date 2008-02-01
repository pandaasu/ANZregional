/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : kpi_invoice_hdr_summary_view
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
create or replace force view dw_app.kpi_invoice_hdr_summary_view
   (BILLING_YYYYPP, 
    BILLING_YYYYPPDD,
    BILLING_DATE,
    INV_COUNT) AS 
   SELECT SUBSTR(MAIN.BILLING_YYYYPPDD,1,6) AS BILLING_YYYYPP, 
          MAIN.BILLING_YYYYPPDD, 
          MAIN.BILLING_DATE, 
          COUNT(MAIN.INVC_NUM) AS INV_COUNT 
     FROM (SELECT DISTINCT 
                  SF.BILLING_YYYYPPDD, 
                  MD.CALENDAR_DATE AS BILLING_DATE, 
                  SF.INVC_NUM 
             FROM (SELECT *
                     FROM SALES_FACT
                    WHERE BILLING_YYYYPPDD >= 20040101) SF, 
                  MARS_DATE MD 
            WHERE SF.BILLING_YYYYPPDD = MD.MARS_YYYYPPDD) MAIN 
    GROUP BY SUBSTR(MAIN.BILLING_YYYYPPDD,1,6), 
             MAIN.BILLING_YYYYPPDD, 
             MAIN.BILLING_DATE;

/*-*/
/* Authority
/*-*/
grant select on dw_app.kpi_invoice_hdr_summary_view to public;

/*-*/
/* Synonym
/*-*/
create or replace public synonym kpi_invoice_hdr_summary_view for dw_app.kpi_invoice_hdr_summary_view;