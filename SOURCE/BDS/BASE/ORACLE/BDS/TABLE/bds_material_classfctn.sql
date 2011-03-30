/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_CLASSFCTN
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Classification - ATLLAD06 (CLFMAS01)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/11   Linden Glen    Created
 2006/11   Linden Glen    Added Raws and Packs classification columns
 2008/01   Linden Glen    Added Z_APCHAR10 to 13
 2011/04   Ben Halicki	  Added additional columns

*******************************************************************************/



/**/
/* Table creation
/**/
create table bds_material_classfctn
   (sap_material_code                varchar2(18 char)     not null,
    bds_lads_date                    date                  null,
    bds_lads_status                  varchar2(2 char)      null,
    sap_idoc_name                    varchar2(30 char)     null,
    sap_idoc_number                  number                null,
    sap_idoc_timestamp               varchar2(14 char)     null,
    sap_bus_sgmnt_code               varchar2(30 char)     null,
    sap_mrkt_sgmnt_code              varchar2(30 char)     null,
    sap_brand_flag_code              varchar2(30 char)     null,
    sap_funcl_vrty_code              varchar2(30 char)     null,
    sap_ingrdnt_vrty_code            varchar2(30 char)     null,
    sap_brand_sub_flag_code          varchar2(30 char)     null,
    sap_supply_sgmnt_code            varchar2(30 char)     null,
    sap_trade_sector_code            varchar2(30 char)     null,
    sap_occsn_code                   varchar2(30 char)     null,
    sap_mrkting_concpt_code          varchar2(30 char)     null,
    sap_multi_pack_qty_code          varchar2(30 char)     null,
    sap_prdct_ctgry_code             varchar2(30 char)     null,
    sap_pack_type_code               varchar2(30 char)     null,
    sap_size_code                    varchar2(30 char)     null,
    sap_size_grp_code                varchar2(30 char)     null,
    sap_prdct_type_code              varchar2(30 char)     null,
    sap_trad_unit_config_code        varchar2(30 char)     null,
    sap_trad_unit_frmt_code          varchar2(30 char)     null,
    sap_dsply_storg_condtn_code      varchar2(30 char)     null,
    sap_onpack_cnsmr_value_code      varchar2(30 char)     null,
    sap_onpack_cnsmr_offer_code      varchar2(30 char)     null,
    sap_onpack_trade_offer_code      varchar2(30 char)     null,
    sap_brand_essnc_code             varchar2(30 char)     null,
    sap_cnsmr_pack_frmt_code         varchar2(30 char)     null,
    sap_cuisine_code                 varchar2(30 char)     null,
    sap_fpps_minor_pack_code         varchar2(30 char)     null,
    sap_fighting_unit_code           varchar2(30 char)     null,
    sap_china_bdt_code               varchar2(30 char)     null,
    sap_mrkt_ctgry_code              varchar2(30 char)     null,
    sap_mrkt_sub_ctgry_code          varchar2(30 char)     null,
    sap_mrkt_sub_ctgry_grp_code      varchar2(30 char)     null,
    sap_sop_bus_code                 varchar2(30 char)     null,
    sap_prodctn_line_code            varchar2(30 char)     null,
    sap_planning_src_code            varchar2(30 char)     null,
    sap_sub_fighting_unit_code       varchar2(30 char)     null,
    sap_raw_family_code              varchar2(30 char)     null,
    sap_raw_sub_family_code          varchar2(30 char)     null,
    sap_raw_group_code               varchar2(30 char)     null,
    sap_animal_parts_code            varchar2(30 char)     null,
    sap_physical_condtn_code         varchar2(30 char)     null,
    sap_pack_family_code             varchar2(30 char)     null,
    sap_pack_sub_family_code         varchar2(30 char)     null,
    sap_china_abc_indctr_code        varchar2(30 char)     null,
    sap_nz_promotional_grp_code      varchar2(30 char)     null,
    sap_nz_sop_business_code         varchar2(30 char)     null,
    sap_nz_must_win_ctgry_code       varchar2(30 char)     null,
    sap_hk_sub_ctgry_code            varchar2(30 char)     null,
    sap_hk_line_code                 varchar2(30 char)     null,
    sap_hk_product_sgmnt_code        varchar2(30 char)     null,
    sap_hk_type_code                 varchar2(30 char)     null,
    sap_strgy_grp_code               varchar2(30 char)     null,
    sap_th_boi_code                  varchar2(30 char)     null,
    sap_pack_dspsal_class            varchar2(30 char)     null,
    sap_th_boi_grp_code              varchar2(30 char)     null,
    sap_nz_launch_ranking_code       varchar2(30 char)     null,
    sap_nz_selectively_grow_code     varchar2(30 char)     nulll);

