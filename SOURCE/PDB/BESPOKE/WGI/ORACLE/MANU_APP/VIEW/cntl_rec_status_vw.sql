DROP VIEW MANU_APP.CNTL_REC_STATUS_VW;

/* Formatted on 2008/11/05 13:18 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.cntl_rec_status_vw (proc_order, closed)
AS
  SELECT LTRIM (proc_order, '0') proc_order,
         DECODE (teco_status, 'YES', 'X', '') closed
    FROM cntl_rec
   WHERE teco_status = 'YES';


DROP PUBLIC SYNONYM CNTL_REC_STATUS_VW;

CREATE PUBLIC SYNONYM CNTL_REC_STATUS_VW FOR MANU_APP.CNTL_REC_STATUS_VW;


GRANT SELECT ON MANU_APP.CNTL_REC_STATUS_VW TO PUBLIC WITH GRANT OPTION;

