DROP VIEW MANU_APP.RECPE_FCS_VW;

/* Formatted on 2008/06/30 14:46 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.recpe_fcs_vw (proc_order,
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
                                                    bf_item,
                                                    diff,
                                                    m,
                                                    opertn_header
                                                   )
AS
  SELECT "PROC_ORDER", "CNTL_REC_ID", "MATL_CODE", "MATL_TEXT", "RESRCE_CODE",
         "OPERTN", "PHASE", "SEQ", "CODE", "DESCRIPTION", "VALUE", "UOM",
         "MPI_TYPE", "RUN_START_DATIME", "RUN_END_DATIME", "PROC_ORDER_STATS",
         "BATCH_QTY", "STRGE_LOCN", "MC_CODE", "WORK_CTR_CODE",
         "WORK_CTR_NAME", "PANS", "USED_MADE", "PAN_SIZE", "LAST_PAN_SIZE",
         "PLANT", "BF_ITEM", "DIFF", "M", "OPERTN_HEADER"
    FROM (SELECT LTRIM (t03.proc_order, 0) AS proc_order,
/**********************************************************************************/
/* NOTE:
/*     The first part creates a view of all materials within each process order
/*     the tables CNTL_REC_LCL_RESRCE  and WORK_CTR have been commented out
/*     because there is no re-timming tool in wodonga and the view was running slow
/*     added the query using recpe_dtl and recpe_hdr to get the bom qty
/*     if the entry is using - RATIO from USED feature src 1999
/**********************************************************************************/
/**********************************************************************************/
/* 27-Jul-2007 Jeff Phillipson - added filter for proc orders starting with '%'
/*                                in both parts of the query
/* 27-Sep-2007 Jeff Phillipson - added filter for proc orders that have a recipe
/* 05-Oct-2007 Jeff Phillipson - modified so that phantom mades are in the view - 3rd union
/* 11-Oct-2007 Jeff Phillipson - added function 'convert_complex_number' to SRC section of query
/*                               to convert target weights
/* 21-Nov-2007 Jeff Phillipson   changed the method of getting 'VALUE' in the 3rd part of the query
/**********************************************************************************/
                                                         t03.cntl_rec_id,
                 LTRIM (t03.material, '0') AS matl_code,
                 t03.material_text AS matl_text,
                 t02.resource_code AS resrce_code, t01.operation AS opertn,
                 TO_NUMBER (t01.phase) AS phase,
                 TO_NUMBER (LPAD (t01.seq, 4, 0)) AS seq,
                 LTRIM (t01.material_code, '0') AS code,
                 t01.material_desc AS description,
                 TO_CHAR (t05.bom_qty, '99999990D999') AS VALUE,
                 t01.material_uom AS uom, 'M' AS mpi_type,
                 t03.run_start_datime, t03.run_end_datime,
                 t04.closed proc_order_stats,
                 TO_CHAR
                        (get_bom_batch_qty (LTRIM (t03.material, '0'))
                        ) AS batch_qty,
                 storage_locn AS strge_locn, '' AS mc_code,
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
                 END pans,
                 t01.phantom used_made,
                 TO_CHAR (pan_size, '999999.999') AS pan_size,
                 TO_CHAR (last_pan_size, '999999.999') AS last_pan_size,
                 t01.plant_code AS plant, t01.bf_item,
                 CASE
                   WHEN t06.proc_order IS NOT NULL
                     THEN 1
                   ELSE 0
                 END AS diff, TO_CHAR (t05.pans) AS m, t05.opertn_header
            FROM bds_recipe_bom t01,
                 bds_recipe_resource t02,
                 bds_recipe_header t03,
                 cntl_rec_stat_vw t04,
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
                     AND rd.opertn = rr.opertn) t05,
                 recpe_diff t06,
                 recpe_phantom t07
           WHERE t02.proc_order = t01.proc_order
             AND t02.operation = t01.operation
             AND t03.proc_order = t01.proc_order
             AND LTRIM (t02.proc_order, '0') = t04.proc_order(+)
             AND LTRIM (t01.proc_order, '0') = t05.proc_order
             AND t01.operation = t05.opertn
             AND t01.phase = t05.phase
             AND LTRIM (t01.material_code, '0') = t05.matl_code
             AND LTRIM (t01.proc_order, '0') = t06.proc_order(+)
             AND t01.operation = t06.opertn(+)
             AND t01.phase = t06.phase(+)
             AND t01.seq = t06.seq(+)
             AND LTRIM (t01.material_code, '0') = t06.matl_src_code(+)
             AND teco_status = 'NO'
             AND LTRIM (t01.material_code, '0') <> t07.matl_code
             AND SUBSTR (t01.proc_order, 1, 1) BETWEEN '0' AND '9'
          UNION ALL
          SELECT LTRIM (t03.proc_order, 0) AS proc_order,
