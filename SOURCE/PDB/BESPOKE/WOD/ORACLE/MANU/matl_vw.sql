DROP VIEW MANU.MATL_VW;

/* Formatted on 2008/12/22 11:33 (Formatter Plus v4.8.8) */
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
                                           back_flush_ind,
                                           brand_flag_code,
                                           brand_flag_long_desc,
                                           rprsnttv_item_code,
                                           matl_sales_text
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
         a."BACK_FLUSH_IND", b.brand_flag_code, c.brand_flag_long_desc,
         rprsnttv_item_code, matl_sales_text
  /*********************************************************************************/
/* 21 Sep 2006 - Jeff Phillipson
/* Modifications TO MATL_VW TO ADD 4 NEW COLUMNS
/* BRAND_FLAG_CODE, BRAND_FLAG_LONG_DESC, RPRSNTTV_ITEM_CODE, MATL_SALES_TEXT
/* BRAND_FLAG_CODE and BRAND_FLAG_LONG_DESC have been taken from the existing
/* snapshot REF_BRAND_FLAG
/* RPRSNTTV_ITEM_CODE and MATL_SALES_TEXT have been derived from a new snapshot created
/* called MATL_RPRSNTTV_XREF - this was added as a simpler way of bringing new data from LADS
/**********************************************************************************/
  FROM   matl a, matl_clssfctn_fg b, ref_brand_flag c, matl_rprsnttv_xref d
   WHERE a.matl_code = b.matl_code(+)
     AND b.brand_flag_code = c.brand_flag_code(+)
     AND a.matl_code = d.matl_code(+)
     AND a.plant = d.plant_code(+);


DROP PUBLIC SYNONYM MATL_VW;

CREATE PUBLIC SYNONYM MATL_VW FOR MANU.MATL_VW;


GRANT SELECT ON MANU.MATL_VW TO MANU_APP WITH GRANT OPTION;

GRANT SELECT ON MANU.MATL_VW TO PUBLIC;

