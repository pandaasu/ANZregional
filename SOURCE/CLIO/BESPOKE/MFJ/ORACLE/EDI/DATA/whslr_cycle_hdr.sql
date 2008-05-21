/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : whslr_cycle
 Owner  : edi

 Description
 -----------
 Electronic Data Interchange - Wholesaler Cycle Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/05   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table edi.whslr_cycle
   (edi_sndto_code                  varchar2(20 char)             not null,
    edi_effat_month                 varchar2(6 char)              not null,
    edi_crton_day                   varchar2(2 char)              not null,
    edi_sndon_delay                 number                        not null);

/**/
/* Comments
/**/
comment on table edi.whslr_cycle is 'Wholesaler Cycle Table';
comment on column edi.whslr_cycle.edi_sndto_code is 'EDI Send to code';
comment on column edi.whslr_cycle.edi_effat_month is 'EDI Effective at month';
comment on column edi.whslr_cycle.edi_crton_day is 'EDI Create on day number (01-27 or 99)';
comment on column edi.whslr_cycle.edi_sndon_delay is 'EDI Send on delay days';

/**/
/* Primary Key Constraint
/**/
alter table edi.whslr_cycle
   add constraint whslr_cycle_pk primary key (edi_sndto_code, edi_effat_month, edi_crton_day);

/**/
/* Authority
/**/
grant select, insert, update, delete on edi.whslr_cycle to dw_app;
grant select on edi.whslr_cycle to public with grant option;

/**/
/* Synonym
/**/
create or replace public synonym whslr_cycle for edi.whslr_cycle;