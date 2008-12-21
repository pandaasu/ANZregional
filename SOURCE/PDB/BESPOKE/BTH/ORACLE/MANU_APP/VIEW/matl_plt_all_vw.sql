DROP VIEW MANU_APP.MATL_PLT_ALL_VW;

/* Formatted on 2008/12/22 10:14 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.matl_plt_all_vw (matl_code,
                                                       matl_desc,
                                                       crtns_per_pllt,
                                                       crtns_per_layer,
                                                       uom_qty,
                                                       matl_type,
                                                       trdd_unit,
                                                       semi_fnshd_prdct
                                                      )
AS
  SELECT "MATL_CODE", "MATL_DESC", "CRTNS_PER_PLLT", "CRTNS_PER_LAYER",
         "UOM_QTY", "MATL_TYPE", "TRDD_UNIT", "SEMI_FNSHD_PRDCT"
    FROM matl_plt_all;


DROP PUBLIC SYNONYM MATL_PLT_ALL_VW;

CREATE PUBLIC SYNONYM MATL_PLT_ALL_VW FOR MANU_APP.MATL_PLT_ALL_VW;


GRANT SELECT ON MANU_APP.MATL_PLT_ALL_VW TO APPSUPPORT;

GRANT SELECT ON MANU_APP.MATL_PLT_ALL_VW TO BTHSUPPORT;

GRANT SELECT ON MANU_APP.MATL_PLT_ALL_VW TO CITECT_USER;

GRANT SELECT ON MANU_APP.MATL_PLT_ALL_VW TO MANU_MAINT;

GRANT SELECT ON MANU_APP.MATL_PLT_ALL_VW TO MANU_USER;

GRANT SELECT ON MANU_APP.MATL_PLT_ALL_VW TO PUBLIC WITH GRANT OPTION;

