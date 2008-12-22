DROP VIEW MANU.MATL_CLSSFCTN_FG;

/* Formatted on 2008/12/22 11:00 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.matl_clssfctn_fg (matl_code,
                                                    bus_sgmnt_code,
                                                    mkt_sgmnt_code,
                                                    brand_flag_code,
                                                    brand_sub_flag_code,
                                                    spply_sgmnt_code,
                                                    ingrdnt_vrty_code,
                                                    fnctnl_vrty_code,
                                                    trade_sctr_code,
                                                    mrktng_cncpt_code,
                                                    mltpck_qty_code,
                                                    occsn_code,
                                                    prdct_ctgry_code,
                                                    prdct_type_code,
                                                    size_code,
                                                    brand_essnc_code,
                                                    pack_type_code,
                                                    size_group_code,
                                                    dsply_strg_cndtn_code,
                                                    tdu_frmt_code,
                                                    tdu_cnfgrtn_code,
                                                    on_pack_cnsmr_value_code,
                                                    on_pack_cnsmr_offer_code,
                                                    on_pack_trade_offer_code,
                                                    cnsmr_pack_frmt_code
                                                   )
AS
  SELECT       /*************************************************************/
              /*  Created:  09 Feb 2007                                     */
              /*    By:   Jeff Phillipson                                   */
              /*                                                            */
              /*    Ver   Date       Author       Description               */
              /*  ----- ---------- ------------------------------------     */
              /*   1.0  09/02/2007 J Phillipson Converted for snack food    */
              /*  PURPOSE                                                   */
              /* Provide a generic view of Material Classification for      */
              /*  FG materials                                              */
              /*  Note:                                                     */
              /*   This contains all requirements for all plants to date    */
              /**************************************************************/
         LTRIM (sap_material_code, '0') matl_code,
         sap_bus_sgmnt_code bus_sgmnt_code,
         sap_mrkt_sgmnt_code mkt_sgmnt_code,
         sap_brand_flag_code brand_flag_code,
         sap_brand_sub_flag_code brand_sub_flag_code,
         sap_supply_sgmnt_code spply_sgmnt_code,
         sap_ingrdnt_vrty_code ingrdnt_vrty_code,
         sap_funcl_vrty_code fnctnl_vrty_code,
         sap_trade_sector_code trade_sctr_code,
         sap_mrkting_concpt_code mrktng_cncpt_code,
         sap_multi_pack_qty_code mltpck_qty_code, sap_occsn_code occsn_code,
         sap_prdct_ctgry_code prdct_ctgry_code,
         sap_prdct_type_code prdct_type_code, sap_size_code size_code,
         sap_brand_essnc_code brand_essnc_code,
         sap_pack_type_code pack_type_code, sap_size_grp_code size_group_code,
         sap_dsply_storg_condtn_code dsply_strg_cndtn_code,
         sap_trad_unit_frmt_code tdu_frmt_code,
         sap_trad_unit_config_code tdu_cnfgrtn_code,
         sap_onpack_cnsmr_value_code on_pack_cnsmr_value_code,
         sap_onpack_cnsmr_offer_code on_pack_cnsmr_offer_code,
         sap_onpack_trade_offer_code on_pack_trade_offer_code,
         sap_cnsmr_pack_frmt_code cnsmr_pack_frmt_code
    FROM bds_material_classfctn t01
   WHERE EXISTS (
           SELECT 'x'
             FROM bds_material_plant_mfanz t02
            WHERE t02.sap_material_code = LTRIM (t01.sap_material_code, '0')
              AND t02.material_type = 'FERT');


DROP PUBLIC SYNONYM MATL_CLSSFCTN_FG;

CREATE PUBLIC SYNONYM MATL_CLSSFCTN_FG FOR MANU.MATL_CLSSFCTN_FG;


GRANT SELECT ON MANU.MATL_CLSSFCTN_FG TO MANU_APP WITH GRANT OPTION;

