/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_addr_header
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Address Header

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_addr_header
   (address_type                       varchar2(10 char)        not null,
    address_code                       varchar2(70 char)        not null,
    address_context                    number                   not null,
    sap_idoc_name                      varchar2(30 char)        null,
    sap_idoc_number                    number(16,0)             null,
    sap_idoc_timestamp                 varchar2(14 char)        null,
    bds_lads_date                      date                     null,
    bds_lads_status                    varchar2(2 char)         null,
    address_key                        varchar2(70 char)        null);

/*-*/
/* Comments
/*-*/
comment on table bds_addr_header is 'Business Data Store - Address Header';
comment on column bds_addr_header.address_type is 'Address owner object type - lads_adr_hdr.obj_type';
comment on column bds_addr_header.address_code is 'Address owner object code - lads_adr_hdr.obj_id';
comment on column bds_addr_header.address_context is 'Semantic description of an object address - lads_adr_hdr.context';
comment on column bds_addr_header.sap_idoc_name is 'IDOC name - lads_adr_hdr.idoc_name';
comment on column bds_addr_header.sap_idoc_number is 'IDOC number - lads_adr_hdr.idoc_number';
comment on column bds_addr_header.sap_idoc_timestamp is 'IDOC timestamp - lads_adr_hdr.idoc_timestamp';
comment on column bds_addr_header.bds_lads_date is 'LADS date loaded - lads_adr_hdr.lads_date';
comment on column bds_addr_header.bds_lads_status is 'LADS status (1=valid, 2=error, 3=orphan) - lads_adr_hdr.lads_status';
comment on column bds_addr_header.address_key is 'Object Key - lads_adr_hdr.obj_id_ext';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_addr_header
   add constraint bds_addr_header_pk primary key (address_type, address_code, address_context);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_addr_header to lics_app;
grant select, insert, update, delete on bds_addr_header to lads_app;
grant select, insert, update, delete on bds_addr_header to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_addr_header for bds.bds_addr_header;