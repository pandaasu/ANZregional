/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : agency
 Owner  : edi

 Description
 -----------
 Electronic Data Interchange - Collection Agency Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table edi.agency
   (edi_agency_code                 varchar2(20 char)             not null,
    edi_agency_name                 varchar2(128 char)            not null,
    update_user                     varchar2(30 char)             not null,
    update_date                     date                          not null);

/**/
/* Comments
/**/
comment on table edi.agency is 'Collection Agency Table';
comment on column edi.agency.edi_agency_code is 'EDI Collection agency code';
comment on column edi.agency.edi_agency_name is 'EDI Collection agency name';
comment on column edi.agency.update_user is 'Last updated user';
comment on column edi.agency.update_date is 'Last updated time';

/**/
/* Primary Key Constraint
/**/
alter table edi.agency
   add constraint agency_pk primary key (edi_agency_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on edi.agency to dw_app;
grant select on edi.agency to public with grant option;

/**/
/* Synonym
/**/
create or replace public synonym agency for edi.agency;