/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : whslr_billing
 Owner  : edi

 Description
 -----------
 Electronic Data Interchange - Wholesaler Billing Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table edi.whslr_billing
   (edi_sndto_code                  varchar2(20 char)             not null,
    edi_bilto_date                  varchar2(8 char)              not null,
    edi_bilto_str_date              varchar2(8 char)              not null,
    edi_bilto_end_date              varchar2(8 char)              not null,
    edi_sndon_date                  varchar2(8 char)              not null);

/**/
/* Comments
/**/
comment on table edi.whslr_billing is 'Wholesaler Billing Table';
comment on column edi.whslr_billing.edi_sndto_code is 'EDI Send To code';
comment on column edi.whslr_billing.edi_bilto_date is 'EDI Bill to date';
comment on column edi.whslr_billing.edi_bilto_str_date is 'EDI Bill to start date';
comment on column edi.whslr_billing.edi_bilto_end_date is 'EDI Bill to end date';
comment on column edi.whslr_billing.edi_sndon_date is 'EDI send on date';

/**/
/* Primary Key Constraint
/**/
alter table edi.whslr_billing
   add constraint whslr_billing_pk primary key (edi_sndto_code, edi_bilto_date);

/**/
/* Authority
/**/
grant select, insert, update, delete on edi.whslr_billing to dw_app;
grant select on edi.whslr_billing to public with grant option;

/**/
/* Synonym
/**/
create or replace public synonym whslr_billing for edi.whslr_billing;