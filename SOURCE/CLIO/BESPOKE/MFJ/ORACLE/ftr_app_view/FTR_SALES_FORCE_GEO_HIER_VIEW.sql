/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : ftr_sales_force_geo_hier_view
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
create or replace force view ftr_app.ftr_sales_force_geo_hier_view
   (SAP_SALES_ORG_CODE, SAP_DIVISION_CODE, SAP_DISTBN_CHNL_CODE, SAP_CUST_CODE_LEVEL_1, CUST_NAME_EN_LEVEL_1, 
 CUST_NAME_JA_LEVEL_1, SAP_CUST_CODE_LEVEL_2, CUST_NAME_EN_LEVEL_2, CUST_NAME_JA_LEVEL_2, SAP_CUST_CODE_LEVEL_3, 
 CUST_NAME_EN_LEVEL_3, CUST_NAME_JA_LEVEL_3, SAP_CUST_CODE_LEVEL_4, CUST_NAME_EN_LEVEL_4, CUST_NAME_JA_LEVEL_4, 
 SAP_CUST_CODE_LEVEL_5, CUST_NAME_EN_LEVEL_5, CUST_NAME_JA_LEVEL_5)
AS 
SELECT DISTINCT
    SOD.SAP_SALES_ORG_CODE,
    DND.SAP_DIVISION_CODE,
    DCD.SAP_DISTBN_CHNL_CODE,
    CD1.SAP_CUST_CODE AS SAP_CUST_CODE_LEVEL_1,
    SFGH.CUST_NAME_EN_LEVEL_1,
    SFGH.CUST_NAME_JA_LEVEL_1,
    CD2.SAP_CUST_CODE AS SAP_CUST_CODE_LEVEL_2,
    SFGH.CUST_NAME_EN_LEVEL_2,
    SFGH.CUST_NAME_JA_LEVEL_2,
    CD3.SAP_CUST_CODE AS SAP_CUST_CODE_LEVEL_3,
    SFGH.CUST_NAME_EN_LEVEL_3,
    SFGH.CUST_NAME_JA_LEVEL_3,
    CD4.SAP_CUST_CODE AS SAP_CUST_CODE_LEVEL_4,
    SFGH.CUST_NAME_EN_LEVEL_4,
    SFGH.CUST_NAME_JA_LEVEL_4,
    CD5.SAP_CUST_CODE AS SAP_CUST_CODE_LEVEL_5,
    SFGH.CUST_NAME_EN_LEVEL_5,
    SFGH.CUST_NAME_JA_LEVEL_5
FROM
    DD.CUST_DIM CD1,
    DD.CUST_DIM CD2,
    DD.CUST_DIM CD3,
    DD.CUST_DIM CD4,
    DD.CUST_DIM CD5,
    DD.SALES_FORCE_GEO_HIER SFGH,
    DD.SALES_ORG_DIM SOD,
    DD.DIVISION_DIM DND,
    DD.DISTBN_CHNL_DIM DCD
WHERE
    SFGH.SAP_CUST_CODE_LEVEL_1 = CD1.SAP_CUST_CODE AND
    SFGH.SAP_CUST_CODE_LEVEL_2 = CD2.SAP_CUST_CODE AND
    SFGH.SAP_CUST_CODE_LEVEL_3 = CD3.SAP_CUST_CODE AND
    SFGH.SAP_CUST_CODE_LEVEL_4 = CD4.SAP_CUST_CODE AND
    SFGH.SAP_CUST_CODE_LEVEL_5 = CD5.SAP_CUST_CODE AND
    SFGH.SAP_SALES_ORG_CODE = SOD.SAP_SALES_ORG_CODE AND
    SFGH.SAP_DIVISION_CODE = DND.SAP_DIVISION_CODE AND
    SFGH.SAP_DISTBN_CHNL_CODE = DCD.SAP_DISTBN_CHNL_CODE AND
    SOD.SAP_SALES_ORG_CODE = '131' AND
    DND.SAP_DIVISION_CODE = '51' AND
    DCD.SAP_DISTBN_CHNL_CODE = '11'
WITH READ ONLY;

/*-*/
/* Authority
/*-*/
grant select on ftr_app.ftr_sales_force_geo_hier_view to ftr_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ftr_sales_force_geo_hier_view for ftr_app.ftr_sales_force_geo_hier_view;