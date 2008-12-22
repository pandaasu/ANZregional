DROP VIEW MANU.CNTL_REC_BOM_VW;

/* Formatted on 2008/12/22 11:32 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.cntl_rec_bom_vw (cntl_rec_bom_id,
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
                                                   pan_size,
                                                   last_pan_size,
                                                   pan_size_flag,
                                                   pan_qty
                                                  )
AS
  SELECT cntl_rec_bom_id, LTRIM (proc_order, 0) proc_order, opertn, phase,
         seq, LTRIM (matl_code, '0') matl_code, matl_desc, qty, uom, prnt,
         bf_item, rsrvtn, pan_size, last_pan_size, pan_size_flag, pan_qty
    FROM cntl_rec_bom;


DROP PUBLIC SYNONYM CNTL_REC_BOM_VW;

CREATE PUBLIC SYNONYM CNTL_REC_BOM_VW FOR MANU.CNTL_REC_BOM_VW;


GRANT SELECT ON MANU.CNTL_REC_BOM_VW TO MANU_APP WITH GRANT OPTION;

GRANT SELECT ON MANU.CNTL_REC_BOM_VW TO PUBLIC;

