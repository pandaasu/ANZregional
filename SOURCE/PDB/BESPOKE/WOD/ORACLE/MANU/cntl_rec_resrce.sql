DROP VIEW MANU.CNTL_REC_RESRCE;

/* Formatted on 2008/12/22 11:32 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.cntl_rec_resrce (cntl_rec_resrce_id,
                                                   proc_order,
                                                   opertn,
                                                   resrce_code,
                                                   batch_qty,
                                                   batch_uom,
                                                   phantom,
                                                   phantom_desc,
                                                   phantom_qty,
                                                   phantom_uom,
                                                   plant
                                                  )
AS
  SELECT recipe_resource_id cntl_rec_resrce_id, proc_order, operation opertn,
         resource_code resrce_code, batch_qty, batch_uom, phantom,
         phantom_desc, phantom_qty, phantom_uom, plant_code AS plant
    FROM bds_recipe_resource
   WHERE plant_code IN ('AU20', 'AU21', 'AU22', 'AU23', 'AU24', 'AU25');


DROP PUBLIC SYNONYM CNTL_REC_RESRCE;

CREATE PUBLIC SYNONYM CNTL_REC_RESRCE FOR MANU.CNTL_REC_RESRCE;


GRANT SELECT ON MANU.CNTL_REC_RESRCE TO MANU_APP WITH GRANT OPTION;

