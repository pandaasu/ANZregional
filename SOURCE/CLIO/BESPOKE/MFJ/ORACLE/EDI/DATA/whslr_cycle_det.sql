/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : whslr_cycle_det
 Owner  : edi

 Description
 -----------
 Electronic Data Interchange - Wholesaler Cycle Detail Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/05   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table edi.whslr_cycle_det
   (edi_sndto_code                  varchar2(20 char)             not null,
    edi_effat_month                 varchar2(6 char)              not null,
    edi_endon_day                   varchar2(2 char)              not null,
    edi_stron_month                 varchar2(1 char)              not null,
    edi_stron_day                   varchar2(2 char)              not null);

/**/
/* Comments
/**/
comment on table edi.whslr_cycle_det is 'Wholesaler Cycle Detail Table';
comment on column edi.whslr_cycle_det.edi_sndto_code is 'EDI Send to code';
comment on column edi.whslr_cycle_det.edi_effat_month is 'EDI Effective at month';
comment on column edi.whslr_cycle_det.edi_endon_day is 'EDI End on day number (01-27 or 99)';
comment on column edi.whslr_cycle_det.edi_stron_month is 'EDI Start on month flag (P=previous,C=Current)';
comment on column edi.whslr_cycle_det.edi_stron_day is 'EDI Start on day number (01-27)';

/**/
/* Primary Key Constraint
/**/
alter table edi.whslr_cycle_det
   add constraint whslr_cycle_det_pk primary key (edi_sndto_code, edi_effat_month, edi_endon_day);

/**/
/* Authority
/**/
grant select, insert, update, delete on edi.whslr_cycle_det to dw_app;
grant select on edi.whslr_cycle_det to public with grant option;

/**/
/* Synonym
/**/
create or replace public synonym whslr_cycle_det for edi.whslr_cycle_det;