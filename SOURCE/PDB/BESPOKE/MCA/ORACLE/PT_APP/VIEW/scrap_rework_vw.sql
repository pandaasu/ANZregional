DROP VIEW PT_APP.SCRAP_REWORK_VW;

/* Formatted on 2008/06/30 14:41 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW pt_app.scrap_rework_vw (scrap_rework_id,
                                                     proc_order,
                                                     matl_code,
                                                     qty,
                                                     uom,
                                                     storage_locn,
                                                     event_datime,
                                                     plant_code,
                                                     scrap_rework_code,
                                                     reason_code,
                                                     sent_flag,
                                                     rework_code,
                                                     rework_batch_code,
                                                     rework_exp_date,
                                                     rework_sloc,
                                                     cost_centre
                                                    )
AS
  SELECT "SCRAP_REWORK_ID", "PROC_ORDER", "MATL_CODE", "QTY", "UOM",
         "STORAGE_LOCN", "EVENT_DATIME", "PLANT_CODE", "SCRAP_REWORK_CODE",
         "REASON_CODE", "SENT_FLAG", "REWORK_CODE", "REWORK_BATCH_CODE",
         "REWORK_EXP_DATE", "REWORK_SLOC", "COST_CENTRE"
    FROM scrap_rework;


GRANT SELECT ON PT_APP.SCRAP_REWORK_VW TO APPSUPPORT;

GRANT SELECT ON PT_APP.SCRAP_REWORK_VW TO FCS_USER;

