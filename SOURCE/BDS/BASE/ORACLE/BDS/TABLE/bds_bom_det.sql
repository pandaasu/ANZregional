/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_BOM_DET
 Owner   : BDS
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Bill Of Material (LOIBOM01)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created
 2007/04   Steve Gregan   Added redundant header fields

*******************************************************************************/

/**/
/* Table creation
/**/
create table bds_bom_det
   (bom_material_code                  varchar2(18 char)     not null,
    bom_alternative                    varchar2(2 char)      not null,
    bom_plant                          varchar2(4 char)      not null,
    item_sequence                      number                not null,
    item_number                        varchar2(4 char)      null,
    item_msg_function                  varchar2(3 char)      null,
    item_material_code                 varchar2(18 char)     null,
    item_category                      varchar2(1 char)      null,
    item_base_qty                      number                null,
    item_base_uom                      varchar2(3 char)      null,
    item_eff_from_date                 date                  null,
    item_eff_to_date                   date                  null,
    bds_lads_date                      date                  null,
    bds_lads_status                    varchar2(2 char)      null,
    bom_number                         varchar2(8 char)      null,
    bom_msg_function                   varchar2(3 char)      null,
    bom_usage                          varchar2(1 char)      null,
    bom_eff_from_date                  date                  null,
    bom_eff_to_date                    date                  null,
    bom_base_qty                       number                null,
    bom_base_uom                       varchar2(3 char)      null,
    bom_status                         varchar2(2 char)      null);
   
/**/
/* Primary Key Constraint
/**/
alter table bds_bom_det
   add constraint bds_bom_det_pk primary key (bom_material_code, bom_alternative, bom_plant, item_sequence);

/**/
/* Comments
/**/
comment on table bds_bom_det is 'Business Data Store - Bill Of Material Detail (LOIBOM01)';
comment on column bds_bom_det.bom_material_code is 'Material Number - lads_bom_det.matnr';
comment on column bds_bom_det.bom_alternative is 'Alternative BOM - lads_bom_det.stlal';
comment on column bds_bom_det.bom_plant is 'Plant - lads_bom_det.werks';
comment on column bds_bom_det.item_sequence is 'Item Sequence - lads_bom_det.detseq';
comment on column bds_bom_det.item_number is 'Item Number - lads_bom_det.posnr';
comment on column bds_bom_det.item_msg_function is 'Item Message Function - lads_bom_det.msgfn';
comment on column bds_bom_det.item_material_code is 'Component - lads_bom_det.idnrk';
comment on column bds_bom_det.item_category is 'Item Category - lads_bom_det.postp';
comment on column bds_bom_det.item_base_qty is 'Component Quantity - lads_bom_det.menge';
comment on column bds_bom_det.item_base_uom is 'Component UOM - lads_bom_det.meins';
comment on column bds_bom_det.item_eff_from_date is 'Component Valid From Date - lads_bom_det.datuv';
comment on column bds_bom_det.item_eff_to_date is 'Component Valid To Date - lads_bom_det.datub';
comment on column bds_bom_det.bds_lads_date is 'LADS date loaded - lads_bom_hdr.lads_date';
comment on column bds_bom_det.bds_lads_status is 'LADS status (1=valid, 2=error, 3=orphan) - lads_bom_hdr.lads_status';
comment on column bds_bom_det.bom_number is 'Bill of Material - lads_bom_hdr.stlnr';
comment on column bds_bom_det.bom_msg_function is 'BOM Message Function - lads_bom_hdr.msgfn';
comment on column bds_bom_det.bom_usage is 'BOM Usage - lads_bom_hdr.stlan';
comment on column bds_bom_det.bom_eff_from_date is 'BOM Valid From Date - lads_bom_hdr.datuv';
comment on column bds_bom_det.bom_eff_to_date is 'BOM Valid To Date - lads_bom_hdr.datub';
comment on column bds_bom_det.bom_base_qty is 'Base Quantity - lads_bom_hdr.bmeng';
comment on column bds_bom_det.bom_base_uom is 'UOM for Base Quantity - lads_bom_hdr.bmein';
comment on column bds_bom_det.bom_status is 'BOM status - lads_bom_hdr.stlst';

/**/
/* Synonym
/**/
create or replace public synonym bds_bom_det for bds.bds_bom_det;

/**/
/* Authority
/**/
grant select,update,delete,insert on bds_bom_det to lics_app;
grant select,update,delete,insert on bds_bom_det to bds_app;
grant select,update,delete,insert on bds_bom_det to lads_app;
