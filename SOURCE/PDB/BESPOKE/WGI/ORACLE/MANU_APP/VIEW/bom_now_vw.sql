DROP VIEW MANU_APP.BOM_NOW_VW;

/* Formatted on 2008/11/05 13:13 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.bom_now_vw (plant,
                                                  bom_code,
                                                  alternate,
                                                  material,
                                                  batch_qty,
                                                  batch_uom,
                                                  eff_start_date,
                                                  eff_end_date,
                                                  seq,
                                                  sub_matl,
                                                  qty,
                                                  uom
                                                 )
AS
  SELECT   plant, bom_code, alternate, material, batch_qty, batch_uom,
           MAX (eff_start_date) eff_start_date,
           MAX (eff_end_date) eff_end_date, seq, sub_matl, qty, uom
      FROM bom
     WHERE alternate = get_alternate (material)
  GROUP BY plant,
           bom_code,
           alternate,
           material,
           batch_qty,
           batch_uom,
           seq,
           sub_matl,
           qty,
           uom;


DROP PUBLIC SYNONYM BOM_NOW_VW;

CREATE PUBLIC SYNONYM BOM_NOW_VW FOR MANU_APP.BOM_NOW_VW;


GRANT SELECT ON MANU_APP.BOM_NOW_VW TO APPSUPPORT;

GRANT SELECT ON MANU_APP.BOM_NOW_VW TO PT_APP;

GRANT SELECT ON MANU_APP.BOM_NOW_VW TO SHIFTLOG;

GRANT SELECT ON MANU_APP.BOM_NOW_VW TO SHIFTLOG_APP;

GRANT SELECT ON MANU_APP.BOM_NOW_VW TO SITESUPPORT;

