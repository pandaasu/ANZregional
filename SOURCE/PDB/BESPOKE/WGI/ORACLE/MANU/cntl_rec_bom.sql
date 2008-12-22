DROP VIEW MANU.CNTL_REC_BOM;

/* Formatted on 2008/12/22 11:25 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.cntl_rec_bom (cntl_rec_bom_id,
                                                proc_order,
                                                operation,
                                                phase,
                                                seq,
                                                material_code,
                                                material_desc,
                                                material_qty,
                                                material_uom,
                                                material_prnt,
                                                bf_item,
                                                reservation,
                                                plant_code,
                                                pan_size,
                                                last_pan_size,
                                                pan_size_flag,
                                                pan_qty,
                                                phantom,
                                                opertn_from
                                               )
AS
  SELECT recipe_bom_id cntl_rec_bom_id, proc_order, operation, phase, seq,
         material_code, material_desc, material_qty, material_uom,
         material_prnt, bf_item, reservation, plant_code, pan_size,
         last_pan_size, pan_size_flag, pan_qty, phantom,
         operation_from opertn_from
    FROM bds_recipe_bom
   WHERE plant_code = 'NZ01';


DROP PUBLIC SYNONYM CNTL_REC_BOM;

CREATE PUBLIC SYNONYM CNTL_REC_BOM FOR MANU.CNTL_REC_BOM;


GRANT SELECT ON MANU.CNTL_REC_BOM TO MANU_APP WITH GRANT OPTION;

