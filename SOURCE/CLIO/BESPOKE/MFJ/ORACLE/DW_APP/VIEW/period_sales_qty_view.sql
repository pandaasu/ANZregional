/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : period_sales_qty_view
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
create or replace force view period_sales_qty_view
   (BILLING_PERIOD,
    RSU_SAP_MATERIAL_CODE,
    BASE_UOM_BILLED_QTY) AS 
   SELECT T1.BILLING_YYYYPP AS BILLING_PERIOD, 
          'IT' || T4.SAP_MATERIAL_CODE AS RSU_SAP_MATERIAL_CODE, 
          SUM(T1.BASE_UOM_BILLED_QTY) AS BASE_UOM_BILLED_QTY 
     FROM SALES_PERIOD_01_FACT T1, 
          MATERIAL_DIM T2, 
          (SELECT T1.MATERIAL_CHAIN_CODE, 
                  MAX(T1.CMPNT_MATERIAL_CODE) AS CMPNT_MATERIAL_CODE 
             FROM MATERIAL_CHAIN T1 
            GROUP BY T1.MATERIAL_CHAIN_CODE) T3, 
          MATERIAL_DIM T4 
    WHERE T1.MATERIAL_CODE = T2.MATERIAL_CODE AND 
          T2.MATERIAL_TYPE_FLAG_TDU = 'Y' AND 
          T2.MATERIAL_CODE = T3.MATERIAL_CHAIN_CODE AND 
          T3.CMPNT_MATERIAL_CODE = T4.MATERIAL_CODE 
    GROUP BY T1.BILLING_YYYYPP, 
             T4.SAP_MATERIAL_CODE;

/*-*/
/* Authority
/*-*/
grant select on dw_app.period_sales_qty_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym period_sales_qty_view for dw_app.period_sales_qty_view;