DROP VIEW PT_APP.PRODN_ACTUAL;

/* Formatted on 2008/11/24 14:25 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW pt_app.prodn_actual (YEAR,
                                                  period,
                                                  week,
                                                  plant_code,
                                                  matl_code,
                                                  quantity,
                                                  uom
                                                 )
AS
  SELECT   t02.year_num YEAR, t02.period_num period, t02.mars_week week,
           t01.plant_code plant_code, t01.matl_code matl_code,
           ROUND (SUM (t01.qty)) quantity, t01.uom uom
      FROM plt_hdr t01, mars_date t02
     WHERE TRUNC (t01.start_prodn_datime) = t02.calendar_date
       AND status = 'CREATE'
  GROUP BY t02.period_num,
           t02.mars_week,
           t01.plant_code,
           t01.matl_code,
           t01.uom,
           t02.year_num;


DROP PUBLIC SYNONYM PRODN_ACTUAL;

CREATE PUBLIC SYNONYM PRODN_ACTUAL FOR PT_APP.PRODN_ACTUAL;


GRANT SELECT ON PT_APP.PRODN_ACTUAL TO APPSUPPORT;

GRANT SELECT ON PT_APP.PRODN_ACTUAL TO BTHSUPPORT;

