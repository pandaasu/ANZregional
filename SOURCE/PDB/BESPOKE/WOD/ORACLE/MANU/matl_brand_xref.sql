DROP VIEW MANU.MATL_BRAND_XREF;

/* Formatted on 2008/12/22 11:33 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.matl_brand_xref (matl_code,
                                                   brand_flag_code,
                                                   brand_flag_short_desc,
                                                   brand_flag_long_desc
                                                  )
AS
  SELECT matl_code, b.brand_flag_code, brand_flag_short_desc,
         brand_flag_long_desc
    FROM matl_clssfctn_fg c, ref_brand_flag b
   WHERE b.brand_flag_code = c.brand_flag_code;


DROP PUBLIC SYNONYM MATL_BRAND_XREF;

CREATE PUBLIC SYNONYM MATL_BRAND_XREF FOR MANU.MATL_BRAND_XREF;


GRANT SELECT ON MANU.MATL_BRAND_XREF TO MANU_APP WITH GRANT OPTION;

