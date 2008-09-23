/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : dlvry_fact 
 Owner  : dds 

 DESCRIPTION 
 -----------
 Dimensional Data Store - Dlvry_Fact view over the dw_dlvry_base 

 YYYY/MM   Author           Description 
 -------   ------           ----------- 
 2008/07   Jonathan Girling Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view dds.dlvry_fact as

select COMPANY_CODE,
  DLVRY_DOC_NUM,
  DLVRY_DOC_LINE_NUM,
  ORDER_DOC_NUM,
  ORDER_DOC_LINE_NUM,
  PURCH_ORDER_DOC_NUM,
  PURCH_ORDER_DOC_LINE_NUM,
  DLVRY_TYPE_CODE,
  decode(dlvry_line_status,'*OPEN','OUTSTANDING','*CLOSED','INVOICED','INVOICED') as DLVRY_LINE_STATUS,
  DLVRY_PROCG_STAGE,
  CREATN_DATE,
  CREATN_YYYYPPDD,
  DLVRY_EFF_DATE,
  DLVRY_EFF_YYYYPPDD,
  DLVRY_EFF_YYYYPPW,
  GOODS_ISSUE_DATE,
  GOODS_ISSUE_YYYYPPDD,
  SALES_ORG_CODE as HDR_SALES_ORG_CODE,
  DISTBN_CHNL_CODE as DET_DISTBN_CHNL_CODE,
  DIVISION_CODE as DET_DIVISION_CODE,
  DOC_CURRCY_CODE,
  COMPANY_CURRCY_CODE,
  EXCH_RATE,
  SOLD_TO_CUST_CODE,
  BILL_TO_CUST_CODE,
  PAYER_CUST_CODE,
  DEL_QTY as DLVRY_QTY,
  DEL_QTY_BASE_UOM as BASE_UOM_DLVRY_QTY,
  DEL_QTY_GROSS_TONNES as DLVRY_QTY_GROSS_TONNES,
  DEL_QTY_NET_TONNES as DLVRY_QTY_NET_TONNES,
  SHIP_TO_CUST_CODE,
  MATL_CODE,
  MATL_ENTD,
  DLVRY_UOM_CODE as DLVRY_QTY_UOM_CODE,
  DLVRY_BASE_UOM_CODE as DLVRY_QTY_BASE_UOM_CODE,
  PLANT_CODE,
  STORAGE_LOCN_CODE,
  DEL_GSV as GSV,
  DEL_GSV_XACTN as GSV_XACTN,
  DEL_GSV_AUD as GSV_AUD,
  DEL_GSV_USD as GSV_USD,
  DEL_GSV_EUR as GSV_EUR,
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
from 
    dw_dlvry_base;


/*-*/
/* Authority 
/*-*/
GRANT SELECT ON DDS.DLVRY_FACT TO APPSUPPORT;
GRANT SELECT ON DDS.DLVRY_FACT TO BO_USER;
GRANT SELECT ON DDS.DLVRY_FACT TO CDW_READER_ROLE;
GRANT SELECT ON DDS.DLVRY_FACT TO DDS_APP WITH GRANT OPTION;
GRANT SELECT ON DDS.DLVRY_FACT TO DDS_MAINT;
GRANT SELECT ON DDS.DLVRY_FACT TO DDS_SELECT;
GRANT SELECT ON DDS.DLVRY_FACT TO DDS_USER;
GRANT SELECT ON DDS.DLVRY_FACT TO DW_APP;
GRANT SELECT ON DDS.DLVRY_FACT TO KPI_APP WITH GRANT OPTION;
GRANT SELECT ON DDS.DLVRY_FACT TO ODS_APP WITH GRANT OPTION;
GRANT SELECT ON DDS.DLVRY_FACT TO PUBLIC;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym dlvry_fact for dds.dlvry_fact;


