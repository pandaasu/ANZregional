/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : std_price_for_jp_view
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
create or replace force view std_price_for_jp_view
   (SAP_MATERIAL_CODE,
    PRICE_UNIT,
    STD_PRICE) AS 
   SELECT T1.SAP_MATERIAL_CODE, 
          T2.PRICE_UNIT, 
          T2.STD_PRICE 
     FROM MATERIAL_DIM T1, 
          MATERIAL_STD_PRICE T2
    WHERE T1.SAP_MATERIAL_CODE = T2.SAP_MATERIAL_CODE 
      AND NOT(T1.MATERIAL_DESC_JA IS NULL)
      AND T2.SAP_PLANT_CODE IN ('JP01','JP14')
      AND (T1.MATERIAL_TYPE_FLAG_TDU = 'Y' 
           OR T1.MATERIAL_TYPE_FLAG_SFP  = 'Y' 
           OR T1.MATERIAL_TYPE_FLAG_INT  = 'Y')
    GROUP BY T1.SAP_MATERIAL_CODE, 
             T2.PRICE_UNIT, 
             T2.STD_PRICE;

/*-*/
/* Authority
/*-*/
grant select on dw_app.std_price_for_jp_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym std_price_for_jp_view for dw_app.std_price_for_jp_view;