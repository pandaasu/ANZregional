DROP VIEW MANU.BOM_VW;

/* Formatted on 2008/12/22 11:24 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.bom_vw (plant,
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
  SELECT plant, bom_code, alternate, material, batch_qty, batch_uom,
         eff_start_date, eff_end_date, seq, detseq, sub_matl, qty, uom
    FROM bom;


DROP PUBLIC SYNONYM BOM_VW;

CREATE PUBLIC SYNONYM BOM_VW FOR MANU.BOM_VW;


GRANT SELECT ON MANU.BOM_VW TO MANU_APP WITH GRANT OPTION;

