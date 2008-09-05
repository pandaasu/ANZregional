DROP VIEW MANU_APP.AUTOMATION_TOWER_VW;

/* Formatted on 2008/09/05 10:49 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.automation_tower_vw (proc_order,
                                                           batch,
                                                           material,
                                                           mixtime,
                                                           ramptype,
                                                           buf_dischs,
                                                           liquids,
                                                           sugar,
                                                           powders,
                                                           tomato,
                                                           veges,
                                                           water,
                                                           vegwater,
                                                           onion_dehy,
                                                           r_capsicum,
                                                           g_capsicum,
                                                           jalapeno,
                                                           dryherb,
                                                           temp_sp1,
                                                           temp_sp2,
                                                           whitebase,
                                                           pallecon,
                                                           acid,
                                                           whitebase2,
                                                           pallecon2,
                                                           acid2,
                                                           speed1,
                                                           speed2,
                                                           speed3,
                                                           speed4,
                                                           spd_chng1,
                                                           spd_chng2,
                                                           fill_sp,
                                                           buff_ag,
                                                           buff_agspd,
                                                           use_slry,
                                                           slry_watr,
                                                           slry_agspd,
                                                           slry_spray,
                                                           trans_watr,
                                                           user1,
                                                           user2,
                                                           user3,
                                                           user4
                                                          )
AS
  SELECT "PROC_ORDER", "BATCH", matl_code material, "MIXTIME", "RAMPTYPE",
         "BUF_DISCHS", "LIQUIDS", "SUGAR", "POWDERS", "TOMATO", "VEGES",
         "WATER", "VEGWATER", "ONION_DEHY", "R_CAPSICUM", "G_CAPSICUM",
         "JALAPENO", "DRYHERB", "TEMP_SP1", "TEMP_SP2", "WHITEBASE",
         "PALLECON", "ACID", "WHITEBASE2", "PALLECON2", "ACID2", "SPEED1",
         "SPEED2", "SPEED3", "SPEED4", "SPD_CHNG1", "SPD_CHNG2", "FILL_SP",
         "BUFF_AG", "BUFF_AGSPD", "USE_SLRY", "SLRY_WATR", "SLRY_AGSPD",
         "SLRY_SPRAY", "TRANS_WATR", "USER1", "USER2", "USER3", "USER4"
    FROM automation_tower;


DROP PUBLIC SYNONYM AUTOMATION_TOWER_VW;

CREATE PUBLIC SYNONYM AUTOMATION_TOWER_VW FOR MANU_APP.AUTOMATION_TOWER_VW;


GRANT SELECT ON MANU_APP.AUTOMATION_TOWER_VW TO NEGUSIAN;

