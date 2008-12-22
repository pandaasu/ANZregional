DROP VIEW PT_APP.PTS_MISSING_VIEW;

/* Formatted on 2008/12/22 11:15 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW pt_app.pts_missing_view (plt_code)
AS
  SELECT plt_code
    FROM (SELECT a.plt_code, b.plt_code plt2
            FROM (SELECT DECODE
                           (pts_batch_cntl.batch_type,
                            'STO', RTRIM (SUBSTR (pts_batch_err.batch_rec,
                                                  4,
                                                  20
                                                 )
                                         ),
                            'STA', RTRIM (SUBSTR (pts_batch_err.batch_rec,
                                                  4,
                                                  8
                                                 )
                                         ),
                            'PSH', RTRIM (SUBSTR (pts_batch_err.batch_rec,
                                                  12,
                                                  20
                                                 )
                                         ),
                            'ERROR'
                           ) plt_code
                    FROM pts_batch_err, pts_batch_cntl
                   WHERE SUBSTR (pts_batch_err.batch_rec, 1, 3) = 'REC'
                     AND pts_batch_err.batch_code = pts_batch_cntl.batch_code
                     AND pts_batch_err.batch_seq_code =
                                                 pts_batch_cntl.batch_seq_code) a,
                 pts_plt b
           WHERE a.plt_code = b.plt_code(+))
   WHERE plt2 IS NULL
         WITH READ ONLY;


DROP PUBLIC SYNONYM PTS_MISSING_VIEW;

CREATE PUBLIC SYNONYM PTS_MISSING_VIEW FOR PT_APP.PTS_MISSING_VIEW;


GRANT SELECT ON PT_APP.PTS_MISSING_VIEW TO CITEC_PLT_USERS;

GRANT SELECT ON PT_APP.PTS_MISSING_VIEW TO PT_MAINT;

GRANT SELECT ON PT_APP.PTS_MISSING_VIEW TO PT_SUPPORT;

GRANT SELECT ON PT_APP.PTS_MISSING_VIEW TO PT_USER;

