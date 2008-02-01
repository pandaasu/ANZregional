/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : distbn_chnl_view
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
create or replace force view od.distbn_chnl_view
   (SAP_DISTBN_CHNL_CODE, DISTBN_CHNL_DESC, DISTBN_CHNL_LUPDP, DISTBN_CHNL_LUPDT)
AS 
SELECT 
-- ************************************************************************ 
-- Please note that this view will only work if an equivelant username and 
-- password on the Data Warehouse side exists. 
-- ************************************************************************ 
  SAP_DISTBN_CHNL_CODE, 
  DISTBN_CHNL_DESC, 
  DISTBN_CHNL_LUPDP, 
  DISTBN_CHNL_LUPDT
FROM 
  DISTBN_CHNL_IN_DW;

/*-*/
/* Authority
/*-*/
grant select on od.distbn_chnl_view to public;

/*-*/
/* Synonym
/*-*/
create or replace public synonym distbn_chnl_view for od.distbn_chnl_view;