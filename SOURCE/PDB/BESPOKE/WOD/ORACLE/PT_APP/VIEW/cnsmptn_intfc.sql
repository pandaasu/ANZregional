DROP VIEW PT_APP.CNSMPTN_INTFC;

/* Formatted on 2008/09/24 12:18 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW pt_app.cnsmptn_intfc (plt_cnsmptn_id,
                                                   proc_order,
                                                   matl_code,
                                                   qty,
                                                   uom,
                                                   plant_code,
                                                   sent_flag,
                                                   store_locn,
                                                   upd_datime,
                                                   trans_id,
                                                   trans_type
                                                  )
AS
  SELECT "PLT_CNSMPTN_ID", "PROC_ORDER", "MATL_CODE", "QTY", "UOM",
         "PLANT_CODE", "SENT_FLAG", "STORE_LOCN", "UPD_DATIME", "TRANS_ID",
         "TRANS_TYPE"
    FROM plt_cnsmptn;


DROP PUBLIC SYNONYM CNSMPTN_INTFC;

CREATE PUBLIC SYNONYM CNSMPTN_INTFC FOR PT_APP.CNSMPTN_INTFC;


GRANT SELECT ON PT_APP.CNSMPTN_INTFC TO APPSUPPORT;

GRANT SELECT ON PT_APP.CNSMPTN_INTFC TO PT_MAINT;

GRANT SELECT ON PT_APP.CNSMPTN_INTFC TO PT_USER;

GRANT SELECT ON PT_APP.CNSMPTN_INTFC TO PUBLIC;

