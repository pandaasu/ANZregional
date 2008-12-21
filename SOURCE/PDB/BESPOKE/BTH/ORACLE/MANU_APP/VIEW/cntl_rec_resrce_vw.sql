DROP VIEW MANU_APP.CNTL_REC_RESRCE_VW;

/* Formatted on 2008/12/22 10:14 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.cntl_rec_resrce_vw (proc_order,
                                                          opertn,
                                                          resrce_code
                                                         )
AS
  SELECT LTRIM (proc_order, '0') proc_order, opertn, resrce_code
    FROM cntl_rec_resrce;


DROP PUBLIC SYNONYM CNTL_REC_RESRCE_VW;

CREATE PUBLIC SYNONYM CNTL_REC_RESRCE_VW FOR MANU_APP.CNTL_REC_RESRCE_VW;


GRANT SELECT ON MANU_APP.CNTL_REC_RESRCE_VW TO APPSUPPORT;

GRANT SELECT ON MANU_APP.CNTL_REC_RESRCE_VW TO CITECT_USER;

GRANT SELECT ON MANU_APP.CNTL_REC_RESRCE_VW TO MANU_MAINT;

GRANT SELECT ON MANU_APP.CNTL_REC_RESRCE_VW TO MANU_USER;

