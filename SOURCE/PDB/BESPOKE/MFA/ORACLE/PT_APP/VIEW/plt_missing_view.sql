DROP VIEW PT_APP.PLT_MISSING_VIEW;

/* Formatted on 2008/12/22 11:15 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW pt_app.plt_missing_view (plt_code)
AS
  SELECT plt_code
    FROM (SELECT a.plt_code, b.plt_code plt2
            FROM (SELECT DECODE
                               (batch_cntl.batch_type,
                                'STA', RTRIM (SUBSTR (batch_err.batch_rec,
                                                      4,
                                                      8
                                                     )
                                             ),
                                'PSH', RTRIM (SUBSTR (batch_err.batch_rec,
                                                      10,
                                                      8
                                                     )
                                             ),
                                'ERROR'
                               ) plt_code
                    FROM batch_err, batch_cntl
                   WHERE SUBSTR (batch_err.batch_rec, 1, 3) = 'REC'
                     AND batch_err.batch_code = batch_cntl.batch_code
                     AND batch_err.batch_seq_code = batch_cntl.batch_seq_code) a,
                 plt b
           WHERE a.plt_code = b.plt_code(+))
   WHERE plt2 IS NULL
         WITH READ ONLY;


DROP PUBLIC SYNONYM PLT_MISSING_VIEW;

CREATE PUBLIC SYNONYM PLT_MISSING_VIEW FOR PT_APP.PLT_MISSING_VIEW;


GRANT SELECT ON PT_APP.PLT_MISSING_VIEW TO CITEC_PLT_USERS;

GRANT SELECT ON PT_APP.PLT_MISSING_VIEW TO PT_MAINT;

GRANT SELECT ON PT_APP.PLT_MISSING_VIEW TO PT_SUPPORT;

GRANT SELECT ON PT_APP.PLT_MISSING_VIEW TO PT_USER;

