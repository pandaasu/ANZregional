/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_REFRNC_PLANT
 Owner   : BDS
 Author  : Linden Glen

 taxription
 -----------
 Business Data Store - Reference Data - Plant (ZDISTR)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_refrnc_plant
   (plant_code                        varchar2(4 char)      not null, 
    sap_idoc_number                   number                null, 
    sap_idoc_timestamp                varchar2(14 char)     null, 
    change_flag                       varchar2(1 char)      null, 
    plant_name                        varchar2(30 char)     null, 
    vltn_area                         varchar2(4 char)      null, 
    plant_customer_no                 varchar2(10 char)     null, 
    plant_vendor_no                   varchar2(10 char)     null, 
    factory_calendar_key              varchar2(2 char)      null, 
    plant_name_2                      varchar2(30 char)     null, 
    plant_street                      varchar2(30 char)     null, 
    plant_po_box                      varchar2(10 char)     null, 
    plant_post_code                   varchar2(10 char)     null, 
    plant_city                        varchar2(25 char)     null, 
    plant_purchasing_organisation     varchar2(4 char)      null, 
    plant_sales_organisation          varchar2(4 char)      null, 
    batch_manage_indctr               varchar2(1 char)      null, 
    plant_condition_indctr            varchar2(1 char)      null, 
    source_list_indctr                varchar2(1 char)      null, 
    activate_reqrmnt_indctr           varchar2(1 char)      null, 
    plant_country_key                 varchar2(3 char)      null, 
    plant_region                      varchar2(3 char)      null, 
    plant_country_code                varchar2(3 char)      null, 
    plant_city_code                   varchar2(4 char)      null, 
    plant_address                     varchar2(10 char)     null, 
    maint_planning_plant              varchar2(4 char)      null, 
    tax_jurisdiction_code             varchar2(15 char)     null, 
    dstrbtn_channel                   varchar2(2 char)      null, 
    division                          varchar2(2 char)      null, 
    language_key                      varchar2(1 char)      null, 
    sop_plant                         varchar2(1 char)      null, 
    variance_key                      varchar2(6 char)      null, 
    batch_manage_old_indctr           varchar2(1 char)      null, 
    plant_ctgry                       varchar2(1 char)      null, 
    plant_sales_district              varchar2(6 char)      null, 
    plant_supply_region               varchar2(10 char)     null, 
    plant_tax_indctr                  varchar2(1 char)      null, 
    regular_vendor_indctr             varchar2(1 char)      null, 
    first_reminder_days               varchar2(3 char)      null, 
    second_reminder_days              varchar2(3 char)      null, 
    third_reminder_days               varchar2(3 char)      null, 
    vendor_declaration_text_1         varchar2(16 char)     null, 
    vendor_declaration_text_2         varchar2(16 char)     null, 
    vendor_declaration_text_3         varchar2(16 char)     null, 
    po_tolerance_days                 varchar2(3 char)      null, 
    plant_business_place              varchar2(4 char)      null, 
    stock_xfer_rule                   varchar2(2 char)      null, 
    plant_dstrbtn_profile             varchar2(3 char)      null, 
    central_archive_marker            varchar2(1 char)      null, 
    dms_type_indctr                   varchar2(1 char)      null, 
    node_type                         varchar2(3 char)      null, 
    name_formation_structure          varchar2(4 char)      null, 
    cost_control_active_indctr        varchar2(1 char)      null, 
    mixed_costing_active_indctr       varchar2(1 char)      null, 
    actual_costing_active_indctr      varchar2(1 char)      null, 
    transport_point                   varchar2(4 char)      null);

    
/**/
/* Primary Key Constraint
/**/
alter table bds_refrnc_plant
   add constraint bds_refrnc_plant_pk primary key (plant_code);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_refrnc_plant is 'Business Data Store - Reference Data - Plants (ZDISTR - T001W)';
comment on column bds_refrnc_plant.plant_code is 'Plant - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.plant_name is 'Name - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.vltn_area is 'Valuation area - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.plant_customer_no is 'Customer number of plant - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.plant_vendor_no is 'Vendor number of plant - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.factory_calendar_key is 'Factory calendar key - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.plant_name_2 is 'Name 2 - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.plant_street is 'House number and street - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.plant_po_box is 'PO Box - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.plant_post_code is 'Postal Code - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.plant_city is 'City - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.plant_purchasing_organisation is 'Purchasing Organization - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.plant_sales_organisation is 'Sales organization for intercompany billing - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.batch_manage_indctr is 'Indicator: batch status management active - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.plant_condition_indctr is 'Indicator: Conditions at plant level - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.source_list_indctr is 'Indicator: Source list requirement - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.activate_reqrmnt_indctr is 'Activating requirements planning - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.plant_country_key is 'Country Key - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.plant_region is 'Region (State, Province, County) - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.plant_country_code is 'County Code - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.plant_city_code is 'City Code - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.plant_address is 'Address - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.maint_planning_plant is 'Maintenance Planning Plant - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.tax_jurisdiction_code is 'Jurisdiction for Tax Calculation - Tax Jurisdiction Code - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.dstrbtn_channel is 'Distribution channel for intercompany billing - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.division is 'Division for intercompany billing - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.language_key is 'Language Key - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.sop_plant is 'SOP plant - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.variance_key is 'Variance Key - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.batch_manage_old_indctr is 'Indicator: batch status management active - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.plant_ctgry is 'Plant category - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.plant_sales_district is 'Sales district - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.plant_supply_region is 'Supply region (region supplied) - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.plant_tax_indctr is 'Tax indicator: Plant (Purchasing) - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.regular_vendor_indctr is 'Take regular vendor into account - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.first_reminder_days is 'Number of days for first reminder/urging letter (expediter) - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.second_reminder_days is 'Number of days for second reminder/urging letter (expediter) - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.third_reminder_days is 'Number of days for third reminder/urging letter (expediter) - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.vendor_declaration_text_1 is 'Text name of 1st dunning of vendor declarations - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.vendor_declaration_text_2 is 'Text name of the 2nd dunning of vendor declarations - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.vendor_declaration_text_3 is 'Text name of 3rd dunning of vendor declarations - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.po_tolerance_days is 'Number of days for PO tolerance - Compress info records - SU - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.plant_business_place is 'Business Place - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.stock_xfer_rule is 'Rule for determining the sales area for stock transfers - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.plant_dstrbtn_profile is 'Distribution profile at plant level - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.central_archive_marker is 'Central archiving marker for master record - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.dms_type_indctr is 'Batch Record: Type of DMS Used - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.node_type is 'Node type: supply chain network - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.name_formation_structure is 'Structure for name formation - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.cost_control_active_indctr is 'Cost Object Controlling linking active - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.mixed_costing_active_indctr is 'Updating is active for mixed costing - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.actual_costing_active_indctr is 'Updating is active in actual costing - LADS_REF_DAT - T001W';
comment on column bds_refrnc_plant.transport_point is 'Shipping Point/Receiving Point - LADS_REF_DAT - T001W';


/**/
/* Synonym
/**/
create or replace public synonym bds_refrnc_plant for bds.bds_refrnc_plant;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_refrnc_plant to lics_app;
grant select,update,delete,insert on bds_refrnc_plant to bds_app;
grant select,update,delete,insert on bds_refrnc_plant to lads_app;
