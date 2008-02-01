/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : mercia_intransit_contnr_view
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
create or replace force view dw_app.mercia_intransit_contnr_view
   (SAP_MATERIAL_CODE,
    SAP_BUS_SGMNT_CODE,
    SAP_PLANT_CODE,
    SAP_STORAGE_LOCN_CODE,
    SHIPD_QTY, 
    SAP_HANDLING_UNIT_STS_CODE,
    WHSE_ESTD_ARRIVAL_DATE,
    PURCH_ORDER_NUM,
    VESSEL_DESC,
    CONTNR_NUM) AS 
   SELECT T3.SAP_MATERIAL_CODE, 
          T3.SAP_BUS_SGMNT_CODE, 
          T2.SAP_PLANT_CODE, 
          T2.SAP_STORAGE_LOCN_CODE, 
          ROUND(SUM(T2.SHIPD_QTY / DECODE(T7.CONV_FACTOR, NULL, 1, CONV_FACTOR)), 0) AS SHIPD_QTY, 
          T1.SAP_HANDLING_UNIT_STS_CODE, 
          T1.WHSE_ESTD_ARRIVAL_DATE, 
          T1.PURCH_ORDER_NUM, 
          T1.VESSEL_DESC, 
          T1.CONTNR_NUM 
     FROM INTRANSIT_CONTNR_HDR T1, 
          INTRANSIT_CONTNR_DTL T2, 
          MATERIAL_DIM T3, 
     --     PLANT T4, 
     --     STORAGE_LOCN T5, 
     --     HANDLING_UNIT_STATUS T6, 
          (SELECT A.SAP_MATERIAL_CODE, 
	           B.NUMERATOR_Y_CONV / B.DENOMINATOR_X_CONV AS CONV_FACTOR 
              FROM MATERIAL_DIM A, 
	           MATERIAL_UOM B 
             WHERE A.SAP_BASE_UOM_CODE = 'KGM' 
	       AND B.SAP_MATERIAL_CODE = A.SAP_MATERIAL_CODE 
	       AND B.ALT_UOM_CODE = 'CS') T7 
    WHERE T1.HANDLING_UNIT_ID = T2.HANDLING_UNIT_ID 
      AND T2.SAP_MATERIAL_CODE = T3.SAP_MATERIAL_CODE 
  --    AND T2.PLANT_CODE = T4.PLANT_CODE 
  --    AND T2.STORAGE_LOCN_CODE = T5.STORAGE_LOCN_CODE 
  --    AND T1.HANDLING_UNIT_STS_CODE = T6.HANDLING_UNIT_STS_CODE 
      AND T1.SAP_HANDLING_UNIT_STS_CODE IN ('1', '2', '3') 
      AND T3.SAP_BUS_SGMNT_CODE IN ('01', '02', '05') 
      AND (T3.MATERIAL_TYPE_FLAG_TDU = 'Y' 
           OR T3.MATERIAL_TYPE_FLAG_SFP = 'Y' 
           OR T3.MATERIAL_TYPE_FLAG_INT = 'Y') 
      AND TO_CHAR(T1.IDOC_CREATN_DATE, 'YYYYMMDD') = (SELECT TO_CHAR(MAX(IDOC_CREATN_DATE), 'YYYYMMDD') 
                                                        FROM INTRANSIT_CONTNR_HDR) 
      AND T7.SAP_MATERIAL_CODE(+) = T2.SAP_MATERIAL_CODE 
    GROUP BY T3.SAP_MATERIAL_CODE, 
             T3.SAP_BUS_SGMNT_CODE, 
             T2.SAP_PLANT_CODE, 
             T2.SAP_STORAGE_LOCN_CODE, 
             T1.SAP_HANDLING_UNIT_STS_CODE, 
             T1.WHSE_ESTD_ARRIVAL_DATE, 
             T1.PURCH_ORDER_NUM, 
             T1.VESSEL_DESC, 
             T1.CONTNR_NUM;

/*-*/
/* Authority
/*-*/
grant select on dw_app.mercia_intransit_contnr_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym mercia_intransit_contnr_view for dw_app.mercia_intransit_contnr_view;


