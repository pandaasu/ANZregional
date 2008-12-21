DROP VIEW MANU_APP.RECPE_FCS_VW_TEST;

/* Formatted on 2008/12/22 10:14 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.recpe_fcs_vw_test (proc_order,
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
                                                         last_pan_size,
                                                         plant,
                                                         m,
                                                         opertn_header
                                                        )
AS
  SELECT t01.proc_order, t01.cntl_rec_id, t01.matl_code, t01.matl_text,
         t01.resrce_code, t01.opertn, t01.phase, t01.seq, t01.code,
         t01.description, t01.VALUE, t01.uom, t01.mpi_type,
         t01.run_start_datime, t01.run_end_datime, t01.proc_order_stats,
         t02.batch_qty, t01.strge_locn, t01.mc_code, t01.work_ctr_code,
         t01.work_ctr_name, t01.pans, t01.used_made, t01.pan_size,
         t01.last_pan_size, t01.plant, t01.m, t01.opertn_header
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
                 t01.strge_locn, '' AS mc_code,
                 DECODE (t05.work_ctr_code,
                         '-1', '',
                         DECODE (t02.resrce_code,
                                 'USEBN001', '200030',
                                 t05.work_ctr_code
                                )
                        ) work_ctr_code,
                 DECODE (t02.resrce_code,
                         'USEBN001', 'USE BINS',
                         RTRIM (work_ctr_name)
                        ) work_ctr_name,
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
                 t03.plant, TO_CHAR (t04.pans) AS m, t04.opertn_header
            FROM cntl_rec_bom t03,
                 cntl_rec_resrce t02,
                 cntl_rec t01,
                 cntl_rec_lcl_resrce t05,
                 work_ctr t06,
                 (SELECT rh.proc_order, rd.opertn, rd.phase, rd.matl_code,
                         bom_qty, rr.pan_qty AS pans,
                            'Op:'
                         || rd.opertn
                         || ' '
                         || resrce_desc
                         || DECODE (matl_made,
                                    NULL, '',
                                       ' for '
                                    || matl_made
                                    || ': '
                                    || matl_made_desc
                                    || ' '
                                    || matl_made_qty
                                    || 'kg'
                                   ) AS opertn_header
                    FROM recpe_hdr rh, recpe_dtl rd, recpe_resrce rr
                   WHERE rh.cntl_rec_id = rd.cntl_rec_id
                     AND rd.cntl_rec_id = rr.cntl_rec_id
                     AND rd.opertn = rr.opertn) t04
           WHERE t02.proc_order = t03.proc_order
             AND t02.opertn = t03.opertn
             AND t01.proc_order = t03.proc_order
             AND LTRIM (t03.proc_order, '0') = t04.proc_order(+)
             AND t03.opertn = t04.opertn(+)
             AND t03.phase = t04.phase(+)
             AND LTRIM (t03.matl_code, '0') = t04.matl_code(+)
             AND LTRIM (t02.proc_order, '0') = t05.proc_order(+)
             AND t02.resrce_code = t05.resrce_code(+)
             AND TRIM (t05.work_ctr_code) = TRIM (t06.work_ctr_code(+))
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
                 SUBSTR (t03.mc_code, LENGTH (t03.mc_code), 1) AS mc_code,
                 DECODE (t04.work_ctr_code,
                         '-1', '',
                         t04.work_ctr_code
                        ) work_ctr_code,
                 work_ctr_name, '', '', '', '', t01.plant,
                 TO_CHAR (t06.pans) AS m, t06.opertn_header
            FROM cntl_rec_mpi_val t03,
                 cntl_rec_resrce t02,
                 cntl_rec t01,
                 cntl_rec_lcl_resrce t04,
                 work_ctr t05,
                 (SELECT proc_order, rd.opertn, rd.phase, rd.mpi_tag,
                         rr.pan_qty AS pans,
                            'Op:'
                         || rd.opertn
                         || ' '
                         || resrce_desc
                         || DECODE (matl_made,
                                    NULL, '',
                                       ' for '
                                    || matl_made
                                    || ': '
                                    || matl_made_desc
                                    || ' '
                                    || matl_made_qty
                                    || 'kg'
                                   ) AS opertn_header
                    FROM recpe_hdr rh, recpe_val rd, recpe_resrce rr
                   WHERE rh.cntl_rec_id = rd.cntl_rec_id
                     AND rd.cntl_rec_id = rr.cntl_rec_id
                     AND rd.opertn = rr.opertn) t06
           WHERE t02.proc_order = t03.proc_order
             AND t02.opertn = t03.opertn
             AND t02.proc_order = t01.proc_order
             AND LTRIM (t02.proc_order, '0') = t04.proc_order(+)
             AND TRIM (t04.work_ctr_code) = TRIM (t05.work_ctr_code(+))
             AND t02.resrce_code = t04.resrce_code(+)
             AND LTRIM (t03.proc_order, '0') = t06.proc_order(+)
             AND t03.opertn = t06.opertn(+)
             AND t03.phase = t06.phase(+)
             AND LTRIM (t03.mpi_tag, '0') = t06.mpi_tag(+)
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
     --AND t01.run_start_datime BETWEEN trunc(sysdate) - 2 AND trunc(sysdate) + 20
     --AND SUBSTR(t01.proc_order, 1, 1) BETWEEN '0' AND '9';
     AND SUBSTR (t01.proc_order, 1, 1) = '%';


DROP PUBLIC SYNONYM RECPE_FCS_VW_TEST;

CREATE PUBLIC SYNONYM RECPE_FCS_VW_TEST FOR MANU_APP.RECPE_FCS_VW_TEST;


GRANT SELECT ON MANU_APP.RECPE_FCS_VW_TEST TO APPSUPPORT;

GRANT SELECT ON MANU_APP.RECPE_FCS_VW_TEST TO PUBLIC;

