/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : material_chain_pre0_view
 Owner  : dw_app

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
create or replace force view material_chain_pre0_view
   (SAP_MATERIAL_CODE,
    VALID_FROM_DATE,
    CMPNT_MATERIAL_CODE,
    CMPNT_QTY,
    CMPNT_UOM_CODE) AS 
   SELECT SAP_MATERIAL_CODE,
          MAX(MATERIAL_CHAIN_VALID_FROM_DATE) AS VALID_FROM_DATE,
          CMPNT_MATERIAL_CODE,
          CMPNT_QTY,
          CMPNT_UOM_CODE
     FROM MATERIAL_CHAIN
    GROUP BY SAP_MATERIAL_CODE,
             CMPNT_MATERIAL_CODE,
             CMPNT_QTY,
             CMPNT_UOM_CODE;

/*-*/
/* Authority
/*-*/
grant select on dw_app.material_chain_pre0_view to bo_user;

/*-*/
/* Synonym
/*-*/
create public synonym material_chain_pre0_view for dw_app.material_chain_pre0_view;



