DROP VIEW MANU.CNTL_REC_BOM;

/* Formatted on 2008/12/22 11:32 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.cntl_rec_bom (cntl_rec_bom_id,
                                                proc_order,
                                                opertn,
                                                phase,
                                                seq,
                                                matl_code,
                                                matl_desc,
                                                qty,
                                                uom,
                                                prnt,
                                                bf_item,
                                                rsrvtn,
                                                plant,
                                                pan_size,
                                                last_pan_size,
                                                pan_size_flag,
                                                pan_qty,
                                                phantom,
                                                opertn_from
                                               )
AS
  SELECT recipe_bom_id cntl_rec_bom_id, proc_order, operation opertn, phase,
         seq, material_code matl_code, material_desc matl_desc,
         material_qty qty, material_uom uom, material_prnt prnt, bf_item,
         reservation rsrvtn, plant_code plant, pan_size, last_pan_size,
         pan_size_flag, pan_qty, phantom, operation_from opertn_from
    FROM bds_recipe_bom
   WHERE plant_code IN ('AU20', 'AU21', 'AU22', 'AU23', 'AU24', 'AU25');


DROP PUBLIC SYNONYM CNTL_REC_BOM;

CREATE PUBLIC SYNONYM CNTL_REC_BOM FOR MANU.CNTL_REC_BOM;


GRANT SELECT ON MANU.CNTL_REC_BOM TO MANU_APP WITH GRANT OPTION;

