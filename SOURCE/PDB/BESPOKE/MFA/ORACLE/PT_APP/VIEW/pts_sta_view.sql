DROP VIEW PT_APP.PTS_STA_VIEW;

/* Formatted on 2008/12/22 11:15 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW pt_app.pts_sta_view (plt_code,
                                                  batch_code,
                                                  sto_cnn_code,
                                                  created_date
                                                 )
AS
  SELECT sto_dtl.plt_code, sto.batch_code, sto.sto_cnn_code, sto.created_date
    FROM sto, sto_dtl
   WHERE sto.sto_cnn_code = sto_dtl.sto_cnn_code AND sto.status = 'C'
         WITH READ ONLY;


DROP PUBLIC SYNONYM PTS_STA_VIEW;

CREATE PUBLIC SYNONYM PTS_STA_VIEW FOR PT_APP.PTS_STA_VIEW;


GRANT SELECT ON PT_APP.PTS_STA_VIEW TO CITEC_PLT_USERS;

GRANT SELECT ON PT_APP.PTS_STA_VIEW TO NEGUSIAN;

GRANT SELECT ON PT_APP.PTS_STA_VIEW TO PT_MAINT;

GRANT SELECT ON PT_APP.PTS_STA_VIEW TO PT_SUPPORT;

GRANT SELECT ON PT_APP.PTS_STA_VIEW TO PT_USER;

