/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : period_order_view
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
create or replace force view period_order_view
   (SAP_MATERIAL_CODE,
    SAP_BUS_SGMNT_CODE,
    SAP_PLANT_CODE,
    SAP_STORAGE_LOCN_CODE,
    SHIPD_QTY, 
    WHSE_ESTD_ARRIVAL_DATE,
    SAP_HANDLING_UNIT_STS_CODE,
    sap_prv_handling_unit_sts_code) AS 
   SELECT T5.SAP_MATERIAL_CODE, 
          T5.SAP_BUS_SGMNT_CODE, 
          T6.SAP_PLANT_CODE, 
          T7.SAP_STORAGE_LOCN_CODE, 
          ROUND(SUM(T2.SHIPD_QTY / DECODE(T8.CONV_FACTOR,NULL,1,CONV_FACTOR)),0) AS SHIPD_QTY, 
          T1.WHSE_ESTD_ARRIVAL_DATE, 
          T3.SAP_HANDLING_UNIT_STS_CODE AS SAP_HANDLING_UNIT_STS_CODE, 
          T4.SAP_HANDLING_UNIT_STS_CODE AS sap_prv_handling_unit_sts_code
     FROM INTRANSIT_CONTNR_HDR T1, 
          INTRANSIT_CONTNR_DTL T2, 
          HANDLING_UNIT_STATUS T3, 
          HANDLING_UNIT_STATUS T4, 
          MATERIAL_DIM T5, 
          PLANT T6, 
          STORAGE_LOCN T7, 
          (SELECT A.SAP_MATERIAL_CODE,
                  B.NUMERATOR_Y_CONV / B.DENOMINATOR_X_CONV AS CONV_FACTOR 
             FROM MATERIAL_DIM A,
                  MATERIAL_UOM B 
            WHERE A.SAP_BASE_UOM_CODE = 'KGM'
              AND B.SAP_MATERIAL_CODE = A.SAP_MATERIAL_CODE
              AND B.ALT_UOM_CODE = 'CS') T8 
    WHERE T1.handling_unit_id = T2.handling_unit_id AND 
          T1.SAP_HANDLING_UNIT_STS_CODE = T3.SAP_HANDLING_UNIT_STS_CODE AND 
          T2.SAP_MATERIAL_CODE = T5.SAP_MATERIAL_CODE AND 
          T2.SAP_PLANT_CODE = T6.SAP_PLANT_CODE AND 
          T2.SAP_STORAGE_LOCN_CODE = T7.SAP_STORAGE_LOCN_CODE AND 
          T3.SAP_HANDLING_UNIT_STS_CODE IN ('1','2','3','4') AND 
          T1.sap_prv_handling_unit_sts_code = T4.SAP_HANDLING_UNIT_STS_CODE (+) AND 
          T5.SAP_BUS_SGMNT_CODE IN ('01','02','05')  AND 
          T8.SAP_MATERIAL_CODE(+) = T2.SAP_MATERIAL_CODE 
    GROUP BY T5.SAP_MATERIAL_CODE, 
             T5.SAP_BUS_SGMNT_CODE, 
             T6.SAP_PLANT_CODE, 
             T7.SAP_STORAGE_LOCN_CODE, 
             T1.WHSE_ESTD_ARRIVAL_DATE, 
             T3.SAP_HANDLING_UNIT_STS_CODE, 
             T4.SAP_HANDLING_UNIT_STS_CODE;

/*-*/
/* Authority
/*-*/
grant select on dw_app.period_order_view to bo_user;
grant select on dw_app.period_order_view to pb_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym period_order_view for dw_app.period_order_view;

