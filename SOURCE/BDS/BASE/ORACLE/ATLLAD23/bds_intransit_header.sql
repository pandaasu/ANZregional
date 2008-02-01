/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_intransit_header
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Intransit Stock Header

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_intransit_header
   (plant_code                         varchar2(4 char)         not null,
    sap_idoc_name                      varchar2(30 char)        null,
    sap_idoc_number                    number(16,0)             null,
    sap_idoc_timestamp                 varchar2(14 char)        null,
    bds_lads_date                      date                     null,
    bds_lads_status                    varchar2(2 char)         null,
    target_planning_area               varchar2(10 char)        null);

/*-*/
/* Comments
/*-*/
comment on table bds_intransit_header is 'Business Data Store - Intransit Stock Header';
comment on column bds_intransit_header.plant_code is 'Plant - lads_int_stk_hdr.werks';
comment on column bds_intransit_header.sap_idoc_name is 'IDOC name - lads_int_stk_hdr.idoc_name';
comment on column bds_intransit_header.sap_idoc_number is 'IDOC number - lads_int_stk_hdr.idoc_number';
comment on column bds_intransit_header.sap_idoc_timestamp is 'IDOC timestamp - lads_int_stk_hdr.idoc_timestamp';
comment on column bds_intransit_header.bds_lads_date is 'LADS date loaded - lads_int_stk_hdr.lads_date';
comment on column bds_intransit_header.bds_lads_status is 'LADS status (1=valid, 2=error, 3=orphan) - lads_int_stk_hdr.lads_status';
comment on column bds_intransit_header.target_planning_area is 'Target Planning Area - lads_int_stk_hdr.berid';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_intransit_header
   add constraint bds_intransit_header_pk primary key (plant_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_intransit_header to lics_app;
grant select, insert, update, delete on bds_intransit_header to lads_app;
grant select, insert, update, delete on bds_intransit_header to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_intransit_header for bds.bds_intransit_header;