/**/
/* Primary Key Constraint
/**/
alter table bds_material_classfctn
   add constraint bds_material_classfctn_pk primary key (sap_material_code);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds.bds_material_classfctn is 'Business Data Store - Material Classification (CLFMAS01)';

comment on column bds.bds_material_classfctn.sap_hk_sub_ctgry_code is 'SAP HK Sub Category - LADS_CLA_CHR.ATWRT - Z_APCHAR16';

comment on column bds.bds_material_classfctn.sap_hk_line_code is 'SAP HK Line - LADS_CLA_CHR.ATWRT - Z_APCHAR17';

comment on column bds.bds_material_classfctn.sap_hk_product_sgmnt_code is 'SAP HK Product Segment - LADS_CLA_CHR.ATWRT - Z_APCHAR18';

comment on column bds.bds_material_classfctn.sap_hk_type_code is 'SAP HK Type - LADS_CLA_CHR.ATWRT - Z_APCHAR19';

comment on column bds.bds_material_classfctn.sap_strgy_grp_code is 'SAP AU Strategy Group - LADS_CLA_CHR.ATWRT - Z_APCHAR20';

comment on column bds.bds_material_classfctn.sap_th_boi_code is 'SAP TH BOI - LADS_CLA_CHR.ATWRT - Z_APCHAR21';

comment on column bds.bds_material_classfctn.sap_pack_dspsal_class is 'SAP Pack Disposal Class - LADS_CLA_CHR.ATWRT - Z_APVERP01';

comment on column bds.bds_material_classfctn.sap_th_boi_grp_code is 'SAP TH BOI Group - LADS_CLA_CHR.ATWRT - Z_APVERP02';

comment on column bds.bds_material_classfctn.sap_nz_launch_ranking_code is 'SAP NZ Launch Ranking Code - LADS_CLA_CHR.ATWRT - Z_APCHAR22';

comment on column bds.bds_material_classfctn.sap_nz_selectively_grow_code is 'SAP NZ Selectively Grow Code - LADS_CLA_CHR.ATWRT - Z_APCHAR23';

comment on column bds.bds_material_classfctn.sap_pack_family_code is 'SAP Pack Family - LADS_CLA_CHR.ATWRT - CLFVERP01';

comment on column bds.bds_material_classfctn.sap_pack_sub_family_code is 'SAP Packs Sub Family - LADS_CLA_CHR.ATWRT - CLFVERP02';

comment on column bds.bds_material_classfctn.sap_china_abc_indctr_code is 'SAP China ABC Indicator - LADS_CLA_CHR.ATWRT - Z_APCHAR10';

comment on column bds.bds_material_classfctn.sap_nz_promotional_grp_code is 'SAP NZ Promotional Group - LADS_CLA_CHR.ATWRT - Z_APCHAR11';

comment on column bds.bds_material_classfctn.sap_nz_sop_business_code is 'SAP NZ SandOP Business - LADS_CLA_CHR.ATWRT - Z_APCHAR12';

comment on column bds.bds_material_classfctn.sap_nz_must_win_ctgry_code is 'SAP NZ Must Win Category - LADS_CLA_CHR.ATWRT - Z_APCHAR13';

comment on column bds.bds_material_classfctn.sap_au_snk_activity_name is 'SAP AU SNK Activity Name - LADS_CLA_CHR.ATWRT - Z_APCHAR14';

comment on column bds.bds_material_classfctn.sap_china_forecast_group is 'SAP CN Forecast Group - LADS_CLA_CHR.ATWRT - Z_APCHAR15';

