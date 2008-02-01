/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : period_order_material_view
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
create or replace force view period_order_material_view
   (SAP_MATERIAL_CODE,
    MATERIAL_DESC_EN,
    MATERIAL_DESC_JA,
    SAP_BRAND_FLAG_CODE,
    BRAND_FLAG_ABBRD_DESC, 
    BRAND_FLAG_DESC) AS 
   SELECT T1.SAP_MATERIAL_CODE, 
          T1.MATERIAL_DESC_EN, 
          T1.MATERIAL_DESC_JA, 
          T1.SAP_BRAND_FLAG_CODE, 
          T1.BRAND_FLAG_ABBRD_DESC, 
          T1.BRAND_FLAG_DESC 
     FROM MATERIAL_DIM T1;

/*-*/
/* Authority
/*-*/
grant select on dw_app.period_order_material_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym period_order_material_view for dw_app.period_order_material_view;