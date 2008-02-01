/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_PLANT_VRSN
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Production vrsn (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_plant_vrsn
   (sap_material_code               varchar2(18 char)     not null, 
    plant_code                      varchar2(4 char)      not null, 
    prdctn_vrsn                     varchar2(4 char)      not null, 
    sap_function                    varchar2(3 char)      null, 
    runtime_end                     date                  null, 
    prdctn_vrsn_valid_date          date                  null, 
    alternative_bom                 varchar2(2 char)      null, 
    bom_usage                       varchar2(1 char)      null, 
    task_list_type                  varchar2(1 char)      null, 
    task_list_grp_key               varchar2(8 char)      null, 
    grp_counter                     varchar2(2 char)      null, 
    procurement_type                varchar2(1 char)      null, 
    special_procurement_type        varchar2(2 char)      null, 
    prdct_costing_lot_size          number                null, 
    aggregation_field_1             varchar2(8 char)      null, 
    aggregation_field_2             varchar2(8 char)      null, 
    short_text                      varchar2(40 char)     null, 
    vrsn_cntrl_usage_probability    number                null, 
    qty_produced_dstrbtn_key        varchar2(4 char)      null, 
    repetitive_manu_allowed_indctr  varchar2(1 char)      null, 
    lot_size_lower_value_interval   number                null, 
    lot_size_upper_value_interval   number                null, 
    rs_header_backflush_indctr      varchar2(1 char)      null, 
    repetitive_manu_receive_storg   varchar2(4 char)      null, 
    task_list_type_1                varchar2(1 char)      null, 
    task_list_grp_key_1             varchar2(8 char)      null, 
    grp_counter_1                   varchar2(2 char)      null, 
    task_list_type_2                varchar2(1 char)      null, 
    task_list_grp_key_2             varchar2(8 char)      null, 
    grp_counter_2                   varchar2(2 char)      null, 
    apportionment_structure         varchar2(4 char)      null, 
    similar_bom_tasklist_material   varchar2(18 char)     null, 
    issue_storg_location            varchar2(4 char)      null, 
    default_supply_area             varchar2(10 char)     null, 
    long_material_code              varchar2(40 char)     null, 
    vrsn_number                     varchar2(10 char)     null, 
    external_guid                   varchar2(32 char)     null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_plant_vrsn
   add constraint bds_material_plant_vrsn_pk primary key (sap_material_code, plant_code, prdctn_vrsn);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_material_plant_vrsn is 'Business Data Store - Material Production vrsn (MATMAS)';
comment on column bds_material_plant_vrsn.sap_material_code is 'Material Number - lads_mat_mpv.matnr';
comment on column bds_material_plant_vrsn.plant_code is 'Plant - lads_mat_mrc.werks';
comment on column bds_material_plant_vrsn.prdctn_vrsn is 'Production vrsn - lads_mat_mpv.verid';
comment on column bds_material_plant_vrsn.sap_function is 'Function - lads_mat_mpv.msgfn';
comment on column bds_material_plant_vrsn.runtime_end is 'Run-time end: production vrsn - lads_mat_mpv.bdatu';
comment on column bds_material_plant_vrsn.prdctn_vrsn_valid_date is 'Valid-from date of production vrsn - lads_mat_mpv.adatu';
comment on column bds_material_plant_vrsn.alternative_bom is 'Alternative BOM - lads_mat_mpv.stlal';
comment on column bds_material_plant_vrsn.bom_usage is 'BOM Usage - lads_mat_mpv.stlan';
comment on column bds_material_plant_vrsn.task_list_type is 'Task List Type - lads_mat_mpv.plnty';
comment on column bds_material_plant_vrsn.task_list_grp_key is 'Key for Task List Group - lads_mat_mpv.plnnr';
comment on column bds_material_plant_vrsn.grp_counter is 'Group Counter - lads_mat_mpv.alnal';
comment on column bds_material_plant_vrsn.procurement_type is 'Procurement Type - lads_mat_mpv.beskz';
comment on column bds_material_plant_vrsn.special_procurement_type is 'Special procurement type - lads_mat_mpv.sobsl';
comment on column bds_material_plant_vrsn.prdct_costing_lot_size is 'Lot Size for Product Costing - lads_mat_mpv.losgr';
comment on column bds_material_plant_vrsn.aggregation_field_1 is 'Aggregation field for production vrsns - lads_mat_mpv.mdv01';
comment on column bds_material_plant_vrsn.aggregation_field_2 is 'Aggregation field for production vrsns - lads_mat_mpv.mdv02';
comment on column bds_material_plant_vrsn.short_text is 'Short text on the production vrsn - lads_mat_mpv.text1';
comment on column bds_material_plant_vrsn.vrsn_cntrl_usage_probability is 'Usage Probability with vrsn Control - lads_mat_mpv.ewahr';
comment on column bds_material_plant_vrsn.qty_produced_dstrbtn_key is 'Distribution key for quantity produced - lads_mat_mpv.verto';
comment on column bds_material_plant_vrsn.repetitive_manu_allowed_indctr is 'Repetitive manufacturing allowed for vrsn - lads_mat_mpv.serkz';
comment on column bds_material_plant_vrsn.lot_size_lower_value_interval is 'Lower value of the lot-size interval - lads_mat_mpv.bstmi';
comment on column bds_material_plant_vrsn.lot_size_upper_value_interval is 'Upper value of the lot-size interval - lads_mat_mpv.bstma';
comment on column bds_material_plant_vrsn.rs_header_backflush_indctr is 'Indicator: backflush for RS header - lads_mat_mpv.rgekz';
comment on column bds_material_plant_vrsn.repetitive_manu_receive_storg is 'Receiving storage location for repetitive manufacturing - lads_mat_mpv.alort';
comment on column bds_material_plant_vrsn.task_list_type_1 is 'Task List Type - lads_mat_mpv.pltyg';
comment on column bds_material_plant_vrsn.task_list_grp_key_1 is 'Key for Task List Group - lads_mat_mpv.plnng';
comment on column bds_material_plant_vrsn.grp_counter_1 is 'Group Counter - lads_mat_mpv.alnag';
comment on column bds_material_plant_vrsn.task_list_type_2 is 'Task List Type - lads_mat_mpv.pltym';
comment on column bds_material_plant_vrsn.task_list_grp_key_2 is 'Key for Task List Group - lads_mat_mpv.plnnm';
comment on column bds_material_plant_vrsn.grp_counter_2 is 'Group Counter - lads_mat_mpv.alnam';
comment on column bds_material_plant_vrsn.apportionment_structure is 'Apportionment Structure - lads_mat_mpv.csplt';
comment on column bds_material_plant_vrsn.similar_bom_tasklist_material is 'Other material for which BOM and task list are maintained - lads_mat_mpv.matko';
comment on column bds_material_plant_vrsn.issue_storg_location is 'Proposed issue storage location for components - lads_mat_mpv.elpro';
comment on column bds_material_plant_vrsn.default_supply_area is 'Default supply area for components - lads_mat_mpv.prvbe';
comment on column bds_material_plant_vrsn.long_material_code is 'Long material number (future development) for field MATKO - lads_mat_mpv.matko_external';
comment on column bds_material_plant_vrsn.vrsn_number is 'Version number (future development) for field MATKO - lads_mat_mpv.matko_vrsn';
comment on column bds_material_plant_vrsn.external_guid is 'External GUID (future development) for field MATKO - lads_mat_mpv.matko_guid';


/**/
/* Synonym
/**/
create or replace public synonym bds_material_plant_vrsn for bds.bds_material_plant_vrsn;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_plant_vrsn to lics_app;
grant select,update,delete,insert on bds_material_plant_vrsn to bds_app;
grant select,update,delete,insert on bds_material_plant_vrsn to lads_app;
