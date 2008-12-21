DROP VIEW MANU_APP.CNTL_REC_VW_TEST;

/* Formatted on 2008/12/22 10:14 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.cntl_rec_vw_test (proc_order,
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
  SELECT LTRIM (proc_order, 0) proc_order, cntl_rec_id, plant, cntl_rec_stat,
         test_flag, recpe_text, LTRIM (matl_code, '0') matl, matl_text,
         ROUND (TO_NUMBER (qty), 3) qty, insplot, uom, batch,
         sched_start_datime, run_start_datime, run_end_datime, vrsn,
         upd_datime, cntl_rec_xfer, teco_stat, strge_locn
    FROM cntl_rec
   WHERE SUBSTR (proc_order, 1, 1) BETWEEN '0' AND '9'
     AND LTRIM (proc_order, '0') IN (SELECT DISTINCT LTRIM (proc_order, '0')
                                                FROM recpe_hdr t01,
                                                     recpe_dtl t02
                                               WHERE t01.cntl_rec_id =
                                                               t02.cntl_rec_id);


DROP PUBLIC SYNONYM CNTL_REC_VW_TEST;

CREATE PUBLIC SYNONYM CNTL_REC_VW_TEST FOR MANU_APP.CNTL_REC_VW_TEST;


GRANT SELECT ON MANU_APP.CNTL_REC_VW_TEST TO PUBLIC;

