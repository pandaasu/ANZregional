 /******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_CLASSFCTN_EN
 Owner   : BDS
 Author  : Linden Glen

 dscription
 -----------
 Business Data Store - Material Characteristic/Classification View

 YYYY/MM   Author         dscription
 -------   ------         -----------
 2006/11   Linden Glen    Created
 2006/12   Linden Glen    Included bds_material_hdr join for material_type
 2007/01   Linden Glen    Included ROH01, 02, 03, 04, 05 and VERP01, 02 classifications

*******************************************************************************/


/**/
/* Table creation
/**/

create or replace view bds_material_classfctn_en as  
   select t01.sap_material_code as sap_material_code,
          nvl(t37.material_type,'*NONE') as material_type,
          t01.sap_bus_sgmnt_code as sap_bus_sgmnt_code,
          t02.sap_charistic_value_shrt_desc as sap_bus_sgmnt_sht_dsc,
          t02.sap_charistic_value_long_desc as sap_bus_sgmnt_lng_dsc,
          t01.sap_mrkt_sgmnt_code as sap_mrkt_sgmnt_code,
          t03.sap_charistic_value_shrt_desc as sap_mrkt_sgmnt_sht_dsc,
          t03.sap_charistic_value_long_desc as sap_mrkt_sgmnt_lng_dsc,
          t01.sap_brand_flag_code as sap_brand_flag_code,
          t04.sap_charistic_value_shrt_desc as sap_brand_flag_sht_dsc,
          t04.sap_charistic_value_long_desc as sap_brand_flag_lng_dsc,
          t01.sap_funcl_vrty_code as sap_funcl_vrty_code,
          t05.sap_charistic_value_shrt_desc as sap_funcl_vrty_sht_dsc,
          t05.sap_charistic_value_long_desc as sap_funcl_vrty_lng_dsc,
          t01.sap_ingrdnt_vrty_code as sap_ingrdnt_vrty_code,
          t06.sap_charistic_value_shrt_desc as sap_ingrdnt_vrty_sht_dsc,
          t06.sap_charistic_value_long_desc as sap_ingrdnt_vrty_lng_dsc,
          t01.sap_brand_sub_flag_code as sap_brand_sub_flag_code,
          t07.sap_charistic_value_shrt_desc as sap_brand_sub_flag_sht_dsc,
          t07.sap_charistic_value_long_desc as sap_brand_sub_flag_lng_dsc,
          t01.sap_supply_sgmnt_code as sap_supply_sgmnt_code,
          t08.sap_charistic_value_shrt_desc as sap_supply_sgmnt_sht_dsc,
          t08.sap_charistic_value_long_desc as sap_supply_sgmnt_lng_dsc,
          t01.sap_trade_sector_code as sap_trade_sector_code,
          t09.sap_charistic_value_shrt_desc as sap_trade_sector_sht_dsc,
          t09.sap_charistic_value_long_desc as sap_trade_sector_lng_dsc,
          t01.sap_occsn_code as sap_occsn_code,
          t10.sap_charistic_value_shrt_desc as sap_occsn_sht_dsc,
          t10.sap_charistic_value_long_desc as sap_occsn_lng_dsc,
          t01.sap_mrkting_concpt_code as sap_mrkting_concpt_code,
          t11.sap_charistic_value_shrt_desc as sap_mrkting_concpt_sht_dsc,
          t11.sap_charistic_value_long_desc as sap_mrkting_concpt_lng_dsc,
          t01.sap_multi_pack_qty_code as sap_multi_pack_qty_code,
          t12.sap_charistic_value_shrt_desc as sap_multi_pack_qty_sht_dsc,
          t12.sap_charistic_value_long_desc as sap_multi_pack_qty_lng_dsc,
          t01.sap_prdct_ctgry_code as sap_prdct_ctgry_code,
          t13.sap_charistic_value_shrt_desc as sap_prdct_ctgry_sht_dsc,
          t13.sap_charistic_value_long_desc as sap_prdct_ctgry_lng_dsc,
          t01.sap_pack_type_code as sap_pack_type_code,
          t14.sap_charistic_value_shrt_desc as sap_pack_type_sht_dsc,
          t14.sap_charistic_value_long_desc as sap_pack_type_lng_dsc,
          t01.sap_size_code as sap_size_code,
          t15.sap_charistic_value_shrt_desc as sap_size_sht_dsc,
          t15.sap_charistic_value_long_desc as sap_size_lng_dsc,
          t01.sap_size_grp_code as sap_size_grp_code,
          t16.sap_charistic_value_shrt_desc as sap_size_grp_sht_dsc,
          t16.sap_charistic_value_long_desc as sap_size_grp_lng_dsc,
          t01.sap_prdct_type_code as sap_prdct_type_code,
          t17.sap_charistic_value_shrt_desc as sap_prdct_type_sht_dsc,
          t17.sap_charistic_value_long_desc as sap_prdct_type_lng_dsc,
          t01.sap_trad_unit_config_code as sap_trad_unit_config_code,
          t18.sap_charistic_value_shrt_desc as sap_trad_unit_config_sht_dsc,
          t18.sap_charistic_value_long_desc as sap_trad_unit_config_lng_dsc,
          t01.sap_trad_unit_frmt_code as sap_trad_unit_frmt_code,
          t19.sap_charistic_value_shrt_desc as sap_trad_unit_frmt_sht_dsc,
          t19.sap_charistic_value_long_desc as sap_trad_unit_frmt_lng_dsc,
          t01.sap_dsply_storg_condtn_code as sap_dsply_storg_condtn_code,
          t20.sap_charistic_value_shrt_desc as sap_dsply_storg_condtn_sht_dsc,
          t20.sap_charistic_value_long_desc as sap_dsply_storg_condtn_lng_dsc,
          t01.sap_onpack_cnsmr_value_code as sap_onpack_cnsmr_value_code,
          t21.sap_charistic_value_shrt_desc as sap_onpack_cnsmr_value_sht_dsc,
          t21.sap_charistic_value_long_desc as sap_onpack_cnsmr_value_lng_dsc,
          t01.sap_onpack_cnsmr_offer_code as sap_onpack_cnsmr_offer_code,
          t22.sap_charistic_value_shrt_desc as sap_onpack_cnsmr_offer_sht_dsc,
          t22.sap_charistic_value_long_desc as sap_onpack_cnsmr_offer_lng_dsc,
          t01.sap_onpack_trade_offer_code as sap_onpack_trade_offer_code,
          t23.sap_charistic_value_shrt_desc as sap_onpack_trade_offer_sht_dsc,
          t23.sap_charistic_value_long_desc as sap_onpack_trade_offer_lng_dsc,
          t01.sap_brand_essnc_code as sap_brand_essnc_code,
          t24.sap_charistic_value_shrt_desc as sap_brand_essnc_sht_dsc,
          t24.sap_charistic_value_long_desc as sap_brand_essnc_lng_dsc,
          t01.sap_cnsmr_pack_frmt_code as sap_cnsmr_pack_frmt_code,
          t25.sap_charistic_value_shrt_desc as sap_cnsmr_pack_frmt_sht_dsc,
          t25.sap_charistic_value_long_desc as sap_cnsmr_pack_frmt_lng_dsc,
          t01.sap_cuisine_code as sap_cuisine_code,
          t26.sap_charistic_value_shrt_desc as sap_cuisine_sht_dsc,
          t26.sap_charistic_value_long_desc as sap_cuisine_lng_dsc,
          t01.sap_fpps_minor_pack_code as sap_fpps_minor_pack_code,
          t27.sap_charistic_value_shrt_desc as sap_fpps_minor_pack_sht_dsc,
          t27.sap_charistic_value_long_desc as sap_fpps_minor_pack_lng_dsc,
          t01.sap_fighting_unit_code as sap_fighting_unit_code,
          t28.sap_charistic_value_desc as sap_fighting_unit_desc,
          t01.sap_china_bdt_code as sap_china_bdt_code,
          t29.sap_charistic_value_desc as sap_china_bdt_desc,
          t01.sap_mrkt_ctgry_code as sap_mrkt_ctgry_code,
          t30.sap_charistic_value_desc as sap_mrkt_ctgry_desc,
          t01.sap_mrkt_sub_ctgry_code as sap_mrkt_sub_ctgry_code,
          t31.sap_charistic_value_desc as sap_mrkt_sub_ctgry_desc,
          t01.sap_mrkt_sub_ctgry_grp_code as sap_mrkt_sub_ctgry_grp_code,
          t32.sap_charistic_value_desc as sap_mrkt_sub_ctgry_grp_desc,
          t01.sap_sop_bus_code as sap_sop_bus_code,
          t33.sap_charistic_value_desc as sap_sop_bus_desc,
          t01.sap_prodctn_line_code as sap_prodctn_line_code,
          t34.sap_charistic_value_desc as sap_prodctn_line_desc,
          t01.sap_planning_src_code as sap_planning_src_code,
          t35.sap_charistic_value_desc as sap_planning_src_desc,
          t01.sap_sub_fighting_unit_code as sap_sub_fighting_unit_code,
          t36.sap_charistic_value_desc as sap_sub_fighting_unit_desc,
          t01.sap_pack_family_code as sap_pack_family_code,
          t38.sap_charistic_value_long_desc as sap_pack_family_lng_dsc,
          t01.sap_pack_sub_family_code as sap_pack_sub_family_code,
          t39.sap_charistic_value_long_desc as sap_pack_sub_family_lng_dsc,
          t01.sap_raw_family_code as sap_raw_family_code,
          t40.sap_charistic_value_long_desc as sap_raw_family_lng_dsc,
          t01.sap_raw_sub_family_code as sap_raw_sub_family_code,
          t41.sap_charistic_value_long_desc as sap_raw_sub_family_lng_dsc,
          t01.sap_raw_group_code as sap_raw_group_code,
          t42.sap_charistic_value_long_desc as sap_raw_group_lng_dsc,
          t01.sap_animal_parts_code as sap_animal_parts_code,
          t43.sap_charistic_value_long_desc as sap_animal_parts_lng_dsc,
          t01.sap_physical_condtn_code as sap_physical_condtn_code,
          t44.sap_charistic_value_long_desc as sap_physical_condtn_lng_dsc
   from bds_material_classfctn t01,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC001') t02,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC002') t03,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC003') t04,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC007') t05,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC006') t06,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC004') t07,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC005') t08,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC008') t09,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC011') t10,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC009') t11,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC010') t12,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC012') t13,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC017') t14,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC014') t15,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC018') t16,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC013') t17,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC021') t18,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC020') t19,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC019') t20,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC022') t21,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC023') t22,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC024') t23,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC016') t24,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC025') t25,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC040') t26,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_shrt_desc,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_CHC038') t27,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_desc
         from bds_charistic_value_en a
         where sap_charistic_code = 'Z_APCHAR6') t28,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_desc
         from bds_charistic_value_en a
         where sap_charistic_code = 'Z_APCHAR7') t29,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_desc
         from bds_charistic_value_en a
         where sap_charistic_code = 'Z_APCHAR1') t30,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_desc
         from bds_charistic_value_en a
         where sap_charistic_code = 'Z_APCHAR2') t31,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_desc
         from bds_charistic_value_en a
         where sap_charistic_code = 'Z_APCHAR3') t32,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_desc
         from bds_charistic_value_en a
         where sap_charistic_code = 'Z_APCHAR4') t33,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_desc
         from bds_charistic_value_en a
         where sap_charistic_code = 'Z_APCHAR5') t34,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_desc
         from bds_charistic_value_en a
         where sap_charistic_code = 'Z_APCHAR8') t35,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_desc
         from bds_charistic_value_en a
         where sap_charistic_code = 'Z_APCHAR9') t36,
        bds_material_hdr t37,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_VERP01') t38,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_VERP02') t39,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_ROH01') t40,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_ROH02') t41,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_ROH03') t42,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_ROH04') t43,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_long_desc
         from bds_refrnc_charistic a
         where sap_charistic_code = '/MARS/MD_ROH05') t44
   where t01.sap_bus_sgmnt_code = t02.sap_charistic_value_code(+)
     and t01.sap_mrkt_sgmnt_code = t03.sap_charistic_value_code(+)
     and t01.sap_brand_flag_code = t04.sap_charistic_value_code(+)
     and t01.sap_funcl_vrty_code = t05.sap_charistic_value_code(+)
     and t01.sap_ingrdnt_vrty_code = t06.sap_charistic_value_code(+)
     and t01.sap_brand_sub_flag_code = t07.sap_charistic_value_code(+)
     and t01.sap_supply_sgmnt_code = t08.sap_charistic_value_code(+)
     and t01.sap_trade_sector_code = t09.sap_charistic_value_code(+)
     and t01.sap_occsn_code = t10.sap_charistic_value_code(+)
     and t01.sap_mrkting_concpt_code = t11.sap_charistic_value_code(+)
     and t01.sap_multi_pack_qty_code = t12.sap_charistic_value_code(+)
     and t01.sap_prdct_ctgry_code = t13.sap_charistic_value_code(+)
     and t01.sap_pack_type_code = t14.sap_charistic_value_code(+)
     and t01.sap_size_code = t15.sap_charistic_value_code(+)
     and t01.sap_size_grp_code = t16.sap_charistic_value_code(+)
     and t01.sap_prdct_type_code = t17.sap_charistic_value_code(+)
     and t01.sap_trad_unit_config_code = t18.sap_charistic_value_code(+)
     and t01.sap_trad_unit_frmt_code = t19.sap_charistic_value_code(+)
     and t01.sap_dsply_storg_condtn_code = t20.sap_charistic_value_code(+)
     and t01.sap_onpack_cnsmr_value_code = t21.sap_charistic_value_code(+)
     and t01.sap_onpack_cnsmr_offer_code = t22.sap_charistic_value_code(+)
     and t01.sap_onpack_trade_offer_code = t23.sap_charistic_value_code(+)
     and t01.sap_brand_essnc_code = t24.sap_charistic_value_code(+)
     and t01.sap_cnsmr_pack_frmt_code = t25.sap_charistic_value_code(+)
     and t01.sap_cuisine_code = t26.sap_charistic_value_code(+)
     and t01.sap_fpps_minor_pack_code = t27.sap_charistic_value_code(+)
     and t01.sap_fighting_unit_code = t28.sap_charistic_value_code(+)
     and t01.sap_china_bdt_code = t29.sap_charistic_value_code(+)
     and t01.sap_mrkt_ctgry_code = t30.sap_charistic_value_code(+)
     and t01.sap_mrkt_sub_ctgry_code = t31.sap_charistic_value_code(+)
     and t01.sap_mrkt_sub_ctgry_grp_code = t32.sap_charistic_value_code(+)
     and t01.sap_sop_bus_code = t33.sap_charistic_value_code(+)
     and t01.sap_prodctn_line_code = t34.sap_charistic_value_code(+)
     and t01.sap_planning_src_code = t35.sap_charistic_value_code(+)
     and t01.sap_sub_fighting_unit_code = t36.sap_charistic_value_code(+)
     and t01.sap_material_code = t37.sap_material_code(+)
     and t01.sap_pack_family_code = t38.sap_charistic_value_code(+)
     and t01.sap_pack_sub_family_code = t39.sap_charistic_value_code(+)
     and t01.sap_raw_family_code = t40.sap_charistic_value_code(+)
     and t01.sap_raw_sub_family_code = t41.sap_charistic_value_code(+)
     and t01.sap_raw_group_code = t42.sap_charistic_value_code(+)
     and t01.sap_animal_parts_code = t43.sap_charistic_value_code(+)
     and t01.sap_physical_condtn_code = t44.sap_charistic_value_code(+);
/

/**/
/* Synonym
/**/
create or replace public synonym bds_material_classfctn_en for bds.bds_material_classfctn_en;


/**/
/* Authority
/**/