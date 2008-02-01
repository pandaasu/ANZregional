/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : chain_check
 Owner  : ftr_app

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
create or replace force view ftr_app.chain_check
   (CHAIN_MATERIAL_CODE, CHN_TDU, CHN_MCU, CHN_RSU, CMPNT_MATERIAL_CODE, 
 CMP_TDU, CMP_MCU, CMP_RSU, CMPNT_QTY, LUPDT)
AS 
SELECT 
    SAP_MTR.SAP_MATERIAL_CODE AS CHAIN_MATERIAL_CODE, 
    SAP_MTR.MATERIAL_TYPE_FLAG_TDU AS CHN_TDU,
    SAP_MTR.MATERIAL_TYPE_FLAG_MCU AS CHN_MCU,
    SAP_MTR.MATERIAL_TYPE_FLAG_RSU AS CHN_RSU,
    SAP_CMP.SAP_MATERIAL_CODE AS CMPNT_MATERIAL_CODE, 
    SAP_CMP.MATERIAL_TYPE_FLAG_TDU AS CMP_TDU,
    SAP_CMP.MATERIAL_TYPE_FLAG_MCU AS CMP_MCU,
    SAP_CMP.MATERIAL_TYPE_FLAG_RSU AS CMP_RSU,
    CASE
        WHEN CHAIN.CMPNT_QTY >= 1000 THEN CHAIN.CMPNT_QTY /1000
        ELSE CHAIN.CMPNT_QTY
    END CMPNT_QTY,
    CHAIN.MATERIAL_CHAIN_LUPDT
FROM
    OD.MATERIAL SAP_MTR,
    OD.MATERIAL SAP_CMP,
    OD.MATERIAL_CHAIN CHAIN
WHERE
    SAP_MTR.SAP_MATERIAL_CODE = CHAIN.SAP_MATERIAL_CODE AND
    SAP_CMP.SAP_MATERIAL_CODE = CHAIN.CMPNT_MATERIAL_CODE
ORDER BY
    SAP_MTR.SAP_MATERIAL_CODE, 
    SAP_CMP.SAP_MATERIAL_CODE, 
    CHAIN.MATERIAL_CHAIN_LUPDT;

/*-*/
/* Authority
/*-*/
grant select on ftr_app.chain_check to ftr_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym chain_check for ftr_app.chain_check;