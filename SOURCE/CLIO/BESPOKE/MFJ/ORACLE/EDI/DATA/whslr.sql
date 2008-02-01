/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : whslr
 Owner  : edi

 Description
 -----------
 Electronic Data Interchange - Wholesaler Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table edi.whslr
   (edi_sndto_code                  varchar2(20 char)             not null,
    edi_whslr_code                  varchar2(20 char)             not null,
    edi_whslr_name                  varchar2(128 char)            not null,
    edi_disc_code                   varchar2(1 char)              not null,
    edi_email_group                 varchar2(64 char)             not null,
    update_user                     varchar2(30 char)             not null,
    update_date                     date                          not null);

/**/
/* Comments
/**/
comment on table edi.whslr is 'Wholesaler Table';
comment on column edi.whslr.edi_sndto_code is 'EDI Send To code';
comment on column edi.whslr.edi_whslr_code is 'EDI Wholesaler code';
comment on column edi.whslr.edi_whslr_name is 'EDI Wholesaler name';
comment on column edi.whslr.edi_disc_code is 'EDI Discount code (V=Volume, A=All)';
comment on column edi.whslr.edi_email_group is 'EDI Email group - notification';
comment on column edi.whslr.update_user is 'Last updated user';
comment on column edi.whslr.update_date is 'Last updated time';

/**/
/* Primary Key Constraint
/**/
alter table edi.whslr
   add constraint whslr_pk primary key (edi_sndto_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on edi.whslr to dw_app;
grant select on edi.whslr to public with grant option;

/**/
/* Synonym
/**/
create or replace public synonym whslr for edi.whslr;