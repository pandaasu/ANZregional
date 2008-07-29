/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_BOM_HDR
 Owner   : BDS
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Material Bill Of Material (BOMMAT)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table bds_material_bom_hdr
   (sap_bom                            varchar2(8 char)      not null,
    sap_bom_alternative                varchar2(2 char)      not null,
    sap_idoc_name                      varchar2(30 char)     null,
    sap_idoc_number                    number                null,
    sap_idoc_timestamp                 varchar2(14 char)     null,
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
alter table bds_material_bom_hdr
   add constraint bds_material_bom_hdr_pk primary key (sap_bom, sap_bom_alternative);

/**/
/* Indexes
/**/
create index bds_material_bom_hdr_idx1 on bds_material_bom_hdr (parent_material_code, sap_bom_alternative, bom_plant, bom_usage, bom_status, bom_eff_date);

/**/
/* Comments
/**/
comment on table bds_material_bom_hdr is 'Business Data Store - Material Bill Of Material Header (BOMMAT)';
comment on column bds_material_bom_hdr.sap_bom is 'Bill of Material - lads_mat_bom_hdr.stlnr';
comment on column bds_material_bom_hdr.sap_bom_alternative is 'Alternative BOM - lads_mat_bom_hdr.stlal';
comment on column bds_material_bom_hdr.sap_idoc_name is 'IDOC name - lads_mat_bom_hdr.idoc_name';
comment on column bds_material_bom_hdr.sap_idoc_number is 'IDOC number - lads_mat_bom_hdr.idoc_number';
comment on column bds_material_bom_hdr.sap_idoc_timestamp is 'IDOC timestamp - lads_mat_bom_hdr.idoc_timestamp';
comment on column bds_material_bom_hdr.bds_lads_date is 'LADS date loaded - lads_mat_bom_hdr.lads_date';
comment on column bds_material_bom_hdr.bds_lads_status is 'LADS status (1=valid, 2=error, 3=orphan, 4=deleted) - lads_mat_bom_hdr.lads_status';
comment on column bds_material_bom_hdr.bom_plant is 'Plant - lads_mat_bom_hdr.werks';
comment on column bds_material_bom_hdr.bom_usage is 'BOM Usage - lads_mat_bom_hdr.stlan';
comment on column bds_material_bom_hdr.bom_eff_date is 'BOM Valid From Date - lads_mat_bom_hdr.datuv';
comment on column bds_material_bom_hdr.bom_status is 'BOM Status - lads_mat_bom_hdr.stlst';
comment on column bds_material_bom_hdr.parent_material_code is 'Material Number - lads_mat_bom_hdr.matnr';
comment on column bds_material_bom_hdr.parent_base_qty is 'Base Quantity - lads_mat_bom_hdr.bmeng_c';
comment on column bds_material_bom_hdr.parent_base_uom is 'UOM for Base Quantity - lads_mat_bom_hdr.bmein';

/**/
/* Synonym
/**/
create or replace public synonym bds_material_bom_hdr for bds.bds_material_bom_hdr;

/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_bom_hdr to lics_app;
grant select,update,delete,insert on bds_material_bom_hdr to bds_app;
grant select,update,delete,insert on bds_material_bom_hdr to lads_app;
