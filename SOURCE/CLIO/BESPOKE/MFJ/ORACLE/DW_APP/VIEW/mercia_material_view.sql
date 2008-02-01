/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : mercia_material_view
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
create or replace force view dw_app.mercia_material_view
   (SAP_MATERIAL_CODE,
    MATERIAL_DESC_EN,
    BRAND_FLAG_DESC,
    BRAND_SUB_FLAG_DESC,
    PRDCT_PACK_SIZE_DESC, 
    INGRED_VRTY_DESC,
    BUS_SGMNT_DESC,
    MKT_SGMNT_DESC,
    PRDCT_CTGRY_DESC,
    SUPPLY_SGMNT_DESC, 
    RSU_SAP_MATERIAL_CODE,
    RSU_MATERIAL_DESC_EN,
    PIECES_PER_BASE_UOM) AS 
   SELECT SAP_MATERIAL_CODE, 
          MATERIAL_DESC_EN, 
          BRAND_FLAG_DESC, 
          BRAND_SUB_FLAG_DESC, 
          PRDCT_PACK_SIZE_DESC, 
          INGRED_VRTY_DESC, 
          BUS_SGMNT_DESC, 
          MKT_SGMNT_DESC, 
          PRDCT_CTGRY_DESC, 
          SUPPLY_SGMNT_DESC, 
          RSU_SAP_MATERIAL_CODE, 
          RSU_MATERIAL_DESC_EN, 
          SUM(PIECES_PER_BASE_UOM) AS PIECES_PER_BASE_UOM 
     FROM (SELECT T1.SAP_MATERIAL_CODE, 
                  T1.MATERIAL_DESC_EN, 
                  T1.BRAND_FLAG_DESC, 
                  T1.BRAND_SUB_FLAG_DESC, 
                  T1.PRDCT_PACK_SIZE_DESC, 
                  T1.INGRED_VRTY_DESC, 
                  T1.BUS_SGMNT_DESC, 
                  T1.MKT_SGMNT_DESC, 
                  T1.PRDCT_CTGRY_DESC, 
                  T1.SUPPLY_SGMNT_DESC, 
                  T4.SAP_MATERIAL_CODE AS RSU_SAP_MATERIAL_CODE, 
                  T4.MATERIAL_DESC_EN AS RSU_MATERIAL_DESC_EN, 
                  T2.DENOMINATOR_X_CONV/T2.NUMERATOR_Y_CONV AS PIECES_PER_BASE_UOM 
             FROM MATERIAL_DIM T1, 
                  MATERIAL_UOM T2, 
                  UOM T3, 
                  (SELECT T1.SAP_MATERIAL_CODE, 
                          T4.MATERIAL_DESC AS MATERIAL_DESC_EN 
                     FROM MATERIAL T1, 
                          MATERIAL_CHAIN T2, 
                          MATERIAL T3, 
                          MATERIAL_DESC T4, 
                          LANGUAGE T5 
                    WHERE T1.SAP_MATERIAL_CODE = T2.SAP_MATERIAL_CODE AND 
                          (T1.MATERIAL_TYPE_FLAG_TDU = 'Y' 
	                   OR T1.MATERIAL_TYPE_FLAG_SFP = 'Y' 
		           OR T1.MATERIAL_TYPE_FLAG_INT = 'Y') AND 
                          T2.CMPNT_MATERIAL_CODE = T3.SAP_MATERIAL_CODE AND 
                          T3.MATERIAL_TYPE_FLAG_RSU = 'Y' AND 
                          T3.SAP_MATERIAL_CODE = T4.SAP_MATERIAL_CODE AND 
                          T4.SAP_LANG_CODE = T5.SAP_LANG_CODE AND 
                          T5.SAP_LANG_CODE = 'EN' 
                    GROUP BY T1.SAP_MATERIAL_CODE, 
                             T4.MATERIAL_DESC) T4, 
                  MATERIAL_DESC T5, 
                  LANGUAGE T6 
            WHERE T1.SAP_MATERIAL_CODE = T2.SAP_MATERIAL_CODE (+) AND 
                  T2.ALT_UOM_CODE = T3.SAP_UOM_CODE (+) AND 
                  T3.SAP_UOM_CODE = 'PCE' AND 
                  T1.SAP_MATERIAL_CODE = T4.SAP_MATERIAL_CODE (+) AND 
                  T1.SAP_MATERIAL_CODE = T5.SAP_MATERIAL_CODE AND 
                  T5.SAP_LANG_CODE = T6.SAP_LANG_CODE AND 
                  T6.SAP_LANG_CODE = 'JA' AND 
                  T1.SAP_BUS_SGMNT_CODE IN ('01','02','05') AND 
                  (T1.MATERIAL_TYPE_FLAG_TDU = 'Y' 
                   OR T1.MATERIAL_TYPE_FLAG_SFP = 'Y' 
                   OR T1.MATERIAL_TYPE_FLAG_INT = 'Y') 
              AND T1.SAP_MATERIAL_TYPE_CODE <> 'ZREP' -- 10/09/2003 VM 
            UNION ALL 
           SELECT T1.SAP_MATERIAL_CODE, 
                  T1.MATERIAL_DESC_EN, 
                  T1.BRAND_FLAG_DESC, 
                  T1.BRAND_SUB_FLAG_DESC, 
                  T1.PRDCT_PACK_SIZE_DESC, 
                  T1.INGRED_VRTY_DESC, 
                  T1.BUS_SGMNT_DESC, 
                  T1.MKT_SGMNT_DESC, 
                  T1.PRDCT_CTGRY_DESC, 
                  T1.SUPPLY_SGMNT_DESC, 
                  T4.SAP_MATERIAL_CODE AS RSU_SAP_MATERIAL_CODE, 
                  T4.MATERIAL_DESC_EN AS RSU_MATERIAL_DESC_EN, 
                  0 AS PIECES_PER_BASE_UOM 
             FROM MATERIAL_DIM T1, 
                  MATERIAL_UOM T2, 
                  UOM T3, 
                 (SELECT T1.SAP_MATERIAL_CODE, 
                         T4.MATERIAL_DESC AS MATERIAL_DESC_EN 
                    FROM MATERIAL T1, 
                         MATERIAL_CHAIN T2, 
                         MATERIAL T3, 
                         MATERIAL_DESC T4, 
                         LANGUAGE T5 
                   WHERE T1.SAP_MATERIAL_CODE = T2.SAP_MATERIAL_CODE AND 
                         (T1.MATERIAL_TYPE_FLAG_TDU = 'Y' 
	                  OR T1.MATERIAL_TYPE_FLAG_SFP = 'Y' 
		          OR T1.MATERIAL_TYPE_FLAG_INT = 'Y') AND 
                         T2.CMPNT_MATERIAL_CODE = T3.SAP_MATERIAL_CODE AND 
                         T3.MATERIAL_TYPE_FLAG_RSU = 'Y' AND 
                         T3.SAP_MATERIAL_CODE = T4.SAP_MATERIAL_CODE AND 
                         T4.SAP_LANG_CODE = T5.SAP_LANG_CODE AND 
                         T5.SAP_LANG_CODE = 'EN' 
                   GROUP BY T1.SAP_MATERIAL_CODE, 
                            T4.MATERIAL_DESC) T4, 
                  MATERIAL_DESC T5, 
                  LANGUAGE T6 
            WHERE T1.SAP_MATERIAL_CODE = T2.SAP_MATERIAL_CODE (+) AND 
                  T2.ALT_UOM_CODE = T3.SAP_UOM_CODE (+) AND 
                  T3.SAP_UOM_CODE <> 'PCE' AND 
                  T1.SAP_MATERIAL_CODE = T4.SAP_MATERIAL_CODE (+) AND 
                  T1.SAP_MATERIAL_CODE = T5.SAP_MATERIAL_CODE AND 
                  T5.SAP_LANG_CODE = T6.SAP_LANG_CODE AND 
                  T6.SAP_LANG_CODE = 'JA' AND 
                  T1.SAP_BUS_SGMNT_CODE IN ('01','02','05') AND 
                  (T1.MATERIAL_TYPE_FLAG_TDU = 'Y' 
                   OR T1.MATERIAL_TYPE_FLAG_SFP = 'Y' 
	           OR T1.MATERIAL_TYPE_FLAG_INT = 'Y') 
                  AND T1.SAP_MATERIAL_TYPE_CODE <> 'ZREP'
            GROUP BY T1.SAP_MATERIAL_CODE, 
                     T1.MATERIAL_DESC_EN, 
                     T1.BRAND_FLAG_DESC, 
                     T1.BRAND_SUB_FLAG_DESC, 
                     T1.PRDCT_PACK_SIZE_DESC, 
                     T1.INGRED_VRTY_DESC, 
                     T1.BUS_SGMNT_DESC, 
                     T1.MKT_SGMNT_DESC, 
                     T1.PRDCT_CTGRY_DESC, 
                     T1.SUPPLY_SGMNT_DESC, 
                     T4.SAP_MATERIAL_CODE, 
                     T4.MATERIAL_DESC_EN) 
    GROUP BY SAP_MATERIAL_CODE, 
             MATERIAL_DESC_EN, 
             BRAND_FLAG_DESC, 
             BRAND_SUB_FLAG_DESC, 
             PRDCT_PACK_SIZE_DESC, 
             INGRED_VRTY_DESC, 
             BUS_SGMNT_DESC, 
             MKT_SGMNT_DESC, 
             PRDCT_CTGRY_DESC, 
             SUPPLY_SGMNT_DESC, 
             RSU_SAP_MATERIAL_CODE, 
             RSU_MATERIAL_DESC_EN;

/*-*/
/* Authority
/*-*/
grant select on dw_app.mercia_material_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym mercia_material_view for dw_app.mercia_material_view;


