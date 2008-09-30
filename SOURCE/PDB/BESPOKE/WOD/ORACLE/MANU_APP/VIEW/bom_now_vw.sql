DROP VIEW MANU_APP.BOM_NOW_VW;

/* Formatted on 2008/10/01 09:01 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.bom_now_vw (plant,
                                                  bom_code,
                                                  alt,
                                                  matl_code,
                                                  batch_qty,
                                                  batch_uom,
                                                  eff_start_date,
                                                  eff_end_date,
                                                  seq,
                                                  sub_matl_code,
                                                  qty,
                                                  uom
                                                 )
AS
  SELECT   plant, bom_code, alt, matl_code, batch_qty, batch_uom,
           MAX (eff_start_date) eff_start_date,
           MAX (eff_end_date) eff_end_date, seq, sub_matl_code, qty, uom
      FROM bom
     WHERE alt = get_alternate (matl_code)
  GROUP BY plant,
           bom_code,
           alt,
           matl_code,
           batch_qty,
           batch_uom,
           seq,
           sub_matl_code,
           qty,
           uom;


GRANT SELECT ON MANU_APP.BOM_NOW_VW TO APPSUPPORT;

GRANT SELECT ON MANU_APP.BOM_NOW_VW TO MANU_MAINT;

GRANT SELECT ON MANU_APP.BOM_NOW_VW TO MANU_USER;

