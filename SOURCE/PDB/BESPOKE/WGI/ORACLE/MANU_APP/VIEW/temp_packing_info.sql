DROP VIEW MANU_APP.TEMP_PACKING_INFO;

/* Formatted on 2008/11/05 13:18 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.temp_packing_info (old_material_code,
                                                         matl_code,
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
                                                         uom_qty,
                                                         rsu_code
                                                        )
AS
  SELECT old_material_code, p."MATL_CODE", p."UNITS_PER_CASE_DATE",
         p."APN_CODE", p."UNITS_PER_CASE", p."INNERS_PER_CASE_DATE",
         p."INNERS_PER_CASE", p."PI_START_DATE", p."PI_END_DATE",
         p."PLLT_GROSS_WGHT", p."CRTNS_PER_PLLT", p."CRTNS_PER_LAYER",
         p."UOM_QTY", p."RSU_CODE"
    FROM material_pllt p, material m
   WHERE p.matl_code = m.material_code;


DROP PUBLIC SYNONYM TEMP_PACKING_INFO;

CREATE PUBLIC SYNONYM TEMP_PACKING_INFO FOR MANU_APP.TEMP_PACKING_INFO;


GRANT SELECT ON MANU_APP.TEMP_PACKING_INFO TO PUBLIC;

GRANT SELECT ON MANU_APP.TEMP_PACKING_INFO TO SHIFTLOG_APP;

