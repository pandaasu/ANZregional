DROP VIEW MANU.RECIPE_VW;

/* Formatted on 2008/12/22 11:05 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.recipe_vw (proc_order,
                                             operation,
                                             phase,
                                             seq,
                                             code,
                                             description,
                                             VALUE,
                                             uom,
                                             mpi_type
                                            )
AS
  SELECT LTRIM (v.proc_order, '0') proc_order, v.operation,
         TO_NUMBER (v.phase) phase, TO_NUMBER (LPAD (v.seq, 4, 0)) seq,
         LTRIM (v.material_code, '0') code,
            ' '
         || LTRIM (v.material_code, '0')
         || '-'
         || DECODE (m.old_material_code,
                    NULL, '',
                    '(' || m.old_material_code || ') '
                   )
         || v.material_desc description,
         
         --' ' || DECODE(m.SFP_CODE, get_link(v.MATERIAL_CODE, v.PROC_ORDER,m.SFP_CODE),'') || v.MATERIAL_CODE || '-' || DECODE(m.old_material_code, NULL,'','(' || m.old_material_code || ') ') || v.MATERIAL_DESC DESCRIPTION,
         TO_CHAR (ROUND (TO_NUMBER (  v.material_qty
                                    * DECODE (b.batch_qty,
                                              NULL, 1,
                                              b.batch_qty
                                             )
                                    / DECODE (b.batch_qty,
                                              NULL, 1,
                                              c.quantity
                                             )
                                   ),
                         3
                        ),
                  '999990.990'
                 ) VALUE,
         
         --TO_CHAR(v.MATERIAL_QTY) VALUE,
         v.material_uom uom, 'M' mpi_type
    FROM cntl_rec_bom v, cntl_rec_resource b, cntl_rec c, material_vw m
   WHERE v.proc_order = b.proc_order
     AND v.operation = b.operation(+)
     AND b.proc_order = c.proc_order
     AND LTRIM (v.material_code, '0') = m.material_code(+)
     AND SUBSTR (c.proc_order, 1, 1) BETWEEN '0' AND '9'
  UNION ALL
  SELECT LTRIM (proc_order, '0') proc_order, operation,
         TO_NUMBER (phase) phase, TO_NUMBER (LPAD (seq, 4, 0)) seq,
         mpi_tag code,
         DECODE (SUBSTR (mpi_desc, LENGTH (mpi_desc)),
                 CHR (13), SUBSTR (mpi_desc, 1, LENGTH (mpi_desc) - 1),
                 mpi_desc
                ) description,
         mpi_val VALUE, mpi_uom uom, 'V'
    FROM cntl_rec_mpi_val
   WHERE SUBSTR (proc_order, 1, 1) BETWEEN '0' AND '9'
  UNION ALL
  SELECT LTRIM (proc_order, '0') proc_order, operation,
         TO_NUMBER (phase) phase, TO_NUMBER (LPAD (seq, 4, 0)) seq,
         machine_code code,
         DECODE (SUBSTR (mpi_text, LENGTH (mpi_text)),
                 CHR (13), SUBSTR (mpi_text, 1, LENGTH (mpi_text) - 1),
                 mpi_text
                ) description,
         '' VALUE, '' uom, mpi_type
    FROM cntl_rec_mpi_txt
   WHERE SUBSTR (proc_order, 1, 1) BETWEEN '0' AND '9';


DROP PUBLIC SYNONYM RECIPE_VW;

CREATE PUBLIC SYNONYM RECIPE_VW FOR MANU.RECIPE_VW;


GRANT SELECT ON MANU.RECIPE_VW TO MANU_APP;

GRANT SELECT ON MANU.RECIPE_VW TO MANU_USER;

