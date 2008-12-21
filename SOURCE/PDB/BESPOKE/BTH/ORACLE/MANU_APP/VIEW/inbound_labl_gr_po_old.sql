DROP VIEW MANU_APP.INBOUND_LABL_GR_PO_OLD;

/* Formatted on 2008/12/22 10:14 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.inbound_labl_gr_po_old (proc_order,
                                                              opertn,
                                                              resrce_code,
                                                              cntl_rec_id,
                                                              plant,
                                                              matl_code,
                                                              matl_text,
                                                              qty,
                                                              uom,
                                                              run_start_datime,
                                                              run_end_datime,
                                                              vrsn,
                                                              upd_datime,
                                                              strge_locn
                                                             )
AS
  SELECT LTRIM (t01.proc_order, '0') proc_order, t02.opertn, t02.resrce_code,
         "CNTL_REC_ID",
                  -- changes every time a change is recieved to the proc order
                       t01.plant, LTRIM (matl_code, '0') matl, "MATL_TEXT",
         ROUND (TO_NUMBER (qty), 6) qty, "UOM", "RUN_START_DATIME",
         "RUN_END_DATIME", "VRSN",
                       -- counts the number of times a new version has arrived
                                  "UPD_DATIME", "STRGE_LOCN"
    FROM cntl_rec t01, cntl_rec_resrce t02
   WHERE t01.proc_order = t02.proc_order
     AND teco_stat = 'NO'
     AND (   (resrce_code IN ('RETRT001') AND t01.plant = 'AU30')
          OR (    resrce_code IN ('PAKLN007', 'DENTA008', 'LINEO009')
              AND t01.plant = 'AU21'
             )
         );


GRANT SELECT ON MANU_APP.INBOUND_LABL_GR_PO_OLD TO APPSUPPORT;

GRANT SELECT ON MANU_APP.INBOUND_LABL_GR_PO_OLD TO BTHSUPPORT;

GRANT SELECT ON MANU_APP.INBOUND_LABL_GR_PO_OLD TO CITECT_USER;

GRANT SELECT ON MANU_APP.INBOUND_LABL_GR_PO_OLD TO MANU_MAINT;

GRANT SELECT ON MANU_APP.INBOUND_LABL_GR_PO_OLD TO MANU_USER;

GRANT SELECT ON MANU_APP.INBOUND_LABL_GR_PO_OLD TO PUBLIC;

