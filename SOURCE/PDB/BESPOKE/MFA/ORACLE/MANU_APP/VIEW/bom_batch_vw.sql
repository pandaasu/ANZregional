DROP VIEW MANU_APP.BOM_BATCH_VW;

/* Formatted on 2008/09/05 10:49 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.bom_batch_vw (plant,
                                                    bom_code,
                                                    alternate,
                                                    material,
                                                    batch_qty,
                                                    batch_uom,
                                                    eff_start_date,
                                                    eff_end_date,
                                                    seq,
                                                    det_seq,
                                                    sub_matl,
                                                    qty,
                                                    uom
                                                   )
AS
  SELECT "PLANT", "BOM_CODE", "ALTERNATE", "MATERIAL", "BATCH_QTY",
         "BATCH_UOM", "EFF_START_DATE", "EFF_END_DATE", "SEQ", "DET_SEQ",
         "SUB_MATL", "QTY", "UOM"
    FROM bom_vw a
   WHERE (a.material, eff_start_date) =
           (SELECT   material, MAX (eff_start_date)
                FROM bom_vw b
               WHERE a.material = b.material
                 AND alternate = get_alternate (material)
            GROUP BY material);


GRANT SELECT ON MANU_APP.BOM_BATCH_VW TO MANU_USER;

