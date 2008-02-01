/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : material_list_price_view
 Owner  : od

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
create or replace force view od.material_list_price_view
   (SAP_MATERIAL_CODE, SAP_CNDTN_TYPE_CODE, CNDTN_TYPE_DESC, SAP_SALES_ORG_CODE, 
 SAP_DISTBN_CHNL_CODE, MATERIAL_LIST_PRICE_VALID_FROM, MATERIAL_LIST_PRICE_VALID_TO, MATERIAL_LIST_PRICE, MATERIAL_LIST_PRICE_CRRCY_CODE, 
 MATERIAL_LIST_PRICE_PER_UNITS, MATERIAL_LIST_PRICE_UOM_CODE)
AS 
SELECT 
  A.SAP_MATERIAL_CODE, 
  B.SAP_CNDTN_TYPE_CODE, 
  B.CNDTN_TYPE_DESC, 
  A.SAP_SALES_ORG_CODE, 
  A.SAP_DISTBN_CHNL_CODE, 
  A.MATERIAL_LIST_PRICE_VALID_FROM, 
  A.MATERIAL_LIST_PRICE_VALID_TO, 
  A.MATERIAL_LIST_PRICE, 
  A.MATERIAL_LIST_PRICE_CRRCY_CODE, 
  A.MATERIAL_LIST_PRICE_PER_UNITS, 
  A.MATERIAL_LIST_PRICE_UOM_CODE 
FROM 
  MATERIAL_LIST_PRICE A, 
  CONDITION_TYPE      B 
WHERE 
  A.SAP_CNDTN_TYPE_CODE = B.SAP_CNDTN_TYPE_CODE;

/*-*/
/* Authority
/*-*/
grant select on od.material_list_price_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym material_list_price_view for od.material_list_price_view;