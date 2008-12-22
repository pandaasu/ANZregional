DROP VIEW PT_APP.PLT_MATCHING_VIEW;

/* Formatted on 2008/12/22 11:16 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW pt_app.plt_matching_view (plt_code)
AS
  SELECT DECODE (batch_cntl.batch_type,
                 'STA', RTRIM (SUBSTR (batch_err.batch_rec, 4, 8)),
                 'PSH', RTRIM (SUBSTR (batch_err.batch_rec, 10, 8)),
                 'ERROR'
                ) plt_code
    FROM batch_err, batch_cntl
   WHERE SUBSTR (batch_err.batch_rec, 1, 3) = 'REC'
     AND batch_err.batch_code = batch_cntl.batch_code
     AND batch_err.batch_seq_code = batch_cntl.batch_seq_code
     AND DECODE (batch_cntl.batch_type,
                 'STA', RTRIM (SUBSTR (batch_err.batch_rec, 4, 8)),
                 'PSH', RTRIM (SUBSTR (batch_err.batch_rec, 10, 8)),
                 'ERROR'
                ) IN (SELECT plt_code
                        FROM plt)
         WITH READ ONLY;


DROP PUBLIC SYNONYM PLT_MATCHING_VIEW;

CREATE PUBLIC SYNONYM PLT_MATCHING_VIEW FOR PT_APP.PLT_MATCHING_VIEW;


GRANT SELECT ON PT_APP.PLT_MATCHING_VIEW TO PUBLIC;

