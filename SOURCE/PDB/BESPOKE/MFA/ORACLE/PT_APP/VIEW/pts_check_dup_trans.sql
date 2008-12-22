DROP VIEW PT_APP.PTS_CHECK_DUP_TRANS;

/* Formatted on 2008/12/22 11:15 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW pt_app.pts_check_dup_trans (proc_order,
                                                         xactn_seq,
                                                         xactn_type,
                                                         intfc_id,
                                                         plt_code,
                                                         material_code,
                                                         qty,
                                                         sent_flag,
                                                         reprocessed,
                                                         created_date,
                                                         xactn_date,
                                                         xactn_time,
                                                         created_by,
                                                         user_id,
                                                         sender_name,
                                                         zpppi_batch,
                                                         last_gr_flag,
                                                         dispn_code
                                                        )
AS
  SELECT t1.proc_order, t1.xactn_seq, t1.xactn_type, t3.intfc_id, plt_code,
         material_code, qty, sent_flag, t3.reprocessed, created_date,
         xactn_date, xactn_time, created_by, user_id, sender_name,
         zpppi_batch, last_gr_flag, dispn_code
    FROM pts_intfc t1,
         (SELECT   proc_order, xactn_seq, xactn_type, COUNT (*) rec_cnt
              FROM pts_xactn_intfc_xref
          GROUP BY proc_order, xactn_seq, xactn_type
            HAVING COUNT (*) > 1) t2,
         (SELECT proc_order, xactn_seq, xactn_type, intfc_id, reprocessed
            FROM pts_xactn_intfc_xref) t3
   WHERE t1.proc_order = t2.proc_order
     AND t2.proc_order = t3.proc_order
     AND t1.xactn_seq = t2.xactn_seq
     AND t2.xactn_seq = t3.xactn_seq
     AND t1.xactn_type = t2.xactn_type
     AND t2.xactn_type = t3.xactn_type
  UNION ALL
  SELECT t1.proc_order, t1.seq_id xactn_seq, t1.xactn_type, t3.intfc_id,
         '' plt_code, material_code, qty, sent_flag, t3.reprocessed,
         created_date, xactn_date, xactn_time, created_by, user_id,
         sender_name, zpppi_batch, last_gr_flag, dispn_code
    FROM process_intfc t1,
         (SELECT   proc_order, xactn_seq, xactn_type, COUNT (*) rec_cnt
              FROM pts_xactn_intfc_xref
          GROUP BY proc_order, xactn_seq, xactn_type
            HAVING COUNT (*) > 1) t2,
         (SELECT proc_order, xactn_seq, xactn_type, intfc_id, reprocessed
            FROM pts_xactn_intfc_xref) t3
   WHERE t1.proc_order = t2.proc_order
     AND t2.proc_order = t3.proc_order
     AND t1.seq_id = t2.xactn_seq
     AND t2.xactn_seq = t3.xactn_seq
     AND t1.xactn_type = t2.xactn_type
     AND t2.xactn_type = t3.xactn_type
--
-- Created By Craig George, 5 Aug 2005
--
-- Used to identify pallets or processes, which have been sent to SAP more than once
-- Used by the procedure CREATE_CSV_INTFC_ERR
--;


