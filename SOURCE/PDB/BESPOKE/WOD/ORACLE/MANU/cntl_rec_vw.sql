DROP VIEW MANU.CNTL_REC_VW;

/* Formatted on 2008/12/22 11:33 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.cntl_rec_vw (proc_order,
                                               cntl_rec_id,
                                               plant,
                                               cntl_rec_stat,
                                               test_flag,
                                               recpe_text,
                                               matl_code,
                                               matl_text,
                                               qty,
                                               insplot,
                                               uom,
                                               batch,
                                               sched_start_datime,
                                               run_start_datime,
                                               run_end_datime,
                                               vrsn,
                                               upd_datime,
                                               cntl_rec_xfer,
                                               teco_stat,
                                               strge_locn
                                              )
AS
  SELECT LTRIM (proc_order, 0) proc_order, "CNTL_REC_ID", "PLANT",
         "CNTL_REC_STAT", "TEST_FLAG", "RECPE_TEXT",
         LTRIM (matl_code, '0') matl_code, "MATL_TEXT",
         ROUND (TO_NUMBER (qty), 3) qty, "INSPLOT", "UOM", "BATCH",
         "SCHED_START_DATIME", "RUN_START_DATIME", "RUN_END_DATIME", "VRSN",
         "UPD_DATIME", "CNTL_REC_XFER", teco_stat, strge_locn
    FROM cntl_rec
   WHERE run_end_datime BETWEEN TRUNC (SYSDATE) - 5 AND TRUNC (SYSDATE) + 10
     AND SUBSTR (proc_order, 1, 1) BETWEEN '0' AND '9'
     AND LTRIM (proc_order, '0') IN (SELECT DISTINCT LTRIM (proc_order, '0')
                                                FROM recpe_hdr t01,
                                                     recpe_dtl t02
                                               WHERE t01.cntl_rec_id =
                                                               t02.cntl_rec_id);


DROP PUBLIC SYNONYM CNTL_REC_VW;

CREATE PUBLIC SYNONYM CNTL_REC_VW FOR MANU.CNTL_REC_VW;


GRANT SELECT ON MANU.CNTL_REC_VW TO MANU_APP;

GRANT SELECT ON MANU.CNTL_REC_VW TO PUBLIC;

