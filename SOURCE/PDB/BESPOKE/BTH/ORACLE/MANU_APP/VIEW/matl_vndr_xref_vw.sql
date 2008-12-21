DROP VIEW MANU_APP.MATL_VNDR_XREF_VW;

/* Formatted on 2008/12/22 10:13 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.matl_vndr_xref_vw (plant,
                                                         matl_code,
                                                         vndr_code,
                                                         vndr_name,
                                                         eff_start_date,
                                                         eff_end_date,
                                                         plant_from,
                                                         prchsng_org,
                                                         sales_org,
                                                         uom
                                                        )
AS
  SELECT DISTINCT "PLANT", "MATL_CODE", "VNDR_CODE", "VNDR_NAME",
                  "EFF_START_DATE", "EFF_END_DATE", "PLANT_FROM",
                  "PRCHSNG_ORG", "SALES_ORG", "UOM"
             FROM matl_vndr_xref;


DROP PUBLIC SYNONYM MATL_VNDR_XREF_VW;

CREATE PUBLIC SYNONYM MATL_VNDR_XREF_VW FOR MANU_APP.MATL_VNDR_XREF_VW;


GRANT SELECT ON MANU_APP.MATL_VNDR_XREF_VW TO APPSUPPORT;

GRANT SELECT ON MANU_APP.MATL_VNDR_XREF_VW TO BTHSUPPORT;

GRANT SELECT ON MANU_APP.MATL_VNDR_XREF_VW TO MANU_MAINT;

GRANT SELECT ON MANU_APP.MATL_VNDR_XREF_VW TO MANU_USER;

GRANT SELECT ON MANU_APP.MATL_VNDR_XREF_VW TO PUBLIC;

