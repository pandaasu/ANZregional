/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : weekly_sales_qty_view
 Owner  : dw_app

 DESCRIPTION
 -----------
 Data Warehouse - View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created
 2005/10   Steve Gregan   Swapped SALES_FACT.BILLING_DATE to SALES_FACT.SAP_BILLING_DATE

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view dw_app.weekly_sales_qty_view
   (SAP_MATERIAL_CODE,
    SAP_PLANT_CODE,
    MARS_YEAR,
    PERIOD_NUM,
    MARS_WEEK, 
    BASE_UOM_BILLED_QTY) AS
   SELECT T2.SAP_MATERIAL_CODE, 
           T4.SAP_PLANT_CODE, 
           T5.MARS_YEAR, 
           T5.PERIOD_NUM, 
           T5.MARS_WEEK, 
           SUM(T1.BASE_UOM_BILLED_QTY) AS BASE_UOM_BILLED_QTY 
      FROM SALES_FACT T1, 
           MATERIAL_DIM T2, 
           CUST_SALES_AREA T3, 
           PLANT T4, 
           MARS_DATE T5 
     WHERE T1.SAP_MATERIAL_CODE = T2.SAP_MATERIAL_CODE AND 
           T1.SAP_SHIP_TO_CUST_CODE = T3.SAP_CUST_CODE AND 
           T1.SAP_SALES_DTL_SALES_ORG_CODE = T3.SAP_SALES_ORG_CODE AND 
           T1.SAP_SALES_DTL_DISTBN_CHNL_CODE = T3.SAP_DISTBN_CHNL_CODE AND 
           T1.SAP_SALES_DTL_DIVISION_CODE = T3.SAP_DIVISION_CODE AND 
           T3.SAP_CUST_DLVRY_PLANT_CODE = T4.SAP_PLANT_CODE AND 
           T1.SAP_BILLING_DATE = T5.CALENDAR_DATE AND 
           T2.SAP_BUS_SGMNT_CODE IN ('01','02','05') AND 
           (T2.MATERIAL_TYPE_FLAG_TDU = 'Y' OR T2.MATERIAL_TYPE_FLAG_SFP = 'Y') AND 
           T1.BASE_UOM_BILLED_QTY IS NOT NULL 
     GROUP BY T2.SAP_MATERIAL_CODE, 
              T4.SAP_PLANT_CODE, 
              T5.MARS_YEAR, 
              T5.PERIOD_NUM, 
              T5.MARS_WEEK;

/*-*/
/* Authority
/*-*/
grant select on dw_app.weekly_sales_qty_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym weekly_sales_qty_view for dw_app.weekly_sales_qty_view;