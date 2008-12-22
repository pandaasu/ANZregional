DROP VIEW MANU.CNTL_REC_BOM_VW;

/* Formatted on 2008/12/22 11:25 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.cntl_rec_bom_vw (cntl_rec_bom_id,
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
                                                   reservation
                                                  )
AS
  SELECT "CNTL_REC_BOM_ID", LTRIM (proc_order, 0) proc_order, "OPERATION",
         "PHASE", "SEQ", LTRIM (material_code, '0') material_code,
         "MATERIAL_DESC", "MATERIAL_QTY", "MATERIAL_UOM", "MATERIAL_PRNT",
         "BF_ITEM", "RESERVATION"
    FROM cntl_rec_bom;


DROP PUBLIC SYNONYM CNTL_REC_BOM_VW;

CREATE PUBLIC SYNONYM CNTL_REC_BOM_VW FOR MANU.CNTL_REC_BOM_VW;


GRANT SELECT ON MANU.CNTL_REC_BOM_VW TO MANU_APP WITH GRANT OPTION;

