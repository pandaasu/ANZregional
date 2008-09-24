DROP VIEW PT_APP.PLT_HDR_VW;

/* Formatted on 2008/09/24 12:18 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW pt_app.plt_hdr_vw (plt_code,
                                                matl_code,
                                                qty,
                                                status,
                                                plant_code,
                                                zpppi_batch,
                                                proc_order,
                                                stor_locn_code,
                                                dispn_code,
                                                use_by_date,
                                                last_gr_flag,
                                                plt_create_datime,
                                                uom,
                                                full_plt_flag
                                               )
AS
  SELECT "PLT_CODE", "MATL_CODE", "QTY", "STATUS", "PLANT_CODE",
         "ZPPPI_BATCH", "PROC_ORDER", "STOR_LOCN_CODE", "DISPN_CODE",
         "USE_BY_DATE", "LAST_GR_FLAG", "PLT_CREATE_DATIME", "UOM",
         "FULL_PLT_FLAG"
    FROM plt_hdr;


DROP PUBLIC SYNONYM PLT_HDR_VW;

CREATE PUBLIC SYNONYM PLT_HDR_VW FOR PT_APP.PLT_HDR_VW;


GRANT SELECT ON PT_APP.PLT_HDR_VW TO APPSUPPORT;

GRANT SELECT ON PT_APP.PLT_HDR_VW TO CITSRV1;

GRANT SELECT ON PT_APP.PLT_HDR_VW TO CITSRV2;

GRANT SELECT ON PT_APP.PLT_HDR_VW TO CITSRV3;

GRANT SELECT ON PT_APP.PLT_HDR_VW TO MANU WITH GRANT OPTION;

GRANT SELECT ON PT_APP.PLT_HDR_VW TO MANU_APP WITH GRANT OPTION;

GRANT SELECT ON PT_APP.PLT_HDR_VW TO PT_MAINT;

GRANT SELECT ON PT_APP.PLT_HDR_VW TO PT_USER;

