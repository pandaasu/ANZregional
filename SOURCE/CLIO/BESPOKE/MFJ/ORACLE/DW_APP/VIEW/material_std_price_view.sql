/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : material_std_price_view
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
create or replace force view dw_app.material_std_price_view
   (SAP_MATERIAL_CODE,
    SAP_PLANT_CODE,
    PRICE_UNIT,
    STD_PRICE) AS 
   SELECT T1.SAP_MATERIAL_CODE, 
          T2.SAP_PLANT_CODE, 
          T2.PRICE_UNIT, 
          T2.STD_PRICE 
     FROM MATERIAL_DIM T1, 
          MATERIAL_STD_PRICE T2 
     --     PLANT T3,
     --     MATERIAL_DESC T4, 
     --     LANGUAGE T5 
    WHERE T1.SAP_MATERIAL_CODE = T2.SAP_MATERIAL_CODE 
   --   AND T2.PLANT_CODE = T3.PLANT_CODE
      AND NOT(T1.MATERIAL_DESC_JA IS NULL)
   --   AND T1.MATERIAL_CODE = T4.MATERIAL_CODE 
   --   AND T4.LANG_CODE = T5.LANG_CODE 
   --   AND T5.SAP_LANG_CODE = 'JA' 
      AND T1.SAP_BUS_SGMNT_CODE IN ('01', '02', '05') 
      AND (T1.MATERIAL_TYPE_FLAG_TDU = 'Y' 
           OR T1.MATERIAL_TYPE_FLAG_SFP = 'Y' 
           OR T1.MATERIAL_TYPE_FLAG_INT = 'Y');

/*-*/
/* Authority
/*-*/
grant select on dw_app.material_std_price_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym material_std_price_view for dw_app.material_std_price_view;