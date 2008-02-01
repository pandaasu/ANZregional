/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 System  : lads
 Package : ods_material
 Owner   : lads
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - ODS Material View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created
 2006/05   Steve Gregan   Added BDT code

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view lads.ods_material
   (sap_material_code,
    material_sts_type_code,
    material_sts_code,
    sap_indust_sector_code,
    sap_material_type_code,
    sap_base_uom_code,
    old_material_code,
    sap_material_grp_code,
    sap_material_division_code,
    sap_cross_plant_matl_sts_code,
    cross_plant_matl_sts_from_date,
    gross_wgt,
    sap_wgt_unit_code,
    net_wgt,
    vol,
    sap_vol_unit_code,
    ean_upc,
    sap_ean_upc_ctgry_code,
    sap_material_grp_packs_code,
    material_owner,
    sap_rep_item_code,
    mat_lead_time_days,
    material_type_flag_int,
    material_type_flag_rsu,
    material_type_flag_tdu,
    material_type_flag_mcu,
    material_type_flag_pro,
    material_type_flag_sfp,
    material_type_flag_sc,
    material_type_flag_rep,
    material_lupdt,
    sap_bus_sgmnt_code,
    sap_mkt_sgmnt_code,
    sap_brand_flag_code,
    sap_brand_sub_flag_code, 
    sap_supply_sgmnt_code,
    sap_ingred_vrty_code,
    sap_funcl_vrty_code,
    sap_major_pack_code,
    sap_minor_pack_code,
    sap_multi_pack_qty,
    sap_occsn_code,
    sap_prdct_ctgry_code,
    sap_prdct_type_code,
    sap_prdct_pack_size_code,
    sap_brand_essnc_code,
    sap_pack_type_code,
    sap_prdct_size_grp_code,
    sap_prim_cnsmptn_grp_code,
    sap_trad_unit_frmt_code,
    sap_trad_unit_config_code,
    sap_onpack_cnsmr_value_code,
    sap_onpack_cnsmr_offer_code,
    sap_onpack_trade_offer_code,
    sap_cnsmr_pack_frmt_code,
    sap_bdt_code) as 
   select lads_trim_code(t01.matnr),
          1,
          case when t01.lvorm = 'X' then 'INACTIVE' else 'ACTIVE' end,
          t01.mbrsh,
          t01.mtart,
          t01.meins,
          t01.bismt,
          t01.matkl,
          t01.spart,
          t01.mstae,
          t01.mstde,
          t01.brgew,
          t01.gewei,
          t01.ntgew,
          t01.volum,
          t01.voleh,
          t01.ean11,
          t01.numtp,
          t01.magrv,
          t01.zzitemowner,
          lads_trim_code(t01.zzrepmatnr),
          t01.zzmattim,
          case when t01.zzisint = 'X' then 'Y' else 'N' end,
          case when t01.zzisrsu = 'X' then 'Y' else 'N' end,
          case when t01.zzistdu = 'X' then 'Y' else 'N' end,
          case when t01.zzismcu = 'X' then 'Y' else 'N' end,
          case when t01.zzispro = 'X' then 'Y' else 'N' end,
          case when t01.zzissfp = 'X' then 'Y' else 'N' end,
          case when t01.zzissc = 'X' then 'Y' else 'N' end,
          case when t01.zzistra = 'X' then 'Y' else 'N' end,
          t01.lads_date,
          nvl(t02.sap_bus_sgmnt_code,'00'),
          nvl(t02.sap_mkt_sgmnt_code,'00'),
          nvl(t02.sap_brand_flag_code,'000'),
          nvl(t02.sap_brand_sub_flag_code,'000'),
          nvl(t02.sap_supply_sgmnt_code,'000'),
          nvl(t02.sap_ingred_vrty_code,'0000'),
          nvl(t02.sap_funcl_vrty_code,'000'),
          nvl(t02.sap_major_pack_code,'00'),
          nvl(t02.sap_minor_pack_code,'000'),
          nvl(t02.sap_multi_pack_qty,'00'),
          nvl(t02.sap_occsn_code,'00'),
          nvl(t02.sap_prdct_ctgry_code,'00'),
          nvl(t02.sap_prdct_type_code,'000'),
          nvl(t02.sap_prdct_pack_size_code,'000'),
          nvl(t02.sap_brand_essnc_code,'000'),
          nvl(t02.sap_pack_type_code,'00'),
          nvl(t02.sap_prdct_size_grp_code,'00'),
          nvl(t02.sap_prim_cnsmptn_grp_code,'00'),
          nvl(t02.sap_trad_unit_frmt_code,'00'),
          nvl(t02.sap_trad_unit_config_code,'000'),
          nvl(t02.sap_onpack_cnsmr_value_code,'00'),
          nvl(t02.sap_onpack_cnsmr_offer_code,'00'),
          nvl(t02.sap_onpack_trade_offer_code,'00'),
          nvl(t02.sap_cnsmr_pack_frmt_code,'00'),
          nvl(t02.sap_bdt_code,'00')
     from lads_mat_hdr t01,
          (select t21.objek as matnr,
                  max(case when t22.atnam = 'CLFFERT01' then t22.atwrt end) as sap_bus_sgmnt_code,
                  max(case when t22.atnam = 'CLFFERT02' then t22.atwrt end) as sap_mkt_sgmnt_code,
                  max(case when t22.atnam = 'CLFFERT03' then t22.atwrt end) as sap_brand_flag_code,
                  max(case when t22.atnam = 'CLFFERT04' then t22.atwrt end) as sap_brand_sub_flag_code,
                  max(case when t22.atnam = 'CLFFERT05' then t22.atwrt end) as sap_supply_sgmnt_code,
                  max(case when t22.atnam = 'CLFFERT06' then t22.atwrt end) as sap_ingred_vrty_code,
                  max(case when t22.atnam = 'CLFFERT07' then t22.atwrt end) as sap_funcl_vrty_code,
                  max(case when t22.atnam = 'CLFFERT08' then t22.atwrt end) as sap_major_pack_code,
                  max(case when t22.atnam = 'CLFFERT09' then t22.atwrt end) as sap_minor_pack_code,
                  max(case when t22.atnam = 'CLFFERT10' then t22.atwrt end) as sap_multi_pack_qty,
                  max(case when t22.atnam = 'CLFFERT11' then t22.atwrt end) as sap_occsn_code,
                  max(case when t22.atnam = 'CLFFERT12' then t22.atwrt end) as sap_prdct_ctgry_code,
                  max(case when t22.atnam = 'CLFFERT13' then t22.atwrt end) as sap_prdct_type_code,
                  max(case when t22.atnam = 'CLFFERT14' then t22.atwrt end) as sap_prdct_pack_size_code,
                  max(case when t22.atnam = 'CLFFERT16' then t22.atwrt end) as sap_brand_essnc_code,
                  max(case when t22.atnam = 'CLFFERT17' then t22.atwrt end) as sap_pack_type_code,
                  max(case when t22.atnam = 'CLFFERT18' then t22.atwrt end) as sap_prdct_size_grp_code,
                  max(case when t22.atnam = 'CLFFERT19' then t22.atwrt end) as sap_prim_cnsmptn_grp_code,
                  max(case when t22.atnam = 'CLFFERT20' then t22.atwrt end) as sap_trad_unit_frmt_code,
                  max(case when t22.atnam = 'CLFFERT21' then t22.atwrt end) as sap_trad_unit_config_code,
                  max(case when t22.atnam = 'CLFFERT22' then t22.atwrt end) as sap_onpack_cnsmr_value_code,
                  max(case when t22.atnam = 'CLFFERT23' then t22.atwrt end) as sap_onpack_cnsmr_offer_code,
                  max(case when t22.atnam = 'CLFFERT24' then t22.atwrt end) as sap_onpack_trade_offer_code,
                  max(case when t22.atnam = 'CLFFERT25' then t22.atwrt end) as sap_cnsmr_pack_frmt_code,
                  max(case when t22.atnam = 'Z_APCHAR7' then t22.atwrt end) as sap_bdt_code
             from lads_cla_hdr t21,
                  lads_cla_chr t22
            where t21.obtab = 'MARA'
              and t21.klart = '001'
              and t21.obtab = t22.obtab(+)
              and t21.klart = t22.klart(+)
              and t21.objek = t22.objek(+)
            group by t21.objek) t02
    where t01.matnr = t02.matnr(+)
      and t01.lads_status = '1';

/*-*/
/* Authority
/*-*/
grant select on lads.ods_material to od with grant option;
grant select on lads.ods_material to dw_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym ods_material for lads.ods_material;

