DROP VIEW MANU_APP.DMND_PLNNG_CLSTR_VIEW;

/* Formatted on 2008/09/05 10:50 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.dmnd_plnng_clstr_view (plant,
                                                             line_code,
                                                             line_stts,
                                                             line_sort_sqnc,
                                                             clstr_code,
                                                             clstr_stts,
                                                             clstr_sort_sqnc,
                                                             matl_code,
                                                             trgt_wght
                                                            )
AS
  SELECT d.plant_code AS plant, c.line_code AS line_code,
         d.line_status AS line_stts, d.sort_sequence AS line_sort_sqnc,
         b.cluster_code AS clstr_code, c.cluster_status AS clstr_stts,
         c.sort_sequence AS clstr_sort_sqnc, b.material_code AS matl_code,
         b.trgt_wght AS trgt_wght
    FROM material a,
         site_matl_cluster_xref b,
         site_cluster_mstr c,
         site_line d
   WHERE a.material_code = b.material_code
     AND a.material_type = 'FERT'
     AND a.tdu_code = 'X'
     AND b.cluster_code = c.cluster_code
     AND c.line_code = d.line_code;


DROP PUBLIC SYNONYM DMND_PLNNG_CLSTR_VIEW;

CREATE PUBLIC SYNONYM DMND_PLNNG_CLSTR_VIEW FOR MANU_APP.DMND_PLNNG_CLSTR_VIEW;


GRANT SELECT ON MANU_APP.DMND_PLNNG_CLSTR_VIEW TO MANU_USER;

