/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : vds
 Table   : vds_doc_meta
 Owner   : vds
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - Validation Document Meta Data

 YYYY/MM   Author         Description
 -------   ------         -----------
 2010/03   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table vds.vds_doc_meta
   (vdm_query                                    varchar2(30 char)                   not null,
    vdm_row                                      number                              not null,
    vdm_table                                    varchar2(30 char)                   not null,
    vdm_column                                   varchar2(30 char)                   not null,
    vdm_type                                     varchar2(10 char)                   not null,
    vdm_offset                                   number                              not null,
    vdm_length                                   number                              not null);

/**/
/* Comments
/**/
comment on table vds.vds_doc_meta is 'Validation Document Meta Data';
comment on column vds.vds_doc_meta.vdm_query is 'Query code';
comment on column vds.vds_doc_meta.vdm_row is 'Row number';
comment on column vds.vds_doc_meta.vdm_table is 'Table code';
comment on column vds.vds_doc_meta.vdm_column is 'Column name';
comment on column vds.vds_doc_meta.vdm_type is 'Column type';
comment on column vds.vds_doc_meta.vdm_offset is 'Column data offset';
comment on column vds.vds_doc_meta.vdm_length is 'Column data length';

/**/
/* Primary Key Constraint
/**/
alter table vds.vds_doc_meta
   add constraint vds_doc_meta_pk primary key (vdm_query, vdm_row);

/**/
/* Authority
/**/
grant select, insert, update, delete on vds.vds_doc_meta to vds_app;
grant select on vds.vds_doc_meta to public;

/**/
/* Synonym
/**/
create or replace public synonym vds_doc_meta for vds.vds_doc_meta;