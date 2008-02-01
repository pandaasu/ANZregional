/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : invc_type_view
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
create or replace force view od.invc_type_view
   (SAP_INVC_TYPE_CODE, INVC_TYPE_DESC, INVC_TYPE_LUPDP, INVC_TYPE_LUPDT)
AS 
SELECT 
-- ************************************************************************ 
-- Please note that this view will only work if an equivelant username and 
-- password on the Data Warehouse side exists. 
-- ************************************************************************  
  SAP_INVC_TYPE_CODE, 
  INVC_TYPE_DESC, 
  INVC_TYPE_LUPDP, 
  INVC_TYPE_LUPDT
FROM 
  INVC_TYPE_IN_DW;

/*-*/
/* Authority
/*-*/
grant select on od.invc_type_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym invc_type_view for od.invc_type_view;