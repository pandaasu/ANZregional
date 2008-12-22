DROP VIEW MANU.BOM_VW;

/* Formatted on 2008/12/22 11:32 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.bom_vw (plant,
                                          bom_code,
                                          alt,
                                          matl_code,
                                          batch_qty,
                                          batch_uom,
                                          eff_start_date,
                                          eff_end_date,
                                          seq,
                                          detseq,
                                          sub_matl_code,
                                          qty,
                                          uom
                                         )
AS
  SELECT a."PLANT", a."BOM_CODE", a."ALT", a."MATL_CODE", a."BATCH_QTY",
         a."BATCH_UOM", a."EFF_START_DATE", a."EFF_END_DATE", a."SEQ",
         a."DETSEQ", a."SUB_MATL_CODE", a."QTY", a."UOM"
    FROM bom a;


GRANT SELECT ON MANU.BOM_VW TO MANU_APP WITH GRANT OPTION;

