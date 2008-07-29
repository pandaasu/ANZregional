/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_addr_comment
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Address Comment

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_addr_comment
   (address_type                       varchar2(10 char)        not null,
    address_code                       varchar2(70 char)        not null,
    address_context                    number                   not null,
    address_version                    varchar2(5 char)         not null,
    address_language                   varchar2(5 char)         not null,
    address_language_iso               varchar2(2 char)         null,
    address_notes                      varchar2(50 char)        null,
    error_flag                         varchar2(1 char)         null);

/*-*/
/* Comments
/*-*/
comment on table bds_addr_comment is 'Business Data Store - Address Comment';
comment on column bds_addr_comment.address_type is 'Address owner object type - lads_adr_com.obj_type';
comment on column bds_addr_comment.address_code is 'Address owner object code - lads_adr_com.obj_id';
comment on column bds_addr_comment.address_context is 'Semantic description of an object address - lads_adr_com.context';
comment on column bds_addr_comment.address_version is 'International address version ID - lads_adr_com.addr_vers';
comment on column bds_addr_comment.address_language is 'Language Key - lads_adr_com.langu';
comment on column bds_addr_comment.address_language_iso is 'Language according to ISO 639 - lads_adr_com.langu_iso';
comment on column bds_addr_comment.address_notes is 'Address notes - lads_adr_com.adr_notes';
comment on column bds_addr_comment.error_flag is 'Flag: Record not processed - lads_adr_com.errorflag';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_addr_comment
   add constraint bds_addr_comment_pk primary key (address_type, address_code, address_context, address_version, address_language);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_addr_comment to lics_app;
grant select, insert, update, delete on bds_addr_comment to lads_app;
grant select, insert, update, delete on bds_addr_comment to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_addr_comment for bds.bds_addr_comment;