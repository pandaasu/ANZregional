DROP VIEW MANU.MATL_PLT_VW;

/* Formatted on 2008/12/22 10:53 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.matl_plt_vw (matl_code,
                                               plant,
                                               plant_sts_start,
                                               units_per_case_date,
                                               apn,
                                               units_per_case,
                                               inners_per_case_date,
                                               inners_per_case,
                                               pi_start_date,
                                               pi_end_date,
                                               pllt_gross_wght,
                                               crtns_per_pllt,
                                               crtns_per_layer,
                                               uom_qty
                                              )
AS
  SELECT a."MATL_CODE", a."PLANT", a."PLANT_STS_START",
         a."UNITS_PER_CASE_DATE", a."APN", a."UNITS_PER_CASE",
         a."INNERS_PER_CASE_DATE", a."INNERS_PER_CASE", a."PI_START_DATE",
         a."PI_END_DATE", a."PLLT_GROSS_WGHT", a."CRTNS_PER_PLLT",
         a."CRTNS_PER_LAYER", a."UOM_QTY"
    FROM matl_plt a;


DROP PUBLIC SYNONYM MATL_PLT_VW;

CREATE PUBLIC SYNONYM MATL_PLT_VW FOR MANU.MATL_PLT_VW;


GRANT SELECT ON MANU.MATL_PLT_VW TO MANU_APP WITH GRANT OPTION;

GRANT SELECT ON MANU.MATL_PLT_VW TO PR_USER;