comment on column bds.bds_material_classfctn.sap_material_code is 'SAP Material Code - LADS_CLA_HDR.OBJEK';

comment on column bds.bds_material_classfctn.bds_lads_date is 'LADS Date - LADS_CLA_HDR.LADS_DATE';

comment on column bds.bds_material_classfctn.bds_lads_status is 'LADS Status - LADS_CLA_HDR.LADS_STATUS';

comment on column bds.bds_material_classfctn.sap_idoc_name is 'IDOC Name - LADS_CLA_HDR.IDOC_NAME';

comment on column bds.bds_material_classfctn.sap_idoc_number is 'IDOC Number - LADS_CLA_HDR.IDOC_NUMBER';

comment on column bds.bds_material_classfctn.sap_idoc_timestamp is 'IDOC Timestamp - LADS_CLA_HDR.IDOC_TIMESTAMP';

comment on column bds.bds_material_classfctn.sap_bus_sgmnt_code is 'SAP Business Segment - LADS_CLA_CHR.ATWRT - CLFFERT01';

comment on column bds.bds_material_classfctn.sap_mrkt_sgmnt_code is 'SAP Market Segment - LADS_CLA_CHR.ATWRT - CLFFERT02';

comment on column bds.bds_material_classfctn.sap_brand_flag_code is 'SAP Brand Flag - LADS_CLA_CHR.ATWRT - CLFFERT03';

comment on column bds.bds_material_classfctn.sap_funcl_vrty_code is 'SAP Functional variety - LADS_CLA_CHR.ATWRT - CLFFERT07';

comment on column bds.bds_material_classfctn.sap_ingrdnt_vrty_code is 'SAP Ingredient Variety - LADS_CLA_CHR.ATWRT - CLFFERT06';

comment on column bds.bds_material_classfctn.sap_brand_sub_flag_code is 'SAP Brand Sub Flag - LADS_CLA_CHR.ATWRT - CLFFERT04';

comment on column bds.bds_material_classfctn.sap_supply_sgmnt_code is 'SAP Supply Segment - LADS_CLA_CHR.ATWRT - CLFFERT05';

comment on column bds.bds_material_classfctn.sap_trade_sector_code is 'SAP Trade Sector - LADS_CLA_CHR.ATWRT - CLFFERT08';

comment on column bds.bds_material_classfctn.sap_occsn_code is 'SAP Occasion - LADS_CLA_CHR.ATWRT - CLFFERT11';

comment on column bds.bds_material_classfctn.sap_mrkting_concpt_code is 'SAP Marketing Concept - LADS_CLA_CHR.ATWRT - CLFFERT09';

comment on column bds.bds_material_classfctn.sap_multi_pack_qty_code is 'SAP Multipack Quantity - LADS_CLA_CHR.ATWRT - CLFFERT10';

comment on column bds.bds_material_classfctn.sap_prdct_ctgry_code is 'SAP Product Category - LADS_CLA_CHR.ATWRT - CLFFERT12';

comment on column bds.bds_material_classfctn.sap_pack_type_code is 'SAP Pack Type - LADS_CLA_CHR.ATWRT - CLFFERT17';

comment on column bds.bds_material_classfctn.sap_size_code is 'SAP Size - LADS_CLA_CHR.ATWRT - CLFFERT14';

comment on column bds.bds_material_classfctn.sap_size_grp_code is 'SAP Size Group - LADS_CLA_CHR.ATWRT - CLFFERT18';

comment on column bds.bds_material_classfctn.sap_prdct_type_code is 'SAP Product Type - LADS_CLA_CHR.ATWRT - CLFFERT13';

comment on column bds.bds_material_classfctn.sap_trad_unit_config_code is 'SAP Traded Unit Configuration - LADS_CLA_CHR.ATWRT - CLFFERT21';

comment on column bds.bds_material_classfctn.sap_trad_unit_frmt_code is 'SAP Traded Unit Format - LADS_CLA_CHR.ATWRT - CLFFERT20';

comment on column bds.bds_material_classfctn.sap_dsply_storg_condtn_code is 'SAP Display Storage Condition - LADS_CLA_CHR.ATWRT - CLFFERT19';

