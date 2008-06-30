DROP VIEW MANU_APP.CNTL_REC_STAT_VW;

/* Formatted on 2008/06/30 14:46 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.cntl_rec_stat_vw (proc_order, closed)
AS
  SELECT LTRIM (proc_order, '0') proc_order,
         DECODE (teco_stat, 'YES', 'X', '') closed
    FROM cntl_rec
   WHERE teco_stat = 'YES' AND SUBSTR (proc_order, 1, 1) BETWEEN '0' AND '9';


GRANT SELECT ON MANU_APP.CNTL_REC_STAT_VW TO APPSUPPORT;

GRANT SELECT ON MANU_APP.CNTL_REC_STAT_VW TO FCS_READER;

GRANT SELECT ON MANU_APP.CNTL_REC_STAT_VW TO MANU_MAINT;

GRANT SELECT ON MANU_APP.CNTL_REC_STAT_VW TO MANU_USER;

