/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : mercia_intransit_status_3_view
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
create or replace force view dw_app.mercia_intransit_status_3_view
   (SAP_MATERIAL_CODE,
    SAP_PLANT_CODE,
    SHIPD_QTY) AS 
   SELECT T3.SAP_MATERIAL_CODE, 
          T2.SAP_PLANT_CODE, 
           ROUND(SUM(T2.SHIPD_QTY / DECODE(T6.CONV_FACTOR, NULL, 1, CONV_FACTOR)), 0) AS SHIPD_QTY 
     FROM INTRANSIT_CONTNR_HDR T1, 
          INTRANSIT_CONTNR_DTL T2, 
          MATERIAL_DIM         T3, 
        --  PLANT                T4, 
        --  HANDLING_UNIT_STATUS T5, 
          (SELECT A.SAP_MATERIAL_CODE, 
	           B.NUMERATOR_Y_CONV / B.DENOMINATOR_X_CONV AS CONV_FACTOR 
              FROM MATERIAL_DIM A, 
	           MATERIAL_UOM B 
             WHERE A.SAP_BASE_UOM_CODE = 'KGM' 
	       AND B.SAP_MATERIAL_CODE = A.SAP_MATERIAL_CODE 
	       AND B.ALT_UOM_CODE = 'CS') T6 
    WHERE T1.HANDLING_UNIT_ID = T2.HANDLING_UNIT_ID 
      AND T2.SAP_MATERIAL_CODE = T3.SAP_MATERIAL_CODE 
    --  AND T2.PLANT_CODE = T4.PLANT_CODE 
    --  AND T1.HANDLING_UNIT_STS_CODE = T5.HANDLING_UNIT_STS_CODE 
      AND T1.SAP_HANDLING_UNIT_STS_CODE = '3' 
      AND T3.SAP_BUS_SGMNT_CODE IN ('01','02','05') 
      AND (T3.MATERIAL_TYPE_FLAG_TDU = 'Y' 
           OR T3.MATERIAL_TYPE_FLAG_SFP = 'Y' 
           OR T3.MATERIAL_TYPE_FLAG_INT = 'Y') 
      AND TO_CHAR(T1.IDOC_CREATN_DATE,'YYYYMMDD') = (SELECT TO_CHAR(MAX(IDOC_CREATN_DATE), 'YYYYMMDD') 
                                                       FROM INTRANSIT_CONTNR_HDR) 
      AND T6.SAP_MATERIAL_CODE(+) = T2.SAP_MATERIAL_CODE 
    GROUP BY T3.SAP_MATERIAL_CODE, 
             T2.SAP_PLANT_CODE;

/*-*/
/* Authority
/*-*/
grant select on dw_app.mercia_intransit_status_3_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym mercia_intransit_status_3_view for dw_app.mercia_intransit_status_3_view;


