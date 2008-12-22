DROP VIEW PT_APP.PTS_HOLD_CODES_VIEW;

/* Formatted on 2008/12/22 11:15 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW pt_app.pts_hold_codes_view (hold_code,
                                                         short_desc,
                                                         description
                                                        )
AS
  SELECT hr.hold_reason_code, ht.description, hr.description
    FROM pts_hold_reason hr, pts_hold_reason_type ht
   WHERE hr.hold_reason_type_code = ht.hold_reason_type_code
     AND hr.status = 'A'
     AND ht.status = 'A';


DROP PUBLIC SYNONYM PTS_HOLD_CODES_VIEW;

CREATE PUBLIC SYNONYM PTS_HOLD_CODES_VIEW FOR PT_APP.PTS_HOLD_CODES_VIEW;


GRANT SELECT ON PT_APP.PTS_HOLD_CODES_VIEW TO CITEC_PLT_USERS;

GRANT SELECT ON PT_APP.PTS_HOLD_CODES_VIEW TO PT_MAINT;

GRANT SELECT ON PT_APP.PTS_HOLD_CODES_VIEW TO PT_SUPPORT;

GRANT SELECT ON PT_APP.PTS_HOLD_CODES_VIEW TO PT_USER;

