/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : ods
 Table   : sap_bom_data
 Owner   : ods
 Author  : Steve Gregan

 Description
 -----------
 Operational Data Store - Bill Of Material Data
 YYYY/MM   Author         Description
 -------   ------         -----------
 2010/08   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table ods.sap_bom_data
   (bom_material_code                  varchar2(18 char)     not null,
    bom_alternative                    varchar2(2 char)      not null,
    bom_plant                          varchar2(4 char)      not null,
    bom_number                         varchar2(8 char)      null,
    bom_usage                          varchar2(1 char)      null,
    bom_eff_from_date                  date                  null,
    bom_eff_to_date                    date                  null,
    bom_base_qty                       number                null,
    bom_base_uom                       varchar2(3 char)      null,
    bom_status                         varchar2(2 char)      null,
    item_sequence                      number                not null,
    item_number                        varchar2(4 char)      null,
    item_material_code                 varchar2(18 char)     null,
    item_category                      varchar2(1 char)      null,
    item_base_qty                      number                null,
    item_base_uom                      varchar2(3 char)      null,
    item_eff_from_date                 date                  null,
    item_eff_to_date                   date                  null);
   
/**/
/* Comments
/**/
comment on table ods.sap_bom_data is 'Operational Data Store - Bill Of Material Data';
comment on column ods.sap_bom_data.bom_material_code is 'Material Numberr';
comment on column ods.sap_bom_data.bom_alternative is 'Alternative BOM';
comment on column ods.sap_bom_data.bom_plant is 'Plant';
comment on column ods.sap_bom_data.bom_number is 'Bill of Material';
comment on column ods.sap_bom_data.bom_usage is 'BOM Usage';
comment on column ods.sap_bom_data.bom_eff_from_date is 'BOM Valid From Date';
comment on column ods.sap_bom_data.bom_eff_to_date is 'BOM Valid To Date';
comment on column ods.sap_bom_data.bom_base_qty is 'Base Quantity';
comment on column ods.sap_bom_data.bom_base_uom is 'UOM for Base Quantity';
comment on column ods.sap_bom_data.bom_status is 'BOM status';
comment on column ods.sap_bom_data.item_sequence is 'Item Sequence';
comment on column ods.sap_bom_data.item_number is 'Item Number';
comment on column ods.sap_bom_data.item_material_code is 'Component';
comment on column ods.sap_bom_data.item_category is 'Item Category';
comment on column ods.sap_bom_data.item_base_qty is 'Component Quantity';
comment on column ods.sap_bom_data.item_base_uom is 'Component UOM';
comment on column ods.sap_bom_data.item_eff_from_date is 'Component Valid From Date';
comment on column ods.sap_bom_data.item_eff_to_date is 'Component Valid To Date';

/**/
/* Synonym
/**/
create or replace public synonym sap_bom_data for ods.sap_bom_data;

/**/
/* Authority
/**/
grant select,update,delete,insert on ods.sap_bom_data to ods_app;
