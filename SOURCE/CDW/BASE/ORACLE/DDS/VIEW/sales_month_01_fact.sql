/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : sales_month_01_fact  
 Owner  : dds 

 DESCRIPTION 
 -----------
 Dimensional Data Store - Sales_Month_01_Fact view over the dw_sales_month01 table 

 YYYY/MM   Author           Description 
 -------   ------           ----------- 
 2008/07   Jonathan Girling Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view dds.sales_month_01_fact as

SELECT COMPANY_CODE,
  ORDER_TYPE_CODE,
  INVC_TYPE_CODE,
  BILLING_EFF_YYYYMM,
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
FROM
    DW_SALES_MONTH01;
    
    
/*-*/
/* Authority 
/*-*/
GRANT SELECT ON DDS.SALES_MONTH_01_FACT TO ODS_APP;
GRANT SELECT ON DDS.SALES_MONTH_01_FACT TO APPSUPPORT;
GRANT SELECT ON DDS.SALES_MONTH_01_FACT TO BO_USER;
GRANT SELECT ON DDS.SALES_MONTH_01_FACT TO CDW_READER_ROLE;
GRANT SELECT ON DDS.SALES_MONTH_01_FACT TO DDS_APP WITH GRANT OPTION;
GRANT SELECT ON DDS.SALES_MONTH_01_FACT TO DDS_MAINT;
GRANT SELECT ON DDS.SALES_MONTH_01_FACT TO DDS_SELECT;
GRANT SELECT ON DDS.SALES_MONTH_01_FACT TO DDS_USER;
GRANT SELECT ON DDS.SALES_MONTH_01_FACT TO DW_APP;
GRANT SELECT ON DDS.SALES_MONTH_01_FACT TO KPI_APP WITH GRANT OPTION;
GRANT SELECT ON DDS.SALES_MONTH_01_FACT TO ODS_APP WITH GRANT OPTION;
GRANT SELECT ON DDS.SALES_MONTH_01_FACT TO PUBLIC;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym sales_month_01_fact for dds.sales_month_01_fact;


