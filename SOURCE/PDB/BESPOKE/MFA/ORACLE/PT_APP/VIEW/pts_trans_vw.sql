DROP VIEW PT_APP.PTS_TRANS_VW;

/* Formatted on 2008/12/22 11:15 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW pt_app.pts_trans_vw (xactn_seq,
                                                  xactn_type,
                                                  plt_code,
                                                  use_by_date,
                                                  uom,
                                                  qty,
                                                  full_plt_flag,
                                                  hold_plt_flag,
                                                  frm_whse_code,
                                                  frm_whse_locn_code,
                                                  frm_work_centre,
                                                  to_whse_code,
                                                  rework_code,
                                                  plt_created_intfc_xactn_seq,
                                                  plt_created_id,
                                                  plt_created_date,
                                                  plt_created_qty,
                                                  plt_cancel_intfc_xactn_seq,
                                                  plt_cancel_id,
                                                  plt_cancel_date,
                                                  plt_cancel_qty,
                                                  backflush_code,
                                                  backflush_by,
                                                  backflush_date,
                                                  rev_backflush_code,
                                                  rev_backflush_by,
                                                  rev_backflush_date,
                                                  sta_intfc_xactn_seq,
                                                  sta_code,
                                                  sta_batch_code,
                                                  sta_date,
                                                  sta_loader_id,
                                                  sta_driver_id,
                                                  sta_trailer_id,
                                                  sta_dispn_code,
                                                  sta_status,
                                                  receipt_code,
                                                  receipt_by,
                                                  receipt_date,
                                                  status,
                                                  created_by,
                                                  created_date,
                                                  disposition_code,
                                                  disposition_by,
                                                  disposition_date,
                                                  disposition_dispn_code,
                                                  plt_hold_intfc_xactn_seq,
                                                  plt_hold_id,
                                                  plt_hold_date,
                                                  hold_code_1,
                                                  hold_code_2,
                                                  hold_code_3,
                                                  hold_code_4,
                                                  hold_code_5,
                                                  hold_comment,
                                                  xactn_time,
                                                  plant_code,
                                                  sender_name,
                                                  zpppi_batch,
                                                  proc_order,
                                                  stor_loc_code,
                                                  dispn_code,
                                                  material_code,
                                                  sta_time
                                                 )
AS
  SELECT "XACTN_SEQ", "XACTN_TYPE", "PLT_CODE", "USE_BY_DATE", "UOM", "QTY",
         "FULL_PLT_FLAG", "HOLD_PLT_FLAG", "FRM_WHSE_CODE",
         "FRM_WHSE_LOCN_CODE", "FRM_WORK_CENTRE", "TO_WHSE_CODE",
         "REWORK_CODE", "PLT_CREATED_INTFC_XACTN_SEQ", "PLT_CREATED_ID",
         "PLT_CREATED_DATE", "PLT_CREATED_QTY", "PLT_CANCEL_INTFC_XACTN_SEQ",
         "PLT_CANCEL_ID", "PLT_CANCEL_DATE", "PLT_CANCEL_QTY",
         "BACKFLUSH_CODE", "BACKFLUSH_BY", "BACKFLUSH_DATE",
         "REV_BACKFLUSH_CODE", "REV_BACKFLUSH_BY", "REV_BACKFLUSH_DATE",
         "STA_INTFC_XACTN_SEQ", "STA_CODE", "STA_BATCH_CODE", "STA_DATE",
         "STA_LOADER_ID", "STA_DRIVER_ID", "STA_TRAILER_ID", "STA_DISPN_CODE",
         "STA_STATUS", "RECEIPT_CODE", "RECEIPT_BY", "RECEIPT_DATE", "STATUS",
         "CREATED_BY", "CREATED_DATE", "DISPOSITION_CODE", "DISPOSITION_BY",
         "DISPOSITION_DATE", "DISPOSITION_DISPN_CODE",
         "PLT_HOLD_INTFC_XACTN_SEQ", "PLT_HOLD_ID", "PLT_HOLD_DATE",
         "HOLD_CODE_1", "HOLD_CODE_2", "HOLD_CODE_3", "HOLD_CODE_4",
         "HOLD_CODE_5", "HOLD_COMMENT", "XACTN_TIME", "PLANT_CODE",
         "SENDER_NAME", "ZPPPI_BATCH", "PROC_ORDER", "STOR_LOC_CODE",
         "DISPN_CODE", "MATERIAL_CODE", "STA_TIME"
    FROM pts_trans
   WHERE plt_created_date > (SYSDATE - 7);


GRANT SELECT ON PT_APP.PTS_TRANS_VW TO MAYDAV;

GRANT SELECT ON PT_APP.PTS_TRANS_VW TO PT_MAINT;

GRANT SELECT ON PT_APP.PTS_TRANS_VW TO PT_SUPPORT;

GRANT SELECT ON PT_APP.PTS_TRANS_VW TO PT_USER;

GRANT SELECT ON PT_APP.PTS_TRANS_VW TO SHIFTMGR;

