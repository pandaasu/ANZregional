/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_stock_header
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Stock Balance Header

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_stock_header
   (company_code                       varchar2(3 char)         not null,
    plant_code                         varchar2(4 char)         not null,
    storage_location_code              varchar2(4 char)         not null,
    stock_balance_date                 varchar2(8 char)         not null,
    stock_balance_time                 varchar2(8 char)         not null,
    sap_idoc_name                      varchar2(30 char)        null,
    sap_idoc_number                    number(16,0)             null,
    sap_idoc_timestamp                 varchar2(14 char)        null,
    bds_lads_date                      date                     null,
    bds_lads_status                    varchar2(2 char)         null,
    create_date                        varchar2(8 char)         null,
    create_time                        varchar2(6 char)         null,
    company_identifier                 varchar2(6 char)         null,
    inventory_document                 varchar2(10 char)        null);

/*-*/
/* Comments
/*-*/
comment on table bds_stock_header is 'Business Data Store - Stock Balance Header';
comment on column bds_stock_header.company_code is 'Company Code - lads_stk_bal_hdr.bukrs';
comment on column bds_stock_header.plant_code is 'Plant - lads_stk_bal_hdr.werks';
comment on column bds_stock_header.storage_location_code is 'Storage Location. Intransit and Consignment does not have a storage location. - lads_stk_bal_hdr.lgort';
comment on column bds_stock_header.stock_balance_date is 'Date of stock balance - lads_stk_bal_hdr.budat';
comment on column bds_stock_header.stock_balance_time is 'Stock balance Time - lads_stk_bal_hdr.timlo';
comment on column bds_stock_header.sap_idoc_name is 'IDOC name - lads_stk_bal_hdr.idoc_name';
comment on column bds_stock_header.sap_idoc_number is 'IDOC number - lads_stk_bal_hdr.idoc_number';
comment on column bds_stock_header.sap_idoc_timestamp is 'IDOC timestamp - lads_stk_bal_hdr.idoc_timestamp';
comment on column bds_stock_header.bds_lads_date is 'LADS date loaded - lads_stk_bal_hdr.lads_date';
comment on column bds_stock_header.bds_lads_status is 'LADS status (1=valid, 2=error, 3=orphan) - lads_stk_bal_hdr.lads_status';
comment on column bds_stock_header.create_date is 'Idoc Creation Date - lads_stk_bal_hdr.credat';
comment on column bds_stock_header.create_time is 'Idoc Creation Time - lads_stk_bal_hdr.cretim';
comment on column bds_stock_header.company_identifier is 'Company ID - lads_stk_bal_hdr.vbund';
comment on column bds_stock_header.inventory_document is 'Physical Inventory Document - lads_stk_bal_hdr.mblnr';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_stock_header
   add constraint bds_stock_header_pk primary key (company_code, plant_code, storage_location_code, stock_balance_date, stock_balance_time);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_stock_header to lics_app;
grant select, insert, update, delete on bds_stock_header to lads_app;
grant select, insert, update, delete on bds_stock_header to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_stock_header for bds.bds_stock_header;