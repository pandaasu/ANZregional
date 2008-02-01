/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : material_cross_ref_view
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
create or replace force view material_cross_ref_view
   (SAP_MATERIAL_CODE,
    SAP_MATL_CROSS_REF_TYPE_CODE,
    MATERIAL_CROSS_REF_TYPE_DESC,
    MATERIAL_CROSS_REF) AS 
   SELECT T1.SAP_MATERIAL_CODE, 
          T2.SAP_MATL_CROSS_REF_TYPE_CODE, 
          T2.MATERIAL_CROSS_REF_TYPE_DESC, 
          T3.MATERIAL_CROSS_REF 
     FROM MATERIAL_DIM T1, 
          MATERIAL_CROSS_REF_TYPE T2, 
          MATERIAL_CROSS_REF T3 
     --     MATERIAL_DESC T4
     --     LANGUAGE T5 
    WHERE T1.SAP_MATERIAL_CODE = T3.SAP_MATERIAL_CODE 
      AND T3.SAP_MATL_CROSS_REF_TYPE_CODE = T2.SAP_MATL_CROSS_REF_TYPE_CODE
      AND NOT(T1.MATERIAL_DESC_JA IS NULL) 
    --  AND T1.SAP_MATERIAL_CODE = T4.SAP_MATERIAL_CODE 
    --  AND T4.LANG_CODE = T5.LANG_CODE 
    --  AND T4.SAP_LANG_CODE = 'JA' 
      AND T1.SAP_BUS_SGMNT_CODE IN ('01', '02', '05') 
      AND (T1.MATERIAL_TYPE_FLAG_TDU = 'Y' 
           OR T1.MATERIAL_TYPE_FLAG_SFP = 'Y' 
           OR T1.MATERIAL_TYPE_FLAG_INT = 'Y');

/*-*/
/* Authority
/*-*/
grant select on dw_app.material_cross_ref_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym material_cross_ref_view for dw_app.material_cross_ref_view;