/**********************************************************************************/
/* NOTE:
/*     The second part creates a view of all SRC values within each process order
/*     the tables CNTL_REC_LCL_RESRCE  and WORK_CTR have been commented out
/*     because there is no re-timming tool in wodonga and the view was running slow
/**********************************************************************************/
                                                         t03.cntl_rec_id,
                 LTRIM (t03.material, '0') AS matl_code,
                 t03.material_text AS matl_text,
                 t02.resource_code AS resrce_code, t01.operation AS opertn,
                 TO_NUMBER (t01.phase) AS phase,
                 TO_NUMBER (LPAD (t01.seq, 4, 0)) AS seq, src_tag AS code,
                 src_desc AS description,
                 CASE
                   WHEN src_val = '?'
                     THEN ''
                   WHEN SUBSTR (src_val, 1, 3) = '=TW'
                   AND SUBSTR (src_uom, 1, 1) = 'G'
                   AND t07.nake_uom = 'KGM'
                     THEN TO_CHAR
                           (convert_complex_number
                                            (   TO_CHAR
                                                       (  t07.nake_target_wght
                                                        * 1000
                                                       )
                                             || TO_CHAR (SUBSTR (src_val, 4))
                                            )
                           )
                   WHEN SUBSTR (src_val, 1, 3) = '=TW'
                   AND SUBSTR (src_uom, 1, 1) = 'K'
                   AND t07.nake_uom = 'KGM'
                     THEN TO_CHAR
                           (convert_complex_number
                                              (   TO_CHAR
                                                         (t07.nake_target_wght)
                                               || TO_CHAR (SUBSTR (src_val, 4))
                                              )
                           )
                   ELSE src_val
                 END VALUE,
                 DECODE (src_uom, '?', '', src_uom) AS uom, 'V' AS mpi_type,
                 t03.run_start_datime, t03.run_end_datime,
                 t04.closed AS proc_order_status,
                 TO_CHAR
                        (get_bom_batch_qty (LTRIM (t03.material, '0'))
                        ) AS batch_qty,
                 storage_locn AS strge_locn,
                 SUBSTR (machine_code, LENGTH (machine_code), 1) AS mc_code,
                 '' AS work_ctr_code, '' AS work_ctr_name, '', '', '', '',
                 t03.plant_code plant, '',
                 CASE
                   WHEN t06.proc_order IS NOT NULL
                     THEN 1
                   ELSE 0
                 END diff, '', ''
            FROM bds_recipe_src_value t01,
                 bds_recipe_resource t02,
                 bds_recipe_header t03,
                 cntl_rec_stat_vw t04,
                 recpe_diff t06,
                 material_target_weight t07
           WHERE t02.proc_order = t01.proc_order
             AND t02.operation = t01.operation
             AND t02.proc_order = t03.proc_order
             AND LTRIM (t02.proc_order, '0') = LTRIM (t04.proc_order(+), '0')
             AND LTRIM (t01.proc_order, '0') = t06.proc_order(+)
             AND t01.operation = t06.opertn(+)
             AND t01.phase = t06.phase(+)
             AND t01.seq = t06.seq(+)
             AND LTRIM (t01.src_tag, '0') = t06.matl_src_code(+)
             AND LTRIM (t03.material, '0') = t07.matl_code(+)
             AND t03.plant_code = t07.plant_code(+)
             AND t03.teco_status = 'NO'
             AND SUBSTR (t01.proc_order, 1, 1) BETWEEN '0' AND '9'
             AND t01.src_tag NOT IN (
                   SELECT mpi_tag
                     FROM recpe_spcl_cndtn
                    WHERE spcl_cndtn_name IN
                            ('SCALE_TO_PARENT', 'HIDE_DUPLICATES',
                             'SCALE_TO_BOM'))
          UNION ALL
