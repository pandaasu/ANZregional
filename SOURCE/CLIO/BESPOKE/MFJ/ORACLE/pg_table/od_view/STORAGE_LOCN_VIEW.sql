/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : storage_locn_view
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
create or replace force view od.storage_locn_view
   (SAP_STORAGE_LOCN_CODE, STORAGE_LOCN_DESC, STORAGE_LOCN_LUPDP, STORAGE_LOCN_LUPDT)
AS 
SELECT 
-- ************************************************************************ 
-- Please note that this view will only work if an equivelant username and 
-- password on the Data Warehouse side exists. 
-- ************************************************************************  
  SAP_STORAGE_LOCN_CODE, 
  STORAGE_LOCN_DESC, 
  STORAGE_LOCN_LUPDP, 
  STORAGE_LOCN_LUPDT
FROM 
  STORAGE_LOCN_IN_DW;

/*-*/
/* Authority
/*-*/
grant select on od.storage_locn_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym storage_locn_view for od.storage_locn_view;