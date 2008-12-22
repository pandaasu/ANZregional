DROP VIEW PT_APP.PLT_CURRENT_CREATE_VIEW;

/* Formatted on 2008/12/22 11:15 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW pt_app.plt_current_create_view (xactn_seq,
                                                             xactn_type,
                                                             plt_code,
                                                             use_by_date,
                                                             item_code,
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
                                                             hold_comment
                                                            )
AS
  SELECT plt_trans.*
    FROM plt, plt_trans
   WHERE plt.plt_trans_xactn_seq = plt_trans.xactn_seq
     AND plt_trans.plt_created_date > TRUNC (SYSDATE) - 1
         WITH READ ONLY;


DROP PUBLIC SYNONYM PLT_CURRENT_CREATE_VIEW;

CREATE PUBLIC SYNONYM PLT_CURRENT_CREATE_VIEW FOR PT_APP.PLT_CURRENT_CREATE_VIEW;


GRANT SELECT ON PT_APP.PLT_CURRENT_CREATE_VIEW TO PUBLIC;

