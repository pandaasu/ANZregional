DROP VIEW MANU.OLD_MATL_VNDR_XREF_TEST;

/* Formatted on 2008/12/22 10:53 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.old_matl_vndr_xref_test (plant,
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
  SELECT a."PLANT", a."MATL_CODE", a."VNDR_CODE", a."VNDR_NAME",
         a."EFF_START_DATE", a."EFF_END_DATE", a."PLANT_FROM",
         a."PRCHSNG_ORG", a."SALES_ORG", a."UOM"
    FROM matl_vndr_xref@ap0052t a
   WHERE plant IN ('AU10');


GRANT SELECT ON MANU.OLD_MATL_VNDR_XREF_TEST TO MANU_APP WITH GRANT OPTION;

