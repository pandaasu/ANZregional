/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : division_view
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
create or replace force view od.division_view
   (SAP_DIVISION_CODE, DIVISION_DESC, DIVISION_LUPDP, DIVISION_LUPDT)
AS 
SELECT 
-- ************************************************************************ 
-- Please note that this view will only work if an equivelant username and 
-- password on the Data Warehouse side exists. 
-- ************************************************************************ 
  SAP_DIVISION_CODE, 
  DIVISION_DESC, 
  DIVISION_LUPDP, 
  DIVISION_LUPDT
FROM 
  DIVISION_IN_DW;

/*-*/
/* Authority
/*-*/
grant select on od.division_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym division_view for od.division_view;