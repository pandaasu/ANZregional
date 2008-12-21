DROP VIEW MANU_APP.MATL_PLT_VW_OLD;

/* Formatted on 2008/12/22 10:13 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.matl_plt_vw_old (matl_code,
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
  SELECT "MATL_CODE", "PLANT", "PLANT_STS_START", "UNITS_PER_CASE_DATE",
         "APN", "UNITS_PER_CASE", "INNERS_PER_CASE_DATE", "INNERS_PER_CASE",
         "PI_START_DATE", "PI_END_DATE", "PLLT_GROSS_WGHT", "CRTNS_PER_PLLT",
         "CRTNS_PER_LAYER", "UOM_QTY"
    FROM matl_plt;


