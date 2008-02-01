/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : ftr_material_hier_view
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
create or replace force view ftr_app.ftr_material_hier_view
   (BUS_SGMNT_CODE, BUS_SGMNT_DESC, BUS_SGMNT_ABBRD_DESC, MKT_SGMNT_CODE, MKT_SGMNT_DESC, 
 MKT_SGMNT_ABBRD_DESC, PRD_CATE_CODE, PRD_CATE_DESC, PRD_CATE_ABBRD_DESC, BRAND_CODE, 
 BRAND_DESC, BRAND_ABBRD_DESC, PACK_SIZE_CODE, PACK_SIZE_DESC, PACK_SIZE_ABBRD_DESC, 
 VARIETY_CODE, VARIETY_DESC, VARIETY_ABBRD_DESC, TDU_MATERIAL_CODE, 
 TDU_MATERIAL_DESC, TDU_MATERIAL_DESC_EN, TDU_EAN_UPC, RSU_MATERIAL_CODE, 
 RSU_MATERIAL_DESC, RSU_MATERIAL_DESC_EN, RSU_EAN_UPC, RSU_GROSS_WGT, RSU_VOL)
AS 
SELECT
    BUS_SGMNT_CODE,
    BUS_SGMNT_DESC,
    BUS_SGMNT_ABBRD_DESC,
    MKT_SGMNT_CODE,
    MKT_SGMNT_DESC,
    MKT_SGMNT_ABBRD_DESC,
    PRD_CATE_CODE,
    PRD_CATE_DESC,
    PRD_CATE_ABBRD_DESC,
    BRAND_CODE,
    BRAND_DESC,
    BRAND_ABBRD_DESC,
    PACK_SIZE_CODE,
    PACK_SIZE_DESC,
    PACK_SIZE_ABBRD_DESC,
    VARIETY_CODE,
    VARIETY_DESC,
    VARIETY_ABBRD_DESC,
    TDU_MATERIAL_CODE,
    TDU_MATERIAL_DESC,
    TDU_MATERIAL_DESC_EN,
    TDU_EAN_UPC,
    RSU_MATERIAL_CODE,
    RSU_MATERIAL_DESC,
    RSU_MATERIAL_DESC_EN,
    RSU_EAN_UPC,
    RSU_GROSS_WGT,
    RSU_VOL
FROM
    FTR_APP.FTR_MATERIAL_HIER_VIEW1
UNION
SELECT
    BUS_SGMNT_CODE,
    BUS_SGMNT_DESC,
    BUS_SGMNT_ABBRD_DESC,
    MKT_SGMNT_CODE,
    MKT_SGMNT_DESC,
    MKT_SGMNT_ABBRD_DESC,
    PRD_CATE_CODE,
    PRD_CATE_DESC,
    PRD_CATE_ABBRD_DESC,
    BRAND_CODE,
    BRAND_DESC,
    BRAND_ABBRD_DESC,
    PACK_SIZE_CODE,
    PACK_SIZE_DESC,
    PACK_SIZE_ABBRD_DESC,
    VARIETY_CODE,
    VARIETY_DESC,
    VARIETY_ABBRD_DESC,
    TDU_MATERIAL_CODE,
    TDU_MATERIAL_DESC,
    TDU_MATERIAL_DESC_EN,
    TDU_EAN_UPC,
    RSU_MATERIAL_CODE,
    RSU_MATERIAL_DESC,
    RSU_MATERIAL_DESC_EN,
    RSU_EAN_UPC,
    RSU_GROSS_WGT,
    RSU_VOL
FROM
    FTR_APP.FTR_MATERIAL_HIER_VIEW2
WITH READ ONLY;

/*-*/
/* Authority
/*-*/
grant select on ftr_app.ftr_material_hier_view to ftr_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ftr_material_hier_view for ftr_app.ftr_material_hier_view;