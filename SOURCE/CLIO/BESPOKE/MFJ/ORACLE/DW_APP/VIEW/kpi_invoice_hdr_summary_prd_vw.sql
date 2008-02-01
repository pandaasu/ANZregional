/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : kpi_invoice_hdr_summary_prd_vw
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
create or replace force view dw_app.kpi_invoice_hdr_summary_prd_vw
   (BILLING_YYYYPP,
    INV_COUNT) AS 
   SELECT TO_NUMBER(MAIN.BILLING_YYYYPP) AS BILLING_YYYYPP, 
          COUNT(MAIN.INVC_NUM) AS INV_COUNT 
     FROM (SELECT DISTINCT 
                  SUBSTR(SF.BILLING_YYYYPPDD,1,6) AS BILLING_YYYYPP, 
                  SF.INVC_NUM 
             FROM (SELECT * FROM SALES_FACT WHERE BILLING_YYYYPPDD >= 20040101) SF) MAIN 
    GROUP BY MAIN.BILLING_YYYYPP;

/*-*/
/* Authority
/*-*/
grant select on dw_app.kpi_invoice_hdr_summary_prd_vw to public;

/*-*/
/* Synonym
/*-*/
create or replace public synonym kpi_invoice_hdr_summary_prd_vw for dw_app.kpi_invoice_hdr_summary_prd_vw;

