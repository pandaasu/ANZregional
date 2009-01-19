/* Formatted on 2008/12/22 10:14 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.recpe_fcs_vw_new (proc_order,
                                                        cntl_rec_id,
                                                        matl_code,
                                                        matl_text,
                                                        resrce_code,
                                                        opertn,
                                                        phase,
                                                        seq,
                                                        code,
                                                        description,
                                                        VALUE,
                                                        uom,
                                                        mpi_type,
                                                        run_start_datime,
                                                        run_end_datime,
                                                        proc_order_stats,
                                                        batch_qty,
                                                        strge_locn,
                                                        mc_code,
                                                        work_ctr_code,
                                                        work_ctr_name,
                                                        pans,
                                                        used_made,
                                                        pan_size,
                                                        last_pan_size
                                                       )
AS
  SELECT LTRIM (v.proc_order, '0') proc_order, cntl_rec_id,
         LTRIM (c.matl_code, '0') matl_code, c.matl_text, r.resrce_code,
         v.opertn, TO_NUMBER (v.phase) phase,
         TO_NUMBER (LPAD (v.seq, 4, 0)) seq, LTRIM (v.matl_code, '0') code,
         matl_desc description,
         CASE
           WHEN bom_qty IS NULL
             THEN TO_CHAR (DECODE (pan_size_flag,
                                   'Y', get_pan (v.proc_order,
                                                 v.matl_code,
                                                 v.phase
                                                ),
                                   ROUND (TO_NUMBER (v.qty), 3)
                                  ),
                           '9999990.999'
                          )
           ELSE TO_CHAR (bom_qty, '999990D999')
         END VALUE,
         v.uom, 'M' mpi_type, run_start_datime, run_end_datime,
         s.closed proc_order_stats,
         TO_CHAR (get_bom_batch_qty (LTRIM (c.matl_code, '0'))) batch_qty,
         strge_locn, '' mc_code,
         DECODE (l.work_ctr_code,
                 '-1', '',
                 DECODE (r.resrce_code,
                         'USEBN001', '200030',
                         l.work_ctr_code
                        )
                ) work_ctr_code,
         DECODE (r.resrce_code,
                 'USEBN001', 'USE BINS',
                 RTRIM (work_ctr_name)
                ) work_ctr_name,
         CASE
           WHEN pan_qty IS NULL
             THEN TO_CHAR (NULL)
           WHEN pan_qty = 1
             THEN TO_CHAR (pan_qty)
           ELSE TO_CHAR (ROUND (  (pan_size * (pan_qty - 1) + last_pan_size)
                                / pan_size,
                                1
                               )
                        )
         END pans,
         v.phantom used_made, TO_CHAR (pan_size, '999999.999') pan_size,
         TO_CHAR (last_pan_size, '999999.999') last_pan_size
    FROM cntl_rec_bom v,
         cntl_rec_resrce r,
         cntl_rec c,
         cntl_rec_stat_vw s,
         cntl_rec_lcl_resrce l,
         work_ctr w,
         (SELECT proc_order, opertn, phase, rd.matl_code, bom_qty
            FROM recpe_hdr rh, recpe_dtl rd
           WHERE rh.cntl_rec_id = rd.cntl_rec_id) rx
   WHERE r.proc_order = v.proc_order
     AND r.opertn = v.opertn
     AND c.proc_order = v.proc_order
     AND TO_NUMBER (r.proc_order) = TO_NUMBER (s.proc_order(+))
     AND LTRIM (r.proc_order, '0') = l.proc_order(+)
     AND TRIM (l.work_ctr_code) = TRIM (w.work_ctr_code(+))
     AND r.resrce_code = l.resrce_code(+)
     AND LTRIM (v.proc_order, '0') = rx.proc_order(+)
     AND v.opertn = rx.opertn(+)
     AND v.phase = rx.phase(+)
     AND LTRIM (v.matl_code, '0') = rx.matl_code(+)
     AND teco_stat = 'NO'
     AND LTRIM (v.matl_code, '0') NOT IN (SELECT matl_code
                                            FROM recpe_phantom)
     AND c.run_start_datime > TRUNC (SYSDATE) - 2
     AND c.run_start_datime < TRUNC (SYSDATE) + 20
     AND SUBSTR (v.proc_order, 1, 1) BETWEEN '0' AND '9'
  UNION ALL
  SELECT LTRIM (r.proc_order, 0) proc_order, c.cntl_rec_id,
         LTRIM (c.matl_code, '0') matl_code, c.matl_text, r.resrce_code,
         v.opertn, TO_NUMBER (v.phase) phase,
         TO_NUMBER (LPAD (v.seq, 4, 0)) seq, mpi_tag code,
         mpi_desc description, DECODE (mpi_val, '?', '', mpi_val) VALUE,
         DECODE (mpi_uom, '?', '', mpi_uom) uom, 'V', run_start_datime,
         run_end_datime, s.closed proc_order_status,
         TO_CHAR (get_bom_batch_qty (LTRIM (c.matl_code, '0'))) batch_qty,
         strge_locn, SUBSTR (mc_code, LENGTH (mc_code), 1) mc_code,
         DECODE (l.work_ctr_code, '-1', '', l.work_ctr_code) work_ctr_code,
         work_ctr_name, '', '', '', ''
    FROM cntl_rec_mpi_val v,
         cntl_rec_resrce r,
         cntl_rec c,
         cntl_rec_stat_vw s,
         cntl_rec_lcl_resrce l,
         work_ctr w
   WHERE r.proc_order = v.proc_order
     AND r.opertn = v.opertn
     AND r.proc_order = c.proc_order
     AND TO_NUMBER (r.proc_order) = TO_NUMBER (s.proc_order(+))
     AND LTRIM (r.proc_order, '0') = l.proc_order(+)
     AND TRIM (l.work_ctr_code) = TRIM (w.work_ctr_code(+))
     AND r.resrce_code = l.resrce_code(+)
     AND teco_stat = 'NO'
     AND c.run_start_datime > TRUNC (SYSDATE) - 2
     AND c.run_start_datime < TRUNC (SYSDATE) + 20
     AND SUBSTR (c.proc_order, 1, 1) BETWEEN '0' AND '9';

CREATE OR REPLACE PUBLIC SYNONYM RECPE_FCS_VW_NEW FOR MANU_APP.RECPE_FCS_VW_NEW;


