/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : purch_order_fact  
 Owner  : dds 

 DESCRIPTION 
 -----------
 Dimensional Data Store - Purch_Order_Fact view over the dw_purch_base 

 YYYY/MM   Author           Description 
 -------   ------           ----------- 
 2008/07   Jonathan Girling Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view dds.purch_order_fact as

SELECT COMPANY_CODE,
  PURCH_ORDER_DOC_NUM,
  PURCH_ORDER_DOC_LINE_NUM,
  PURCH_ORDER_TYPE_CODE,
  CASE 
    WHEN PURCH_ORDER_LINE_STATUS = '*OPEN' THEN
      CASE WHEN INV_QTY != 0 or INV_GSV != 0 THEN 'INVOICED'
      WHEN DEL_QTY != 0 or DEL_GSV != 0 THEN 'DELIVERED'
      ELSE 'OUTSTANDING'
      END
    WHEN PURCH_ORDER_LINE_STATUS = '*CLOSED' THEN 'INVOICED'
    ELSE 'INVOICED'
  END AS PURCH_ORDER_LINE_STATUS,
  CREATN_DATE,
  CREATN_YYYYPPDD,
  PURCH_ORDER_EFF_DATE,
  PURCH_ORDER_EFF_YYYYPPDD,
  PURCH_ORDER_EFF_YYYYPPW,
  SALES_ORG_CODE,
  DISTBN_CHNL_CODE,
  DIVISION_CODE,
  DOC_CURRCY_CODE,
  COMPANY_CURRCY_CODE,
  EXCH_RATE,
  PURCHG_COMPANY_CODE,
  PURCH_ORDER_REASN_CODE,
  VENDOR_CODE,
  CUST_CODE,
  ORD_QTY as PURCH_ORDER_QTY,
  ORD_QTY_BASE_UOM as BASE_UOM_PURCH_ORDER_QTY,
  ORD_QTY_GROSS_TONNES as PURCH_ORDER_QTY_GROSS_TONNES,
  ORD_QTY_NET_TONNES as PURCH_ORDER_QTY_NET_TONNES,
  MATL_CODE,
  PURCH_ORDER_UOM_CODE as PURCH_ORDER_QTY_UOM_CODE,
  PURCH_ORDER_BASE_UOM_CODE as PURCH_ORDER_QTY_BASE_UOM_CODE,
  PLANT_CODE,
  STORAGE_LOCN_CODE,
  PURCH_ORDER_USAGE_CODE,
  ORD_GSV as GSV,
  ORD_GSV_XACTN as GSV_XACTN,
  ORD_GSV_AUD as GSV_AUD,
  ORD_GSV_USD as GSV_USD,
  ORD_GSV_EUR as GSV_EUR,
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
    DW_PURCH_BASE;
    
    
    
/*-*/
/* Authority 
/*-*/
GRANT SELECT ON DDS.PURCH_ORDER_FACT TO APPSUPPORT;
GRANT SELECT ON DDS.PURCH_ORDER_FACT TO BO_USER;
GRANT SELECT ON DDS.PURCH_ORDER_FACT TO CDW_READER_ROLE;
GRANT SELECT ON DDS.PURCH_ORDER_FACT TO DDS_APP WITH GRANT OPTION;
GRANT SELECT ON DDS.PURCH_ORDER_FACT TO DDS_MAINT;
GRANT SELECT ON DDS.PURCH_ORDER_FACT TO DDS_SELECT;
GRANT SELECT ON DDS.PURCH_ORDER_FACT TO DDS_USER;
GRANT SELECT ON DDS.PURCH_ORDER_FACT TO DW_APP;
GRANT SELECT ON DDS.PURCH_ORDER_FACT TO KPI_APP WITH GRANT OPTION;
GRANT SELECT ON DDS.PURCH_ORDER_FACT TO ODS_APP WITH GRANT OPTION;
GRANT SELECT ON DDS.PURCH_ORDER_FACT TO PUBLIC;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym purch_order_fact for dds.purch_order_fact;

