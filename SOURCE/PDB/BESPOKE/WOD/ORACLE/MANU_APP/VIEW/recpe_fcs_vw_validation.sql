DROP VIEW MANU_APP.RECPE_FCS_VW_VALIDATION;

/* Formatted on 2008/10/01 09:01 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.recpe_fcs_vw_validation (proc_order,
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
                 LTRIM (t01.material, '0') AS matl_code,
                 t01.material_text AS matl_text,
                 t02.resource_code AS resrce_code, t03.operation AS opertn,
                 TO_NUMBER (t03.phase) AS phase,
                 TO_NUMBER (LPAD (t03.seq, 4, 0)) AS seq,
                 LTRIM (t03.material_code, '0') AS code,
                 t03.material_desc description,
                 CASE
                   WHEN t04.bom_qty IS NULL AND pan_size_flag <> 'Y'
                     THEN TO_CHAR (ROUND (TO_NUMBER (t03.material_qty), 3),
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
                 t03.material_uom AS uom, 'M' AS mpi_type,
                 t01.run_start_datime, t01.run_end_datime,
                 TO_CHAR ('', '') AS proc_order_stats,
                 t01.storage_locn AS strge_locn, '' AS mc_code,
                 '' AS work_ctr_code, '' AS work_ctr_name,
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
                 t03.plant_code AS plant, TO_CHAR (t04.pans) AS m,
                 t04.opertn_header
            FROM bds_recipe_bom t03,
                 bds_recipe_resource t02,               --cntl_rec_resrce t02,
                 bds_recipe_header t01,
                 (SELECT proc_order, rd.opertn, rd.phase, rd.matl_code,
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
             AND t02.operation = t03.operation
             AND t01.proc_order = t03.proc_order
             AND LTRIM (t03.proc_order, '0') = t04.proc_order(+)
             AND t03.operation = t04.opertn(+)
             AND t03.phase = t04.phase(+)
             AND LTRIM (t03.material_code, '0') = t04.matl_code(+)
             AND t01.teco_status = 'NO'
             AND LTRIM (t03.material_code, '0') NOT IN (SELECT matl_code
                                                          FROM recpe_phantom)
          UNION ALL
          SELECT LTRIM (t02.proc_order, 0) AS proc_order, t01.cntl_rec_id,
                 LTRIM (t01.material, '0') AS matl_code,
                 t01.material_text AS matl_text,
                 t02.resource_code AS resrce_code, t03.operation AS opertn,
                 TO_NUMBER (t03.phase) AS phase,
                 TO_NUMBER (LPAD (t03.seq, 4, 0)) AS seq, t03.src_tag AS code,
                 t03.src_desc description,
                 DECODE (t03.src_val, '?', '', t03.src_val) AS VALUE,
                 DECODE (t03.src_uom, '?', '', t03.src_uom) AS uom, 'V',
                 t01.run_start_datime, t01.run_end_datime,
                 TO_CHAR ('', '') AS proc_order_status,
                 t01.storage_locn AS strge_locn, machine_code AS mc_code,
                 '' AS work_ctr_code, '' AS work_ctr_name, '', '', '', '',
                 t01.plant_code AS plant, TO_CHAR (t04.pans) AS m,
                 t04.opertn_header
            FROM bds_recipe_src_value t03,
                 bds_recipe_resource t02,
                 bds_recipe_header t01,
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
                     AND rd.opertn = rr.opertn) t04
           WHERE t02.proc_order = t03.proc_order
             AND t02.operation = t03.operation
             AND t02.proc_order = t01.proc_order
             AND LTRIM (t03.proc_order, '0') = t04.proc_order(+)
             AND t03.operation = t04.opertn(+)
             AND t03.phase = t04.phase(+)
             AND LTRIM (t03.src_tag, '0') = t04.mpi_tag(+)
             AND t01.teco_status = 'NO') t01,
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
     AND SUBSTR (t01.proc_order, 1, 1) NOT BETWEEN '0' AND '9';


DROP PUBLIC SYNONYM RECPE_FCS_VW_VALIDATION;

CREATE PUBLIC SYNONYM RECPE_FCS_VW_VALIDATION FOR MANU_APP.RECPE_FCS_VW_VALIDATION;


GRANT SELECT ON MANU_APP.RECPE_FCS_VW_VALIDATION TO APPSUPPORT;

GRANT SELECT ON MANU_APP.RECPE_FCS_VW_VALIDATION TO PUBLIC WITH GRANT OPTION;

