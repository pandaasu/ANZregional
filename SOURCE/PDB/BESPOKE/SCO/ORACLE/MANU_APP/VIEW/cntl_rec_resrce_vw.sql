DROP VIEW MANU_APP.CNTL_REC_RESRCE_VW;

/* Formatted on 2008/06/30 14:46 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.cntl_rec_resrce_vw (proc_order,
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
                                                          strge_locn,
                                                          resrce_code
                                                         )
AS
  SELECT  /******************************************************************/
          /* This is a straight view of the bds_recipe_header table
          /* with resource records
          /* 15 Oct 2007 JP added resource column
          /******************************************************************/
         LTRIM (t01.proc_order, 0) AS proc_order, t01.cntl_rec_id,
         t01.plant_code AS plant, t01.cntl_rec_status AS cntl_rec_stat,
         t01.test_flag, t01.recipe_text AS recpe_text,
         LTRIM (t01.material, '0') matl_code, t01.material_text AS matl_text,
         ROUND (TO_NUMBER (t01.quantity), 3) qty, t01.insplot, t01.uom,
         t01.batch, t01.sched_start_datime, t01.run_start_datime,
         t01.run_end_datime, t01.VERSION AS vrsn, t01.upd_datime,
         t01.cntl_rec_xfer, t01.teco_status AS teco_stat,
         t01.storage_locn AS strge_locn, t02.resource_code AS resrce_code
    FROM bds_recipe_header t01,
         (SELECT DISTINCT t01.proc_order, t01.resource_code
                     FROM bds_recipe_resource t01
                    WHERE (   operation IN (
                                SELECT operation
                                  FROM bds_recipe_bom
                                 WHERE proc_order = t01.proc_order
                                   AND operation = t01.operation
                                   AND material_code NOT IN (
                                                            SELECT matl_code
                                                              FROM recpe_phantom))
                           OR (operation IN (
                                 SELECT operation
                                   FROM bds_recipe_src_value
                                  WHERE proc_order = t01.proc_order
                                    AND operation = t01.operation)
                              )
                           OR (operation IN (
                                 SELECT operation
                                   FROM bds_recipe_src_text
                                  WHERE proc_order = t01.proc_order
                                    AND operation = t01.operation)
                              )
                          )) t02
   WHERE t01.proc_order = t02.proc_order
     AND t01.plant_code = 'AU45'
     AND SUBSTR (t01.proc_order, 1, 1) BETWEEN '0' AND '9'
     AND teco_status = 'NO';


DROP PUBLIC SYNONYM CNTL_REC_RESRCE_VW;

CREATE PUBLIC SYNONYM CNTL_REC_RESRCE_VW FOR MANU_APP.CNTL_REC_RESRCE_VW;


GRANT SELECT ON MANU_APP.CNTL_REC_RESRCE_VW TO APPSUPPORT;

GRANT SELECT ON MANU_APP.CNTL_REC_RESRCE_VW TO FCS_READER;

GRANT SELECT ON MANU_APP.CNTL_REC_RESRCE_VW TO FCS_USER;

GRANT SELECT ON MANU_APP.CNTL_REC_RESRCE_VW TO MANU_MAINT;

