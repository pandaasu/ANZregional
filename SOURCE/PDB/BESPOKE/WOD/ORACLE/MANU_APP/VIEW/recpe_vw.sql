DROP VIEW MANU_APP.RECPE_VW;

/* Formatted on 2008/10/01 09:20 (Formatter Plus v4.8.8) */
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
         /*-*/
         /* This view is designed to link the RECPE_DTL and RECPE_VAL tables
         /* together so that a consolidated recordset is supplied to the FRR application
         /*
         /* this section gets all the Operation and Resource codes as Headers
         /*  and if a single phantom is made within the op then the material and qty is concatanated
         /*-*/
         LTRIM (t02.proc_order, '0') proc_order, t01.cntl_rec_id,
         opertn opertn, '0' phase, '0000' seq,
            t01.resrce_code
         || ': '
         || SUBSTR (t01.resrce_desc, 0, 20)
         || DECODE (matl_made_qty,
                    0, '',
                    NULL, '',
                       ' for '
                    || t01.matl_made
                    || ':'
                    || INITCAP (SUBSTR (matl_made_desc, 0, 20))
                    || ' '
                    || matl_made_qty
                    || 'kg'
                   )
         || DECODE (t01.pan_qty,
                    NULL, '',
                    0, '',
                    ' - (M=' || t01.pan_qty || ')'
                   ) description,
         NULL uom, NULL qty, NULL sub_total, 0 dummy, '0' old_matl_code,
         'H' detailtype, '' sub_header
    FROM recpe_resrce t01, cntl_rec t02
   WHERE t01.cntl_rec_id = t02.cntl_rec_id AND teco_stat = 'NO'
  UNION ALL
  /*-*/
  /* this section will find sub phases header within an operation  within the BOM recordes
  /* - these are any SRC's within the range 1500 to 1999
  /*-*/
  SELECT   LTRIM (t02.proc_order, '0') proc_order, t01.cntl_rec_id,
           t01.opertn, t03.phase, '0002' seq, t04.mpi_desc, NULL uom,
           NULL qty, NULL sub_total, 1 dummy, '0', 'HH', '' sub_header
      FROM recpe_resrce t01,
           cntl_rec t02,
           cntl_rec_bom t03,
           (SELECT proc_order, opertn, phase, mpi_desc
              FROM cntl_rec_mpi_val t05
             WHERE TO_NUMBER (mpi_tag) BETWEEN 1500 AND 1999
               AND NOT (mpi_tag = 1999 OR mpi_val = '*NP*')) t04
     WHERE t01.cntl_rec_id = t02.cntl_rec_id
       AND t02.proc_order = t03.proc_order
       AND t01.opertn = t03.opertn
       AND t02.proc_order = t04.proc_order
       AND t03.opertn = t04.opertn
       AND t03.phase = t04.phase
       AND teco_stat = 'NO'
  GROUP BY t02.proc_order,
           t01.cntl_rec_id,
           t01.opertn,
           t03.phase,
           t04.mpi_desc
  /*-*/
  /* this will get the phase headers for SRC values - these are any SRC's within the range 1500 to 1999
  /*-*/
  UNION
  SELECT   LTRIM (t02.proc_order, '0') proc_order, t01.cntl_rec_id,
           t01.opertn, t03.phase, '0001' seq, t04.mpi_desc, NULL uom,
           NULL qty, NULL sub_total, 1 dummy, '0', 'HH', '' sub_header
      FROM recpe_resrce t01,
           cntl_rec t02,
           cntl_rec_mpi_val t03,
           (SELECT proc_order, opertn, phase, mpi_desc
              FROM cntl_rec_mpi_val t05
             WHERE TO_NUMBER (mpi_tag) BETWEEN 1500 AND 1999
               AND NOT (mpi_tag = 1999 OR mpi_val = '*NP*')) t04
     WHERE t01.cntl_rec_id = t02.cntl_rec_id
       AND t02.proc_order = t03.proc_order
       AND t01.opertn = t03.opertn
       AND t02.proc_order = t04.proc_order
       AND t03.opertn = t04.opertn
       AND t03.phase = t04.phase
       AND teco_stat = 'NO'
  GROUP BY t02.proc_order,
           t01.cntl_rec_id,
           t01.opertn,
           t03.phase,
           t04.mpi_desc
  /*-*/
  /* this will get the phase headers for SRC text values ie instructions
  /* - these are any SRC's within the range 1500 to 1999
  /*-*/
  UNION
  SELECT   LTRIM (t02.proc_order, '0') proc_order, t01.cntl_rec_id,
           t01.opertn, t03.phase, '0000' seq,
           t01.resrce_code || '  ' || t01.resrce_desc description, NULL uom,
           NULL qty, NULL sub_total, 1 dummy, '0', 'HH', '' sub_header
      FROM recpe_resrce t01,
           cntl_rec t02,
           cntl_rec_mpi_txt t03,
           (SELECT proc_order, opertn, phase, mpi_desc
              FROM cntl_rec_mpi_val t05
             WHERE TO_NUMBER (mpi_tag) BETWEEN 1500 AND 1999
               AND NOT (mpi_tag = 1999 OR mpi_val = '*NP*')) t04
     WHERE t01.cntl_rec_id = t02.cntl_rec_id
       AND t02.proc_order = t03.proc_order
       AND t01.opertn = t03.opertn
       AND t02.proc_order = t04.proc_order
       AND t03.opertn = t04.opertn
       AND t03.phase = t04.phase
       AND teco_stat = 'NO'
  GROUP BY t02.proc_order,
           t01.cntl_rec_id,
           t01.opertn,
           t03.phase,
           t01.resrce_code || '  ' || t01.resrce_desc
  UNION ALL
    /* material records from recpe_dtl which have been created by the
  /* recpe_conversion package */
  SELECT LTRIM (t01.proc_order, '0') proc_order, t01.cntl_rec_id, opertn,
         t01.phase, LPAD (t01.seq, 4, '0') seq,
         '    ' || RPAD (t01.matl_code, 9, ' ') || t01.matl_desc, t01.uom,
         TO_CHAR (ROUND (t01.bom_qty, 3), '999G990D990'),
         TO_CHAR (ROUND (t01.total, 3), '999G990D990'), 2,
         DECODE (rgnl_code_nmbr, NULL, '0', rgnl_code_nmbr) old_matl_code,
         DECODE (t01.phantom, 'B', 'B', 'M'), '' sub_header
    FROM (SELECT t10.*, t11.proc_order, t11.plant
            FROM recpe_dtl t10, cntl_rec t11
           WHERE t10.cntl_rec_id = t11.cntl_rec_id
             AND (t10.phantom = 'U' OR t10.phantom = 'B'
                  OR t10.phantom IS NULL
                 )) t01,
         matl t02
   WHERE t01.matl_code = t02.matl_code(+) AND t01.plant = t02.plant(+)
  UNION ALL
  /* add the mpi val fields */
  SELECT LTRIM (t01.proc_order, '0') proc_order, t01.cntl_rec_id, t02.opertn,
         phase, LPAD (seq, 4, '0') seq, mpi_desc, mpi_uom, mpi_val, '', 2,
         '0', 'S', sub_header
    FROM recpe_val t02, cntl_rec t01
   WHERE t01.cntl_rec_id = t02.cntl_rec_id
     AND (TO_NUMBER (mpi_tag) NOT BETWEEN 1500 AND 1999 OR mpi_tag IS NULL)
  UNION ALL
  /* add the mpi text fields */
  SELECT LTRIM (t01.proc_order, '0') proc_order, cntl_rec_id, t02.opertn,
         phase, LPAD (seq, 4, '0') seq,
         DECODE (dtl_desc, '*', mpi_text, dtl_desc), '' mpi_uom, '' mpi_val,
         '', 2, '0', DECODE (mpi_type, 'H', 'B', 'N', 'I', mpi_type),
         '' sub_header
    FROM cntl_rec_mpi_txt t02, cntl_rec t01
   WHERE t01.proc_order = t02.proc_order;


GRANT SELECT ON MANU_APP.RECPE_VW TO APPSUPPORT;

GRANT SELECT ON MANU_APP.RECPE_VW TO MANU_MAINT;

GRANT SELECT ON MANU_APP.RECPE_VW TO MANU_USER;

GRANT SELECT ON MANU_APP.RECPE_VW TO PUBLIC;

