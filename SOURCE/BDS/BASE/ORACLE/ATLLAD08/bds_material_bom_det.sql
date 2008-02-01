/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_BOM_DET
 Owner   : BDS
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Material Bill Of Material (BOMMAT)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Steve Gregan   Created
 2007/04   Steve Gregan   Added redundant header fields

*******************************************************************************/

/**/
/* Table creation
/**/
create table bds_material_bom_det
   (sap_bom                            varchar2(8 char)      not null,
    sap_bom_alternative                varchar2(2 char)      not null,
    child_material_code                varchar2(18 char)     not null,
    child_item_category                varchar2(1 char)      null,
    child_base_qty                     number                null,
    child_base_uom                     varchar2(3 char)      null,
    bds_lads_date                      date                  null,
    bds_lads_status                    varchar2(2 char)      null,
    bom_plant                          varchar2(5 char)      null,
    bom_usage                          varchar2(1 char)      null,
    bom_eff_date                       date                  null,
    bom_status                         number                null,
    parent_material_code               varchar2(18 char)     null,
    parent_base_qty                    number                null,
    parent_base_uom                    varchar2(3 char)      null);
      
/**/
/* Primary Key Constraint
/**/
alter table bds_material_bom_det
   add constraint bds_material_bom_det_pk primary key (sap_bom, sap_bom_alternative, child_material_code);

/**/
/* Comments
/**/
comment on table bds_material_bom_det is 'Business Data Store - Material Bill Of Material Detail (BOMMAT)';
comment on column bds_material_bom_det.sap_bom is 'Bill of Material - lads_mat_bom_det.stlnr';
comment on column bds_material_bom_det.sap_bom_alternative is 'Alternative BOM - lads_mat_bom_det.stlal';
comment on column bds_material_bom_det.child_item_category is 'Item Category - lads_mat_bom_det.postp';
comment on column bds_material_bom_det.child_material_code is 'Component - lads_mat_bom_det.idnrk';
comment on column bds_material_bom_det.child_base_qty is 'Component Quantity - lads_mat_bom_det.menge_c';
comment on column bds_material_bom_det.child_base_uom is 'Component UOM - lads_mat_bom_det.meins';
comment on column bds_material_bom_det.bds_lads_date is 'LADS date loaded - lads_mat_bom_hdr.lads_date';
comment on column bds_material_bom_det.bds_lads_status is 'LADS status (1=valid, 2=error, 3=orphan, 4=deleted) - lads_mat_bom_hdr.lads_status';
comment on column bds_material_bom_det.bom_plant is 'Plant - lads_mat_bom_hdr.werks';
comment on column bds_material_bom_det.bom_usage is 'BOM Usage - lads_mat_bom_hdr.stlan';
comment on column bds_material_bom_det.bom_eff_date is 'BOM Valid From Date - lads_mat_bom_hdr.datuv';
comment on column bds_material_bom_det.bom_status is 'BOM Status - lads_mat_bom_hdr.stlst';
comment on column bds_material_bom_det.parent_material_code is 'Material Number - lads_mat_bom_hdr.matnr';
comment on column bds_material_bom_det.parent_base_qty is 'Base Quantity - lads_mat_bom_hdr.bmeng_c';
comment on column bds_material_bom_det.parent_base_uom is 'UOM for Base Quantity - lads_mat_bom_hdr.bmein';

/**/
/* Synonym
/**/
create or replace public synonym bds_material_bom_det for bds.bds_material_bom_det;

/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_bom_det to lics_app;
grant select,update,delete,insert on bds_material_bom_det to bds_app;
grant select,update,delete,insert on bds_material_bom_det to lads_app;
