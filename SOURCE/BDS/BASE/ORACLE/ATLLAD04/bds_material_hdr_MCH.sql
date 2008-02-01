/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_HDR
 Owner   : BDS
 Author  : Linden Glen

 hdrription
 -----------
 Business Data Store - Material Header (MATMAS) - MCH Version

 YYYY/MM   Author         description
 -------   ------         -----------
 2007/05   Steve Gregan   Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_hdr
   (sap_material_code                  varchar2(18 char)     not null, 
    bds_material_desc_en               varchar2(40 char)     null,  
    bds_material_desc_zh               varchar2(40 char)     null,
    sap_idoc_name                      varchar2(30 char)     null, 
    sap_idoc_number                    number                null, 
    sap_idoc_timestamp                 varchar2(14 char)     null, 
    bds_lads_date                      date                  null, 
    bds_lads_status                    varchar2(2 char)      null, 
    creatn_user                        varchar2(12 char)     null,
    creatn_date                        date                  null,  
    change_user                        varchar2(12 char)     null, 
    change_date                        date                  null, 
    maint_status                       varchar2(15 char)     null, 
    deletion_flag                      varchar2(1 char)      null, 
    material_type                      varchar2(4 char)      null, 
    industry_sector                    varchar2(1 char)      null, 
    material_grp                       varchar2(9 char)      null, 
    old_material_code                  varchar2(18 char)     null, 
    base_uom                           varchar2(3 char)      null,     
    length                             number                null, 
    width                              number                null, 
    height                             number                null, 
    dimension_uom                      varchar2(3 char)      null, 
    gross_weight                       number                null, 
    net_weight                         number                null, 
    gross_weight_unit                  varchar2(3 char)      null, 
    volume                             number                null, 
    volume_unit                        varchar2(3 char)      null, 
    mars_plan_item_flag                varchar2(6 char)      null, 
    mars_intrmdt_prdct_compnt_flag     varchar2(1 char)      null, 
    mars_merchandising_unit_flag       varchar2(1 char)      null, 
    mars_prmotional_material_flag      varchar2(1 char)      null, 
    mars_retail_sales_unit_flag        varchar2(1 char)      null, 
    mars_shpping_contnr_flag           varchar2(1 char)      null, 
    mars_semi_finished_prdct_flag      varchar2(1 char)      null, 
    mars_traded_unit_flag              varchar2(1 char)      null, 
    mars_rprsnttv_item_flag            varchar2(1 char)      null, 
    mars_item_status_code              varchar2(3 char)      null, 
    mars_rprsnttv_item_code            varchar2(18 char)     null,
    order_unit                         varchar2(3 char)      null, 
    document_number                    varchar2(22 char)     null, 
    document_type                      varchar2(3 char)      null, 
    document_vrsn                      varchar2(2 char)      null, 
    document_page_frmt                 varchar2(4 char)      null, 
    document_change_no                 varchar2(6 char)      null, 
    document_page_no                   varchar2(3 char)      null, 
    document_sheets_no                 number                null, 
    inspection_memo                    varchar2(18 char)     null, 
    prod_memo_page_frmt                varchar2(4 char)      null, 
    material_dimension                 varchar2(32 char)     null, 
    basic_material_constituent         varchar2(14 char)     null, 
    industry_stndrd_desc               varchar2(18 char)     null, 
    design_office                      varchar2(3 char)      null, 
    purchasing_value_key               varchar2(4 char)      null, 
    contnr_reqrmnt                     varchar2(2 char)      null, 
    storg_condtn                       varchar2(2 char)      null, 
    temprtr_condtn_indctr              varchar2(2 char)      null, 
    transprt_grp                       varchar2(4 char)      null, 
    hazardous_material_no              varchar2(18 char)     null, 
    material_division                  varchar2(2 char)      null, 
    competitor                         varchar2(10 char)     null, 
    qty_print_slips                    number                null, 
    procurement_rule                   varchar2(1 char)      null, 
    supply_src                         varchar2(1 char)      null, 
    season_ctgry                       varchar2(4 char)      null, 
    label_type                         varchar2(2 char)      null, 
    label_form                         varchar2(2 char)      null, 
    interntl_article_no                varchar2(18 char)     null, 
    interntl_article_no_ctgry          varchar2(2 char)      null, 
    prdct_hierachy                     varchar2(18 char)     null, 
    cad_indictr                        varchar2(1 char)      null, 
    allowed_pkging_weight              number                null, 
    allowed_pkging_weight_unit         varchar2(3 char)      null, 
    allowed_pkging_volume              number                null, 
    allowed_pkging_volume_unit         varchar2(3 char)      null, 
    hu_excess_weight_tolrnc            number                null, 
    hu_excess_volume_tolrnc            number                null, 
    variable_order_unit_actv           varchar2(1 char)      null, 
    configurable_material              varchar2(1 char)      null, 
    batch_mngmnt_reqrmnt_indctr        varchar2(1 char)      null, 
    pkging_material_type               varchar2(4 char)      null, 
    max_level_volume                   number                null, 
    stacking_fctr                      number                null, 
    material_grp_pkging                varchar2(4 char)      null, 
    authrztn_grp                       varchar2(4 char)      null, 
    qm_procurement_actv                varchar2(1 char)      null, 
    catalog_profile                    varchar2(9 char)      null, 
    min_remaining_shelf_life           number                null, 
    total_shelf_life                   number                null, 
    storg_percntg                      number                null, 
    complt_maint_status                varchar2(15 char)     null, 
    extrnl_material_grp                varchar2(18 char)     null, 
    xplant_status                      varchar2(2 char)      null, 
    xdstrbtn_chain_status              varchar2(2 char)      null, 
    xplant_status_valid                date                  null, 
    xdstrbtn_chain_status_valid        date                  null, 
    envrnmnt_relevant_indctr           varchar2(1 char)      null, 
    prdct_alloctn_detrmntn_prcdr       varchar2(18 char)     null, 
    discount_in_kind                   varchar2(1 char)      null, 
    manufctr_part_no                   varchar2(40 char)     null, 
    manufctr_no                        varchar2(10 char)     null, 
    to_material_no                     varchar2(18 char)     null, 
    manufctr_part_profile              varchar2(4 char)      null, 
    dangerous_goods_indctr             varchar2(3 char)      null, 
    highly_vicsous_indctr              varchar2(1 char)      null, 
    bulk_liqud_indctr                  varchar2(1 char)      null, 
    closed_pkging_material             varchar2(1 char)      null, 
    apprvd_batch_rec_indctr            varchar2(1 char)      null, 
    compltn_level                      number                null, 
    assign_effctvty_param              varchar2(1 char)      null, 
    sled_rounding_rule                 varchar2(1 char)      null, 
    prd_shelf_life_indctr              varchar2(1 char)      null, 
    compostn_on_pkging                 varchar2(1 char)      null, 
    general_item_ctgry_grp             varchar2(4 char)      null, 
    hu_excess_weight_tolrnc_1          number                null, 
    hu_excess_volume_tolrnc_1          number                null, 
    basic_material                     varchar2(48 char)     null, 
    change_no                          varchar2(12 char)     null, 
    locked_indctr                      varchar2(1 char)      null, 
    config_mngmnt_indctr               varchar2(1 char)      null, 
    xplant_configurable_material       varchar2(18 char)     null, 
    sled_bbd                           varchar2(1 char)      null, 
    global_trade_item_variant          varchar2(2 char)      null, 
    prepack_generic_material_no        varchar2(18 char)     null, 
    explicit_serial_no_level           varchar2(1 char)      null, 
    refrnc_material                    varchar2(18 char)     null, 
    mars_declrd_volume                 number                null, 
    mars_declrd_volume_unit            varchar2(3 char)      null, 
    mars_declrd_count                  number                null, 
    mars_declrd_count_uni              varchar2(3 char)      null, 
    mars_pre_promtd_weight             number                null, 
    mars_pre_promtd_weight_unit        varchar2(3 char)      null, 
    mars_pre_promtd_volume             number                null, 
    mars_pre_promtd_volume_unit        varchar2(3 char)      null, 
    mars_pre_promtd_count              number                null, 
    mars_pre_promtd_count_unit         varchar2(3 char)      null, 
    mars_item_owner                    varchar2(12 char)     null, 
    mars_change_user                   varchar2(12 char)     null, 
    mars_day_lead_time                 number                null,
    mars_zzalpha01                     varchar2(8 char)      null, 
    mars_zzalpha02                     varchar2(8 char)      null, 
    mars_zzalpha03                     varchar2(8 char)      null, 
    mars_zzalpha04                     varchar2(8 char)      null, 
    mars_zzalpha05                     varchar2(8 char)      null, 
    mars_zzalpha06                     varchar2(8 char)      null, 
    mars_zzalpha07                     varchar2(8 char)      null, 
    mars_zzalpha08                     varchar2(8 char)      null, 
    mars_zzalpha09                     varchar2(8 char)      null, 
    mars_zzalpha10                     varchar2(8 char)      null, 
    mars_zznum01                       number                null, 
    mars_zznum02                       number                null, 
    mars_zznum03                       number                null, 
    mars_zznum04                       number                null, 
    mars_zznum05                       number                null, 
    mars_zznum06                       number                null, 
    mars_zznum07                       number                null, 
    mars_zznum08                       number                null, 
    mars_zznum09                       number                null, 
    mars_zznum10                       number                null, 
    mars_zzcheck01                     varchar2(1 char)      null, 
    mars_zzcheck02                     varchar2(1 char)      null, 
    mars_zzcheck03                     varchar2(1 char)      null, 
    mars_zzcheck04                     varchar2(1 char)      null, 
    mars_zzcheck05                     varchar2(1 char)      null, 
    mars_zzcheck06                     varchar2(1 char)      null, 
    mars_zzcheck07                     varchar2(1 char)      null, 
    mars_zzcheck08                     varchar2(1 char)      null, 
    mars_zzcheck09                     varchar2(1 char)      null, 
    mars_zzcheck10                     varchar2(1 char)      null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_hdr
   add constraint bds_material_hdr_pk primary key (sap_material_code);

    
/**/
/* Indexes
/**/
create index bds_material_hdr_idx1 on bds_material_hdr (material_type);
create index bds_material_hdr_idx2 on bds_material_hdr (mars_traded_unit_flag, mars_retail_sales_unit_flag, mars_intrmdt_prdct_compnt_flag);


/**/
/* Comments
/**/
comment on table bds_material_hdr is 'Business Data Store - Material Header (MATMAS)';
comment on column bds_material_hdr.sap_material_code is 'Material Number - lads_mat_hdr.matnr';
comment on column bds_material_hdr.bds_material_desc_en is 'Material English Description  - lads_mat_mkt.maktx';
comment on column bds_material_hdr.bds_material_desc_zh is 'Material Chinese Description  - lads_mat_mkt.maktx';
comment on column bds_material_hdr.sap_idoc_name is 'IDOC name - lads_mat_hdr.idoc_name';
comment on column bds_material_hdr.sap_idoc_number is 'IDOC number - lads_mat_hdr.idoc_number';
comment on column bds_material_hdr.sap_idoc_timestamp is 'IDOC timestamp - lads_mat_hdr.idoc_timestamp';
comment on column bds_material_hdr.bds_lads_date is 'LADS date loaded - lads_mat_hdr.lads_date';
comment on column bds_material_hdr.bds_lads_status is 'LADS status (1=valid, 2=error, 3=orphan, 4=deleted) - lads_mat_hdr.lads_status';
comment on column bds_material_hdr.creatn_date is 'Creation date - lads_mat_hdr.ersda';
comment on column bds_material_hdr.creatn_user is 'Name of Person who Created the Object - lads_mat_hdr.ernam';
comment on column bds_material_hdr.change_user is 'Date of Last Change - lads_mat_hdr.laeda';
comment on column bds_material_hdr.change_date is 'Name of person who changed object - lads_mat_hdr.aenam';
comment on column bds_material_hdr.maint_status is 'Maintenance status - lads_mat_hdr.pstat';
comment on column bds_material_hdr.deletion_flag is 'Flag Material for Deletion at Client Level - lads_mat_hdr.lvorm';
comment on column bds_material_hdr.material_type is 'Material Type - lads_mat_hdr.mtart';
comment on column bds_material_hdr.industry_sector is 'Industry Sector - lads_mat_hdr.mbrsh';
comment on column bds_material_hdr.material_grp is 'Material Group - lads_mat_hdr.matkl';
comment on column bds_material_hdr.old_material_code is 'Old material number - lads_mat_hdr.bismt';
comment on column bds_material_hdr.base_uom is 'Base Unit of Measure - lads_mat_hdr.meins';
comment on column bds_material_hdr.order_unit is 'Order unit - lads_mat_hdr.bstme';
comment on column bds_material_hdr.document_number is 'Document number (without document management system) - lads_mat_hdr.zeinr';
comment on column bds_material_hdr.document_type is 'Document type (without Document Management system) - lads_mat_hdr.zeiar';
comment on column bds_material_hdr.document_vrsn is 'Document version (without Document Management system) - lads_mat_hdr.zeivr';
comment on column bds_material_hdr.document_page_frmt is 'Page format of document (without Document Management system) - lads_mat_hdr.zeifo';
comment on column bds_material_hdr.document_change_no is 'Document change number (without document management system) - lads_mat_hdr.aeszn';
comment on column bds_material_hdr.document_page_no is 'Page number of document (without Document Management system) - lads_mat_hdr.blatt';
comment on column bds_material_hdr.document_sheets_no is 'Number of sheets (without Document Management system) - lads_mat_hdr.blanz';
comment on column bds_material_hdr.inspection_memo is 'Production/Inspection Memo - lads_mat_hdr.ferth';
comment on column bds_material_hdr.prod_memo_page_frmt is 'Page Format of Production Memo - lads_mat_hdr.formt';
comment on column bds_material_hdr.material_dimension is 'Size/dimensions - lads_mat_hdr.groes';
comment on column bds_material_hdr.basic_material_constituent is 'Basic material (basic constituent of a material) - obsolete - lads_mat_hdr.wrkst';
comment on column bds_material_hdr.industry_stndrd_desc is 'Industry Standard Description (such as ANSI or ISO) - lads_mat_hdr.normt';
comment on column bds_material_hdr.design_office is 'Laboratory/design office - lads_mat_hdr.labor';
comment on column bds_material_hdr.purchasing_value_key is 'Purchasing Value Key - lads_mat_hdr.ekwsl';
comment on column bds_material_hdr.gross_weight is 'Gross weight - lads_mat_hdr.brgew';
comment on column bds_material_hdr.net_weight is 'Net weight - lads_mat_hdr.ntgew';
comment on column bds_material_hdr.gross_weight_unit is 'Weight Unit - lads_mat_hdr.gewei';
comment on column bds_material_hdr.volume is 'Volume - lads_mat_hdr.volum';
comment on column bds_material_hdr.volume_unit is 'Volume unit - lads_mat_hdr.voleh';
comment on column bds_material_hdr.contnr_reqrmnt is 'Container requirements - lads_mat_hdr.behvo';
comment on column bds_material_hdr.storg_condtn is 'Storage conditions - lads_mat_hdr.raube';
comment on column bds_material_hdr.temprtr_condtn_indctr is 'Temperature conditions indicator - lads_mat_hdr.tempb';
comment on column bds_material_hdr.transprt_grp is 'Transportation group - lads_mat_hdr.tragr';
comment on column bds_material_hdr.hazardous_material_no is 'Hazardous material number - lads_mat_hdr.stoff';
comment on column bds_material_hdr.material_division is 'Division - lads_mat_hdr.spart';
comment on column bds_material_hdr.competitor is 'Competitor - lads_mat_hdr.kunnr';
comment on column bds_material_hdr.qty_print_slips is 'Quantity: Number of GR/GI slips to be printed - lads_mat_hdr.wesch';
comment on column bds_material_hdr.procurement_rule is 'Procurement rule - lads_mat_hdr.bwvor';
comment on column bds_material_hdr.supply_src is 'Source of Supply - lads_mat_hdr.bwscl';
comment on column bds_material_hdr.season_ctgry is 'Season category - lads_mat_hdr.saiso';
comment on column bds_material_hdr.label_type is 'Label type - lads_mat_hdr.etiar';
comment on column bds_material_hdr.label_form is 'Label form - lads_mat_hdr.etifo';
comment on column bds_material_hdr.interntl_article_no is 'International Article Number (EAN/UPC) - lads_mat_hdr.ean11';
comment on column bds_material_hdr.interntl_article_no_ctgry is 'Category of International Article Number (EAN) - lads_mat_hdr.numtp';
comment on column bds_material_hdr.length is 'Length - lads_mat_hdr.laeng';
comment on column bds_material_hdr.width is 'Width - lads_mat_hdr.breit';
comment on column bds_material_hdr.height is 'Height - lads_mat_hdr.hoehe';
comment on column bds_material_hdr.dimension_uom is 'Unit of dimension for length/width/height - lads_mat_hdr.meabm';
comment on column bds_material_hdr.prdct_hierachy is 'Product hierarchy - lads_mat_hdr.prdha';
comment on column bds_material_hdr.cad_indictr is 'CAD indicator - lads_mat_hdr.cadkz';
comment on column bds_material_hdr.allowed_pkging_weight is 'Allowed packaging weight - lads_mat_hdr.ergew';
comment on column bds_material_hdr.allowed_pkging_weight_unit is 'Weight Unit - lads_mat_hdr.ergei';
comment on column bds_material_hdr.allowed_pkging_volume is 'Allowed packaging volume - lads_mat_hdr.ervol';
comment on column bds_material_hdr.allowed_pkging_volume_unit is 'Volume unit - lads_mat_hdr.ervoe';
comment on column bds_material_hdr.hu_excess_weight_tolrnc is 'Excess Weight Tolerance for Handling unit - lads_mat_hdr.gewto';
comment on column bds_material_hdr.hu_excess_volume_tolrnc is 'Excess Volume Tolerance of the Handling Unit - lads_mat_hdr.volto';
comment on column bds_material_hdr.variable_order_unit_actv is 'Variable order unit active - lads_mat_hdr.vabme';
comment on column bds_material_hdr.configurable_material is 'Configurable Material - lads_mat_hdr.kzkfg';
comment on column bds_material_hdr.batch_mngmnt_reqrmnt_indctr is 'Batch management requirement indicator - lads_mat_hdr.xchpf';
comment on column bds_material_hdr.pkging_material_type is 'Packaging Material Type - lads_mat_hdr.vhart';
comment on column bds_material_hdr.max_level_volume is 'Maximum level (by volume) - lads_mat_hdr.fuelg';
comment on column bds_material_hdr.stacking_fctr is 'Stacking factor - lads_mat_hdr.stfak';
comment on column bds_material_hdr.material_grp_pkging is 'Material Group: Packaging Materials - lads_mat_hdr.magrv';
comment on column bds_material_hdr.authrztn_grp is 'Authorization Group - lads_mat_hdr.begru';
comment on column bds_material_hdr.qm_procurement_actv is 'QM in Procurement is Active - lads_mat_hdr.qmpur';
comment on column bds_material_hdr.catalog_profile is 'Catalog Profile - lads_mat_hdr.rbnrm';
comment on column bds_material_hdr.min_remaining_shelf_life is 'Minimum remaining shelf life - lads_mat_hdr.mhdrz';
comment on column bds_material_hdr.total_shelf_life is 'Total shelf life - lads_mat_hdr.mhdhb';
comment on column bds_material_hdr.storg_percntg is 'Storage percentage - lads_mat_hdr.mhdlp';
comment on column bds_material_hdr.complt_maint_status is 'Maintenance status of complete material - lads_mat_hdr.vpsta';
comment on column bds_material_hdr.extrnl_material_grp is 'External material group - lads_mat_hdr.extwg';
comment on column bds_material_hdr.xplant_status is 'Cross-Plant Material Status - lads_mat_hdr.mstae';
comment on column bds_material_hdr.xdstrbtn_chain_status is 'Cross-distribution-chain material status - lads_mat_hdr.mstav';
comment on column bds_material_hdr.xplant_status_valid is 'Date from which the cross-plant material status is valid - lads_mat_hdr.mstde';
comment on column bds_material_hdr.xdstrbtn_chain_status_valid is 'Date from which the X-distr.-chain material status is valid - lads_mat_hdr.mstdv';
comment on column bds_material_hdr.envrnmnt_relevant_indctr is 'Indicator: Environmentally Relevant - lads_mat_hdr.kzumw';
comment on column bds_material_hdr.prdct_alloctn_detrmntn_prcdr is 'Product allocation determination procedure - lads_mat_hdr.kosch';
comment on column bds_material_hdr.discount_in_kind is 'Material qualifies for discount in kind - lads_mat_hdr.nrfhg';
comment on column bds_material_hdr.manufctr_part_no is 'Manufacturer part number - lads_mat_hdr.mfrpn';
comment on column bds_material_hdr.manufctr_no is 'Manufacturer number - lads_mat_hdr.mfrnr';
comment on column bds_material_hdr.to_material_no is 'To material number - lads_mat_hdr.bmatn';
comment on column bds_material_hdr.manufctr_part_profile is 'Mfr part profile - lads_mat_hdr.mprof';
comment on column bds_material_hdr.dangerous_goods_indctr is 'Dangerous Goods Indicator Profile - lads_mat_hdr.profl';
comment on column bds_material_hdr.highly_vicsous_indctr is 'Indicator: Highly Viscous - lads_mat_hdr.ihivi';
comment on column bds_material_hdr.bulk_liqud_indctr is 'Indicator: In Bulk/Liquid - lads_mat_hdr.iloos';
comment on column bds_material_hdr.closed_pkging_material is 'Packaging Material is Closed Packaging - lads_mat_hdr.kzgvh';
comment on column bds_material_hdr.apprvd_batch_rec_indctr is 'Indicator: Approved batch record required - lads_mat_hdr.xgchp';
comment on column bds_material_hdr.compltn_level is 'Material completion level - lads_mat_hdr.compl';
comment on column bds_material_hdr.assign_effctvty_param is 'Assign effectivity parameter values/ override change numbers - lads_mat_hdr.kzeff';
comment on column bds_material_hdr.sled_rounding_rule is 'Rounding rule for calculation of SLED - lads_mat_hdr.rdmhd';
comment on column bds_material_hdr.prd_shelf_life_indctr is 'Period indicator for shelf life expiration date - lads_mat_hdr.iprkz';
comment on column bds_material_hdr.compostn_on_pkging is 'Indicator: Product composition printed on packaging - lads_mat_hdr.przus';
comment on column bds_material_hdr.general_item_ctgry_grp is 'General item category group - lads_mat_hdr.mtpos_mara';
comment on column bds_material_hdr.hu_excess_weight_tolrnc_1 is 'Excess Weight Tolerance for Handling unit - lads_mat_hdr.gewto_new';
comment on column bds_material_hdr.hu_excess_volume_tolrnc_1 is 'Excess Volume Tolerance of the Handling Unit - lads_mat_hdr.volto_new';
comment on column bds_material_hdr.basic_material is 'Basic Material - lads_mat_hdr.wrkst_new';
comment on column bds_material_hdr.change_no is 'Change Number - lads_mat_hdr.aennr';
comment on column bds_material_hdr.locked_indctr is 'Material Is Locked - lads_mat_hdr.matfi';
comment on column bds_material_hdr.config_mngmnt_indctr is 'Relevant for Configuration Management - lads_mat_hdr.cmrel';
comment on column bds_material_hdr.xplant_configurable_material is 'Cross-Plant Configurable Material - lads_mat_hdr.satnr';
comment on column bds_material_hdr.sled_bbd is 'sled_bbd - lads_mat_hdr.sled_bbd';
comment on column bds_material_hdr.global_trade_item_variant is 'Global Trade Item Number Variant - lads_mat_hdr.gtin_variant';
comment on column bds_material_hdr.prepack_generic_material_no is 'Material Number of the Generic Material in Prepack Materials - lads_mat_hdr.gennr';
comment on column bds_material_hdr.explicit_serial_no_level is 'Level of Explicitness for Serial Number - lads_mat_hdr.serlv';
comment on column bds_material_hdr.refrnc_material is 'Reference material for materials packed in same way - lads_mat_hdr.rmatp';
comment on column bds_material_hdr.mars_declrd_volume is 'Declared Volume - lads_mat_hdr.zzdecvolum';
comment on column bds_material_hdr.mars_declrd_volume_unit is 'Declared Volume Unit - lads_mat_hdr.zzdecvoleh';
comment on column bds_material_hdr.mars_declrd_count is 'Declared Count - lads_mat_hdr.zzdeccount';
comment on column bds_material_hdr.mars_declrd_count_uni is 'Declared Count Unit - lads_mat_hdr.zzdeccounit';
comment on column bds_material_hdr.mars_pre_promtd_weight is 'Pre-Promoted weight - lads_mat_hdr.zzpproweight';
comment on column bds_material_hdr.mars_pre_promtd_weight_unit is 'Pre Promoted weight Unit - lads_mat_hdr.zzpprowunit';
comment on column bds_material_hdr.mars_pre_promtd_volume is 'Pre-Promoted Volume - lads_mat_hdr.zzpprovolum';
comment on column bds_material_hdr.mars_pre_promtd_volume_unit is 'Pre promoted volume unit - lads_mat_hdr.zzpprovunit';
comment on column bds_material_hdr.mars_pre_promtd_count is 'Pre-Promoted Count - lads_mat_hdr.zzpprocount';
comment on column bds_material_hdr.mars_pre_promtd_count_unit is 'Pre Promoted count unit - lads_mat_hdr.zzpprocunit';
comment on column bds_material_hdr.mars_zzalpha01 is 'unused - lads_mat_hdr.zzalpha01';
comment on column bds_material_hdr.mars_zzalpha02 is 'unused - lads_mat_hdr.zzalpha02';
comment on column bds_material_hdr.mars_zzalpha03 is 'Unused - lads_mat_hdr.zzalpha03';
comment on column bds_material_hdr.mars_zzalpha04 is 'Unused - lads_mat_hdr.zzalpha04';
comment on column bds_material_hdr.mars_zzalpha05 is 'Unused - lads_mat_hdr.zzalpha05';
comment on column bds_material_hdr.mars_zzalpha06 is 'Unused - lads_mat_hdr.zzalpha06';
comment on column bds_material_hdr.mars_zzalpha07 is 'Unused - lads_mat_hdr.zzalpha07';
comment on column bds_material_hdr.mars_zzalpha08 is 'Unused - lads_mat_hdr.zzalpha08';
comment on column bds_material_hdr.mars_zzalpha09 is 'Unused - lads_mat_hdr.zzalpha09';
comment on column bds_material_hdr.mars_zzalpha10 is 'Unused - lads_mat_hdr.zzalpha10';
comment on column bds_material_hdr.mars_zznum01 is 'Unused - lads_mat_hdr.zznum01';
comment on column bds_material_hdr.mars_zznum02 is 'Unused - lads_mat_hdr.zznum02';
comment on column bds_material_hdr.mars_zznum03 is 'Unused - lads_mat_hdr.zznum03';
comment on column bds_material_hdr.mars_zznum04 is 'Unused - lads_mat_hdr.zznum04';
comment on column bds_material_hdr.mars_zznum05 is 'Unused - lads_mat_hdr.zznum05';
comment on column bds_material_hdr.mars_zznum06 is 'Unused - lads_mat_hdr.zznum06';
comment on column bds_material_hdr.mars_zznum07 is 'Unused - lads_mat_hdr.zznum07';
comment on column bds_material_hdr.mars_zznum08 is 'Unused - lads_mat_hdr.zznum08';
comment on column bds_material_hdr.mars_zznum09 is 'Unused - lads_mat_hdr.zznum09';
comment on column bds_material_hdr.mars_zznum10 is 'Unused - lads_mat_hdr.zznum10';
comment on column bds_material_hdr.mars_zzcheck01 is 'Unused - lads_mat_hdr.zzcheck01';
comment on column bds_material_hdr.mars_zzcheck02 is 'Unused - lads_mat_hdr.zzcheck02';
comment on column bds_material_hdr.mars_zzcheck03 is 'Unused - lads_mat_hdr.zzcheck03';
comment on column bds_material_hdr.mars_zzcheck04 is 'Unused - lads_mat_hdr.zzcheck04';
comment on column bds_material_hdr.mars_zzcheck05 is 'Unused - lads_mat_hdr.zzcheck05';
comment on column bds_material_hdr.mars_zzcheck06 is 'Unused - lads_mat_hdr.zzcheck06';
comment on column bds_material_hdr.mars_zzcheck07 is 'Unused - lads_mat_hdr.zzcheck07';
comment on column bds_material_hdr.mars_zzcheck08 is 'Unused - lads_mat_hdr.zzcheck08';
comment on column bds_material_hdr.mars_zzcheck09 is 'Unused - lads_mat_hdr.zzcheck09';
comment on column bds_material_hdr.mars_zzcheck10 is 'Unused - lads_mat_hdr.zzcheck10';
comment on column bds_material_hdr.mars_plan_item_flag is 'ATLAS MD plan item - lads_mat_hdr.zzplan_item';
comment on column bds_material_hdr.mars_intrmdt_prdct_compnt_flag is 'INT (Intermediate Product Component) - lads_mat_hdr.zzisint';
comment on column bds_material_hdr.mars_merchandising_unit_flag is 'MCU (Merchandising Unit) - lads_mat_hdr.zzismcu';
comment on column bds_material_hdr.mars_prmotional_material_flag is 'PRO (Promotional Material) - lads_mat_hdr.zzispro';
comment on column bds_material_hdr.mars_retail_sales_unit_flag is 'RSU (Retail Sales Unit) - lads_mat_hdr.zzisrsu';
comment on column bds_material_hdr.mars_shpping_contnr_flag is 'SC  (Shipping Container) - lads_mat_hdr.zzissc';
comment on column bds_material_hdr.mars_semi_finished_prdct_flag is 'SFP (Semi-Finished Product) - lads_mat_hdr.zzissfp';
comment on column bds_material_hdr.mars_traded_unit_flag is 'TDU (Traded Unit) - lads_mat_hdr.zzistdu';
comment on column bds_material_hdr.mars_rprsnttv_item_flag is 'REP (Representative Item) - lads_mat_hdr.zzistra';
comment on column bds_material_hdr.mars_item_status_code is 'ATLAS MD mars Item Status Code - lads_mat_hdr.zzstatuscode';
comment on column bds_material_hdr.mars_item_owner is 'ATLAS MD mars Item Owner - lads_mat_hdr.zzitemowner';
comment on column bds_material_hdr.mars_change_user is 'ATLAS MD mars Last changed by - lads_mat_hdr.zzchangedby';
comment on column bds_material_hdr.mars_day_lead_time is 'Maturation lead time in days - lads_mat_hdr.zzmattim';
comment on column bds_material_hdr.mars_rprsnttv_item_code is 'Representative item code - lads_mat_hdr.zzrepmatnr';


/**/
/* Synonym
/**/
create or replace public synonym bds_material_hdr for bds.bds_material_hdr;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_hdr to lics_app;
grant select,update,delete,insert on bds_material_hdr to bds_app;
grant select,update,delete,insert on bds_material_hdr to lads_app;
