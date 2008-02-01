/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : mercia_material_moe_view
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
create or replace force view dw_app.mercia_material_moe_view
   (SAP_MATERIAL_CODE,
    SAP_MOE_CODE,
    MOE_DESC) AS 
   SELECT T1.SAP_MATERIAL_CODE, 
          T2.SAP_MOE_CODE, 
          T3.MOE_DESC 
     FROM MATERIAL_DIM T1, 
          MATERIAL_MOE T2, 
          MOE T3
      --    BUS_SGMNT T4, 
      --    MATERIAL_DESC T5, 
      --    LANGUAGE T6 
    WHERE T1.SAP_MATERIAL_CODE = T2.SAP_MATERIAL_CODE 
      AND T2.SAP_MOE_CODE = T3.SAP_MOE_CODE 
    --  AND T1.BUS_SGMNT_CODE = T4.BUS_SGMNT_CODE 
    --  AND T1.MATERIAL_CODE = T5.MATERIAL_CODE 
    --  AND T5.LANG_CODE = T6.LANG_CODE 
    --  AND T6.SAP_LANG_CODE = 'JA' 
      AND T1.SAP_BUS_SGMNT_CODE IN ('01','02','05') 
      AND (T1.MATERIAL_TYPE_FLAG_TDU = 'Y' 
           OR T1.MATERIAL_TYPE_FLAG_SFP = 'Y' 
           OR T1.MATERIAL_TYPE_FLAG_INT = 'Y');

/*-*/
/* Authority
/*-*/
grant select on dw_app.mercia_material_moe_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym mercia_material_moe_view for dw_app.mercia_material_moe_view;
