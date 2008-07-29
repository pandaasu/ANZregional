/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_opr_hdr
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_opr_hdr - Open Purachase Order/Requisition Header

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_opr_hdr
   (order_num                                    number                              not null,
    order_item                                   number                              not null,
    target                                       varchar2(10 char)                   null,
    material                                     varchar2(18 char)                   null,
    mrp_element                                  varchar2(2 char)                    null,
    vendor                                       varchar2(10 char)                   null,
    sto_location                                 varchar2(4 char)                    null,
    opr_date                                     number                              null,
    recreq_qty                                   number                              null,
    rec_indicator                                varchar2(1 char)                    null,
    uom                                          varchar2(3 char)                    null,
    mrp_type                                     varchar2(2 char)                    null,
    plant                                        varchar2(4 char)                    null,
    business                                     varchar2(2 char)                    null,
    doc_type                                     varchar2(4 char)                    null,
    co_code                                      varchar2(4 char)                    null,
    source_plant                                 varchar2(4 char)                    null,
    issue_sloc                                   varchar2(4 char)                    null,
    ship_date                                    number                              null,
    item_category                                varchar2(1 char)                    null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_opr_hdr is 'Open Purachase Order/Requisition';
comment on column lads_opr_hdr.target is 'MRP area';
comment on column lads_opr_hdr.material is 'Material Number';
comment on column lads_opr_hdr.mrp_element is 'MRP element';
comment on column lads_opr_hdr.vendor is 'Account Number of Vendor or Creditor';
comment on column lads_opr_hdr.sto_location is 'Storage Location';
comment on column lads_opr_hdr.opr_date is 'Delivery/order finish date';
comment on column lads_opr_hdr.recreq_qty is 'Quantity received or quantity required';
comment on column lads_opr_hdr.rec_indicator is 'Receipt/issue indicator';
comment on column lads_opr_hdr.uom is 'Base Unit of Measure';
comment on column lads_opr_hdr.order_num is 'Purchasing Document Number';
comment on column lads_opr_hdr.order_item is 'Item Number of Purchasing Document';
comment on column lads_opr_hdr.mrp_type is 'MRP Type';
comment on column lads_opr_hdr.plant is 'Plant';
comment on column lads_opr_hdr.business is 'Business Segment';
comment on column lads_opr_hdr.doc_type is 'Order type (Purchasing)';
comment on column lads_opr_hdr.co_code is 'Company Code';
comment on column lads_opr_hdr.source_plant is 'Planning Plant';
comment on column lads_opr_hdr.issue_sloc is 'Issuing/Receiving Storage Location';
comment on column lads_opr_hdr.ship_date is 'Goods issue date';
comment on column lads_opr_hdr.item_category is 'Item category in purchasing document';
comment on column lads_opr_hdr.idoc_name is 'IDOC name';
comment on column lads_opr_hdr.idoc_number is 'IDOC number';
comment on column lads_opr_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_opr_hdr.lads_date is 'LADS date loaded';
comment on column lads_opr_hdr.lads_status is 'LADS status (1=valid, 2=error)';

/**/
/* Primary Key Constraint
/**/
alter table lads_opr_hdr
   add constraint lads_opr_hdr_pk primary key (order_num,order_item);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_opr_hdr to lads_app;
grant select, insert, update, delete on lads_opr_hdr to ics_app;
grant select on lads_opr_hdr to ics_reader with grant option;
grant select on lads_opr_hdr to ics_executor;
grant select on lads_opr_hdr to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_opr_hdr for lads.lads_opr_hdr;
