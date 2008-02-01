/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : material_dim
 Owner  : dd

 Description
 -----------
 Data Warehouse - Material Dimension Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created
 2006/04   Steve Gregan   Removed Japanese descriptions
                          Added report representative item and desc
 2006/05   Steve Gregan   Add BDT code and description

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.material_dim
   (sap_material_code              varchar2(18 char)   not null,
    material_desc_en               varchar2(40 char)   null,
    material_sts_code              varchar2(8 char)    not null,
    material_sts_abbrd_desc        varchar2(20 char)   not null,
    material_sts_desc              varchar2(60 char)   not null,
    gross_wgt                      number(12,4)        null,
    net_wgt                        number(12,4)        null,
    sap_wgt_unit_code              varchar2(3 char)    null,
    wgt_unit_abbrd_desc            varchar2(15 char)   null,
    wgt_unit_desc                  varchar2(40 char)   null,
    vol                            number(12,4)        null,
    sap_vol_unit_code              varchar2(3 char)    null,
    vol_unit_abbrd_desc            varchar2(15 char)   null,
    vol_unit_desc                  varchar2(40 char)   null,
    sap_base_uom_code              varchar2(3 char)    not null,
    base_uom_abbrd_desc            varchar2(15 char)   not null,
    base_uom_desc                  varchar2(40 char)   not null,
    material_owner                 varchar2(12 char)   null,
    sap_rep_item_code              varchar2(18 char)   null,
    rep_item_desc_en               varchar2(40 char)   null,
    sap_rpt_item_code              varchar2(18 char)   null,
    rpt_item_desc_en               varchar2(40 char)   null,
    mat_lead_time_days             number(3)           null,
    old_material_code              varchar2(18 char)   null,
    material_type_flag_int         varchar2(1 char)    null,
    material_type_flag_rsu         varchar2(1 char)    null,
    material_type_flag_tdu         varchar2(1 char)    null,
    material_type_flag_mcu         varchar2(1 char)    null,
    material_type_flag_pro         varchar2(1 char)    null,
    material_type_flag_sfp         varchar2(1 char)    null,
    material_type_flag_sc          varchar2(1 char)    null,
    material_type_flag_rep         varchar2(1 char)    null,
    ean_upc                        varchar2(18 char)   null,
    sap_ean_upc_ctgry_code         varchar2(2 char)    null,
    ean_upc_ctgry_desc             varchar2(40 char)   null,
    sap_material_division_code     varchar2(2 char)    null,
    material_division_desc         varchar2(40 char)   null,
    sap_material_type_code         varchar2(4 char)    null,
    material_type_desc             varchar2(40 char)   null,
    sap_material_grp_code          varchar2(9 char)    null,
    material_grp_desc              varchar2(40 char)   null,
    sap_material_grp_packs_code    varchar2(4 char)    null,
    material_grp_packs_desc        varchar2(40 char)   null,
    sap_cross_plant_matl_sts_code  varchar2(2 char)    null,
    cross_plant_matl_sts_desc      varchar2(40 char)   null,
    sap_bus_sgmnt_code             varchar2(4 char)    null,
    bus_sgmnt_abbrd_desc           varchar2(12 char)   null,
    bus_sgmnt_desc                 varchar2(30 char)   null,
    sap_mkt_sgmnt_code             varchar2(4 char)    null,
    mkt_sgmnt_abbrd_desc           varchar2(12 char)   null,
    mkt_sgmnt_desc                 varchar2(30 char)   null,
    sap_brand_essnc_code           varchar2(4 char)    null,
    brand_essnc_abbrd_desc         varchar2(12 char)   null,
    brand_essnc_desc               varchar2(30 char)   null,
    sap_brand_flag_code            varchar2(4 char)    null,
    brand_flag_abbrd_desc          varchar2(12 char)   null,
    brand_flag_desc                varchar2(30 char)   null,
    sap_brand_sub_flag_code        varchar2(4 char)    null,
    brand_sub_flag_abbrd_desc      varchar2(12 char)   null,
    brand_sub_flag_desc            varchar2(30 char)   null,
    sap_supply_sgmnt_code          varchar2(4 char)    null,
    supply_sgmnt_abbrd_desc        varchar2(12 char)   null,
    supply_sgmnt_desc              varchar2(30 char)   null,
    sap_ingred_vrty_code           varchar2(4 char)    null,
    ingred_vrty_abbrd_desc         varchar2(12 char)   null,
    ingred_vrty_desc               varchar2(30 char)   null,
    sap_funcl_vrty_code            varchar2(4 char)    null,
    funcl_vrty_abbrd_desc          varchar2(12 char)   null,
    funcl_vrty_desc                varchar2(30 char)   null,
    sap_major_pack_code            varchar2(4 char)    null,
    major_pack_abbrd_desc          varchar2(12 char)   null,
    major_pack_desc                varchar2(30 char)   null,
    sap_minor_pack_code            varchar2(4 char)    null,
    minor_pack_abbrd_desc          varchar2(12 char)   null,
    minor_pack_desc                varchar2(30 char)   null,
    sap_multi_pack_qty_code        varchar2(4 char)    null,
    multi_pack_qty_abbrd_desc      varchar2(12 char)   null,
    multi_pack_qty_desc            varchar2(30 char)   null,
    sap_occsn_code                 varchar2(4 char)    null,
    occsn_abbrd_desc               varchar2(12 char)   null,
    occsn_desc                     varchar2(30 char)   null,
    sap_prdct_ctgry_code           varchar2(4 char)    null,
    prdct_ctgry_abbrd_desc         varchar2(12 char)   null,
    prdct_ctgry_desc               varchar2(30 char)   null,
    sap_prdct_type_code            varchar2(4 char)    null,
    prdct_type_abbrd_desc          varchar2(12 char)   null,
    prdct_type_desc                varchar2(30 char)   null,
    sap_prdct_pack_size_code       varchar2(4 char)    null,
    prdct_pack_size_abbrd_desc     varchar2(12 char)   null,
    prdct_pack_size_desc           varchar2(30 char)   null,
    sap_cnsmr_pack_frmt_code       varchar2(4 char)    null,
    cnsmr_pack_frmt_abbrd_desc     varchar2(12 char)   null,
    cnsmr_pack_frmt_desc           varchar2(30 char)   null,
    sap_pack_type_code             varchar2(4 char)    null,
    pack_type_abbrd_desc           varchar2(12 char)   null,
    pack_type_desc                 varchar2(30 char)   null,
    sap_prdct_size_grp_code        varchar2(4 char)    null,
    prdct_size_grp_abbrd_desc      varchar2(12 char)   null,
    prdct_size_grp_desc            varchar2(30 char)   null,
    sap_prim_cnsmptn_grp_code      varchar2(4 char)    null,
    prim_cnsmptn_grp_abbrd_desc    varchar2(12 char)   null,
    prim_cnsmptn_grp_desc          varchar2(30 char)   null,
    sap_trad_unit_frmt_code        varchar2(4 char)    null,
    trad_unit_frmt_abbrd_desc      varchar2(12 char)   null,
    trad_unit_frmt_desc            varchar2(30 char)   null,
    sap_trad_unit_config_code      varchar2(4 char)    null,
    trad_unit_config_abbrd_desc    varchar2(12 char)   null,
    trad_unit_config_desc          varchar2(30 char)   null,
    sap_onpack_cnsmr_value_code    varchar2(4 char)    null,
    onpack_cnsmr_value_abbrd_desc  varchar2(12 char)   null,
    onpack_cnsmr_value_desc        varchar2(30 char)   null,
    sap_onpack_cnsmr_offer_code    varchar2(4 char)    null,
    onpack_cnsmr_offer_abbrd_desc  varchar2(12 char)   null,
    onpack_cnsmr_offer_desc        varchar2(30 char)   null,
    sap_onpack_trade_offer_code    varchar2(4 char)    null,
    onpack_trade_offer_abbrd_desc  varchar2(12 char)   null,
    onpack_trade_offer_desc        varchar2(30 char)   null,
    sap_bdt_code                   varchar2(2 char)    null,
    bdt_abbrd_desc                 varchar2(12 char)   null,
    bdt_desc                       varchar2(30 char)   null);

