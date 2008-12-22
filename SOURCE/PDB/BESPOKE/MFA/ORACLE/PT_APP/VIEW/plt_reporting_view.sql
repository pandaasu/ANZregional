DROP VIEW PT_APP.PLT_REPORTING_VIEW;

/* Formatted on 2008/12/22 11:15 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW pt_app.plt_reporting_view (rptng_flag,
                                                        plt_code,
                                                        use_by_date,
                                                        item_code,
                                                        uom,
                                                        full_plt_flag,
                                                        hold_plt_flag,
                                                        frm_whse_code,
                                                        frm_whse_locn_code,
                                                        frm_work_centre,
                                                        to_whse_code,
                                                        rework_code,
                                                        plt_created_id,
                                                        plt_created_date,
                                                        plt_created_qty,
                                                        plt_cancel_id,
                                                        plt_cancel_date,
                                                        plt_cancel_qty,
                                                        backflush_code,
                                                        backflush_date,
                                                        rev_backflush_code,
                                                        rev_backflush_date,
                                                        sta_code,
                                                        sta_date,
                                                        sta_batch_code,
                                                        sta_loader_id,
                                                        sta_driver_id,
                                                        sta_trailer_id,
                                                        sta_dispn_code,
                                                        sta_status,
                                                        receipt_code,
                                                        receipt_date
                                                       )
AS
  SELECT plt.rptng_flag, plt_trans.plt_code, plt_trans.use_by_date,
         plt_trans.item_code, plt_trans.uom, plt_trans.full_plt_flag,
         plt_trans.hold_plt_flag, plt_trans.frm_whse_code,
         plt_trans.frm_whse_locn_code, plt_trans.frm_work_centre,
         plt_trans.to_whse_code, plt_trans.rework_code,
         plt_trans.plt_created_id, plt_trans.plt_created_date,
         plt_trans.plt_created_qty, plt_trans.plt_cancel_id,
         plt_trans.plt_cancel_date, plt_trans.plt_cancel_qty,
         plt_trans.backflush_code, plt_trans.backflush_date,
         plt_trans.rev_backflush_code, plt_trans.rev_backflush_date,
         plt_trans.sta_code, plt_trans.sta_date, plt_trans.sta_batch_code,
         plt_trans.sta_loader_id, plt_trans.sta_driver_id,
         plt_trans.sta_trailer_id, plt_trans.sta_dispn_code,
         plt_trans.sta_status, plt_trans.receipt_code, plt_trans.receipt_date
    FROM plt, plt_trans
   WHERE plt.plt_trans_xactn_seq = plt_trans.xactn_seq
         WITH READ ONLY;


DROP PUBLIC SYNONYM PLT_REPORTING_VIEW;

CREATE PUBLIC SYNONYM PLT_REPORTING_VIEW FOR PT_APP.PLT_REPORTING_VIEW;


GRANT SELECT ON PT_APP.PLT_REPORTING_VIEW TO PUBLIC;

