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
create table vds_query
   (vdq_query                                    varchar2(30 char)                   not null,
    vqu_meta_ifac                                varchar2(30 char)                   null,
    vqu_meta_time                                varchar2(14 char)                   null,
    vqu_meta_date                                date                                null,
    vqu_data_ifac                                varchar2(30 char)                   null,
    vqu_data_time                                varchar2(14 char)                   null,
    vqu_data_date                                date                                null,
    vqu_view_date                                date                                null);

/**/
/* Comments
/**/
comment on table vds_doc_query is 'Validation Document Query';
comment on column vds_doc_query.vqu_query is 'Query code';
comment on column vds_doc_query.vqu_meta_ifac is 'Query meta interface name';
comment on column vds_doc_query.vqu_meta_time is 'Query meta interface timestamp';
comment on column vds_doc_query.vqu_meta_date is 'Query meta update date';
comment on column vds_doc_query.vqu_data_ifac is 'Query data interface name';
comment on column vds_doc_query.vqu_data_time is 'Query data interface timestamp';
comment on column vds_doc_query.vqu_data_date is 'Query data update date';
comment on column vds_doc_query.vqu_view_date is 'Query view generation date';

/**/
/* Primary Key Constraint
/**/
alter table vds_doc_query
   add constraint vds_doc_query_pk primary key (vqu_query);

/**/
/* Authority
/**/
grant select, insert, update, delete on vds_doc_query to vds_app;
grant select on vds_doc_query to public;

/**/
/* Synonym
/**/
create or replace public synonym vds_doc_query for vds.vds_doc_query;