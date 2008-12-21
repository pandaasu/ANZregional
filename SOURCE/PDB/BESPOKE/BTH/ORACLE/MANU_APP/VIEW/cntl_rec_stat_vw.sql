DROP VIEW MANU_APP.CNTL_REC_STAT_VW;

/* Formatted on 2008/12/22 10:14 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.cntl_rec_stat_vw (proc_order, closed)
AS
  SELECT LTRIM (proc_order, '0') proc_order,
         DECODE (teco_stat, 'YES', 'X', '') closed
    FROM cntl_rec
   WHERE teco_stat = 'YES' AND SUBSTR (proc_order, 1, 1) BETWEEN '0' AND '9';


DROP PUBLIC SYNONYM CNTL_REC_STAT_VW;

CREATE PUBLIC SYNONYM CNTL_REC_STAT_VW FOR MANU_APP.CNTL_REC_STAT_VW;


GRANT SELECT ON MANU_APP.CNTL_REC_STAT_VW TO APPSUPPORT;

GRANT SELECT ON MANU_APP.CNTL_REC_STAT_VW TO BARNEHEL WITH GRANT OPTION;

GRANT SELECT ON MANU_APP.CNTL_REC_STAT_VW TO BTHSUPPORT;

GRANT SELECT ON MANU_APP.CNTL_REC_STAT_VW TO CITECT_USER;

GRANT SELECT ON MANU_APP.CNTL_REC_STAT_VW TO MANU_MAINT;

GRANT SELECT ON MANU_APP.CNTL_REC_STAT_VW TO MANU_USER;

