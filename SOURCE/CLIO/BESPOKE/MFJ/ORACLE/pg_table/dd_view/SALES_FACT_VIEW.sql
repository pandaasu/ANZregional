/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : sales_fact_view
 Owner  : dd

 DESCRIPTION
 -----------
 Data Warehouse - View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created
 2005/11   Steve Gregan   Modified to use SAP_BILLING_DATE

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view dd.sales_fact_view
   (SAP_ORDER_TYPE_CODE, SAP_INVC_TYPE_CODE, CREATN_DATE, BILLING_DATE, BILLING_YYYYPPDD, 
 GOODS_ISSUED_DATE, REQD_DLVRY_DATE, BILLED_QTY, BASE_UOM_BILLED_QTY, PIECES_BILLED_QTY, 
 TONNES_BILLED_QTY, SAP_MATERIAL_CODE, SAP_PLANT_CODE, SAP_STORAGE_LOCN_CODE, SAP_SALES_DTL_SALES_ORG_CODE, 
 SAP_SALES_DTL_DISTBN_CHNL_CODE, SAP_SALES_DTL_DIVISION_CODE, SALES_DTL_PRICE_VALUE_1, SALES_DTL_PRICE_VALUE_2, SALES_DTL_PRICE_VALUE_3, 
 SALES_DTL_PRICE_VALUE_4, SALES_DTL_PRICE_VALUE_5, SALES_DTL_PRICE_VALUE_6, SALES_DTL_PRICE_VALUE_7, SALES_DTL_PRICE_VALUE_8, 
 SALES_DTL_PRICE_VALUE_9, SALES_DTL_PRICE_VALUE_10, SALES_DTL_PRICE_VALUE_11, SALES_DTL_PRICE_VALUE_12, SALES_DTL_PRICE_VALUE_13, 
 SALES_DTL_PRICE_VALUE_14, SALES_DTL_PRICE_VALUE_15, SALES_DTL_PRICE_VALUE_16, SALES_DTL_PRICE_VALUE_17, SALES_DTL_PRICE_VALUE_18, 
 SALES_DTL_PRICE_VALUE_19, SALES_DTL_PRICE_VALUE_20, SALES_DTL_PRICE_VALUE_21, SALES_DTL_PRICE_VALUE_22, SALES_DTL_PRICE_VALUE_23)
AS 
SELECT
-- ************************************************************************
-- Please note that this view will only work if an equivelant username and
-- password on the Data Warehouse side exists.
-- ************************************************************************
  SAP_ORDER_TYPE_CODE,
  SAP_INVC_TYPE_CODE,
  CREATN_DATE,
  SAP_BILLING_DATE,
  SAP_BILLING_YYYYPPDD,
  GOODS_ISSUED_DATE,
  REQD_DLVRY_DATE,
  BILLED_QTY,
  BASE_UOM_BILLED_QTY,
  PIECES_BILLED_QTY,
  TONNES_BILLED_QTY,
  SAP_MATERIAL_CODE,
  SAP_PLANT_CODE,
  SAP_STORAGE_LOCN_CODE,
  SAP_SALES_DTL_SALES_ORG_CODE,
  SAP_SALES_DTL_DISTBN_CHNL_CODE,
  SAP_SALES_DTL_DIVISION_CODE,
  SALES_DTL_PRICE_VALUE_1,
  SALES_DTL_PRICE_VALUE_2,
  SALES_DTL_PRICE_VALUE_3,
  SALES_DTL_PRICE_VALUE_4,
  SALES_DTL_PRICE_VALUE_5,
  SALES_DTL_PRICE_VALUE_6,
  SALES_DTL_PRICE_VALUE_7,
  SALES_DTL_PRICE_VALUE_8,
  SALES_DTL_PRICE_VALUE_9,
  SALES_DTL_PRICE_VALUE_10,
  SALES_DTL_PRICE_VALUE_11,
  SALES_DTL_PRICE_VALUE_12,
  SALES_DTL_PRICE_VALUE_13,
  SALES_DTL_PRICE_VALUE_14,
  SALES_DTL_PRICE_VALUE_15,
  SALES_DTL_PRICE_VALUE_16,
  SALES_DTL_PRICE_VALUE_17,
  SALES_DTL_PRICE_VALUE_18,
  SALES_DTL_PRICE_VALUE_19,
  SALES_DTL_PRICE_VALUE_20,
  SALES_DTL_PRICE_VALUE_21,
  SALES_DTL_PRICE_VALUE_22,
  SALES_DTL_PRICE_VALUE_23
FROM
  SALES_FACT_IN_DW;

/*-*/
/* Authority
/*-*/
grant select on dd.sales_fact_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym sales_fact_view for dd.sales_fact_view;