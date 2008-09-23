/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : order_fact  
 Owner  : dds 

 DESCRIPTION 
 -----------
 Dimensional Data Store - Order_Fact view over the dw_order_base 

 YYYY/MM   Author           Description 
 -------   ------           ----------- 
 2008/07   Jonathan Girling Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view dds.order_fact as

select COMPANY_CODE,
  ORDER_DOC_NUM,
  ORDER_DOC_LINE_NUM,
  CUST_ORDER_DOC_NUM,
  CUST_ORDER_DOC_LINE_NUM,
  CUST_ORDER_DUE_DATE,
  ORDER_TYPE_CODE,
  CASE 
    WHEN ORDER_LINE_STATUS = '*OPEN' THEN
      CASE WHEN INV_QTY != 0 or INV_GSV != 0 THEN 'INVOICED'
           WHEN DEL_QTY != 0 or DEL_GSV != 0 THEN 'DELIVERED'
      ELSE 'OUTSTANDING'
      END
    WHEN ORDER_LINE_STATUS = '*CLOSED' THEN 'INVOICED'
    ELSE 'INVOICED'
  END AS ORDER_LINE_STATUS,
  CREATN_DATE,
  CREATN_YYYYPPDD,
  ORDER_EFF_DATE,
  ORDER_EFF_YYYYPPDD,
  ORDER_EFF_YYYYPPW,
  SALES_ORG_CODE as HDR_SALES_ORG_CODE,
  DISTBN_CHNL_CODE as HDR_DISTBN_CHNL_CODE,
  DIVISION_CODE as HDR_DIVISION_CODE,
  DOC_CURRCY_CODE,
  COMPANY_CURRCY_CODE,
  EXCH_RATE,
  ORDER_REASN_CODE,
  SOLD_TO_CUST_CODE,
  BILL_TO_CUST_CODE,
  PAYER_CUST_CODE,
  ORD_QTY as ORDER_QTY,
  CON_QTY as CONFIRMED_QTY,
  ORD_QTY_BASE_UOM as BASE_UOM_ORDER_QTY,
  CON_QTY_BASE_UOM as BASE_UOM_CONFIRMED_QTY,
  ORD_QTY_GROSS_TONNES as ORDER_QTY_GROSS_TONNES,
  CON_QTY_GROSS_TONNES as CONFIRMED_QTY_GROSS_TONNES,
  ORD_QTY_NET_TONNES as ORDER_QTY_NET_TONNES,
  CON_QTY_NET_TONNES as CONFIRMED_QTY_NET_TONNES,
  SHIP_TO_CUST_CODE,
  MATL_CODE,
  MATL_ENTD,
  ORDER_UOM_CODE as ORDER_QTY_UOM_CODE,
  ORDER_BASE_UOM_CODE as ORDER_QTY_BASE_UOM_CODE,
  PLANT_CODE,
  STORAGE_LOCN_CODE,
  ORDER_USAGE_CODE,
  ORD_GSV as ORDER_GSV,
  CON_GSV as CONFIRMED_GSV,
  ORD_GSV_XACTN as ORDER_GSV_XACTN,
  CON_GSV_XACTN as CONFIRMED_GSV_XACTN,
  ORD_GSV_AUD as ORDER_GSV_AUD,
  CON_GSV_AUD as CONFIRMED_GSV_AUD,
  ORD_GSV_USD as ORDER_GSV_USD,
  CON_GSV_USD as CONFIRMED_GSV_USD,
  ORD_GSV_EUR as ORDER_GSV_EUR,
  CON_GSV_EUR as CONFIRMED_GSV_EUR,
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
  ORDER_LINE_REJECTN_CODE,
  DEMAND_PLNG_GRP_DIVISION_CODE,
  ord_qty,
  ord_qty_base_uom,
  ord_qty_gross_tonnes,
  ord_qty_net_tonnes,
  ord_gsv,
  ord_gsv_xactn,
  ord_gsv_aud,
  ord_gsv_usd,
  ord_gsv_eur,
  con_qty,
  con_qty_base_uom,
  con_qty_gross_tonnes,
  con_qty_net_tonnes,
  con_gsv,
  con_gsv_xactn,
  con_gsv_aud,
  con_gsv_usd,
  con_gsv_eur,
  del_qty,
  del_qty_base_uom,
  del_qty_gross_tonnes,
  del_qty_net_tonnes,
  del_gsv,
  del_gsv_xactn,
  del_gsv_aud,
  del_gsv_usd,
  del_gsv_eur,
  inv_qty,
  inv_qty_base_uom,
  inv_qty_gross_tonnes,
  inv_qty_net_tonnes,
  inv_gsv,
  inv_gsv_xactn,
  inv_gsv_aud,
  inv_gsv_usd,
  inv_gsv_eur,
  out_qty,
  out_qty_base_uom,
  out_qty_gross_tonnes,
  out_qty_net_tonnes,
  out_gsv,
  out_gsv_xactn,
  out_gsv_aud,
  out_gsv_usd,
  out_gsv_eur
FROM 
    DW_ORDER_BASE;
    
    
/*-*/
/* Authority 
/*-*/
GRANT SELECT ON DDS.ORDER_FACT TO APPSUPPORT;
GRANT SELECT ON DDS.ORDER_FACT TO BO_USER;
GRANT SELECT ON DDS.ORDER_FACT TO CDW_READER_ROLE;
GRANT SELECT ON DDS.ORDER_FACT TO DDS_APP WITH GRANT OPTION;
GRANT SELECT ON DDS.ORDER_FACT TO DDS_MAINT;
GRANT SELECT ON DDS.ORDER_FACT TO DDS_SELECT;
GRANT SELECT ON DDS.ORDER_FACT TO DDS_USER;
GRANT SELECT ON DDS.ORDER_FACT TO DW_APP;
GRANT SELECT ON DDS.ORDER_FACT TO KPI_APP WITH GRANT OPTION;
GRANT SELECT ON DDS.ORDER_FACT TO ODS_APP WITH GRANT OPTION;
GRANT SELECT ON DDS.ORDER_FACT TO PUBLIC;


/*-*/
/* Synonym 
/*-*/
create or replace public synonym order_fact for dds.order_fact;

