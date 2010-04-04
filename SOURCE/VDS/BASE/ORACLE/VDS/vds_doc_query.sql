/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : vds
 Table   : vds_doc_query
 Owner   : vds
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - Validation Document Query

 YYYY/MM   Author         Description
 -------   ------         -----------
 2010/03   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table vds.vds_doc_query
   (vdq_query                                    varchar2(30 char)                   not null,
    vdq_load_proc                                varchar2(128 char)                  not null,
    vdq_meta_date                                date                                null,
    vdq_data_date                                date                                null);

/**/
/* Comments
/**/
comment on table vds.vds_doc_query is 'Validation Document Query';
comment on column vds.vds_doc_query.vdq_query is 'Query code';
comment on column vds.vds_doc_query.vdq_load_proc is 'Query load procedure';
comment on column vds.vds_doc_query.vdq_meta_date is 'Query meta rebuild date';
comment on column vds.vds_doc_query.vdq_data_date is 'Query data update date';

/**/
/* Primary Key Constraint
/**/
alter table vds.vds_doc_query
   add constraint vds_doc_query_pk primary key (vdq_query);

/**/
/* Authority
/**/
grant select, insert, update, delete on vds.vds_doc_query to vds_app;
grant select on vds.vds_doc_query to public;

/**/
/* Synonym
/**/
create or replace public synonym vds_doc_query for vds.vds_doc_query;