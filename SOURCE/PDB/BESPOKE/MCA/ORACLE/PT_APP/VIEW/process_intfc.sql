DROP VIEW PT_APP.PROCESS_INTFC;

/* Formatted on 2008/06/30 14:41 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW pt_app.process_intfc (plt_code,
                                                   xactn_type,
                                                   xactn_date,
                                                   xactn_time,
                                                   user_id,
                                                   proc_order,
                                                   matl_code,
                                                   qty,
                                                   uom,
                                                   plant_code,
                                                   stor_locn_code,
                                                   dispn_code,
                                                   use_by_date,
                                                   plt_create_datime,
                                                   full_plt_flag,
                                                   plt_type,
                                                   sender_name
                                                  )
AS
  SELECT t01.plt_code, xactn_type, xactn_date, xactn_time, user_id,
         proc_order, matl_code, qty, uom, plant_code, stor_locn_code,
         dispn_code, use_by_date, last_gr_flag plt_create_datime,
         full_plt_flag, plt_type, sender_name
    FROM plt_hdr t01, plt_det t02
   WHERE t01.plt_code = t02.plt_code AND LENGTH (t01.plt_code) < 10;


DROP PUBLIC SYNONYM PROCESS_INTFC;

CREATE PUBLIC SYNONYM PROCESS_INTFC FOR PT_APP.PROCESS_INTFC;


GRANT SELECT ON PT_APP.PROCESS_INTFC TO APPSUPPORT;

GRANT SELECT ON PT_APP.PROCESS_INTFC TO FCS_READER;

GRANT SELECT ON PT_APP.PROCESS_INTFC TO FCS_USER;

GRANT SELECT ON PT_APP.PROCESS_INTFC TO MANU_APP;

GRANT SELECT ON PT_APP.PROCESS_INTFC TO PT_MAINT;

GRANT SELECT ON PT_APP.PROCESS_INTFC TO PT_USER;

