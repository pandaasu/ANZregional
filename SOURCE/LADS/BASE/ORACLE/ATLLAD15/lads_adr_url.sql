/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_adr_url
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_adr_url

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_adr_url
   (obj_type                                     varchar2(10 char)                   not null,
    obj_id                                       varchar2(70 char)                   not null,
    context                                      number                              not null,
    urlseq                                       number                              not null,
    std_no                                       varchar2(1 char)                    null,
    uri_type                                     varchar2(3 char)                    null,
    uri                                          varchar2(132 char)                  null,
    std_recip                                    varchar2(1 char)                    null,
    home_flag                                    varchar2(1 char)                    null,
    consnumber                                   number                              null,
    uri_part1                                    varchar2(250 char)                  null,
    uri_part2                                    varchar2(250 char)                  null,
    uri_part3                                    varchar2(250 char)                  null,
    uri_part4                                    varchar2(250 char)                  null,
    uri_part5                                    varchar2(250 char)                  null,
    uri_part6                                    varchar2(250 char)                  null,
    uri_part7                                    varchar2(250 char)                  null,
    uri_part8                                    varchar2(250 char)                  null,
    uri_part9                                    varchar2(48 char)                   null,
    errorflag                                    varchar2(1 char)                    null,
    flg_nouse                                    varchar2(1 char)                    null);

/**/
/* Comments
/**/
comment on table lads_adr_url is 'LADS Address URL';
comment on column lads_adr_url.obj_type is 'Address owner object type';
comment on column lads_adr_url.obj_id is 'Address owner object ID';
comment on column lads_adr_url.context is 'Semantic description of an object address';
comment on column lads_adr_url.urlseq is 'URL - generated sequence number';
comment on column lads_adr_url.std_no is 'Standard Sender Address in this Communication Type';
comment on column lads_adr_url.uri_type is 'URI type flag';
comment on column lads_adr_url.uri is '"URI, e.g. Homepage or ftp Address"';
comment on column lads_adr_url.std_recip is 'Flag: Recipient is standard recipient for this number';
comment on column lads_adr_url.home_flag is 'Recipient address in this communication type (mail sys.grp)';
comment on column lads_adr_url.consnumber is 'Sequence number';
comment on column lads_adr_url.uri_part1 is 'Universal Resource Identifier (URI): Parts 1-8';
comment on column lads_adr_url.uri_part2 is 'Universal Resource Identifier (URI): Parts 1-8';
comment on column lads_adr_url.uri_part3 is 'Universal Resource Identifier (URI): Parts 1-8';
comment on column lads_adr_url.uri_part4 is 'Universal Resource Identifier (URI): Parts 1-8';
comment on column lads_adr_url.uri_part5 is 'Universal Resource Identifier (URI): Parts 1-8';
comment on column lads_adr_url.uri_part6 is 'Universal Resource Identifier (URI): Parts 1-8';
comment on column lads_adr_url.uri_part7 is 'Universal Resource Identifier (URI): Parts 1-8';
comment on column lads_adr_url.uri_part8 is 'Universal Resource Identifier (URI): Parts 1-8';
comment on column lads_adr_url.uri_part9 is 'Universal Resource Identifier (URI) - Part 9';
comment on column lads_adr_url.errorflag is 'Flag: Record not processed';
comment on column lads_adr_url.flg_nouse is 'Flag: This Communication Number is Not Used';

/**/
/* Primary Key Constraint
/**/
alter table lads_adr_url
   add constraint lads_adr_url_pk primary key (obj_type, obj_id, context, urlseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_adr_url to lads_app;
grant select, insert, update, delete on lads_adr_url to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_adr_url for lads.lads_adr_url;
