DROP VIEW MANU.MATL_VW;

/* Formatted on 2008/12/22 10:53 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.matl_vw (matl_code,
                                           matl_desc,
                                           plant,
                                           matl_type,
                                           matl_group,
                                           rgnl_code_nmbr,
                                           base_uom,
                                           order_uom,
                                           gross_wght,
                                           net_wght,
                                           dclrd_uom,
                                           lngth,
                                           width,
                                           hght,
                                           uom_for_lwh,
                                           ean_code,
                                           shelf_life,
                                           intrmdt_prdct_cmpnnt,
                                           mrchndsng_unit,
                                           prmtnl_matl,
                                           rtl_sales_unit,
                                           semi_fnshd_prdct,
                                           rprsnttv_item,
                                           trdd_unit,
                                           plant_orntd_matl_type,
                                           unit_cost,
                                           batch_mngmnt_rqrmnt_indctr,
                                           prcrmnt_type,
                                           spcl_prcrmnt_type,
                                           issue_strg_locn,
                                           mrp_cntrllr,
                                           plant_sts_start,
                                           x_plant_matl_sts,
                                           x_plant_matl_sts_start,
                                           dltn_indctr,
                                           plant_sts,
                                           assy_scrap,
                                           comp_scrap,
                                           plnd_price,
                                           vltn_class,
                                           back_flush_ind
                                          )
AS
  SELECT a."MATL_CODE", a."MATL_DESC", a."PLANT", a."MATL_TYPE",
         a."MATL_GROUP", a."RGNL_CODE_NMBR", a."BASE_UOM", a."ORDER_UOM",
         a."GROSS_WGHT", a."NET_WGHT", a."DCLRD_UOM", a."LNGTH", a."WIDTH",
         a."HGHT", a."UOM_FOR_LWH", a."EAN_CODE", a."SHELF_LIFE",
         a."INTRMDT_PRDCT_CMPNNT", a."MRCHNDSNG_UNIT", a."PRMTNL_MATL",
         a."RTL_SALES_UNIT", a."SEMI_FNSHD_PRDCT", a."RPRSNTTV_ITEM",
         a."TRDD_UNIT", a."PLANT_ORNTD_MATL_TYPE", a."UNIT_COST",
         a."BATCH_MNGMNT_RQRMNT_INDCTR", a."PRCRMNT_TYPE",
         a."SPCL_PRCRMNT_TYPE", a."ISSUE_STRG_LOCN", a."MRP_CNTRLLR",
         a."PLANT_STS_START", a."X_PLANT_MATL_STS",
         a."X_PLANT_MATL_STS_START", a."DLTN_INDCTR", a."PLANT_STS",
         a."ASSY_SCRAP", a."COMP_SCRAP", a."PLND_PRICE", a."VLTN_CLASS",
         a."BACK_FLUSH_IND"
    FROM matl a;


DROP PUBLIC SYNONYM MATL_VW;

CREATE PUBLIC SYNONYM MATL_VW FOR MANU.MATL_VW;


GRANT SELECT ON MANU.MATL_VW TO MANU_APP;

GRANT SELECT ON MANU.MATL_VW TO PR_USER;

