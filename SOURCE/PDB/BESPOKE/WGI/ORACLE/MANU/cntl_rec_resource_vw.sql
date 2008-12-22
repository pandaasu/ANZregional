DROP VIEW MANU.CNTL_REC_RESOURCE_VW;

/* Formatted on 2008/12/22 11:24 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.cntl_rec_resource_vw (cntl_rec_resource_id,
                                                        proc_order,
                                                        operation,
                                                        resource_code,
                                                        batch_qty,
                                                        batch_uom,
                                                        phantom,
                                                        phantom_desc,
                                                        phantom_qty,
                                                        phantom_uom
                                                       )
AS
  SELECT "CNTL_REC_RESOURCE_ID", LTRIM (proc_order, '0') proc_order,
         "OPERATION", "RESOURCE_CODE", "BATCH_QTY", "BATCH_UOM", "PHANTOM",
         "PHANTOM_DESC", "PHANTOM_QTY", "PHANTOM_UOM"
    FROM cntl_rec_resource;


DROP PUBLIC SYNONYM CNTL_REC_RESOURCE_VW;

CREATE PUBLIC SYNONYM CNTL_REC_RESOURCE_VW FOR MANU.CNTL_REC_RESOURCE_VW;


GRANT SELECT ON MANU.CNTL_REC_RESOURCE_VW TO MANU_APP WITH GRANT OPTION;

