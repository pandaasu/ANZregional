DROP VIEW MANU_APP.MATL_CLASS_CODES_VW;

/* Formatted on 2008/09/05 10:50 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.matl_class_codes_vw (material_code,
                                                           bus_sgmnt_code,
                                                           bus_sgmnt_desc,
                                                           mkt_sgmnt_code,
                                                           mkt_sgmnt_desc,
                                                           brand_flag_code,
                                                           brand_flag_desc,
                                                           prdct_ctgry_code,
                                                           prdct_ctgry_desc,
                                                           raw_fmly_code,
                                                           raw_fmly_desc,
                                                           raw_sub_fmly_code,
                                                           raw_sub_fmly_desc
                                                          )
AS
  SELECT m.material_code, b.bus_sgmnt_code,
         b.bus_sgmnt_long_desc AS bus_sgmnt_desc, s.mkt_sgmnt_code,
         s.mkt_sgmnt_long_desc AS mkt_sgmnt_desc, f.brand_flag_code,
         f.brand_flag_long_desc AS brand_flag_desc, c.prdct_ctgry_code,
         c.prdct_ctgry_long_desc AS prdct_ctgry_desc, r.raw_fmly_code,
         rf.raw_fmly_long_desc AS raw_fmly_desc, r.raw_sub_fmly_code,
         rsf.raw_sub_fmly_long_desc AS raw_sub_fmly_desc
    FROM matl_clssfctn_fg m,
         ref_bus_sgmnt b,
         ref_brand_flag f,
         ref_prdct_ctgry c,
         ref_mkt_sgmnt s,
         matl_clssfctn_raw r,
         ref_raw_family rf,
         ref_raw_sub_family rsf
   WHERE m.bus_sgmnt_code = b.bus_sgmnt_code(+)
     AND m.brand_flag_code = f.brand_flag_code(+)
     AND m.prdct_ctgry_code = c.prdct_ctgry_code(+)
     AND m.mkt_sgmnt_code = s.mkt_sgmnt_code(+)
     AND m.material_code = r.material_code(+)
     AND r.raw_fmly_code = rf.raw_fmly_code(+)
     AND r.raw_sub_fmly_code = rsf.raw_sub_fmly_code(+);


DROP PUBLIC SYNONYM MATL_CLASS_CODES_VW;

CREATE PUBLIC SYNONYM MATL_CLASS_CODES_VW FOR MANU_APP.MATL_CLASS_CODES_VW;


GRANT SELECT ON MANU_APP.MATL_CLASS_CODES_VW TO MANU_USER;

GRANT SELECT ON MANU_APP.MATL_CLASS_CODES_VW TO PUBLIC WITH GRANT OPTION;