/* this section will get all the Made components */
          SELECT LTRIM (t03.proc_order, 0) AS proc_order, t01.cntl_rec_id,
                 LTRIM (t01.material, '0') AS matl_code,
                 t01.material_text AS matl_text,
                 t03.resource_code AS resrce_code, t02.operation AS opertn,
                 TO_NUMBER (t02.phase) AS phase,
                 TO_NUMBER (LPAD (t02.seq, 4, 0)) AS seq,
                 LTRIM (t02.material_code, '0') AS code,
                 t02.material_desc AS description,
                 TO_CHAR (DECODE (t05.matl_made_qty,
                                  NULL, pan_size,
                                  t05.matl_made_qty
                                 ),
                          '99999990D999'
                         ) AS VALUE,
                 t02.material_uom AS uom, 'M' AS mpi_type,
                 t01.run_start_datime, t01.run_end_datime,
                 t04.closed proc_order_stats,
                 TO_CHAR
                   (get_bom_batch_qty (LTRIM (t02.material_code, '0'))
                   ) AS batch_qty,
                 t01.storage_locn AS strge_locn, '' AS mc_code,
                 '' AS work_ctr_code, '' AS work_ctr_name, TO_CHAR (t05.pans),
                 t02.phantom used_made,
                 TO_CHAR (pan_size, '999999.999') AS pan_size,
                 TO_CHAR (last_pan_size, '999999.999') AS last_pan_size,
                 t01.plant_code AS plant, t02.bf_item, 0 AS diff,
                 TO_CHAR (t05.pans) AS m, t05.opertn_header
            FROM bds_recipe_header t01,
                 bds_recipe_bom t02,
                 bds_recipe_resource t03,
                 cntl_rec_stat_vw t04,
                 (SELECT DISTINCT proc_order, rd.opertn, rd.phase,
                                  rr.pan_qty AS pans, rr.matl_made,
                                  rr.matl_made_qty,
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
                              AND rd.opertn = rr.opertn) t05,
                 bds_recipe_header t06,
                 recpe_phantom t07
           WHERE t01.proc_order = t02.proc_order
             AND t01.proc_order = t03.proc_order
             AND t02.operation = t03.operation
             AND LTRIM (t01.proc_order, '0') = t04.proc_order(+)
             AND LTRIM (t02.proc_order, '0') = t05.proc_order(+)
             AND t02.operation = t05.opertn(+)
             AND t02.phase = t05.phase(+)
             AND t01.proc_order = t06.proc_order
             AND LTRIM (t02.material_code, '0') = t05.matl_made(+)
             AND t02.phantom = 'M'
             AND SUBSTR (t01.proc_order, 1, 1) BETWEEN '0' AND '9'
             AND t06.teco_status = 'NO'
             AND LTRIM (t02.material_code, '0') <> t07.matl_code
                                                                --  AND Recipe_Disp_Hide(LTRIM(t01.proc_order,'0'),t02.operation, t02.phase,LTRIM (t02.material_code, '0')) = 'D'
         )
   WHERE DECODE (used_made,
                 'M', recipe_disp_hide (proc_order, opertn, phase, matl_code),
                 'D'
                ) = 'D';


DROP PUBLIC SYNONYM RECPE_FCS_VW;

CREATE PUBLIC SYNONYM RECPE_FCS_VW FOR MANU_APP.RECPE_FCS_VW;


GRANT SELECT ON MANU_APP.RECPE_FCS_VW TO APPSUPPORT;

GRANT SELECT ON MANU_APP.RECPE_FCS_VW TO FCS_READER;

GRANT SELECT ON MANU_APP.RECPE_FCS_VW TO MANU_MAINT;

GRANT SELECT ON MANU_APP.RECPE_FCS_VW TO MANU_USER;

GRANT SELECT ON MANU_APP.RECPE_FCS_VW TO PUBLIC;