/**/
/* Comments
/**/
comment on table dd.material_dim is 'Material Dimension Table';
comment on column dd.material_dim.sap_material_code is 'SAP Material Code';
comment on column dd.material_dim.material_desc_en is 'Material Description EN';
comment on column dd.material_dim.material_sts_code is 'Material Status Code';
comment on column dd.material_dim.material_sts_abbrd_desc is 'Material Status Abbreviated Description';
comment on column dd.material_dim.material_sts_desc is 'Material Status Description';
comment on column dd.material_dim.gross_wgt is 'Gross Weight';
comment on column dd.material_dim.net_wgt is 'Net Weight';
comment on column dd.material_dim.sap_wgt_unit_code is 'SAP Weight Unit Code which is used for Gross Weight and Net Weight';
comment on column dd.material_dim.wgt_unit_abbrd_desc is 'Weight Unit Abbreviated Description';
comment on column dd.material_dim.wgt_unit_desc is 'Weight Unit Description';
comment on column dd.material_dim.vol is 'Volume';
comment on column dd.material_dim.sap_vol_unit_code is 'SAP Volume Unit Code';
comment on column dd.material_dim.vol_unit_abbrd_desc is 'Volume Unit Abbreviated Description';
comment on column dd.material_dim.vol_unit_desc is 'Volume Unit Description';
comment on column dd.material_dim.sap_base_uom_code is 'SAP Base Unit of Measure Code';
comment on column dd.material_dim.base_uom_abbrd_desc is 'Base Unit of Measure Abbreviated Description';
comment on column dd.material_dim.base_uom_desc is 'Base Unit of Measure Description';
comment on column dd.material_dim.material_owner is 'Material Owner';
comment on column dd.material_dim.sap_rep_item_code is 'SAP Representative Material Code';
comment on column dd.material_dim.rep_item_desc_en is 'Representative Material English Description';
comment on column dd.material_dim.sap_rpt_item_code is 'SAP Report Representative Material Code';
comment on column dd.material_dim.rpt_item_desc_en is 'Report Representative Material English Description';
comment on column dd.material_dim.mat_lead_time_days is 'Maturation Lead Time Days';
comment on column dd.material_dim.old_material_code is 'Old Material Number';
comment on column dd.material_dim.material_type_flag_int is 'Material Type Flag Intermediate Product Component';
comment on column dd.material_dim.material_type_flag_rsu is 'Material Type Flag Retail Sales Unit';
comment on column dd.material_dim.material_type_flag_tdu is 'Material Type Flag Traded Unit';
comment on column dd.material_dim.material_type_flag_mcu is 'Material Type Flag Merchanising Unit';
comment on column dd.material_dim.material_type_flag_pro is 'Material Type Flag Promotional Material';
comment on column dd.material_dim.material_type_flag_sfp is 'Material Type Flag Semi Finished Product';
comment on column dd.material_dim.material_type_flag_sc is 'Material Type Flag Shipping Container';
comment on column dd.material_dim.material_type_flag_rep is 'Material Type Flag Representative Item';
comment on column dd.material_dim.ean_upc is 'EAN-UPC';
comment on column dd.material_dim.sap_ean_upc_ctgry_code is 'EAN-UPC Category Code';
comment on column dd.material_dim.ean_upc_ctgry_desc is 'EAN-UPC Category Description';
comment on column dd.material_dim.sap_material_division_code is 'SAP Material Division Code';
comment on column dd.material_dim.material_division_desc is 'Material Division Description';
comment on column dd.material_dim.sap_material_type_code is 'SAP Material Type Code';
comment on column dd.material_dim.material_type_desc is 'Material Type Description';
comment on column dd.material_dim.sap_material_grp_code is 'SAP Material Group Code';
comment on column dd.material_dim.material_grp_desc is 'Material Group Description';
comment on column dd.material_dim.sap_material_grp_packs_code is 'SAP Material Group Packs Code';
comment on column dd.material_dim.material_grp_packs_desc is 'Material Group Packs Description';
comment on column dd.material_dim.sap_cross_plant_matl_sts_code is 'SAP Cross Plant Material Status Code';
comment on column dd.material_dim.cross_plant_matl_sts_desc is 'Cross Plant Material Status Description';
comment on column dd.material_dim.sap_bus_sgmnt_code is 'SAP Business Segment Code';
comment on column dd.material_dim.bus_sgmnt_abbrd_desc is 'Business Segment Abbreviated Description';
comment on column dd.material_dim.bus_sgmnt_desc is 'Business Segment Description';
comment on column dd.material_dim.sap_mkt_sgmnt_code is 'SAP Market Segment Code';
comment on column dd.material_dim.mkt_sgmnt_abbrd_desc is 'Market Segment Abbreviated Description';
comment on column dd.material_dim.mkt_sgmnt_desc is 'Market Segment Description';
comment on column dd.material_dim.sap_brand_essnc_code is 'SAP Brand Essence Code';
comment on column dd.material_dim.brand_essnc_abbrd_desc is 'Brand Essence Abbreviated Description';
comment on column dd.material_dim.brand_essnc_desc is 'Brand Essence Description';
comment on column dd.material_dim.sap_brand_flag_code is 'SAP Brand Flag Code';
comment on column dd.material_dim.brand_flag_abbrd_desc is 'Brand Flag Abbreviated Description';
comment on column dd.material_dim.brand_flag_desc is 'Brand Flag Description';
comment on column dd.material_dim.sap_brand_sub_flag_code is 'SAP Brand Sub-Flag Code';
comment on column dd.material_dim.brand_sub_flag_abbrd_desc is 'Brand Sub-Flag Abbreviated Description';
comment on column dd.material_dim.brand_sub_flag_desc is 'Brand Sub-Flag Description';
comment on column dd.material_dim.sap_supply_sgmnt_code is 'SAP Supply Segment Code';
comment on column dd.material_dim.sap_onpack_trade_offer_code is 'SAP On-pack Trade Offer Code';
comment on column dd.material_dim.onpack_trade_offer_abbrd_desc is 'On-pack Trade Offer Abbreviated Description';
comment on column dd.material_dim.onpack_trade_offer_desc is 'On-pack Trade Offer Description';
comment on column dd.material_dim.supply_sgmnt_abbrd_desc is 'Supply Segment Abbreviated Description';
comment on column dd.material_dim.supply_sgmnt_desc is 'Supply Segment Description';
comment on column dd.material_dim.sap_ingred_vrty_code is 'SAP Ingredient Variety Code';
comment on column dd.material_dim.ingred_vrty_abbrd_desc is 'Ingredient Variety Abbreviated Description';
comment on column dd.material_dim.ingred_vrty_desc is 'Ingredient Variety Description';
comment on column dd.material_dim.sap_funcl_vrty_code is 'SAP Functional Variety Code';
comment on column dd.material_dim.funcl_vrty_abbrd_desc is 'Functional Variety Abbreviated Description';
comment on column dd.material_dim.funcl_vrty_desc is 'Functional Variety Description';
comment on column dd.material_dim.sap_major_pack_code is 'SAP Major Pack Code';
comment on column dd.material_dim.major_pack_abbrd_desc is 'Major Pack Abbreviated Description';
comment on column dd.material_dim.major_pack_desc is 'Major Pack Description';
comment on column dd.material_dim.sap_minor_pack_code is 'SAP Minor Pack Code';
comment on column dd.material_dim.minor_pack_abbrd_desc is 'Minor Pack Abbreviated Description';
comment on column dd.material_dim.minor_pack_desc is 'Minor Pack Description';
comment on column dd.material_dim.sap_multi_pack_qty_code is 'SAP Multi-pack Quantity Code';
comment on column dd.material_dim.multi_pack_qty_abbrd_desc is 'Multi-pack Quantity Abbreviated Description';
comment on column dd.material_dim.multi_pack_qty_desc is 'Multi-pack Quantity Description';
comment on column dd.material_dim.sap_occsn_code is 'SAP Occasion Code';
comment on column dd.material_dim.occsn_abbrd_desc is 'Occasion Abbreviated Description';
comment on column dd.material_dim.occsn_desc is 'Occasion Description';
comment on column dd.material_dim.sap_prdct_ctgry_code is 'SAP Product Category Code';
comment on column dd.material_dim.prdct_ctgry_abbrd_desc is 'Product Category Abbreviated Description';
comment on column dd.material_dim.prdct_ctgry_desc is 'Product Category Description';
comment on column dd.material_dim.sap_prdct_type_code is 'SAP Product Type Code';
comment on column dd.material_dim.prdct_type_abbrd_desc is 'Product Type Abbreviated Description';
comment on column dd.material_dim.prdct_type_desc is 'Product Type Description';
comment on column dd.material_dim.sap_prdct_pack_size_code is 'SAP Product Pack Size Code';
comment on column dd.material_dim.prdct_pack_size_abbrd_desc is 'Product Pack Size Abbreviated Description';
comment on column dd.material_dim.prdct_pack_size_desc is 'Product Pack Size Description';
comment on column dd.material_dim.sap_cnsmr_pack_frmt_code is 'SAP Consumer Pack Format Code';
comment on column dd.material_dim.cnsmr_pack_frmt_abbrd_desc is 'Consumer Pack Format Abbreviated Description';
comment on column dd.material_dim.cnsmr_pack_frmt_desc is 'Consumer Pack Format Description';
comment on column dd.material_dim.sap_pack_type_code is 'SAP Pack Type Code';
comment on column dd.material_dim.pack_type_abbrd_desc is 'Pack Type Abbreviated Description';
comment on column dd.material_dim.pack_type_desc is 'Pack Type Description';
comment on column dd.material_dim.sap_prdct_size_grp_code is 'SAP Product Size Group Code';
comment on column dd.material_dim.prdct_size_grp_abbrd_desc is 'Product Size Group Abbreviated Description';
comment on column dd.material_dim.prdct_size_grp_desc is 'Product Size Group Description';
comment on column dd.material_dim.sap_prim_cnsmptn_grp_code is 'SAP Primary Consumption Group Code';
comment on column dd.material_dim.prim_cnsmptn_grp_abbrd_desc is 'Primary Consumption Group Abbreviated Description';
comment on column dd.material_dim.prim_cnsmptn_grp_desc is 'Primary Consumption Group Description';
comment on column dd.material_dim.sap_trad_unit_frmt_code is 'SAP Traded Unit Format Code';
comment on column dd.material_dim.trad_unit_frmt_abbrd_desc is 'Traded Unit Format Abbreviated Description';
comment on column dd.material_dim.trad_unit_frmt_desc is 'Traded Unit Format Description';
comment on column dd.material_dim.sap_trad_unit_config_code is 'SAP Traded Unit Configuration Code';
comment on column dd.material_dim.trad_unit_config_abbrd_desc is 'Traded Unit Configuration Abbreviated Description';
comment on column dd.material_dim.trad_unit_config_desc is 'Traded Unit Configuration Description';
comment on column dd.material_dim.sap_onpack_cnsmr_value_code is 'SAP On-pack Consumer Value Code';
comment on column dd.material_dim.onpack_cnsmr_value_abbrd_desc is 'On-pack Consumer Value Abbreviated Description';
comment on column dd.material_dim.onpack_cnsmr_value_desc is 'On-pack Consumer Value Description';
comment on column dd.material_dim.sap_onpack_cnsmr_offer_code is 'SAP On-pack Consumer Offer Code';
comment on column dd.material_dim.onpack_cnsmr_offer_abbrd_desc is 'On-pack Consumer Offer Abbreviated Description';
comment on column dd.material_dim.onpack_cnsmr_offer_desc is 'On-pack Consumer Offer Description';
comment on column dd.material_dim.sap_bdt_code is 'SAP BDT Code';
comment on column dd.material_dim.bdt_abbrd_desc is 'BDT Abbreviated Description';
comment on column dd.material_dim.bdt_desc is 'BDT Description';

/**/
/* Primary Key Constraint
/**/
alter table dd.material_dim
   add constraint material_dim_pk primary key (sap_material_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.material_dim to dw_app;
grant select on dd.material_dim to bo_user;
grant select on dd.material_dim to pld_rep_app;
grant select on dd.material_dim to hermes_app;

/**/
/* Synonym
/**/
create or replace public synonym material_dim for dd.material_dim;

