DROP VIEW MANU_APP.BDS_BOM_ALL_VERIFICATION;

/* Formatted on 2008/10/01 09:01 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.bds_bom_all_verification (plant,
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
  SELECT                                                              --'NEW',
         bom_plant AS plant, LTRIM (bom_number, '0') AS bom_code,
         bom_alternative AS alt, bom_material_code AS matl_code,
         bom_base_qty AS batch_qty, bom_base_uom AS batch_uom,
         bom_eff_from_date AS eff_start_date, bom_eff_to_date AS eff_end_date,
         '' AS seq, item_sequence AS detseq,
         item_material_code AS sub_matl_code, item_base_qty AS qty,
         item_base_uom AS uom
    FROM bds_bom_all_ics t01
   WHERE bom_plant IN ('AU20', 'AU21', 'AU22', 'AU23', 'AU24', 'AU25')
     AND TO_NUMBER (bom_status) = 1
--ORDER BY 2,5,12,4,1;;


