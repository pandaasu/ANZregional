/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : plant_view
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
create or replace force view od.plant_view
   (SAP_PLANT_CODE, PLANT_DESC, PLANT_LUPDP, PLANT_LUPDT)
AS 
SELECT 
-- ************************************************************************ 
-- Please note that this view will only work if an equivelant username and 
-- password on the Data Warehouse side exists. 
-- ************************************************************************ 
  SAP_PLANT_CODE, 
  PLANT_DESC, 
  PLANT_LUPDP, 
  PLANT_LUPDT
FROM 
  PLANT_IN_DW;

/*-*/
/* Authority
/*-*/
grant select on od.plant_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym plant_view for od.plant_view;