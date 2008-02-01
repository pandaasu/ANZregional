/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_pcr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_pcr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_pcr
   (matnr                                        varchar2(18 char)                   not null,
    pchseq                                       number                              not null,
    pcrseq                                       number                              not null,
    knumh                                        varchar2(10 char)                   null,
    datab                                        varchar2(8 char)                    null,
    datbi                                        varchar2(8 char)                    null,
    packnr                                       varchar2(22 char)                   null,
    packnr1                                      varchar2(22 char)                   null,
    packnr2                                      varchar2(22 char)                   null,
    packnr3                                      varchar2(22 char)                   null,
    packnr4                                      varchar2(22 char)                   null);

/**/
/* Comments
/**/
comment on table lads_mat_pcr is 'LADS Material Packaging Condition Record';
comment on column lads_mat_pcr.matnr is 'Material Number';
comment on column lads_mat_pcr.pchseq is 'PCH - generated sequence number';
comment on column lads_mat_pcr.pcrseq is 'PCR - generated sequence number';
comment on column lads_mat_pcr.knumh is 'Condition record number';
comment on column lads_mat_pcr.datab is 'Validity start date of the condition record';
comment on column lads_mat_pcr.datbi is 'Validity end date of the condition record';
comment on column lads_mat_pcr.packnr is 'Packing instruction';
comment on column lads_mat_pcr.packnr1 is 'Alternative packing instruction';
comment on column lads_mat_pcr.packnr2 is 'Alternative packing instruction';
comment on column lads_mat_pcr.packnr3 is 'Alternative packing instruction';
comment on column lads_mat_pcr.packnr4 is 'Alternative packing instruction';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_pcr
   add constraint lads_mat_pcr_pk primary key (matnr, pchseq, pcrseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_pcr to lads_app;
grant select, insert, update, delete on lads_mat_pcr to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_pcr for lads.lads_mat_pcr;
