/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : sales_org_view
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
create or replace force view od.sales_org_view
   (SAP_SALES_ORG_CODE, SALES_ORG_DESC, SAP_COMPANY_CODE, SALES_ORG_LUPDP, SALES_ORG_LUPDT)
AS 
SELECT 
-- ************************************************************************ 
-- Please note that this view will only work if an equivelant username and 
-- password on the Data Warehouse side exists. 
-- ************************************************************************  
  SAP_SALES_ORG_CODE, 
  SALES_ORG_DESC, 
  SAP_COMPANY_CODE, 
  SALES_ORG_LUPDP, 
  SALES_ORG_LUPDT
FROM 
  SALES_ORG_IN_DW;

/*-*/
/* Authority
/*-*/
grant select on od.sales_org_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym sales_org_view for od.sales_org_view;