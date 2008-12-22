DROP VIEW MANU.CNTL_REC_VW;

/* Formatted on 2008/12/22 11:05 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.cntl_rec_vw (proc_order,
                                               cntl_rec_id,
                                               plant,
                                               cntl_rec_status,
                                               test_flag,
                                               recipe_text,
                                               material,
                                               material_text,
                                               quantity,
                                               insplot,
                                               uom,
                                               batch,
                                               sched_start_datime,
                                               run_start_datime,
                                               run_end_datime,
                                               VERSION,
                                               upd_datime,
                                               cntl_rec_xfer,
                                               teco_status,
                                               storage_locn
                                              )
AS
  SELECT LTRIM (proc_order, 0) proc_order, "CNTL_REC_ID", "PLANT",
         "CNTL_REC_STATUS", "TEST_FLAG", "RECIPE_TEXT",
         LTRIM (material, '0') material, "MATERIAL_TEXT",
         ROUND (TO_NUMBER (quantity), 3) quantity, "INSPLOT", "UOM", "BATCH",
         "SCHED_START_DATIME", "RUN_START_DATIME", "RUN_END_DATIME",
         "VERSION", "UPD_DATIME", "CNTL_REC_XFER", teco_status, storage_locn
    FROM cntl_rec
   WHERE SUBSTR (proc_order, 1, 1) BETWEEN '0' AND '9';


DROP PUBLIC SYNONYM CNTL_REC_VW;

CREATE PUBLIC SYNONYM CNTL_REC_VW FOR MANU.CNTL_REC_VW;


GRANT SELECT ON MANU.CNTL_REC_VW TO MANU_APP;

GRANT SELECT ON MANU.CNTL_REC_VW TO MANU_USER;

