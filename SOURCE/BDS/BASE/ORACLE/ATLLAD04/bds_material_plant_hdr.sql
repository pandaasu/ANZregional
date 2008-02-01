/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_PLANT_HDR
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Plant Header (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_plant_hdr
   (sap_material_code                      varchar2(18 char)     not null, 
    plant_code                             varchar2(4 char)      not null, 
    sap_function                           varchar2(3 char)      null, 
    sap_function_1                         varchar2(3 char)      null, 
    sap_function_2                         varchar2(3 char)      null, 
    sap_function_3                         varchar2(3 char)      null, 
    maint_status                           varchar2(15 char)     null, 
    deletion_indctr                        varchar2(1 char)      null, 
    mars_plant_material_type               number                null, 
    mars_maturation_lead_time_days         number                null, 
    mars_fpps_source                       varchar2(15 char)     null, 
    vltn_ctgry                             varchar2(1 char)      null, 
    abc_indctr                             varchar2(1 char)      null, 
    critical_part_indctr                   varchar2(1 char)      null, 
    purchasing_grp                         varchar2(3 char)      null, 
    issue_unit                             varchar2(3 char)      null, 
    mrp_profile                            varchar2(4 char)      null, 
    mrp_type                               varchar2(2 char)      null, 
    mrp_controller                         varchar2(3 char)      null, 
    planned_delivery_days                  number                null, 
    gr_processing_days                     number                null, 
    prd_indctr                             varchar2(1 char)      null, 
    assembly_scrap_percntg                 number                null, 
    lot_size                               varchar2(2 char)      null, 
    procurement_type                       varchar2(1 char)      null, 
    special_procurement_type               varchar2(2 char)      null, 
    reorder_point                          number                null, 
    safety_stock                           number                null, 
    min_lot_size                           number                null, 
    max_lot_size                           number                null, 
    fixed_lot_size                         number                null, 
    purchase_order_qty_rounding            number                null, 
    max_stock_level                        number                null, 
    ordering_costs                         number                null, 
    dependent_reqrmnt_indctr               varchar2(1 char)      null, 
    storage_cost_indctr                    varchar2(1 char)      null, 
    altrntv_bom_select_method              varchar2(1 char)      null, 
    discontinuation_indctr                 varchar2(1 char)      null, 
    effective_out_date                     date                  null, 
    followup_material                      varchar2(18 char)     null, 
    reqrmnts_grping_indctr                 varchar2(1 char)      null, 
    mixed_mrp_indctr                       varchar2(1 char)      null, 
    float_schedule_margin_key              varchar2(3 char)      null, 
    planned_order_auto_fix_indctr          varchar2(1 char)      null, 
    prdctn_order_release_indctr            varchar2(1 char)      null, 
    backflush_indctr                       varchar2(1 char)      null, 
    prdctn_scheduler                       varchar2(3 char)      null, 
    processing_time                        number                null, 
    configuration_time                     number                null, 
    interoperation_time                    number                null, 
    base_qty                               number                null, 
    inhouse_prdctn_time                    number                null, 
    max_storage_prd                        number                null, 
    max_storage_prd_unit                   varchar2(3 char)      null, 
    prdctn_bin_withdraw_indctr             varchar2(1 char)      null, 
    roughcut_planning_indctr               varchar2(1 char)      null, 
    over_delivery_tolrnc_limit             number                null, 
    over_delivery_allowed_indctr           varchar2(1 char)      null, 
    under_delivery_tolrnc_limit            number                null, 
    replenishment_lead_time                number                null, 
    replacement_part_indctr                varchar2(1 char)      null, 
    surcharge_factor                       number                null, 
    manufacture_status                     varchar2(2 char)      null, 
    inspection_stock_post_indctr           varchar2(1 char)      null, 
    qa_control_key                         varchar2(8 char)      null, 
    documentation_reqrd_indctr             varchar2(1 char)      null, 
    stock_transfer                         number                null, 
    loading_grp                            varchar2(4 char)      null, 
    batch_manage_reqrmnt_indctr            varchar2(1 char)      null, 
    quota_arrangement_usage                varchar2(1 char)      null, 
    service_level                          number                null, 
    splitting_indctr                       varchar2(1 char)      null, 
    plan_version                           varchar2(2 char)      null, 
    object_type                            varchar2(2 char)      null, 
    object_id                              number                null, 
    availability_check_grp                 varchar2(2 char)      null, 
    fiscal_year_variant                    varchar2(2 char)      null, 
    correction_factor_indctr               varchar2(1 char)      null, 
    shipping_setup_time                    number                null, 
    capacity_planning_base_qty             number                null, 
    shipping_processing_time               number                null, 
    delivery_cycle                         varchar2(4 char)      null, 
    supply_source                          varchar2(1 char)      null, 
    auto_purchase_order_indctr             varchar2(1 char)      null, 
    source_list_reqrmnt_indctr             varchar2(1 char)      null, 
    commodity_code                         varchar2(17 char)     null, 
    origin_country                         varchar2(3 char)      null, 
    origin_region                          varchar2(3 char)      null, 
    comodity_uom                           varchar2(3 char)      null, 
    trade_grp                              varchar2(4 char)      null, 
    profit_center                          varchar2(10 char)     null, 
    stock_in_transit                       number                null, 
    ppc_planning_calendar                  varchar2(3 char)      null, 
    repetitive_manu_allowed_indctr         varchar2(1 char)      null, 
    planning_time_fence                    number                null, 
    consumption_mode                       varchar2(1 char)      null, 
    consumption_prd_back                   number                null, 
    consumption_prd_forward                number                null, 
    alternative_bom                        varchar2(2 char)      null, 
    bom_usage                              varchar2(1 char)      null, 
    task_list_grp_key                      varchar2(8 char)      null, 
    grp_counter                            varchar2(2 char)      null, 
    prdct_costing_lot_size                 number                null, 
    special_cost_procurement_type          varchar2(2 char)      null, 
    production_unit                        varchar2(3 char)      null, 
    issue_storage_location                 varchar2(4 char)      null, 
    mrp_group                              varchar2(4 char)      null, 
    component_scrap_percntg                number                null, 
    certificate_type                       varchar2(4 char)      null, 
    takt_time                              number                null, 
    coverage_profile                       varchar2(3 char)      null, 
    local_field_name                       varchar2(10 char)     null, 
    physical_inventory_indctr              varchar2(1 char)      null, 
    variance_key                           varchar2(6 char)      null, 
    serial_number_profile                  varchar2(4 char)      null, 
    configurable_material                  varchar2(18 char)     null, 
    repetitive_manu_profile                varchar2(4 char)      null, 
    negative_stocks_allowed_indctr         varchar2(1 char)      null, 
    reqrd_qm_vendor_system                 varchar2(4 char)      null, 
    planning_cycle                         varchar2(3 char)      null, 
    rounding_profile                       varchar2(4 char)      null, 
    refrnc_consumption_material            varchar2(18 char)     null, 
    refrnc_consumption_plant               varchar2(4 char)      null, 
    consumption_material_copy_date         date                  null, 
    refrnc_consumption_multiplier          number                null, 
    auto_forecast_model_reset              varchar2(1 char)      null, 
    trade_prfrnc_indctr                    varchar2(1 char)      null, 
    exemption_certificate_indctr           varchar2(1 char)      null, 
    exemption_certificate_qty              number                null, 
    exemption_certificate_issued           date                  null, 
    vendor_declaration_indctr              varchar2(1 char)      null, 
    vendor_declaration_valid_date          date                  null, 
    military_goods_indctr                  varchar2(1 char)      null, 
    char_field                             varchar2(7 char)      null, 
    coprdct_material_indctr                varchar2(1 char)      null, 
    planning_strategy_grp                  varchar2(2 char)      null, 
    default_storage_location               varchar2(4 char)      null, 
    bulk_material_indctr                   varchar2(1 char)      null, 
    fixed_cc_indctr                        varchar2(1 char)      null, 
    stock_withdrawal_seq_grp               varchar2(4 char)      null, 
    qm_activity_authorisation_grp          varchar2(6 char)      null, 
    task_list_type                         varchar2(1 char)      null, 
    plant_specific_status                  varchar2(2 char)      null, 
    prdctn_scheduling_profile              varchar2(6 char)      null, 
    safety_time_indctr                     varchar2(1 char)      null, 
    safety_time_days                       number                null, 
    planned_order_action_cntrl             varchar2(2 char)      null, 
    batch_entry_determination              varchar2(1 char)      null, 
    plant_specific_status_valid            date                  null, 
    freight_grp                            varchar2(8 char)      null, 
    prdctn_version_for_costing             varchar2(4 char)      null, 
    cfop_ctgry                             varchar2(2 char)      null, 
    cap_prdcts_list_no                     varchar2(12 char)     null, 
    cap_prdcts_grp                         varchar2(6 char)      null, 
    cas_no                                 varchar2(15 char)     null, 
    prodcom_no                             varchar2(9 char)      null, 
    consumption_taxes_cntrl_code           varchar2(16 char)     null, 
    jit_delivery_schedules_indctr          varchar2(1 char)      null, 
    transition_matrix_grp                  varchar2(20 char)     null, 
    logistics_handling_grp                 varchar2(4 char)      null, 
    proposed_supply_area                   varchar2(10 char)     null, 
    fair_share_rule                        varchar2(2 char)      null, 
    push_dstrbtn_indctr                    varchar2(1 char)      null, 
    deployment_horizon_days                number                null, 
    supply_demand_min_lot_size             number                null, 
    supply_demand_max_lot_size             number                null, 
    supply_demand_fixed_lot_size           number                null, 
    supply_demand_lot_size_incrmnt         number                null, 
    completion_level                       number                null, 
    prdctn_figure_conversion_type          varchar2(2 char)      null, 
    dstrbtn_profile                        varchar2(3 char)      null, 
    safety_time_prd_profile                varchar2(3 char)      null, 
    fixed_price_coprdct                    varchar2(1 char)      null, 
    xproject_material_indctr               varchar2(1 char)      null, 
    ocm_profile                            varchar2(6 char)      null, 
    apo_relevant_indctr                    varchar2(1 char)      null, 
    mrp_relevancy_reqrmnts                 varchar2(1 char)      null, 
    min_safety_stock                       number                null, 
    do_not_cost_indctr                     varchar2(1 char)      null, 
    uom_grp                                varchar2(4 char)      null, 
    rotation_date                          varchar2(1 char)      null, 
    original_batch_manage_indctr           varchar2(1 char)      null, 
    original_batch_refrnc_material         varchar2(18 char)     null, 
    cim_resource_object_type               varchar2(2 char)      null, 
    cim_resource_object_id                 number                null, 
    internal_counter                       number                null, 
    cim_resource_object_type_1             varchar2(2 char)      null, 
    cim_resource_object_id_1               number                null, 
    create_load_records_indctr             varchar2(1 char)      null, 
    manage_prdctn_tools_key                varchar2(4 char)      null, 
    cntrl_key_change_indctr                varchar2(1 char)      null, 
    prdctn_tool_grp_key_1                  varchar2(4 char)      null, 
    prdctn_tool_grp_key_2                  varchar2(4 char)      null, 
    prdctn_tool_usage                      varchar2(3 char)      null, 
    prdctn_tool_standard_text_key          varchar2(7 char)      null, 
    refrnc_key_change_indctr               varchar2(1 char)      null, 
    prdctn_tool_usage_start_date           varchar2(2 char)      null, 
    start_offset_change_indctr             varchar2(1 char)      null, 
    start_offset_prdctn_tool               number                null, 
    start_offset_unit_prdctn_tool          varchar2(3 char)      null, 
    start_offset_change_indctr_1           varchar2(1 char)      null, 
    end_prdctn_tool_usage_date             varchar2(2 char)      null, 
    end_refrnc_date_change_indctr          varchar2(1 char)      null, 
    finish_offset_prdctn_tool              number                null, 
    finish_offset_unit_prdctn_tool         varchar2(3 char)      null, 
    finish_offset_change_indctr            varchar2(1 char)      null, 
    total_prt_qty_formula                  varchar2(6 char)      null, 
    total_prt_qty_change_indctr            varchar2(1 char)      null, 
    total_prt_usage_value_formula          varchar2(6 char)      null, 
    total_prt_usage_change_indctr          varchar2(1 char)      null, 
    formula_parameter_1                    varchar2(6 char)      null, 
    formula_parameter_2                    varchar2(6 char)      null, 
    formula_parameter_3                    varchar2(6 char)      null, 
    formula_parameter_4                    varchar2(6 char)      null, 
    formula_parameter_5                    varchar2(6 char)      null, 
    formula_parameter_6                    varchar2(6 char)      null, 
    parameter_unit_1                       varchar2(3 char)      null, 
    parameter_unit_2                       varchar2(3 char)      null, 
    parameter_unit_3                       varchar2(3 char)      null, 
    parameter_unit_4                       varchar2(3 char)      null, 
    parameter_unit_5                       varchar2(3 char)      null, 
    parameter_unit_6                       varchar2(3 char)      null, 
    parameter_value_1                      number                null, 
    parameter_value_2                      number                null, 
    parameter_value_3                      number                null, 
    parameter_value_4                      number                null, 
    parameter_value_5                      number                null, 
    parameter_value_6                      number                null, 
    planning_material                      varchar2(18 char)     null, 
    planning_plant                         varchar2(4 char)      null, 
    conversion_factor                      varchar2(10 char)     null, 
    long_material_code                     varchar2(40 char)     null, 
    version_number                         varchar2(10 char)     null, 
    external_guid                          varchar2(32 char)     null, 
    forecast_parameter_version_no          varchar2(2 char)      null, 
    forecast_profile                       varchar2(4 char)      null, 
    model_selection_indctr                 varchar2(1 char)      null, 
    model_selection_prcdr                  varchar2(1 char)      null, 
    parameter_optimisation_indctr          varchar2(1 char)      null, 
    optimisation_level                     varchar2(1 char)      null, 
    initialisation_indctr                  varchar2(1 char)      null, 
    forecast_model                         varchar2(1 char)      null, 
    basic_value_factor_alpha               number                null, 
    basic_value_factor_beta                number                null, 
    seasonal_index_factor_gamma            number                null, 
    mad_factor_delta                       number                null, 
    factor_epsilon                         number                null, 
    tracking_limit                         number                null, 
    indctr                                 varchar2(1 char)      null, 
    last_forecast_date                     varchar2(8 char)      null, 
    historical_prd_no                      number                null, 
    prd_initialisation_no                  number                null, 
    prd_per_seasonal_cycle_no              number                null, 
    prd_expost_forecast_no                 number                null, 
    prd_forecast_no                        number                null, 
    prd_fixed                              number                null, 
    basic_value                            number                null, 
    basic_value_1                          number                null, 
    basic_value_2                          number                null, 
    prev_prd_basic_value                   number                null, 
    prev_prd_base_value_1                  number                null, 
    prev_prd_base_value_2                  number                null, 
    trend_value                            number                null, 
    prev_prd_trend_value                   number                null, 
    mad                                    number                null, 
    prev_prd_mad                           number                null, 
    error_total                            number                null, 
    prev_prd_error_total                   number                null, 
    weighting_grp                          varchar2(2 char)      null, 
    theil_coefficient                      number                null, 
    exception_message_bar                  varchar2(30 char)     null, 
    forecast_flow_cntrl                    varchar2(10 char)     null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_plant_hdr
   add constraint bds_material_plant_hdr_pk primary key (sap_material_code, plant_code);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_material_plant_hdr is 'Business Data Store - Material Plant Data (MATMAS)';
comment on column bds_material_plant_hdr.sap_material_code is 'Material Number - lads_mat_mrc.matnr';
comment on column bds_material_plant_hdr.sap_function is 'Function - lads_mat_mrc.msgfn';
comment on column bds_material_plant_hdr.plant_code is 'Plant - lads_mat_mrc.werks';
comment on column bds_material_plant_hdr.maint_status is 'Maintenance status - lads_mat_mrc.pstat';
comment on column bds_material_plant_hdr.mars_plant_material_type is 'ATLAS MD plant oriented material type - lads_mat_zmc.zzmtart';
comment on column bds_material_plant_hdr.mars_maturation_lead_time_days is 'Maturation lead time in days - lads_mat_zmc.zzmattim_pl';
comment on column bds_material_plant_hdr.mars_fpps_source is 'FPPS source - lads_mat_zmc.zzfppsmoe';
comment on column bds_material_plant_hdr.deletion_indctr is 'Deletion Indicator - lads_mat_mrc.lvorm';
comment on column bds_material_plant_hdr.vltn_ctgry is 'Valuation Category - lads_mat_mrc.bwtty';
comment on column bds_material_plant_hdr.abc_indctr is 'ABC indicator - lads_mat_mrc.maabc';
comment on column bds_material_plant_hdr.critical_part_indctr is 'Indicator: Critical part - lads_mat_mrc.kzkri';
comment on column bds_material_plant_hdr.purchasing_grp is 'Purchasing Group - lads_mat_mrc.ekgrp';
comment on column bds_material_plant_hdr.issue_unit is 'Unit of issue - lads_mat_mrc.ausme';
comment on column bds_material_plant_hdr.mrp_profile is 'Material: MRP profile - lads_mat_mrc.dispr';
comment on column bds_material_plant_hdr.mrp_type is 'MRP Type - lads_mat_mrc.dismm';
comment on column bds_material_plant_hdr.mrp_controller is 'MRP Controller - lads_mat_mrc.dispo';
comment on column bds_material_plant_hdr.planned_delivery_days is 'Planned delivery time in days - lads_mat_mrc.plifz';
comment on column bds_material_plant_hdr.gr_processing_days is 'Goods receipt processing time in days - lads_mat_mrc.webaz';
comment on column bds_material_plant_hdr.prd_indctr is 'Period indicator - lads_mat_mrc.perkz';
comment on column bds_material_plant_hdr.assembly_scrap_percntg is 'Assembly scrap in percent - lads_mat_mrc.ausss';
comment on column bds_material_plant_hdr.lot_size is 'Lot size (materials planning) - lads_mat_mrc.disls';
comment on column bds_material_plant_hdr.procurement_type is 'Procurement Type - lads_mat_mrc.beskz';
comment on column bds_material_plant_hdr.special_procurement_type is 'Special procurement type - lads_mat_mrc.sobsl';
comment on column bds_material_plant_hdr.reorder_point is 'Reorder point - lads_mat_mrc.minbe';
comment on column bds_material_plant_hdr.safety_stock is 'Safety stock - lads_mat_mrc.eisbe';
comment on column bds_material_plant_hdr.min_lot_size is 'Minimum lot size - lads_mat_mrc.bstmi';
comment on column bds_material_plant_hdr.max_lot_size is 'Maximum lot size - lads_mat_mrc.bstma';
comment on column bds_material_plant_hdr.fixed_lot_size is 'Fixed lot size - lads_mat_mrc.bstfe';
comment on column bds_material_plant_hdr.purchase_order_qty_rounding is 'Rounding value for purchase order quantity - lads_mat_mrc.bstrf';
comment on column bds_material_plant_hdr.max_stock_level is 'Maximum stock level - lads_mat_mrc.mabst';
comment on column bds_material_plant_hdr.ordering_costs is 'Ordering costs - lads_mat_mrc.losfx';
comment on column bds_material_plant_hdr.dependent_reqrmnt_indctr is 'Dependent requirements ind. for individual and coll. reqmts - lads_mat_mrc.sbdkz';
comment on column bds_material_plant_hdr.storage_cost_indctr is 'Storage costs indicator - lads_mat_mrc.lagpr';
comment on column bds_material_plant_hdr.altrntv_bom_select_method is 'Method for Selecting Alternative Bills of Material - lads_mat_mrc.altsl';
comment on column bds_material_plant_hdr.discontinuation_indctr is 'Discontinuation indicator - lads_mat_mrc.kzaus';
comment on column bds_material_plant_hdr.effective_out_date is 'Effective-Out Date - lads_mat_mrc.ausdt';
comment on column bds_material_plant_hdr.followup_material is 'Follow-up material - lads_mat_mrc.nfmat';
comment on column bds_material_plant_hdr.reqrmnts_grping_indctr is 'Indicator for Requirements Grouping - lads_mat_mrc.kzbed';
comment on column bds_material_plant_hdr.mixed_mrp_indctr is 'Mixed MRP indicator - lads_mat_mrc.miskz';
comment on column bds_material_plant_hdr.float_schedule_margin_key is 'Scheduling Margin Key for Floats - lads_mat_mrc.fhori';
comment on column bds_material_plant_hdr.planned_order_auto_fix_indctr is 'Indicator: automatic fixing of planned orders - lads_mat_mrc.pfrei';
comment on column bds_material_plant_hdr.prdctn_order_release_indctr is 'Release indicator for production orders - lads_mat_mrc.ffrei';
comment on column bds_material_plant_hdr.backflush_indctr is 'Indicator: Backflush - lads_mat_mrc.rgekz';
comment on column bds_material_plant_hdr.prdctn_scheduler is 'Production scheduler - lads_mat_mrc.fevor';
comment on column bds_material_plant_hdr.processing_time is 'Processing time - lads_mat_mrc.bearz';
comment on column bds_material_plant_hdr.configuration_time is 'Setup and teardown time - lads_mat_mrc.ruezt';
comment on column bds_material_plant_hdr.interoperation_time is 'Interoperation time - lads_mat_mrc.tranz';
comment on column bds_material_plant_hdr.base_qty is 'Base quantity - lads_mat_mrc.basmg';
comment on column bds_material_plant_hdr.inhouse_prdctn_time is 'In-house production time - lads_mat_mrc.dzeit';
comment on column bds_material_plant_hdr.max_storage_prd is 'Maximum storage period - lads_mat_mrc.maxlz';
comment on column bds_material_plant_hdr.max_storage_prd_unit is 'Unit for maximum storage period - lads_mat_mrc.lzeih';
comment on column bds_material_plant_hdr.prdctn_bin_withdraw_indctr is 'Indicator: withdrawal of stock from production bin - lads_mat_mrc.kzpro';
comment on column bds_material_plant_hdr.roughcut_planning_indctr is 'Indicator: material included in rough-cut planning - lads_mat_mrc.gpmkz';
comment on column bds_material_plant_hdr.over_delivery_tolrnc_limit is 'Overdelivery tolerance limit - lads_mat_mrc.ueeto';
comment on column bds_material_plant_hdr.over_delivery_allowed_indctr is 'Indicator: Unlimited overdelivery allowed - lads_mat_mrc.ueetk';
comment on column bds_material_plant_hdr.under_delivery_tolrnc_limit is 'Underdelivery tolerance limit - lads_mat_mrc.uneto';
comment on column bds_material_plant_hdr.replenishment_lead_time is 'Total replenishment lead time (in workdays) - lads_mat_mrc.wzeit';
comment on column bds_material_plant_hdr.replacement_part_indctr is 'Replacement part - lads_mat_mrc.atpkz';
comment on column bds_material_plant_hdr.surcharge_factor is 'Surcharge factor for cost in percent - lads_mat_mrc.vzusl';
comment on column bds_material_plant_hdr.manufacture_status is 'State of manufacture - lads_mat_mrc.herbl';
comment on column bds_material_plant_hdr.inspection_stock_post_indctr is 'Post to Inspection Stock - lads_mat_mrc.insmk';
comment on column bds_material_plant_hdr.qa_control_key is 'QA control key - lads_mat_mrc.ssqss';
comment on column bds_material_plant_hdr.documentation_reqrd_indctr is 'Documentation required indicator - lads_mat_mrc.kzdkz';
comment on column bds_material_plant_hdr.stock_transfer is 'Stock in transfer (plant to plant) - lads_mat_mrc.umlmc';
comment on column bds_material_plant_hdr.loading_grp is 'Loading group - lads_mat_mrc.ladgr';
comment on column bds_material_plant_hdr.batch_manage_reqrmnt_indctr is 'Batch management requirement indicator - lads_mat_mrc.xchpf';
comment on column bds_material_plant_hdr.quota_arrangement_usage is 'Quota arrangement usage - lads_mat_mrc.usequ';
comment on column bds_material_plant_hdr.service_level is 'Service level - lads_mat_mrc.lgrad';
comment on column bds_material_plant_hdr.splitting_indctr is 'Splitting Indicator - lads_mat_mrc.auftl';
comment on column bds_material_plant_hdr.plan_version is 'Plan Version - lads_mat_mrc.plvar';
comment on column bds_material_plant_hdr.object_type is 'Object Type - lads_mat_mrc.otype';
comment on column bds_material_plant_hdr.object_id is 'Object ID - lads_mat_mrc.objid';
comment on column bds_material_plant_hdr.availability_check_grp is 'Checking Group for Availability Check - lads_mat_mrc.mtvfp';
comment on column bds_material_plant_hdr.fiscal_year_variant is 'Fiscal Year Variant - lads_mat_mrc.periv';
comment on column bds_material_plant_hdr.correction_factor_indctr is 'Indicator: take correction factors into account - lads_mat_mrc.kzkfk';
comment on column bds_material_plant_hdr.shipping_setup_time is 'Shipping setup time - lads_mat_mrc.vrvez';
comment on column bds_material_plant_hdr.capacity_planning_base_qty is 'Base quantity for capacity planning in shipping - lads_mat_mrc.vbamg';
comment on column bds_material_plant_hdr.shipping_processing_time is 'Shipping processing time - lads_mat_mrc.vbeaz';
comment on column bds_material_plant_hdr.delivery_cycle is 'Delivery cycle - lads_mat_mrc.lizyk';
comment on column bds_material_plant_hdr.supply_source is 'Source of Supply - lads_mat_mrc.bwscl';
comment on column bds_material_plant_hdr.auto_purchase_order_indctr is 'Indicator: automatic purchase order allowed - lads_mat_mrc.kautb';
comment on column bds_material_plant_hdr.source_list_reqrmnt_indctr is 'Indicator: Source list requirement - lads_mat_mrc.kordb';
comment on column bds_material_plant_hdr.commodity_code is 'Commodity code / Import code number for foreign trade - lads_mat_mrc.stawn';
comment on column bds_material_plant_hdr.origin_country is 'Country of origin of the material - lads_mat_mrc.herkl';
comment on column bds_material_plant_hdr.origin_region is 'Region of origin of material (non-preferential origin) - lads_mat_mrc.herkr';
comment on column bds_material_plant_hdr.comodity_uom is 'Unit of measure for commodity code (foreign trade) - lads_mat_mrc.expme';
comment on column bds_material_plant_hdr.trade_grp is 'Export/import material group - lads_mat_mrc.mtver';
comment on column bds_material_plant_hdr.profit_center is 'Profit Center - lads_mat_mrc.prctr';
comment on column bds_material_plant_hdr.stock_in_transit is 'Stock in transit - lads_mat_mrc.trame';
comment on column bds_material_plant_hdr.ppc_planning_calendar is 'PPC planning calendar - lads_mat_mrc.mrppp';
comment on column bds_material_plant_hdr.repetitive_manu_allowed_indctr is 'Ind.: Repetitive mfg allowed - lads_mat_mrc.sauft';
comment on column bds_material_plant_hdr.planning_time_fence is 'Planning time fence - lads_mat_mrc.fxhor';
comment on column bds_material_plant_hdr.consumption_mode is 'Consumption mode - lads_mat_mrc.vrmod';
comment on column bds_material_plant_hdr.consumption_prd_back is 'Consumption period: backward - lads_mat_mrc.vint1';
comment on column bds_material_plant_hdr.consumption_prd_forward is 'Consumption period: forward - lads_mat_mrc.vint2';
comment on column bds_material_plant_hdr.alternative_bom is 'Alternative BOM - lads_mat_mrc.stlal';
comment on column bds_material_plant_hdr.bom_usage is 'BOM Usage - lads_mat_mrc.stlan';
comment on column bds_material_plant_hdr.task_list_grp_key is 'Key for Task List Group - lads_mat_mrc.plnnr';
comment on column bds_material_plant_hdr.grp_counter is 'Group Counter - lads_mat_mrc.aplal';
comment on column bds_material_plant_hdr.prdct_costing_lot_size is 'Lot Size for Product Costing - lads_mat_mrc.losgr';
comment on column bds_material_plant_hdr.special_cost_procurement_type is 'Special Procurement Type for Costing - lads_mat_mrc.sobsk';
comment on column bds_material_plant_hdr.production_unit is 'Production unit - lads_mat_mrc.frtme';
comment on column bds_material_plant_hdr.issue_storage_location is 'Issue Storage Location - lads_mat_mrc.lgpro';
comment on column bds_material_plant_hdr.mrp_group is 'MRP Group - lads_mat_mrc.disgr';
comment on column bds_material_plant_hdr.component_scrap_percntg is 'Component scrap in percent - lads_mat_mrc.kausf';
comment on column bds_material_plant_hdr.certificate_type is 'Certificate Type - lads_mat_mrc.qzgtp';
comment on column bds_material_plant_hdr.takt_time is 'Takt time - lads_mat_mrc.takzt';
comment on column bds_material_plant_hdr.coverage_profile is 'Range of coverage profile - lads_mat_mrc.rwpro';
comment on column bds_material_plant_hdr.local_field_name is 'Local field name for CO/PA link to SOP - lads_mat_mrc.copam';
comment on column bds_material_plant_hdr.physical_inventory_indctr is 'Physical inventory indicator for cycle counting - lads_mat_mrc.abcin';
comment on column bds_material_plant_hdr.variance_key is 'Variance Key - lads_mat_mrc.awsls';
comment on column bds_material_plant_hdr.serial_number_profile is 'Serial Number Profile - lads_mat_mrc.sernp';
comment on column bds_material_plant_hdr.configurable_material is 'Configurable material - lads_mat_mrc.stdpd';
comment on column bds_material_plant_hdr.repetitive_manu_profile is 'Repetitive manufacturing profile - lads_mat_mrc.sfepr';
comment on column bds_material_plant_hdr.negative_stocks_allowed_indctr is 'Negative stocks allowed in plant - lads_mat_mrc.xmcng';
comment on column bds_material_plant_hdr.reqrd_qm_vendor_system is 'Required QM System for Vendor - lads_mat_mrc.qssys';
comment on column bds_material_plant_hdr.planning_cycle is 'Planning cycle - lads_mat_mrc.lfrhy';
comment on column bds_material_plant_hdr.rounding_profile is 'Rounding profile - lads_mat_mrc.rdprf';
comment on column bds_material_plant_hdr.refrnc_consumption_material is 'Reference material for consumption - lads_mat_mrc.vrbmt';
comment on column bds_material_plant_hdr.refrnc_consumption_plant is 'Reference plant for consumption - lads_mat_mrc.vrbwk';
comment on column bds_material_plant_hdr.consumption_material_copy_date is 'To date of the material to be copied for consumption - lads_mat_mrc.vrbdt';
comment on column bds_material_plant_hdr.refrnc_consumption_multiplier is 'Multiplier for reference material for consumption - lads_mat_mrc.vrbfk';
comment on column bds_material_plant_hdr.auto_forecast_model_reset is 'Reset Forecast Model Automatically - lads_mat_mrc.autru';
comment on column bds_material_plant_hdr.trade_prfrnc_indctr is 'Preference indicator in export/import - lads_mat_mrc.prefe';
comment on column bds_material_plant_hdr.exemption_certificate_indctr is 'Exemption certificate: Indicator for legal control - lads_mat_mrc.prenc';
comment on column bds_material_plant_hdr.exemption_certificate_qty is 'Number of exemption certificate in export/import - lads_mat_mrc.preno';
comment on column bds_material_plant_hdr.exemption_certificate_issued is 'Exemption certificate: Issue date of exemption certificate - lads_mat_mrc.prend';
comment on column bds_material_plant_hdr.vendor_declaration_indctr is 'Indicator: Vendor declaration exists - lads_mat_mrc.prene';
comment on column bds_material_plant_hdr.vendor_declaration_valid_date is 'Validity date of vendor declaration - lads_mat_mrc.preng';
comment on column bds_material_plant_hdr.military_goods_indctr is 'Indicator: Military goods - lads_mat_mrc.itark';
comment on column bds_material_plant_hdr.char_field is 'Character Field With Field Length 7 - lads_mat_mrc.prfrq';
comment on column bds_material_plant_hdr.coprdct_material_indctr is 'Indicator: Material can be co-product - lads_mat_mrc.kzkup';
comment on column bds_material_plant_hdr.planning_strategy_grp is 'Planning strategy group - lads_mat_mrc.strgr';
comment on column bds_material_plant_hdr.default_storage_location is 'Default storage location for external procurement - lads_mat_mrc.lgfsb';
comment on column bds_material_plant_hdr.bulk_material_indctr is 'Indicator: bulk material - lads_mat_mrc.schgt';
comment on column bds_material_plant_hdr.fixed_cc_indctr is 'CC indicator is fixed - lads_mat_mrc.ccfix';
comment on column bds_material_plant_hdr.stock_withdrawal_seq_grp is 'Withdrawal sequence group for stocks - lads_mat_mrc.eprio';
comment on column bds_material_plant_hdr.qm_activity_authorisation_grp is 'Material Authorization Group for Activities in QM - lads_mat_mrc.qmata';
comment on column bds_material_plant_hdr.task_list_type is 'Task List Type - lads_mat_mrc.plnty';
comment on column bds_material_plant_hdr.plant_specific_status is 'Plant-Specific Material Status - lads_mat_mrc.mmsta';
comment on column bds_material_plant_hdr.prdctn_scheduling_profile is 'Production Scheduling Profile - lads_mat_mrc.sfcpf';
comment on column bds_material_plant_hdr.safety_time_indctr is 'Safety time indicator (with or without safety time) - lads_mat_mrc.shflg';
comment on column bds_material_plant_hdr.safety_time_days is 'Safety time (in workdays) - lads_mat_mrc.shzet';
comment on column bds_material_plant_hdr.planned_order_action_cntrl is 'Action control: planned order processing - lads_mat_mrc.mdach';
comment on column bds_material_plant_hdr.batch_entry_determination is 'Determination of batch entry in the production/process order - lads_mat_mrc.kzech';
comment on column bds_material_plant_hdr.plant_specific_status_valid is 'Date from which the plant-specific material status is valid - lads_mat_mrc.mmstd';
comment on column bds_material_plant_hdr.freight_grp is 'Material freight group - lads_mat_mrc.mfrgr';
comment on column bds_material_plant_hdr.prdctn_version_for_costing is 'Production Version To Be Costed - lads_mat_mrc.fvidk';
comment on column bds_material_plant_hdr.cfop_ctgry is 'Material CFOP category - lads_mat_mrc.indus';
comment on column bds_material_plant_hdr.cap_prdcts_list_no is 'CAP: Number of CAP products list - lads_mat_mrc.mownr';
comment on column bds_material_plant_hdr.cap_prdcts_grp is 'Common Agricultural Policy: CAP products group-Foreign Trade - lads_mat_mrc.mogru';
comment on column bds_material_plant_hdr.cas_no is 'CAS number for pharmaceutical products in foreign trade - lads_mat_mrc.casnr';
comment on column bds_material_plant_hdr.prodcom_no is 'Production statistics: PRODCOM number for foreign trade - lads_mat_mrc.gpnum';
comment on column bds_material_plant_hdr.consumption_taxes_cntrl_code is 'Control code for consumption taxes in foreign trade - lads_mat_mrc.steuc';
comment on column bds_material_plant_hdr.jit_delivery_schedules_indctr is 'Indicator: Item relevant to JIT delivery schedules - lads_mat_mrc.fabkz';
comment on column bds_material_plant_hdr.transition_matrix_grp is 'Group of materials for transition matrix - lads_mat_mrc.matgr';
comment on column bds_material_plant_hdr.logistics_handling_grp is 'Logistics handling group for workload calculation - lads_mat_mrc.loggr';
comment on column bds_material_plant_hdr.proposed_supply_area is 'Proposed Supply Area in Material Master Record - lads_mat_mrc.vspvb';
comment on column bds_material_plant_hdr.fair_share_rule is 'Fair share rule - lads_mat_mrc.dplfs';
comment on column bds_material_plant_hdr.push_dstrbtn_indctr is 'Indicator: push distribution - lads_mat_mrc.dplpu';
comment on column bds_material_plant_hdr.deployment_horizon_days is 'Deployment horizon in days - lads_mat_mrc.dplho';
comment on column bds_material_plant_hdr.supply_demand_min_lot_size is 'Minimum lot size for Supply Demand Match - lads_mat_mrc.minls';
comment on column bds_material_plant_hdr.supply_demand_max_lot_size is 'Maximum lot size for Supply Demand Match - lads_mat_mrc.maxls';
comment on column bds_material_plant_hdr.supply_demand_fixed_lot_size is 'Fixed lot size for Supply Demand Match - lads_mat_mrc.fixls';
comment on column bds_material_plant_hdr.supply_demand_lot_size_incrmnt is 'Lot size increment for  Supply Demand Match - lads_mat_mrc.ltinc';
comment on column bds_material_plant_hdr.completion_level is 'Material completion level - lads_mat_mrc.compl';
comment on column bds_material_plant_hdr.prdctn_figure_conversion_type is 'Conversion types for production figures - lads_mat_mrc.convt';
comment on column bds_material_plant_hdr.dstrbtn_profile is 'Distribution profile of material in plant - lads_mat_mrc.fprfm';
comment on column bds_material_plant_hdr.safety_time_prd_profile is 'Period profile for safety time - lads_mat_mrc.shpro';
comment on column bds_material_plant_hdr.fixed_price_coprdct is 'Fixed-Price Co-Product - lads_mat_mrc.fxpru';
comment on column bds_material_plant_hdr.xproject_material_indctr is 'Indicator for cross-project material - lads_mat_mrc.kzpsp';
comment on column bds_material_plant_hdr.ocm_profile is 'Profile for OCM PP / PS - lads_mat_mrc.ocmpf';
comment on column bds_material_plant_hdr.apo_relevant_indctr is 'Indicator: Is material relevant for APO - lads_mat_mrc.apokz';
comment on column bds_material_plant_hdr.mrp_relevancy_reqrmnts is 'MRP relevancy for dependent requirements - lads_mat_mrc.ahdis';
comment on column bds_material_plant_hdr.min_safety_stock is 'Minimum Safety Stock - lads_mat_mrc.eislo';
comment on column bds_material_plant_hdr.do_not_cost_indctr is 'Do Not Cost - lads_mat_mrc.ncost';
comment on column bds_material_plant_hdr.uom_grp is 'Unit of measure group - lads_mat_mrc.megru';
comment on column bds_material_plant_hdr.rotation_date is 'Rotation date - lads_mat_mrc.rotation_date';
comment on column bds_material_plant_hdr.original_batch_manage_indctr is 'Indicator for Original Batch Management - lads_mat_mrc.uchkz';
comment on column bds_material_plant_hdr.original_batch_refrnc_material is 'Reference Material for Original Batches - lads_mat_mrc.ucmat';
comment on column bds_material_plant_hdr.sap_function_1 is 'Function - lads_mat_mrc.msgfn1';
comment on column bds_material_plant_hdr.cim_resource_object_type is 'Object types of the CIM resource - lads_mat_mrc.objty';
comment on column bds_material_plant_hdr.cim_resource_object_id is 'Object ID of the resource - lads_mat_mrc.objid1';
comment on column bds_material_plant_hdr.internal_counter is 'Internal counter - lads_mat_mrc.zaehl';
comment on column bds_material_plant_hdr.cim_resource_object_type_1 is 'Object types of the CIM resource - lads_mat_mrc.objty_v';
comment on column bds_material_plant_hdr.cim_resource_object_id_1 is 'Object ID of the resource - lads_mat_mrc.objid_v';
comment on column bds_material_plant_hdr.create_load_records_indctr is 'Indicator: Create load records for prod. resources/tools - lads_mat_mrc.kzkbl';
comment on column bds_material_plant_hdr.manage_prdctn_tools_key is 'Control key for management of production resources/tools - lads_mat_mrc.steuf';
comment on column bds_material_plant_hdr.cntrl_key_change_indctr is 'Control key cannot be changed - lads_mat_mrc.steuf_ref';
comment on column bds_material_plant_hdr.prdctn_tool_grp_key_1 is 'Grouping key 1 for production resources/tools - lads_mat_mrc.fgru1';
comment on column bds_material_plant_hdr.prdctn_tool_grp_key_2 is 'Grouping key 2 for production resources/tools - lads_mat_mrc.fgru2';
comment on column bds_material_plant_hdr.prdctn_tool_usage is 'Production resource/tool usage - lads_mat_mrc.planv';
comment on column bds_material_plant_hdr.prdctn_tool_standard_text_key is 'Standard text key for production resources/tools - lads_mat_mrc.ktsch';
comment on column bds_material_plant_hdr.refrnc_key_change_indctr is 'Reference key cannot be changed. - lads_mat_mrc.ktsch_ref';
comment on column bds_material_plant_hdr.prdctn_tool_usage_start_date is 'Reference date to start of production resource/tool usage - lads_mat_mrc.bzoffb';
comment on column bds_material_plant_hdr.start_offset_change_indctr is 'Offset to start cannot be changed - lads_mat_mrc.bzoffb_ref';
comment on column bds_material_plant_hdr.start_offset_prdctn_tool is 'Offset to start of production resource/tool usage - lads_mat_mrc.offstb';
comment on column bds_material_plant_hdr.start_offset_unit_prdctn_tool is 'Offset unit for start of prod. resource/tool usage - lads_mat_mrc.ehoffb';
comment on column bds_material_plant_hdr.start_offset_change_indctr_1 is 'Offset to start cannot be changed - lads_mat_mrc.offstb_ref';
comment on column bds_material_plant_hdr.end_prdctn_tool_usage_date is 'Reference date for end of production resource/tool usage - lads_mat_mrc.bzoffe';
comment on column bds_material_plant_hdr.end_refrnc_date_change_indctr is 'End reference date cannot be changed - lads_mat_mrc.bzoffe_ref';
comment on column bds_material_plant_hdr.finish_offset_prdctn_tool is 'Offset to finish of production resource/tool usage - lads_mat_mrc.offste';
comment on column bds_material_plant_hdr.finish_offset_unit_prdctn_tool is 'Offset unit for end of production resource/tool usage - lads_mat_mrc.ehoffe';
comment on column bds_material_plant_hdr.finish_offset_change_indctr is 'Offset to end cannot be changed - lads_mat_mrc.offste_ref';
comment on column bds_material_plant_hdr.total_prt_qty_formula is 'Formula for calculating the total quantity of PRT - lads_mat_mrc.mgform';
comment on column bds_material_plant_hdr.total_prt_qty_change_indctr is 'Formula for calculating the total quantity cannot be changed - lads_mat_mrc.mgform_ref';
comment on column bds_material_plant_hdr.total_prt_usage_value_formula is 'Formula for calculating the total usage value of PRT - lads_mat_mrc.ewform';
comment on column bds_material_plant_hdr.total_prt_usage_change_indctr is 'Formula to calculate entire usage value cannot be changed - lads_mat_mrc.ewform_ref';
comment on column bds_material_plant_hdr.formula_parameter_1 is 'First parameter (for formulas) - lads_mat_mrc.par01';
comment on column bds_material_plant_hdr.formula_parameter_2 is 'Second parameter (for formulas) - lads_mat_mrc.par02';
comment on column bds_material_plant_hdr.formula_parameter_3 is 'Third parameter (for formulas) - lads_mat_mrc.par03';
comment on column bds_material_plant_hdr.formula_parameter_4 is 'Fourth parameter (for formulas) - lads_mat_mrc.par04';
comment on column bds_material_plant_hdr.formula_parameter_5 is 'Fifth parameter (for formulas) - lads_mat_mrc.par05';
comment on column bds_material_plant_hdr.formula_parameter_6 is 'Sixth parameter (for formulas) - lads_mat_mrc.par06';
comment on column bds_material_plant_hdr.parameter_unit_1 is 'Parameter unit - lads_mat_mrc.paru1';
comment on column bds_material_plant_hdr.parameter_unit_2 is 'Parameter unit - lads_mat_mrc.paru2';
comment on column bds_material_plant_hdr.parameter_unit_3 is 'Parameter unit - lads_mat_mrc.paru3';
comment on column bds_material_plant_hdr.parameter_unit_4 is 'Parameter unit - lads_mat_mrc.paru4';
comment on column bds_material_plant_hdr.parameter_unit_5 is 'Parameter unit - lads_mat_mrc.paru5';
comment on column bds_material_plant_hdr.parameter_unit_6 is 'Parameter unit - lads_mat_mrc.paru6';
comment on column bds_material_plant_hdr.parameter_value_1 is 'Parameter value - lads_mat_mrc.parv1';
comment on column bds_material_plant_hdr.parameter_value_2 is 'Parameter value - lads_mat_mrc.parv2';
comment on column bds_material_plant_hdr.parameter_value_3 is 'Parameter value - lads_mat_mrc.parv3';
comment on column bds_material_plant_hdr.parameter_value_4 is 'Parameter value - lads_mat_mrc.parv4';
comment on column bds_material_plant_hdr.parameter_value_5 is 'Parameter value - lads_mat_mrc.parv5';
comment on column bds_material_plant_hdr.parameter_value_6 is 'Parameter value - lads_mat_mrc.parv6';
comment on column bds_material_plant_hdr.sap_function_2 is 'Function - lads_mat_mrc.msgfn2';
comment on column bds_material_plant_hdr.planning_material is 'Planning material - lads_mat_mrc.prgrp';
comment on column bds_material_plant_hdr.planning_plant is 'Planning plant - lads_mat_mrc.prwrk';
comment on column bds_material_plant_hdr.conversion_factor is 'Conv. factor f. plng material - lads_mat_mrc.umref';
comment on column bds_material_plant_hdr.long_material_code is 'Long material number (future development) for field PRGRP - lads_mat_mrc.prgrp_external';
comment on column bds_material_plant_hdr.version_number is 'Version number (future development) for field PRGRP - lads_mat_mrc.prgrp_version';
comment on column bds_material_plant_hdr.external_guid is 'External GUID (future development) for field PRGRP - lads_mat_mrc.prgrp_guid';
comment on column bds_material_plant_hdr.sap_function_3 is 'Function - lads_mat_mrc.msgfn3';
comment on column bds_material_plant_hdr.forecast_parameter_version_no is 'Version number of forecast parameters - lads_mat_mrc.versp';
comment on column bds_material_plant_hdr.forecast_profile is 'Forecast profile - lads_mat_mrc.propr';
comment on column bds_material_plant_hdr.model_selection_indctr is 'Model selection indicator - lads_mat_mrc.modaw';
comment on column bds_material_plant_hdr.model_selection_prcdr is 'Model selection procedure - lads_mat_mrc.modav';
comment on column bds_material_plant_hdr.parameter_optimisation_indctr is 'Indicator for parameter optimization - lads_mat_mrc.kzpar';
comment on column bds_material_plant_hdr.optimisation_level is 'Optimization level - lads_mat_mrc.opgra';
comment on column bds_material_plant_hdr.initialisation_indctr is 'Initialization indicator - lads_mat_mrc.kzini';
comment on column bds_material_plant_hdr.forecast_model is 'Forecast model - lads_mat_mrc.prmod';
comment on column bds_material_plant_hdr.basic_value_factor_alpha is 'Basic value smoothing using alpha factor - lads_mat_mrc.alpha';
comment on column bds_material_plant_hdr.basic_value_factor_beta is 'Trend value smoothing using the beta factor - lads_mat_mrc.beta1';
comment on column bds_material_plant_hdr.seasonal_index_factor_gamma is 'Seasonal index smoothing using gamma factor - lads_mat_mrc.gamma';
comment on column bds_material_plant_hdr.mad_factor_delta is 'MAD (mean absolute deviation) smoothing using delta factor - lads_mat_mrc.delta';
comment on column bds_material_plant_hdr.factor_epsilon is 'Epsilon factor - lads_mat_mrc.epsil';
comment on column bds_material_plant_hdr.tracking_limit is 'Tracking limit - lads_mat_mrc.siggr';
comment on column bds_material_plant_hdr.indctr is 's - lads_mat_mrc.perkz1';
comment on column bds_material_plant_hdr.last_forecast_date is 'Date of last forecast - lads_mat_mrc.prdat';
comment on column bds_material_plant_hdr.historical_prd_no is 'Number of historical periods - lads_mat_mrc.peran';
comment on column bds_material_plant_hdr.prd_initialisation_no is 'Number of periods for initialization - lads_mat_mrc.perin';
comment on column bds_material_plant_hdr.prd_per_seasonal_cycle_no is 'Number of periods per seasonal cycle - lads_mat_mrc.perio';
comment on column bds_material_plant_hdr.prd_expost_forecast_no is 'Number of periods for ex-post forecasting - lads_mat_mrc.perex';
comment on column bds_material_plant_hdr.prd_forecast_no is 'Number of forecast periods - lads_mat_mrc.anzpr';
comment on column bds_material_plant_hdr.prd_fixed is 'Fixed periods - lads_mat_mrc.fimon';
comment on column bds_material_plant_hdr.basic_value is 'Basic value - lads_mat_mrc.gwert';
comment on column bds_material_plant_hdr.basic_value_1 is 'Basic value of the 2nd order - lads_mat_mrc.gwer1';
comment on column bds_material_plant_hdr.basic_value_2 is 'Basic value of the 2nd order - lads_mat_mrc.gwer2';
comment on column bds_material_plant_hdr.prev_prd_basic_value is 'Basic value of previous period - lads_mat_mrc.vmgwe';
comment on column bds_material_plant_hdr.prev_prd_base_value_1 is 'Base value of the second order in previous period - lads_mat_mrc.vmgw1';
comment on column bds_material_plant_hdr.prev_prd_base_value_2 is 'Base value of the second order in previous period - lads_mat_mrc.vmgw2';
comment on column bds_material_plant_hdr.trend_value is 'Trend value - lads_mat_mrc.twert';
comment on column bds_material_plant_hdr.prev_prd_trend_value is 'Trend value of previous period - lads_mat_mrc.vmtwe';
comment on column bds_material_plant_hdr.mad is 'Mean absolute deviation (MAD) - lads_mat_mrc.prmad';
comment on column bds_material_plant_hdr.prev_prd_mad is 'Mean absolute devaition of previous period - lads_mat_mrc.vmmad';
comment on column bds_material_plant_hdr.error_total is 'Error total - lads_mat_mrc.fsumm';
comment on column bds_material_plant_hdr.prev_prd_error_total is 'Error total for the previous period - lads_mat_mrc.vmfsu';
comment on column bds_material_plant_hdr.weighting_grp is 'Weighting group - lads_mat_mrc.gewgr';
comment on column bds_material_plant_hdr.theil_coefficient is 'Theil coefficient - lads_mat_mrc.thkof';
comment on column bds_material_plant_hdr.exception_message_bar is 'Exception message bar - lads_mat_mrc.ausna';
comment on column bds_material_plant_hdr.forecast_flow_cntrl is 'Forecast flow control - lads_mat_mrc.proab';



/**/
/* Synonym
/**/
create or replace public synonym bds_material_plant_hdr for bds.bds_material_plant_hdr;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_plant_hdr to lics_app;
grant select,update,delete,insert on bds_material_plant_hdr to bds_app;
grant select,update,delete,insert on bds_material_plant_hdr to lads_app;
