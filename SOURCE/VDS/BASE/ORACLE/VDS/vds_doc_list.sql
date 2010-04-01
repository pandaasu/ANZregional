/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : vds
 Table   : vds_doc_list
 Owner   : vds
 Author  : Steve Gregan

 Description
 -----------
 Validation Data Store - vds_doc_list

 YYYY/MM   Author         Description
 -------   ------         -----------
 2010/03   Steve Gregan   Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table vds.vds_doc_list
   (vdl_query                          varchar2(30 char)        not null,
    vdl_number                         varchar2(30 char)        not null,
    vdl_date                           varchar2(20 char)        not null,
    vdl_status                         varchar2(20 char)        not null,
    vdl_vds_date                       date                     not null);

/**/
/* Comments
/**/
comment on table vds.vds_doc_list is 'VDS Document List Table';
comment on column vds.vds_doc_list.vdl_query is 'Document query';
comment on column vds.vds_doc_list.vdl_number is 'Document number';
comment on column vds.vds_doc_list.vdl_date is 'Document date';
comment on column vds.vds_doc_list.vdl_status is 'Document status (*ACTIVE, *CHANGED)';
comment on column vds.vds_doc_list.vdl_vds_date is 'VDS date inserted/updated';

/**/
/* Primary Key Constraint
/**/
alter table vds.vds_doc_list
   add constraint vds_doc_list_pk primary key (vdl_query, vdl_number);

/**/
/* Authority
/**/
grant select, insert, update, delete on vds.vds_doc_list to vds_app;
grant select on vds.vds_doc_list to public;

/**/
/* Synonym
/**/
create or replace public synonym vds_doc_list for vds.vds_doc_list;
