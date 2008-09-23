/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : sales_fact 
 Owner  : dds 

 DESCRIPTION 
 -----------
 Dimensional Data Store - Sales_Fact view over the dw_sales_base 

 YYYY/MM   Author           Description 
 -------   ------           ----------- 
 2008/07   Jonathan Girling Created 
 2008/09   Jonathan Girling Bug fix

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view dds.sales_fact as
select COMPANY_CODE,
  BILLING_DOC_NUM,
  BILLING_DOC_LINE_NUM,
  ORDER_DOC_NUM,
  ORDER_DOC_LINE_NUM,
  PURCH_ORDER_DOC_NUM,
  PURCH_ORDER_DOC_LINE_NUM,
  DLVRY_DOC_NUM,
  DLVRY_DOC_LINE_NUM,
  ORDER_TYPE_CODE,
  INVC_TYPE_CODE,
  CREATN_DATE,
  CREATN_YYYYPPDD,
  CREATN_YYYYPPW,
  CREATN_YYYYPP,
  CREATN_YYYYMM,
  BILLING_EFF_DATE,
  BILLING_EFF_YYYYMM,
  BILLING_EFF_YYYYPP,
  BILLING_EFF_YYYYPPDD,
  BILLING_EFF_YYYYPPW,
  HDR_SALES_ORG_CODE,
  HDR_DISTBN_CHNL_CODE,
  HDR_DIVISION_CODE,
  DOC_CURRCY_CODE,
  COMPANY_CURRCY_CODE,
  EXCH_RATE,
  ORDER_REASN_CODE,
  SOLD_TO_CUST_CODE,
  BILL_TO_CUST_CODE,
  PAYER_CUST_CODE,
  ORDER_QTY,
  BILLED_QTY,
  BILLED_QTY_BASE_UOM as BASE_UOM_BILLED_QTY,
  BILLED_QTY_GROSS_TONNES,
  BILLED_QTY_NET_TONNES,
  SHIP_TO_CUST_CODE,
  MATL_CODE,
  MATL_ENTD,
  BILLED_UOM_CODE as BILLED_QTY_UOM_CODE,
  BILLED_BASE_UOM_CODE as BILLED_QTY_BASE_UOM_CODE,
  PLANT_CODE,
  STORAGE_LOCN_CODE,
  GEN_SALES_ORG_CODE,
  GEN_DISTBN_CHNL_CODE,
  GEN_DIVISION_CODE,
  ORDER_USAGE_CODE,
  BILLED_GSV as GSV,
  BILLED_GSV_XACTN as GSV_XACTN,
  BILLED_GSV_AUD as GSV_AUD,
  BILLED_GSV_USD as GSV_USD,
  BILLED_GSV_EUR as GSV_EUR,
  BILLED_WEIGHT_UNIT,
  BILLED_GROSS_WEIGHT,
  BILLED_NET_WEIGHT,
  0 as NIV,
  0 as NIV_XACTN,
  0 as NIV_AUD,
  0 as NIV_USD,
  0 as NIV_EUR,
  0 as NGV,
  0 as NGV_XACTN,
  0 as NGV_AUD,
  0 as NGV_USD,
  0 as NGV_EUR,
  MFANZ_ICB_FLAG,
  DEMAND_PLNG_GRP_DIVISION_CODE
from dw_sales_base;


/*-*/
/* Authority 
/*-*/
GRANT SELECT ON DDS.SALES_FACT TO APPSUPPORT;
GRANT SELECT ON DDS.SALES_FACT TO BO_USER;
GRANT SELECT ON DDS.SALES_FACT TO CDW_READER_ROLE;
GRANT SELECT ON DDS.SALES_FACT TO DDS_APP WITH GRANT OPTION;
GRANT SELECT ON DDS.SALES_FACT TO DDS_MAINT;
GRANT SELECT ON DDS.SALES_FACT TO DDS_SELECT;
GRANT SELECT ON DDS.SALES_FACT TO DDS_USER;
GRANT SELECT ON DDS.SALES_FACT TO DW_APP;
GRANT SELECT ON DDS.SALES_FACT TO KPI_APP WITH GRANT OPTION;
GRANT SELECT ON DDS.SALES_FACT TO ODS_APP WITH GRANT OPTION;
GRANT SELECT ON DDS.SALES_FACT TO PUBLIC;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym sales_fact for dds.sales_fact;

