DROP VIEW MANU_APP.AUTOMATION_KITCHEN_VW;

/* Formatted on 2008/09/05 10:49 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.automation_kitchen_vw (proc_order,
                                                             work_ctr,
                                                             material,
                                                             cycle_no,
                                                             innerag,
                                                             innerspd,
                                                             outerag,
                                                             outerspd,
                                                             bottomag,
                                                             bottomspd,
                                                             cp_water,
                                                             liquids,
                                                             brine,
                                                             dtpaste,
                                                             conctp,
                                                             sugar,
                                                             powders,
                                                             cspry_wtr1,
                                                             hspry_wtr1,
                                                             key_stn,
                                                             glucose,
                                                             oil,
                                                             oil_spd,
                                                             acid,
                                                             acid_spd,
                                                             veges,
                                                             hp_water,
                                                             csball_wtr,
                                                             hsball_wtr,
                                                             cspry_wtr2,
                                                             hspry_wtr2,
                                                             mixtime,
                                                             manadd,
                                                             steam,
                                                             ramptemp,
                                                             ramptype,
                                                             veges_wtr,
                                                             v_blo_pres,
                                                             steam_wt,
                                                             instructn,
                                                             instrvalue,
                                                             soya_oil,
                                                             soya_o_spd
                                                            )
AS
  SELECT proc_order, work_ctr, matl_code material, cycle_no, innerag,
         innerspd, outerag, outerspd, bottomag, bottomspd, cp_water, liquids,
         brine, dtpaste, conctp, sugar, powders, cspry_wtr1, hspry_wtr1,
         key_stn, glucose, oil, oil_spd, acid, acid_spd, veges, hp_water,
         csball_wtr, hsball_wtr, cspry_wtr2, hspry_wtr2, mixtime, manadd,
         steam, ramptemp, ramptype, veges_wtr, v_blo_pres, steam_wt,
         instructn, instrvalu instrvalue, soya_oil, soya_o_spd
    FROM automation_kitchen;


DROP PUBLIC SYNONYM AUTOMATION_KITCHEN_VW;

CREATE PUBLIC SYNONYM AUTOMATION_KITCHEN_VW FOR MANU_APP.AUTOMATION_KITCHEN_VW;


GRANT SELECT ON MANU_APP.AUTOMATION_KITCHEN_VW TO NEGUSIAN;

