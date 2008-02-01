/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : order_type_view
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
create or replace force view od.order_type_view
   (SAP_ORDER_TYPE_CODE, ORDER_TYPE_DESC, ORDER_TYPE_LUPDP, ORDER_TYPE_LUPDT)
AS 
SELECT 
-- ************************************************************************ 
-- Please note that this view will only work if an equivelant username and 
-- password on the Data Warehouse side exists. 
-- ************************************************************************ 
  SAP_ORDER_TYPE_CODE, 
  ORDER_TYPE_DESC, 
  ORDER_TYPE_LUPDP, 
  ORDER_TYPE_LUPDT
FROM 
  ORDER_TYPE_IN_DW;

/*-*/
/* Authority
/*-*/
grant select on od.order_type_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym order_type_view for od.order_type_view;