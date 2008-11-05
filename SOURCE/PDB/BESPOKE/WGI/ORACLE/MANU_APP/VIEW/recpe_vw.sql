DROP VIEW MANU_APP.RECPE_VW;

/* Formatted on 2008/11/05 13:18 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.recpe_vw (proc_order,
                                                cntl_rec_id,
                                                opertn,
                                                phase,
                                                seq,
                                                description,
                                                uom,
                                                qty,
                                                sub_total,
                                                dummy,
                                                old_matl_code,
                                                detailtype,
                                                sub_header
                                               )
AS
  SELECT
/*---------------------------------------------------------------------------*/
/* 1.0  24-Sep-2007 JP changed the phase header query                        */
/* 1.1  08-Oct-2007 JP added the difference flag #Z#                         */
/* 1.2  15-Oct-2007 (D.Woolcock Request)                                     */
/*                  JP removed the word 'for' extended to matl_desc from 22  */
/*                  to 38chars and matl qty changed to 3 dec places          */
/*                                                                           */
/* This view is designed to link the RECPE_DTL and RECPE_VAL tables          */
/* together so that a consolidated recordset is supplied to the FRR app      */
/*---------------------------------------------------------------------------*/
/* This section gets all the Operation and Resource codes as Headers         */
/*  and if a single phantom is made within the op then the material and qty  */
/*  is concatanated                                                          */
/*---------------------------------------------------------------------------*/
         LTRIM (t02.proc_order, '0') proc_order, t01.cntl_rec_id, t01.opertn,
         '0' phase, '0000' seq,
         
            --   t01.resrce_code || ': ' ||
            DECODE (matl_made_qty,
                    0, t01.resrce_desc,
                    SUBSTR (t01.resrce_desc, 0, 28)
                   )
         || DECODE (matl_made_qty,
                    0, '',
                    NULL, '',
                       ' '
                    || t01.matl_made
                    || ':'
                    || INITCAP (SUBSTR (matl_made_desc, 0, 38))
                    || ' '
                    || TO_CHAR (ROUND (matl_made_qty, 3))
                    || LOWER (t03.uom)
                   )
         || DECODE (t01.pan_qty,
                    NULL, '',
                    0, '',
                    ' - (M=' || t01.pan_qty || ')'
                   ) description,
         NULL uom, NULL qty, NULL sub_total, 0 dummy, '0' old_matl_code,
         'H' detailtype, '' sub_header
    FROM recpe_resrce t01,
         cntl_rec t02,
         (SELECT   t01.proc_order, opertn, MAX (t01.material_uom) uom,
                   MAX (rnk) rnk, cntl_rec_id
              FROM (SELECT proc_order, operation AS opertn, material_uom,
                           phantom,
                           RANK () OVER (PARTITION BY proc_order, operation ORDER BY phantom ASC)
                                                                       AS rnk
                      FROM cntl_rec_bom) t01,
                   cntl_rec t02
             WHERE t01.proc_order = t02.proc_order AND rnk = 1
          GROUP BY t01.proc_order, opertn, cntl_rec_id) t03
   WHERE t01.cntl_rec_id = t02.cntl_rec_id
     AND t01.cntl_rec_id = t03.cntl_rec_id(+)
     AND t01.opertn = t03.opertn(+)
     AND t02.teco_status = 'NO'
     AND recipe_line_hide (LTRIM (t02.proc_order, '0'), t01.opertn, '') = 'D'
  UNION ALL
  /*-*/
  /* Phase header as defined by SRC values
  /* this section will find sub phases header within an operation  within the BOM recordes
  /* - these are any SRC's within the range 1500 to 1899
  /*-*/
  SELECT   t02.proc_order, t02.cntl_rec_id, operation AS opertn,
           MIN (phase) phase, '0001' seq, mpi_desc, NULL uom, NULL qty,
           NULL sub_total, 1 dummy, '0', 'HH', '' sub_header
      FROM cntl_rec_mpi_val t01, recpe_hdr t02
     WHERE LTRIM (t01.proc_order, '0') = t02.proc_order
       AND TO_NUMBER (mpi_tag) BETWEEN 1500 AND 1899
       AND mpi_val <> '*NP*'
  GROUP BY t02.proc_order, operation, mpi_desc, mpi_tag, t02.cntl_rec_id
  UNION ALL
  /* add material records from recpe_dtl which have been created by the
  /* recpe_conversion package */
  SELECT LTRIM (t01.proc_order, '0') proc_order, t01.cntl_rec_id, t01.opertn,
         t01.phase, LPAD (t01.seq, 4, '0') seq,
         CASE
           WHEN t03.proc_order IS NULL
             THEN '    ' || RPAD (t01.matl_code, 9, ' ') || t01.matl_desc
           ELSE ' #Z# ' || RPAD (t01.matl_code, 9, ' ') || t01.matl_desc
         END,
         t01.uom, TO_CHAR (ROUND (t01.bom_qty, 3), '999G999G990D990'),
         TO_CHAR (ROUND (t01.total, 3), '999G999G990D990'), 2,
         LTRIM (DECODE (t02.regional_code_19,
                        NULL, '0',
                        t02.regional_code_19
                       ),
                '0'
               ) old_matl_code,
         DECODE (t01.phantom, 'B', 'B', 'M'), '' sub_header
    FROM (SELECT t10.*, LTRIM (t11.proc_order, '0') AS proc_order, t11.plant
            FROM recpe_dtl t10, cntl_rec t11
           WHERE t10.cntl_rec_id = t11.cntl_rec_id
             AND (t10.phantom = 'U' OR t10.phantom = 'B'
                  OR t10.phantom IS NULL
                 )) t01,
         bds_material_plant_mfanz t02,
         recpe_diff t03
   WHERE t01.matl_code = LTRIM (t02.sap_material_code(+), '0')
     AND t01.plant = t02.plant_code(+)
     AND t01.proc_order = t03.proc_order(+)
     AND t01.opertn = t03.opertn(+)
     AND t01.phase = t03.phase(+)
     AND t01.seq = t03.seq(+)
     /* hide bold entries which do not have and sub materials  */
     AND (   t01.phantom IS NULL
          OR t01.phantom = 'U'
          OR (SELECT COUNT (*)
                FROM recpe_dtl
               WHERE cntl_rec_id = t01.cntl_rec_id
                 AND (phantom IS NULL OR phantom = 'U')
                 AND phase = LPAD (TO_CHAR (TO_NUMBER (t01.phase) + 1), 4,
                                   '0')) <> 0
         )
  UNION ALL
  /* add the src value fields */
  SELECT LTRIM (t01.proc_order, '0') proc_order, t01.cntl_rec_id, t02.opertn,
         t02.phase, LPAD (t02.seq, 4, '0') seq,
         DECODE (t03.proc_order, NULL, '', '', '', '#Z# ') || mpi_desc,
         mpi_uom, mpi_val, '', 2, '0', 'S', sub_header
    FROM (SELECT t01.*, t02.proc_order
            FROM recpe_val t01, recpe_hdr t02
           WHERE t01.cntl_rec_id = t02.cntl_rec_id) t02,
         cntl_rec t01,
         recpe_diff t03
   WHERE t01.cntl_rec_id = t02.cntl_rec_id
     AND t02.proc_order = t03.proc_order(+)
     AND t02.opertn = t03.opertn(+)
     AND t02.phase = t03.phase(+)
     AND t02.seq = t03.seq(+)
     AND (TO_NUMBER (mpi_tag) NOT BETWEEN 1500 AND 1899 OR mpi_tag IS NULL)
  UNION ALL
  /* add the src text fields */
  SELECT LTRIM (t01.proc_order, '0') proc_order, cntl_rec_id,
         t02.operation AS opertn, phase, LPAD (seq, 4, '0') seq,
         DECODE (detail_desc, '*', mpi_text, detail_desc), '' mpi_uom,
         '' mpi_val, '', 2, '0',
         DECODE (mpi_type, 'H', 'B', 'N', 'I', mpi_type), '' sub_header
    FROM cntl_rec_mpi_txt t02, cntl_rec t01
   WHERE t01.proc_order = t02.proc_order;


DROP PUBLIC SYNONYM RECPE_VW;

CREATE PUBLIC SYNONYM RECPE_VW FOR MANU_APP.RECPE_VW;


