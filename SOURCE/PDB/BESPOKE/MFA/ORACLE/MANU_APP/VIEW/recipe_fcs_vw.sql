DROP VIEW MANU_APP.RECIPE_FCS_VW;

/* Formatted on 2008/09/05 10:50 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.recipe_fcs_vw (proc_order,
                                                     cntl_rec_id,
                                                     material,
                                                     material_text,
                                                     resource_code,
                                                     operation,
                                                     phase,
                                                     seq,
                                                     code,
                                                     description,
                                                     VALUE,
                                                     uom,
                                                     mpi_type,
                                                     run_start_datime,
                                                     run_end_datime,
                                                     proc_order_status,
                                                     batch_qty,
                                                     storage_locn,
                                                     box_no
                                                    )
AS
  SELECT LTRIM (v.proc_order, 0) proc_order, cntl_rec_id,
         LTRIM (material, '0') material, c.material_text, r.resource_code,
         v.operation, TO_NUMBER (v.phase) phase,
         TO_NUMBER (LPAD (v.seq, 4, 0)) seq, LTRIM (material_code, '0') code,
         material_desc description,
         
         --TO_CHAR(ROUND(TO_NUMBER(MATERIAL_QTY),3),'9999999.990') VALUE,
         TO_CHAR (get_bom_qty (LTRIM (c.material, '0'),
                               LTRIM (v.material_code, '0'),
                               v.seq
                              ),
                  '9999990.990'
                 ) VALUE,
         material_uom uom, 'M' mpi_type, run_start_datime, run_end_datime,
         s.closed proc_order_status,
         TO_CHAR (get_bom_batch_qty (LTRIM (c.material, '0'))) batch_qty,
         storage_locn, l.box_no
    FROM cntl_rec_bom v,
         cntl_rec_resource r,
         cntl_rec c,
         cntl_rec_status_vw s,
         automation_liquid l
   WHERE r.proc_order = v.proc_order
     AND r.operation = v.operation
     AND c.proc_order = v.proc_order
     AND TO_NUMBER (r.proc_order) = TO_NUMBER (s.proc_order(+))
     AND teco_status = 'NO'
     AND LTRIM (v.proc_order, '0') = l.proc_order(+)
     AND v.operation = l.operation(+)
     AND TO_NUMBER (v.phase) = l.phase(+)
     AND TO_NUMBER (v.seq) = l.seq(+)
     AND SUBSTR (c.proc_order, 1, 1) BETWEEN '0' AND '9'
  UNION ALL
  SELECT LTRIM (r.proc_order, 0) proc_order, c.cntl_rec_id,
         LTRIM (c.material, '0') material, c.material_text, r.resource_code,
         v.operation, TO_NUMBER (v.phase) phase,
         TO_NUMBER (LPAD (v.seq, 4, 0)) seq, mpi_tag code,
         mpi_desc description, mpi_val VALUE, mpi_uom uom, 'V',
         run_start_datime, run_end_datime, s.closed proc_order_status,
         TO_CHAR (get_bom_batch_qty (LTRIM (c.material, '0'))) batch_qty,
         storage_locn, box_no
    FROM cntl_rec_mpi_val v,
         cntl_rec_resource r,
         automation_liquid l,
         cntl_rec c,
         cntl_rec_status_vw s
   WHERE r.proc_order = v.proc_order
     AND r.operation = v.operation
     AND r.proc_order = c.proc_order
     AND TO_NUMBER (r.proc_order) = TO_NUMBER (s.proc_order(+))
     AND teco_status = 'NO'
     AND LTRIM (v.proc_order, '0') = l.proc_order(+)
     AND v.operation = l.operation(+)
     AND TO_NUMBER (v.phase) = l.phase(+)
     AND TO_NUMBER (v.seq) = l.seq(+)
     AND SUBSTR (c.proc_order, 1, 1) BETWEEN '0' AND '9';


DROP PUBLIC SYNONYM RECIPE_FCS_VW;

CREATE PUBLIC SYNONYM RECIPE_FCS_VW FOR MANU_APP.RECIPE_FCS_VW;


GRANT SELECT ON MANU_APP.RECIPE_FCS_VW TO IGNUSIAN WITH GRANT OPTION;

GRANT SELECT ON MANU_APP.RECIPE_FCS_VW TO MANU_USER;

GRANT SELECT ON MANU_APP.RECIPE_FCS_VW TO PT_APP;

