CREATE OR REPLACE FORCE VIEW manu_app.recpe_fcs_vw as
  SELECT t01.proc_order, t01.cntl_rec_id, t01.matl_code, t01.matl_text,
         t01.resrce_code, t01.opertn, t01.phase, t01.seq, t01.code,
         t01.description, t01.VALUE, t01.uom, t01.mpi_type,
         t01.run_start_datime, t01.run_end_datime, t01.proc_order_stats,
         t02.batch_qty, t01.strge_locn, t01.mc_code, t01.work_ctr_code,
         t01.work_ctr_name, t01.pans, t01.used_made, t01.pan_size,
         t01.last_pan_size, t01.plant
    FROM (SELECT LTRIM (t03.proc_order, 0) AS proc_order, t01.cntl_rec_id,
                 LTRIM (t01.matl_code, '0') AS matl_code, t01.matl_text,
                 t02.resrce_code, t03.opertn, TO_NUMBER (t03.phase) AS phase,
                 TO_NUMBER (LPAD (t03.seq, 4, 0)) AS seq,
                 LTRIM (t03.matl_code, '0') AS code,
                 t03.matl_desc description,
                 CASE
                   WHEN t04.bom_qty IS NULL AND pan_size_flag <> 'Y'
                     THEN TO_CHAR (ROUND (TO_NUMBER (t03.qty), 3),
                                   '9999990.999'
                                  )
                   WHEN t04.bom_qty IS NULL
                   AND pan_size_flag = 'Y'
                   AND pan_qty = 1
                     THEN TO_CHAR (ROUND (TO_NUMBER (pan_size), 3),
                                   '9999990.999'
                                  )
                   WHEN t04.bom_qty IS NULL
                   AND pan_size_flag = 'Y'
                   AND pan_qty > 1
                     THEN TO_CHAR (ROUND (TO_NUMBER (  (  pan_size
                                                        * (pan_qty - 1)
                                                       )
                                                     + last_pan_size
                                                    ),
                                          3
                                         ),
                                   '9999990.999'
                                  )
                   WHEN t04.bom_qty IS NULL
                   AND pan_size_flag = 'Y'
                   AND (pan_qty IS NULL OR pan_qty = '')
                     THEN TO_CHAR (ROUND (TO_NUMBER (pan_size), 3),
                                   '9999990.999'
                                  )
                   ELSE TO_CHAR (t04.bom_qty, '999990D999')
                 END VALUE,
                 t03.uom, 'M' AS mpi_type, t01.run_start_datime,
                 t01.run_end_datime, TO_CHAR ('', '') AS proc_order_stats,
                 t01.strge_locn, '' AS mc_code, '' AS work_ctr_code,
                 '' AS work_ctr_name,
                 CASE
                   WHEN pan_qty IS NULL
                     THEN TO_CHAR (NULL)
                   WHEN pan_qty = 1
                     THEN TO_CHAR (pan_qty)
                   ELSE TO_CHAR (ROUND (  (  pan_size * (pan_qty - 1)
                                           + last_pan_size
                                          )
                                        / pan_size,
                                        1
                                       )
                                )
                 END AS pans,
                 t03.phantom AS used_made,
                 TO_CHAR (t03.pan_size, '999999.999') AS pan_size,
                 TO_CHAR (t03.last_pan_size, '999999.999') AS last_pan_size,
                 t03.plant
            FROM cntl_rec_bom t03,
                 cntl_rec_resrce t02,
                 cntl_rec t01,
                 (SELECT proc_order, opertn, phase, rd.matl_code, bom_qty
                    FROM recpe_hdr rh, recpe_dtl rd
                   WHERE rh.cntl_rec_id = rd.cntl_rec_id) t04
           WHERE t02.proc_order = t03.proc_order
             AND t02.opertn = t03.opertn
             AND t01.proc_order = t03.proc_order
             AND LTRIM (t03.proc_order, '0') = t04.proc_order(+)
             AND t03.opertn = t04.opertn(+)
             AND t03.phase = t04.phase(+)
             AND LTRIM (t03.matl_code, '0') = t04.matl_code(+)
             AND t01.teco_stat = 'NO'
             AND LTRIM (t03.matl_code, '0') NOT IN (SELECT matl_code
                                                      FROM recpe_phantom)
          UNION ALL
          SELECT LTRIM (t02.proc_order, 0) AS proc_order, t01.cntl_rec_id,
                 LTRIM (t01.matl_code, '0') AS matl_code, t01.matl_text,
                 t02.resrce_code, t03.opertn, TO_NUMBER (t03.phase) AS phase,
                 TO_NUMBER (LPAD (t03.seq, 4, 0)) AS seq, t03.mpi_tag AS code,
                 t03.mpi_desc description,
                 DECODE (t03.mpi_val, '?', '', t03.mpi_val) AS VALUE,
                 DECODE (t03.mpi_uom, '?', '', t03.mpi_uom) AS uom, 'V',
                 t01.run_start_datime, t01.run_end_datime,
                 TO_CHAR ('', '') AS proc_order_status, t01.strge_locn,
                 mc_code,
                       --SUBSTR(t03.mc_code,LENGTH(t03.mc_code),1) as mc_code,
                         '' AS work_ctr_code, '' AS work_ctr_name, '', '', '',
                 '', t01.plant
            FROM cntl_rec_mpi_val t03, cntl_rec_resrce t02, cntl_rec t01
           WHERE t02.proc_order = t03.proc_order
             AND t02.opertn = t03.opertn
             AND t02.proc_order = t01.proc_order
             AND t01.teco_stat = 'NO') t01,
         (SELECT t01.*
            FROM (SELECT DISTINCT TO_CHAR (batch_qty) AS batch_qty, matl_code,
                                  plant, eff_start_date,
                                  RANK () OVER (PARTITION BY matl_code, plant ORDER BY eff_start_date DESC,
                                   alt DESC) AS rnkseq
                             FROM bom
                            WHERE TRUNC (eff_start_date) <= TRUNC (SYSDATE)) t01
           WHERE rnkseq = 1) t02
   WHERE t01.matl_code = t02.matl_code
     AND t01.plant = t02.plant
     AND t01.run_start_datime BETWEEN TRUNC (SYSDATE) - 2 AND   TRUNC (SYSDATE)
                                                              + 20
     AND SUBSTR (t01.proc_order, 1, 1) BETWEEN '0' AND '9';

GRANT SELECT ON MANU_APP.RECPE_FCS_VW TO PUBLIC WITH GRANT OPTION;

CREATE OR REPLACE PUBLIC SYNONYM RECPE_FCS_VW FOR MANU_APP.RECPE_FCS_VW;

