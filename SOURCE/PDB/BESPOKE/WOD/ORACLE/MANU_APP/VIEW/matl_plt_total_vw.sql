DROP VIEW MANU_APP.MATL_PLT_TOTAL_VW;

/* Formatted on 2008/10/01 09:01 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.matl_plt_total_vw (matl_code,
                                                         plant,
                                                         units_per_case,
                                                         crtns_per_pllt
                                                        )
AS
  SELECT matl_code, plant, units_per_case, crtns_per_pllt
    FROM matl_plt
  UNION
  SELECT matl_code, plant, units_per_case, crtns_per_pllt
    FROM matl_int_plt;


GRANT SELECT ON MANU_APP.MATL_PLT_TOTAL_VW TO APPSUPPORT;

GRANT SELECT ON MANU_APP.MATL_PLT_TOTAL_VW TO MANU_MAINT;

GRANT SELECT ON MANU_APP.MATL_PLT_TOTAL_VW TO MANU_USER;

GRANT SELECT ON MANU_APP.MATL_PLT_TOTAL_VW TO PUBLIC WITH GRANT OPTION;

