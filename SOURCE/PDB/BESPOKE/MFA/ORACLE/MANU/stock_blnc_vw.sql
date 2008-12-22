DROP VIEW MANU.STOCK_BLNC_VW;

/* Formatted on 2008/12/22 11:05 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.stock_blnc_vw (plant,
                                                 strg_lctn,
                                                 stock_blnc_date,
                                                 stock_blnc_time,
                                                 matl_code,
                                                 spcl_stock_indctr,
                                                 qty_in_stock,
                                                 stock_uom,
                                                 best_bfr_date,
                                                 cnsgnmnt_cust_or_vend,
                                                 rcvng_or_issng_lctn,
                                                 stock_type
                                                )
AS
  SELECT "PLANT", "STRG_LCTN", "STOCK_BLNC_DATE", "STOCK_BLNC_TIME",
         LTRIM (matl_code, '0') matl_code, "SPCL_STOCK_INDCTR",
         "QTY_IN_STOCK", "STOCK_UOM", "BEST_BFR_DATE",
         "CNSGNMNT_CUST_OR_VEND", "RCVNG_OR_ISSNG_LCTN", "STOCK_TYPE"
    FROM stock_blnc;


DROP PUBLIC SYNONYM STOCK_BLNC_VW;

CREATE PUBLIC SYNONYM STOCK_BLNC_VW FOR MANU.STOCK_BLNC_VW;


GRANT SELECT ON MANU.STOCK_BLNC_VW TO MANU_APP;

GRANT SELECT ON MANU.STOCK_BLNC_VW TO MANU_USER;

