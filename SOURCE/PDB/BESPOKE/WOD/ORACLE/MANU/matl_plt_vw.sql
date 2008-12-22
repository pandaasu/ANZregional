DROP VIEW MANU.MATL_PLT_VW;

/* Formatted on 2008/12/22 11:33 (Formatter Plus v4.8.8) */
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
  SELECT matl_code, plant, plant_sts_start, units_per_case_date, apn,
         units_per_case, inners_per_case_date, 0 inners_per_case,
         pi_start_date, pi_end_date, pllt_gross_wght, crtns_per_pllt,
         crtns_per_layer, uom_qty
    FROM matl_plt a
  UNION
  SELECT matl_code, plant, plant_sts_start, units_per_case_date, apn,
         units_per_case, SYSDATE, 0, pi_start_date, pi_end_date,
         pllt_gross_wght, crtns_per_pllt, crtns_per_layer, uom_qty
    FROM matl_int_plt b;


DROP PUBLIC SYNONYM MATL_PLT_VW;

CREATE PUBLIC SYNONYM MATL_PLT_VW FOR MANU.MATL_PLT_VW;


GRANT SELECT ON MANU.MATL_PLT_VW TO MANU_APP WITH GRANT OPTION;

