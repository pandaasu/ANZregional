DROP VIEW MANU.BOM;

/* Formatted on 2008/12/22 11:00 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.bom (plant,
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
  SELECT bom_plant plant, LTRIM (bom_number, '0') bom_code,
         bom_alternative alt, bom_material_code matl_code,
         bom_base_qty batch_qty, bom_base_uom batch_uom,
         bom_eff_from_date eff_start_date, bom_eff_to_date eff_end_date,
         TO_CHAR (TO_NUMBER (item_number)) seq, item_sequence detseq,
         item_material_code sub_matl_code, item_base_qty qty,
         item_base_uom uom
    FROM bds_bom_all
   WHERE bom_plant = 'AU40';


DROP PUBLIC SYNONYM BOM;

CREATE PUBLIC SYNONYM BOM FOR MANU.BOM;


GRANT SELECT ON MANU.BOM TO MANU_APP WITH GRANT OPTION;

