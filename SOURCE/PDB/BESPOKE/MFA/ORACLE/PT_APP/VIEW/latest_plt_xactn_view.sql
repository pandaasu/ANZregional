DROP VIEW PT_APP.LATEST_PLT_XACTN_VIEW;

/* Formatted on 2008/12/22 11:15 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW pt_app.latest_plt_xactn_view (plt_code,
                                                           max_xactn_seq
                                                          )
AS
  SELECT   pt.pts_trans.plt_code, MAX (pt.pts_trans.xactn_seq) max_xactn_seq
      FROM pt.pts_trans, manu.material_vw
     WHERE pt.pts_trans.material_code = manu.material_vw.material_code
  GROUP BY pt.pts_trans.plt_code;


DROP PUBLIC SYNONYM LATEST_PLT_XACTN_VIEW;

CREATE PUBLIC SYNONYM LATEST_PLT_XACTN_VIEW FOR PT_APP.LATEST_PLT_XACTN_VIEW;


GRANT SELECT ON PT_APP.LATEST_PLT_XACTN_VIEW TO PT_MAINT;

GRANT SELECT ON PT_APP.LATEST_PLT_XACTN_VIEW TO PT_SUPPORT;

GRANT SELECT ON PT_APP.LATEST_PLT_XACTN_VIEW TO PT_USER;