comment on column bds.bds_material_classfctn.sap_onpack_cnsmr_value_code is 'SAP On-pack Consumer Value - LADS_CLA_CHR.ATWRT - CLFFERT22';

comment on column bds.bds_material_classfctn.sap_onpack_cnsmr_offer_code is 'SAP On-pack Consumer Offer - LADS_CLA_CHR.ATWRT - CLFFERT23';

comment on column bds.bds_material_classfctn.sap_onpack_trade_offer_code is 'SAP On-pack Trade Offer - LADS_CLA_CHR.ATWRT - CLFFERT24';

comment on column bds.bds_material_classfctn.sap_brand_essnc_code is 'SAP Brand Essence - LADS_CLA_CHR.ATWRT - CLFFERT16';

comment on column bds.bds_material_classfctn.sap_cnsmr_pack_frmt_code is 'SAP Consumer Pack Format - LADS_CLA_CHR.ATWRT - CLFFERT25';

comment on column bds.bds_material_classfctn.sap_cuisine_code is 'SAP Cuisine - LADS_CLA_CHR.ATWRT - CLFFERT40';

comment on column bds.bds_material_classfctn.sap_fpps_minor_pack_code is 'SAP FPPS Minor Pack - LADS_CLA_CHR.ATWRT - CLFFERT38';

comment on column bds.bds_material_classfctn.sap_fighting_unit_code is 'SAP Fighting Unit - LADS_CLA_CHR.ATWRT - Z_APCHAR6';

comment on column bds.bds_material_classfctn.sap_china_bdt_code is 'SAP China BDT - LADS_CLA_CHR.ATWRT - Z_APCHAR7';

comment on column bds.bds_material_classfctn.sap_mrkt_ctgry_code is 'SAP Market Category - LADS_CLA_CHR.ATWRT - Z_APCHAR1';

comment on column bds.bds_material_classfctn.sap_mrkt_sub_ctgry_code is 'SAP Market Sub Category - LADS_CLA_CHR.ATWRT - Z_APCHAR2';

comment on column bds.bds_material_classfctn.sap_mrkt_sub_ctgry_grp_code is 'SAP Market Sub Category Group - LADS_CLA_CHR.ATWRT - Z_APCHAR3';

comment on column bds.bds_material_classfctn.sap_sop_bus_code is 'SAP S and OP Business Code - LADS_CLA_CHR.ATWRT - Z_APCHAR4';

comment on column bds.bds_material_classfctn.sap_prodctn_line_code is 'SAP Production Line - LADS_CLA_CHR.ATWRT - Z_APCHAR5';

comment on column bds.bds_material_classfctn.sap_planning_src_code is 'SAP Planning Source - LADS_CLA_CHR.ATWRT - Z_APCHAR8';

comment on column bds.bds_material_classfctn.sap_sub_fighting_unit_code is 'SAP Sub Fighting Unit - LADS_CLA_CHR.ATWRT - Z_APCHAR9';

comment on column bds.bds_material_classfctn.sap_raw_family_code is 'SAP Raws Family  - LADS_CLA_CHR.ATWRT - CLFROH01';

comment on column bds.bds_material_classfctn.sap_raw_sub_family_code is 'SAP Raws Sub Family - LADS_CLA_CHR.ATWRT - CLFROH02';

comment on column bds.bds_material_classfctn.sap_raw_group_code is 'SAP Raws Group - LADS_CLA_CHR.ATWRT - CLFROH03';

comment on column bds.bds_material_classfctn.sap_animal_parts_code is 'SAP Animal Parts - LADS_CLA_CHR.ATWRT - CLFROH04';

comment on column bds.bds_material_classfctn.sap_physical_condtn_code is 'SAP Physical Condition - LADS_CLA_CHR.ATWRT - CLFROH05';


/**/
/* Synonym
/**/
create or replace public synonym bds_material_classfctn for bds.bds_material_classfctn;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_classfctn to lics_app;
grant select,update,delete,insert on bds_material_classfctn to bds_app;
grant select,update,delete,insert on bds_material_classfctn to lads_app;
