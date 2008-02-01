/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_PLANT_BATCH
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Plant Warehouse & Batch (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_plant_batch
   (sap_material_code             varchar2(18 char)     not null, 
    plant_code                    varchar2(4 char)      not null, 
    storage_location              varchar2(4 char)      not null, 
    sap_function                  varchar2(3 char)      null, 
    maint_status                  varchar2(15 char)     null, 
    deletion_flag                 varchar2(1 char)      null, 
    mrp_storg_location_indctr     varchar2(1 char)      null, 
    special_procurement_type      varchar2(2 char)      null, 
    mrp_reorder_point             number                null, 
    mrp_replenishment_qty         number                null, 
    origin_country                varchar2(3 char)      null, 
    prfrnc_indctr                 varchar2(1 char)      null, 
    export_indctr                 varchar2(2 char)      null, 
    storg_bin                     varchar2(10 char)     null, 
    profit_center                 varchar2(10 char)     null, 
    pick_area                     varchar2(3 char)      null, 
    invetory_correction_factor    number                null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_plant_batch
   add constraint bds_material_plant_batch_pk primary key (sap_material_code, plant_code, storage_location);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_material_plant_batch is 'Business Data Store - Material Plant Warehouse & Batch (MATMAS)';
comment on column bds_material_plant_batch.sap_material_code is 'Material Number - lads_mat_mrd.matnr';
comment on column bds_material_plant_batch.plant_code is 'Plant - lads_mat_mrc.werks';
comment on column bds_material_plant_batch.storage_location is 'Storage Location - lads_mat_mrd.lgort';
comment on column bds_material_plant_batch.sap_function is 'Function - lads_mat_mrd.msgfn';
comment on column bds_material_plant_batch.maint_status is 'Maintenance status - lads_mat_mrd.pstat';
comment on column bds_material_plant_batch.deletion_flag is 'Flag Material for Deletion at Storage Location Level - lads_mat_mrd.lvorm';
comment on column bds_material_plant_batch.mrp_storg_location_indctr is 'Storage location MRP indicator - lads_mat_mrd.diskz';
comment on column bds_material_plant_batch.special_procurement_type is 'Special procurement type - lads_mat_mrd.lsobs';
comment on column bds_material_plant_batch.mrp_reorder_point is 'Reorder point for storage location MRP - lads_mat_mrd.lminb';
comment on column bds_material_plant_batch.mrp_replenishment_qty is 'Replenishment quantity for storage location MRP - lads_mat_mrd.lbstf';
comment on column bds_material_plant_batch.origin_country is 'Country of origin of the material - lads_mat_mrd.herkl';
comment on column bds_material_plant_batch.prfrnc_indctr is 'Preference indicator (deactivated) - lads_mat_mrd.exppg';
comment on column bds_material_plant_batch.export_indctr is 'Export indicator (deactivated) - lads_mat_mrd.exver';
comment on column bds_material_plant_batch.storg_bin is 'Storage bin - lads_mat_mrd.lgpbe';
comment on column bds_material_plant_batch.profit_center is 'Profit Center - lads_mat_mrd.prctl';
comment on column bds_material_plant_batch.pick_area is 'Picking area for lean WM - lads_mat_mrd.lwmkb';
comment on column bds_material_plant_batch.invetory_correction_factor is 'Inventory correction factor - lads_mat_mrd.bskrf';

/**/
/* Synonym
/**/
create or replace public synonym bds_material_plant_batch for bds.bds_material_plant_batch;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_plant_batch to lics_app;
grant select,update,delete,insert on bds_material_plant_batch to bds_app;
grant select,update,delete,insert on bds_material_plant_batch to lads_app;
