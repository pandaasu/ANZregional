/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : monthly_sales_qty_view
 Owner  : dw_app

 DESCRIPTION
 -----------
 Data Warehouse - View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created
 2005/10   Steve Gregan   Swapped SALES_MONTH_01_FACT to SALES_MONTH_04_FACT

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view dw_app.monthly_sales_qty_view
   (SAP_MATERIAL_CODE,
    BILLING_YEAR,
    BILLING_MONTH,
    BASE_UOM_BILLED_QTY) AS 
   SELECT T2.SAP_MATERIAL_CODE, 
          TRUNC(T1.SAP_BILLING_YYYYMM/100) AS BILLING_YEAR, 
          T1.SAP_BILLING_YYYYMM-((TRUNC(T1.SAP_BILLING_YYYYMM/100)*100)) AS BILLING_MONTH, 
          SUM(T1.BASE_UOM_BILLED_QTY) AS BASE_UOM_BILLED_QTY 
     FROM SALES_MONTH_04_FACT T1, 
          MATERIAL_DIM T2 
    WHERE T1.SAP_MATERIAL_CODE = T2.SAP_MATERIAL_CODE AND 
          T2.SAP_BUS_SGMNT_CODE IN ('01','02','05') AND 
          T2.MATERIAL_TYPE_FLAG_TDU = 'Y' AND 
          T1.BASE_UOM_BILLED_QTY IS NOT NULL 
    GROUP BY T2.SAP_MATERIAL_CODE, 
             TRUNC(T1.SAP_BILLING_YYYYMM/100), 
             T1.SAP_BILLING_YYYYMM-((TRUNC(T1.SAP_BILLING_YYYYMM/100)*100));

/*-*/
/* Authority
/*-*/
grant select on dw_app.monthly_sales_qty_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym monthly_sales_qty_view for dw_app.monthly_sales_qty_view;