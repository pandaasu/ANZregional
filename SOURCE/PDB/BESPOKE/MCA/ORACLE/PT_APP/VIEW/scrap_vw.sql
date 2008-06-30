DROP VIEW PT_APP.SCRAP_VW;

/* Formatted on 2008/06/30 14:41 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW pt_app.scrap_vw (datime,
                                              plant_code,
                                              proc_order,
                                              matl_code,
                                              matl_desc,
                                              qty,
                                              uom,
                                              storage_locn,
                                              event_datime
                                             )
AS
  SELECT t01.event_datime AS datime, t01.plant_code, t01.proc_order,
         t01.matl_code, t02.bds_material_desc_en AS matl_desc, t01.qty,
         t01.uom, t01.storage_locn, t01.event_datime
    FROM scrap_rework t01, bds_material_plant_mfanz t02
   WHERE t01.matl_code = LTRIM (t02.sap_material_code, '0')
     AND t01.scrap_rework_code = 'S';


