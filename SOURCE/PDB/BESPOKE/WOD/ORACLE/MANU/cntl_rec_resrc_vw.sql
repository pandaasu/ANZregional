DROP VIEW MANU.CNTL_REC_RESRC_VW;

/* Formatted on 2008/12/22 11:33 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.cntl_rec_resrc_vw (cntl_rec_resrce_id,
                                                     proc_order,
                                                     opertn,
                                                     resrce_code,
                                                     batch_qty,
                                                     batch_uom,
                                                     phantom,
                                                     phantom_desc,
                                                     phantom_qty,
                                                     phantom_uom
                                                    )
AS
  SELECT "CNTL_REC_RESRCE_ID", LTRIM (proc_order, '0') proc_order, "OPERTN",
         "RESRCE_CODE", "BATCH_QTY", "BATCH_UOM", "PHANTOM", "PHANTOM_DESC",
         "PHANTOM_QTY", "PHANTOM_UOM"
    FROM cntl_rec_resrce;


DROP PUBLIC SYNONYM CNTL_REC_RESRC_VW;

CREATE PUBLIC SYNONYM CNTL_REC_RESRC_VW FOR MANU.CNTL_REC_RESRC_VW;


GRANT SELECT ON MANU.CNTL_REC_RESRC_VW TO MANU_APP WITH GRANT OPTION;

