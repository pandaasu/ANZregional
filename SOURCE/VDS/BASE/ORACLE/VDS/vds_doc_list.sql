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
   (doc_type                          varchar2(30 char)        not null,
    doc_number                        varchar2(30 char)        not null,
    doc_date                          varchar2(20 char)        not null,
    doc_status                        varchar2(20 char)        not null,
    vds_date                          date                     not null);

/**/
/* Comments
/**/
comment on table vds.vds_doc_list is 'VDS Document List Table';
comment on column vds.vds_doc_list.doc_type is 'Document type';
comment on column vds.vds_doc_list.doc_number is 'Document number';
comment on column vds.vds_doc_list.doc_date is 'Document date';
comment on column vds.vds_doc_list.doc_status is 'Document status (*ACTIVE, *CHANGED)';
comment on column vds.vds_doc_list.vds_date is 'VDS date inserted/updated';

/**/
/* Primary Key Constraint
/**/
alter table vds.vds_doc_list
   add constraint vds_doc_list_pk primary key (doc_type, doc_number);

/**/
/* Authority
/**/
grant select, insert, update, delete on ods.vds_doc_list to vds_app;
grant select on vds.vds_doc_list to public;

/**/
/* Synonym
/**/
create public synonym vds_doc_list for vds.vds_doc_list;
