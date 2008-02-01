/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_BOM_HDR
 Owner   : BDS
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Bill Of Material (LOIBOM01)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table bds_bom_hdr
   (bom_material_code                  varchar2(18 char)     not null,
    bom_alternative                    varchar2(2 char)      not null,
    bom_plant                          varchar2(4 char)      not null,
    sap_idoc_name                      varchar2(30 char)     null,
    sap_idoc_number                    number                null,
    sap_idoc_timestamp                 varchar2(14 char)     null,
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
alter table bds_bom_hdr
   add constraint bds_bom_hdr_pk primary key (bom_material_code, bom_alternative, bom_plant);

/**/
/* Comments
/**/
comment on table bds_bom_hdr is 'Business Data Store - Bill Of Material Header (LOIBOM01)';
comment on column bds_bom_hdr.bom_material_code is 'Material Number - lads_bom_hdr.matnr';
comment on column bds_bom_hdr.bom_alternative is 'Alternative BOM - lads_bom_hdr.stlal';
comment on column bds_bom_hdr.bom_plant is 'Plant - lads_bom_hdr.werks';
comment on column bds_bom_hdr.sap_idoc_name is 'IDOC name - lads_bom_hdr.idoc_name';
comment on column bds_bom_hdr.sap_idoc_number is 'IDOC number - lads_bom_hdr.idoc_number';
comment on column bds_bom_hdr.sap_idoc_timestamp is 'IDOC timestamp - lads_bom_hdr.idoc_timestamp';
comment on column bds_bom_hdr.bds_lads_date is 'LADS date loaded - lads_bom_hdr.lads_date';
comment on column bds_bom_hdr.bds_lads_status is 'LADS status (1=valid, 2=error, 3=orphan) - lads_bom_hdr.lads_status';
comment on column bds_bom_hdr.bom_number is 'Bill of Material - lads_bom_hdr.stlnr';
comment on column bds_bom_hdr.bom_msg_function is 'BOM Message Function - lads_bom_hdr.msgfn';
comment on column bds_bom_hdr.bom_usage is 'BOM Usage - lads_bom_hdr.stlan';
comment on column bds_bom_hdr.bom_eff_from_date is 'BOM Valid From Date - lads_bom_hdr.datuv';
comment on column bds_bom_hdr.bom_eff_to_date is 'BOM Valid To Date - lads_bom_hdr.datub';
comment on column bds_bom_hdr.bom_base_qty is 'Base Quantity - lads_bom_hdr.bmeng';
comment on column bds_bom_hdr.bom_base_uom is 'UOM for Base Quantity - lads_bom_hdr.bmein';
comment on column bds_bom_hdr.bom_status is 'BOM status - lads_bom_hdr.stlst';

/**/
/* Synonym
/**/
create or replace public synonym bds_bom_hdr for bds.bds_bom_hdr;

/**/
/* Authority
/**/
grant select,update,delete,insert on bds_bom_hdr to lics_app;
grant select,update,delete,insert on bds_bom_hdr to bds_app;
grant select,update,delete,insert on bds_bom_hdr to lads_app;
