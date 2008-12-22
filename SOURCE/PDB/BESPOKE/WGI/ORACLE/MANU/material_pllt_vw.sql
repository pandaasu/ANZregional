DROP VIEW MANU.MATERIAL_PLLT_VW;

/* Formatted on 2008/12/22 11:24 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.material_pllt_vw (matl_code,
                                                    units_per_case_date,
                                                    apn_code,
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
  SELECT "MATL_CODE", "UNITS_PER_CASE_DATE", "APN_CODE", "UNITS_PER_CASE",
         "INNERS_PER_CASE_DATE", "INNERS_PER_CASE", "PI_START_DATE",
         "PI_END_DATE", "PLLT_GROSS_WGHT", "CRTNS_PER_PLLT",
         "CRTNS_PER_LAYER", "UOM_QTY"
    FROM material_pllt;


DROP PUBLIC SYNONYM MATERIAL_PLLT_VW;

CREATE PUBLIC SYNONYM MATERIAL_PLLT_VW FOR MANU.MATERIAL_PLLT_VW;


GRANT SELECT ON MANU.MATERIAL_PLLT_VW TO MANU_APP WITH GRANT OPTION;

