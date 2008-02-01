/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : vds
 Table   : vds_meta
 Owner   : vds
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - Validation Meta Data

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table vds_meta
   (vme_query                                    varchar2(30 char)                   not null,
    vme_row                                      number                              not null,
    vme_table                                    varchar2(30 char)                   not null,
    vme_column                                   varchar2(30 char)                   not null,
    vme_type                                     varchar2(10 char)                   not null,
    vme_offset                                   number                              not null,
    vme_length                                   number                              not null);

/**/
/* Comments
/**/
comment on table vds_meta is 'Validation Meta Data';
comment on column vds_meta.vme_query is 'Query code';
comment on column vds_meta.vme_row is 'Row number';
comment on column vds_meta.vme_table is 'Table code';
comment on column vds_meta.vme_column is 'Column name';
comment on column vds_meta.vme_type is 'Column type';
comment on column vds_meta.vme_offset is 'Column data offset';
comment on column vds_meta.vme_length is 'Column data length';

/**/
/* Primary Key Constraint
/**/
alter table vds_meta
   add constraint vds_meta_pk primary key (vme_query, vme_row);

/**/
/* Authority
/**/
grant select, insert, update, delete on vds_meta to vds_app;
grant select on vds_meta to public;

/**/
/* Synonym
/**/
create or replace public synonym vds_meta for vds.vds_meta;