DROP VIEW MANU_APP.MATERIAL_TARGET_WEIGHT_VW;

/* Formatted on 2008/06/30 14:33 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.material_target_weight_vw (matl_code,
                                                                 plant_code,
                                                                 matl_type,
                                                                 nake_matl_code,
                                                                 nake_target_wght,
                                                                 nake_uom,
                                                                 upd_datime,
                                                                 rsu_target_wght
                                                                )
AS
  SELECT matl_code, plant_code, matl_type, nake_matl_code, nake_target_wght,
         nake_uom, upd_datime, rsu_target_wght
    FROM material_target_weight
   WHERE plant_code = 'AU40';


