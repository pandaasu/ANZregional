DROP VIEW PT_APP.CNSMPTN_VW;

/* Formatted on 2008/11/24 14:25 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW pt_app.cnsmptn_vw (plt_cnsmptn_id,
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


DROP PUBLIC SYNONYM CNSMPTN_VW;

CREATE PUBLIC SYNONYM CNSMPTN_VW FOR PT_APP.CNSMPTN_VW;


GRANT SELECT ON PT_APP.CNSMPTN_VW TO APPSUPPORT;

GRANT SELECT ON PT_APP.CNSMPTN_VW TO BTHSUPPORT;

GRANT SELECT ON PT_APP.CNSMPTN_VW TO MANU_APP;

GRANT SELECT ON PT_APP.CNSMPTN_VW TO PT_MAINT;

GRANT SELECT ON PT_APP.CNSMPTN_VW TO PT_USER;

