DROP VIEW MANU_APP.MATERIAL_ALL_VW;

/* Formatted on 2008/11/05 13:13 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.material_all_vw (material_code,
                                                       material_type,
                                                       material_grp,
                                                       old_material_code,
                                                       uom,
                                                       order_uom,
                                                       gross_wght,
                                                       dclrd_wght,
                                                       dclrd_uom,
                                                       ean_code,
                                                       LENGTH,
                                                       width,
                                                       height,
                                                       uod,
                                                       shelf_life,
                                                       int_code,
                                                       mcu_code,
                                                       pro_code,
                                                       rsu_code,
                                                       sfp_code,
                                                       rep_code,
                                                       tdu_code,
                                                       material_desc,
                                                       plant_orntd_matl_type,
                                                       eff_start_date,
                                                       unit_cost,
                                                       batch_mngmnt_rqrmnt_indctr,
                                                       prcrmnt_type,
                                                       x_plant_matl_sts,
                                                       x_plant_matl_sts_start,
                                                       dltn_indctr,
                                                       plant_sts
                                                      )
AS
  SELECT "MATERIAL_CODE", "MATERIAL_TYPE", "MATERIAL_GRP",
         "OLD_MATERIAL_CODE", "UOM", "ORDER_UOM", "GROSS_WGHT", "DCLRD_WGHT",
         "DCLRD_UOM", "EAN_CODE", "LENGTH", "WIDTH", "HEIGHT", "UOD",
         "SHELF_LIFE", "INT_CODE", "MCU_CODE", "PRO_CODE", "RSU_CODE",
         "SFP_CODE", "REP_CODE", "TDU_CODE", "MATERIAL_DESC",
         "PLANT_ORNTD_MATL_TYPE", "EFF_START_DATE", "UNIT_COST",
         "BATCH_MNGMNT_RQRMNT_INDCTR", "PRCRMNT_TYPE", "X_PLANT_MATL_STS",
         "X_PLANT_MATL_STS_START", "DLTN_INDCTR", "PLANT_STS"
    FROM material
   WHERE x_plant_matl_sts <> '90'
     AND dltn_indctr IS NULL
     AND SYSDATE >= x_plant_matl_sts_start;


DROP PUBLIC SYNONYM MATERIAL_ALL_VW;

CREATE PUBLIC SYNONYM MATERIAL_ALL_VW FOR MANU_APP.MATERIAL_ALL_VW;


GRANT SELECT ON MANU_APP.MATERIAL_ALL_VW TO SHIFTLOG_APP;

