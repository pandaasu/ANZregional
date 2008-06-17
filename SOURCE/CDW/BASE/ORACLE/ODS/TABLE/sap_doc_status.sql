/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : ods
 Table   : sap_doc_status
 Owner   : ods
 Author  : Steve Gregan

 Description
 -----------
 Operational Data Store - sap_doc_status

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/06   Steve Gregan   Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table ods.sap_doc_status
   (doc_type                          varchar2(30 char)        not null,
    doc_number                        varchar2(30 char)        not null,
    doc_line                          varchar2(30 char)        not null,
    doc_status                        varchar2(20 char)        not null,
    ods_date                          date                     not null);

/**/
/* Comments
/**/
comment on table ods.sap_doc_status is 'SAP Document Status';
comment on column ods.sap_doc_status.doc_type is 'Document type';
comment on column ods.sap_doc_status.doc_number is 'Document number';
comment on column ods.sap_doc_status.doc_line is 'Document line (*NONE)';
comment on column ods.sap_doc_status.doc_status is 'Document status (*DELETED, *OPEN, *CLOSED)';
comment on column ods.sap_doc_status.ods_date is 'ODS date inserted/updated';

/**/
/* Primary Key Constraint
/**/
alter table ods.sap_doc_status
   add constraint ods.sap_doc_status_pk primary key (doc_type, doc_number, doc_line);

/**/
/* Authority
/**/
grant select, insert, update, delete on ods.sap_doc_status to ods_app;
grant select on ods.sap_doc_status to public;

/**/
/* Synonym
/**/
create public synonym sap_doc_status for ods.sap_doc_status;
