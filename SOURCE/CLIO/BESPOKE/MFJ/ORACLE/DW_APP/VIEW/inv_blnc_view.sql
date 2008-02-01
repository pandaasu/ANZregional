/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : inv_blnc_view
 Owner  : dw_app

 DESCRIPTION
 -----------
 Data Warehouse - Inventory Balance View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view dw_app.inv_blnc_view as
   (SELECT T4.SAP_BUS_SGMNT_CODE, 
           T1.SAP_PLANT_CODE, 
           T2.SAP_MATERIAL_CODE, 
           ROUND(SUM(T2.INV_LEVEL / DECODE(T8.CONV_FACTOR, NULL, 1, CONV_FACTOR)), 0) AS INV_LEVEL 
      FROM INV_BLNC_HDR T1, 
           INV_BLNC_DTL T2, 
        --   PLANT T3, 
           MATERIAL_DIM T4, 
        --   STORAGE_LOCN T5, 
        --   STOCK_TYPE T6, 
        --   SPECIAL_STOCK_TYPE T7, 
           (SELECT A.SAP_MATERIAL_CODE, 
	           B.NUMERATOR_Y_CONV / B.DENOMINATOR_X_CONV AS CONV_FACTOR 
              FROM MATERIAL_DIM A, 
	           MATERIAL_UOM B 
             WHERE A.SAP_BASE_UOM_CODE = 'KGM' 
	       AND B.SAP_MATERIAL_CODE = A.SAP_MATERIAL_CODE 
	       AND B.ALT_UOM_CODE = 'CS') T8 
     where T1.sap_company_code = T2.sap_company_code
       and T1.sap_plant_code = T2.sap_plant_code
       and T1.sap_storage_locn_code = T2.sap_storage_locn_code
       and T1.blnc_date = T2.blnc_date
       and T1.blnc_time = T2.blnc_time
     --  AND T1.PLANT_CODE = T3.PLANT_CODE 
       AND T1.SAP_PLANT_CODE <> 'JP01' 
       AND T2.SAP_MATERIAL_CODE = T4.SAP_MATERIAL_CODE 
     --  AND T1.STORAGE_LOCN_CODE = T5.STORAGE_LOCN_CODE 
       AND T1.SAP_STORAGE_LOCN_CODE IN ('0001', '0005', '0007', 'INTR') 
     --  AND T2.STOCK_TYPE_CODE = T6.STOCK_TYPE_CODE 
       AND T2.SAP_STOCK_TYPE_CODE = '1' 
     --  AND T2.SPECIAL_STOCK_TYPE_CODE = T7.SPECIAL_STOCK_TYPE_CODE (+) 
       AND (T2.SAP_SPECIAL_STOCK_TYPE_CODE = '?' OR T2.SAP_SPECIAL_STOCK_TYPE_CODE IS NULL) 
       AND T4.SAP_BUS_SGMNT_CODE IN ('01', '02', '05') 
       AND (T4.MATERIAL_TYPE_FLAG_TDU = 'Y' OR T4.MATERIAL_TYPE_FLAG_SFP = 'Y' OR T4.MATERIAL_TYPE_FLAG_INT = 'Y') 
       AND TO_CHAR(T1.BLNC_DATE,'YYYYMMDD') = (SELECT TO_CHAR(MAX(BLNC_DATE), 'YYYYMMDD') 
                                                 FROM INV_BLNC_HDR) 
       AND T8.SAP_MATERIAL_CODE(+) = T2.SAP_MATERIAL_CODE 
     GROUP BY T4.SAP_BUS_SGMNT_CODE,
              T1.SAP_PLANT_CODE, 
              T2.SAP_MATERIAL_CODE);

/*-*/
/* Authority
/*-*/
grant select on dw_app.inv_blnc_view to ml_app;
grant select on dw_app.inv_blnc_view to pb_app;
grant select on dw_app.inv_blnc_view to pp_app;

/*-*/
/* Synonym
/*-*/
create public synonym inv_blnc_view for dw_app.inv_blnc_view;