a/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_ppo_hdr
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_ppo_hdr - LADS Planned Process Orders

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_ppo_hdr
   (order_id                                     varchar2(12 char)                   not null,
    location                                     varchar2(10 char)                   null,
    coco                                         varchar2(4 char)                    null,
    line                                         varchar2(30 char)                   null,
    item                                         varchar2(18 char)                   null,
    order_profil                                 varchar2(4 char)                    null,
    mrp_area                                     varchar2(8 char)                    null,
    seq_resource                                 varchar2(8 char)                    null,
    start_date_time                              number                              null,
    end_date_time                                number                              null,
    quantity                                     number                              null,
    order_status                                 varchar2(5 char)                    null,
    mp_resource                                  varchar2(10 char)                   null,
    segment                                      varchar2(2 char)                    null,
    achievement                                  number                              null,
    uom                                          varchar2(3 char)                    null,
    mat_type                                     varchar2(4 char)                    null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_ppo_hdr is 'LADS Planned Process Orders';
comment on column lads_ppo_hdr.location is 'Apollo Planning Location';
comment on column lads_ppo_hdr.coco is 'Company Code';
comment on column lads_ppo_hdr.line is '30 Characters';
comment on column lads_ppo_hdr.item is 'Material Number';
comment on column lads_ppo_hdr.order_profil is 'Order type';
comment on column lads_ppo_hdr.mrp_area is 'MRP Area';
comment on column lads_ppo_hdr.seq_resource is 'Not used in this Version of I/F';
comment on column lads_ppo_hdr.start_date_time is 'Start Date & Time';
comment on column lads_ppo_hdr.end_date_time is 'End Date & Time';
comment on column lads_ppo_hdr.quantity is 'Order Quantity';
comment on column lads_ppo_hdr.order_id is 'Order Number';
comment on column lads_ppo_hdr.order_status is 'Status';
comment on column lads_ppo_hdr.mp_resource is 'Master Recipe Group & Counter';
comment on column lads_ppo_hdr.segment is 'Business Segment';
comment on column lads_ppo_hdr.achievement is 'Achievement against Order Qty';
comment on column lads_ppo_hdr.uom is 'Unit of Measure';
comment on column lads_ppo_hdr.mat_type is 'Material Type';
comment on column lads_ppo_hdr.idoc_name is 'IDOC name';
comment on column lads_ppo_hdr.idoc_number is 'IDOC number';
comment on column lads_ppo_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_ppo_hdr.lads_date is 'LADS date loaded';
comment on column lads_ppo_hdr.lads_status is 'LADS status (1=valid, 2=error)';

/**/
/* Primary Key Constraint
/**/
alter table lads_ppo_hdr
   add constraint lads_ppo_hdr_pk primary key (order_id);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_ppo_hdr to lads_app;
grant select, insert, update, delete on lads_ppo_hdr to ics_app;
grant select on lads_ppo_hdr to ics_reader with grant option;
grant select on lads_ppo_hdr to ics_executor;
grant select on lads_ppo_hdr to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_ppo_hdr for lads.lads_ppo_hdr;
