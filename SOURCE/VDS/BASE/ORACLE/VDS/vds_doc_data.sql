/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : vds
 Table   : vds_doc_data
 Owner   : vds
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - Validation Document Data

 YYYY/MM   Author         Description
 -------   ------         -----------
 2010/03   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table vds.vds_doc_data
   (vdd_query                                    varchar2(30 char)                   not null,
    vdd_row                                      number                              not null,
    vdd_table                                    varchar2(30 char)                   not null,
    vdd_key                                      varchar2(30 char)                   not null,
    vdd_data                                     varchar2(4000 char)                 not null);

/**/
/* Comments
/**/
comment on table vds.vds_doc_data is 'Validation Document Data';
comment on column vds.vds_doc_data.vdd_query is 'Query code';
comment on column vds.vds_doc_data.vdd_row is 'Row number';
comment on column vds.vds_doc_data.vdd_table is 'Table code';
comment on column vds.vds_doc_data.vdd_key is 'Row key';
comment on column vds.vds_doc_data.vdd_data is 'Row data';

/**/
/* Primary Key Constraint
/**/
alter table vds.vds_doc_data
   add constraint vds_doc_data_pk primary key (vdd_query, vdd_row);

/**/
/* Authority
/**/
grant select, insert, update, delete on vds.vds_doc_data to vds_app with grant option;
grant select on vds.vds_doc_data to public;

/**/
/* Synonym
/**/
create or replace public synonym vds_doc_data for vds.vds_doc_data;