DROP VIEW MANU.CNTL_REC_RESOURCE;

/* Formatted on 2008/12/22 11:06 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.cntl_rec_resource (cntl_rec_resource_id,
                                                     proc_order,
                                                     operation,
                                                     resource_code,
                                                     batch_qty,
                                                     batch_uom,
                                                     phantom,
                                                     phantom_desc,
                                                     phantom_qty,
                                                     phantom_uom,
                                                     plant
                                                    )
AS
  SELECT recipe_resource_id cntl_rec_resource_id, proc_order, operation,
         resource_code, batch_qty, batch_uom, phantom, phantom_desc,
         phantom_qty, phantom_uom, plant_code AS plant
    FROM bds_recipe_resource
   WHERE plant_code = 'AU10';


DROP PUBLIC SYNONYM CNTL_REC_RESOURCE;

CREATE PUBLIC SYNONYM CNTL_REC_RESOURCE FOR MANU.CNTL_REC_RESOURCE;


GRANT SELECT ON MANU.CNTL_REC_RESOURCE TO MANU_APP WITH GRANT OPTION;

