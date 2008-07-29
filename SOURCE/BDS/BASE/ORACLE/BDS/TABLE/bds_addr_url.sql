/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_addr_url
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Address URL

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_addr_url
   (address_type                       varchar2(10 char)        not null,
    address_code                       varchar2(70 char)        not null,
    address_context                    number                   not null,
    address_sequence                   number                   not null,
    standard_sender_flag               varchar2(1 char)         null,
    uri_type                           varchar2(3 char)         null,
    uri                                varchar2(132 char)       null,
    standard_receiver_flag             varchar2(1 char)         null,
    home_flag                          varchar2(1 char)         null,
    sequence_number                    number                   null,
    uri_part_01                        varchar2(250 char)       null,
    uri_part_02                        varchar2(250 char)       null,
    uri_part_03                        varchar2(250 char)       null,
    uri_part_04                        varchar2(250 char)       null,
    uri_part_05                        varchar2(250 char)       null,
    uri_part_06                        varchar2(250 char)       null,
    uri_part_07                        varchar2(250 char)       null,
    uri_part_08                        varchar2(250 char)       null,
    uri_part_09                        varchar2(48 char)        null,
    error_flag                         varchar2(1 char)         null,
    not_used_flag                      varchar2(1 char)         null);

/*-*/
/* Comments
/*-*/
comment on table bds_addr_url is 'Business Data Store - Address URL';
comment on column bds_addr_url.address_type is 'Address owner object type - lads_adr_url.obj_type';
comment on column bds_addr_url.address_code is 'Address owner object ID - lads_adr_url.obj_id';
comment on column bds_addr_url.address_context is 'Semantic description of an object address - lads_adr_url.context';
comment on column bds_addr_url.address_sequence is 'URL - generated sequence number - lads_adr_url.urlseq';
comment on column bds_addr_url.standard_sender_flag is 'Standard Sender Address in this Communication Type - lads_adr_url.std_no';
comment on column bds_addr_url.uri_type is 'URI type flag - lads_adr_url.uri_type';
comment on column bds_addr_url.uri is '''URI, e.g. Homepage or ftp Address'' - lads_adr_url.uri';
comment on column bds_addr_url.standard_receiver_flag is 'Flag: Recipient is standard recipient for this number - lads_adr_url.std_recip';
comment on column bds_addr_url.home_flag is 'Recipient address in this communication type (mail sys.grp) - lads_adr_url.home_flag';
comment on column bds_addr_url.sequence_number is 'Sequence number - lads_adr_url.consnumber';
comment on column bds_addr_url.uri_part_01 is 'Universal Resource Identifier (URI): Parts 1-8 - lads_adr_url.uri_part1';
comment on column bds_addr_url.uri_part_02 is 'Universal Resource Identifier (URI): Parts 1-8 - lads_adr_url.uri_part2';
comment on column bds_addr_url.uri_part_03 is 'Universal Resource Identifier (URI): Parts 1-8 - lads_adr_url.uri_part3';
comment on column bds_addr_url.uri_part_04 is 'Universal Resource Identifier (URI): Parts 1-8 - lads_adr_url.uri_part4';
comment on column bds_addr_url.uri_part_05 is 'Universal Resource Identifier (URI): Parts 1-8 - lads_adr_url.uri_part5';
comment on column bds_addr_url.uri_part_06 is 'Universal Resource Identifier (URI): Parts 1-8 - lads_adr_url.uri_part6';
comment on column bds_addr_url.uri_part_07 is 'Universal Resource Identifier (URI): Parts 1-8 - lads_adr_url.uri_part7';
comment on column bds_addr_url.uri_part_08 is 'Universal Resource Identifier (URI): Parts 1-8 - lads_adr_url.uri_part8';
comment on column bds_addr_url.uri_part_09 is 'Universal Resource Identifier (URI) - Part 9 - lads_adr_url.uri_part9';
comment on column bds_addr_url.error_flag is 'Flag: Record not processed - lads_adr_url.errorflag';
comment on column bds_addr_url.not_used_flag is 'Flag: This Communication Number is Not Used - lads_adr_url.flg_nouse';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_addr_url
   add constraint bds_addr_url_pk primary key (address_type, address_code, address_context, address_sequence);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_addr_url to lics_app;
grant select, insert, update, delete on bds_addr_url to lads_app;
grant select, insert, update, delete on bds_addr_url to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_addr_url for bds.bds_addr_url;