/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : whslr_cycle_hdr
 Owner  : edi

 Description
 -----------
 Electronic Data Interchange - Wholesaler Cycle Header Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/05   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table edi.whslr_cycle_hdr
   (edi_sndto_code                  varchar2(20 char)             not null,
    edi_effat_month                 varchar2(6 char)              not null,
    edi_sndon_delay                 number                        not null);

/**/
/* Comments
/**/
comment on table edi.whslr_cycle_hdr is 'Wholesaler Cycle Header Table';
comment on column edi.whslr_cycle_hdr.edi_sndto_code is 'EDI Send to code';
comment on column edi.whslr_cycle_hdr.edi_effat_month is 'EDI Effective at month';
comment on column edi.whslr_cycle_hdr.edi_sndon_delay is 'EDI Send on delay days';

/**/
/* Primary Key Constraint
/**/
alter table edi.whslr_cycle_hdr
   add constraint whslr_cycle_hdr_pk primary key (edi_sndto_code, edi_effat_month);

/**/
/* Authority
/**/
grant select, insert, update, delete on edi.whslr_cycle_hdr to dw_app;
grant select on edi.whslr_cycle_hdr to public with grant option;

/**/
/* Synonym
/**/
create or replace public synonym whslr_cycle_hdr for edi.whslr_cycle_hdr;