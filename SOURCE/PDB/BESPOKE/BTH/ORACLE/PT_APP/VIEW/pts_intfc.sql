DROP VIEW PT_APP.PTS_INTFC;

/* Formatted on 2008/11/24 14:25 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW pt_app.pts_intfc (plt_code,
                                               xactn_type,
                                               xactn_date,
                                               xactn_time,
                                               user_id,
                                               proc_order,
                                               matl_code,
                                               qty,
                                               uom,
                                               plant_code,
                                               zpppi_batch,
                                               stor_locn_code,
                                               dispn_code,
                                               use_by_date,
                                               plt_create_datime,
                                               full_plt_flag,
                                               plt_type,
                                               sender_name,
                                               start_prodn_datime,
                                               end_prodn_datime
                                              )
AS
  SELECT t01.plt_code, xactn_type, xactn_date, xactn_time, user_id,
         proc_order, matl_code, qty, uom, plant_code, zpppi_batch,
         stor_locn_code, dispn_code, use_by_date,
         last_gr_flag plt_create_datime, full_plt_flag, plt_type, sender_name,
         t01.start_prodn_datime, t01.end_prodn_datime
    FROM plt_hdr t01, plt_det t02
   WHERE t01.plt_code = t02.plt_code AND LENGTH (t01.plt_code) > 10;


DROP PUBLIC SYNONYM PTS_INTFC;

CREATE PUBLIC SYNONYM PTS_INTFC FOR PT_APP.PTS_INTFC;


GRANT SELECT ON PT_APP.PTS_INTFC TO APPSUPPORT;

GRANT SELECT ON PT_APP.PTS_INTFC TO BTHSUPPORT;

GRANT SELECT ON PT_APP.PTS_INTFC TO CITECT_USER;

GRANT SELECT ON PT_APP.PTS_INTFC TO MANU_APP;

GRANT SELECT ON PT_APP.PTS_INTFC TO PT_MAINT;

GRANT SELECT ON PT_APP.PTS_INTFC TO PT_USER;

