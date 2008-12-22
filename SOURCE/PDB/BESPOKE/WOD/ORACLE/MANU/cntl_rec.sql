DROP VIEW MANU.CNTL_REC;

/* Formatted on 2008/12/22 11:32 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.cntl_rec (proc_order,
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
                                            idoc_timestamp
                                           )
AS
  SELECT   MAX (proc_order) AS proc_order, cntl_rec_id,
           MAX (plant_code) AS plant, MAX (cntl_rec_status) AS cntl_rec_stat,
           MAX (test_flag) AS test_flag, MAX (recipe_text) AS recpe_text,
           MAX (material) AS matl_code, MAX (material_text) AS matl_text,
           MAX (quantity) AS qty, MAX (insplot) AS insplot, MAX (uom) AS uom,
           MAX (batch) AS batch,
           MAX (sched_start_datime) AS sched_start_datime,
           MAX (run_start_datime) AS run_start_datime,
           MAX (run_end_datime) AS run_end_datime, MAX (VERSION) AS vrsn,
           MAX (upd_datime) AS upd_datime,
           MAX (cntl_rec_xfer) AS cntl_rec_xfer,
           MAX (teco_status) AS teco_stat, MAX (storage_locn) AS strge_locn,
           MAX (idoc_timestamp) AS idoc_timestamp
      FROM bds_recipe_header
     WHERE plant_code IN ('AU20', 'AU21', 'AU22', 'AU23', 'AU24', 'AU25')
  GROUP BY cntl_rec_id;


DROP PUBLIC SYNONYM CNTL_REC;

CREATE PUBLIC SYNONYM CNTL_REC FOR MANU.CNTL_REC;


GRANT SELECT ON MANU.CNTL_REC TO MANU_APP WITH GRANT OPTION;

