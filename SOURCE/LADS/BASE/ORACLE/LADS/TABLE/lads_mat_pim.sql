/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_pim
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_pim

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_pim
   (matnr                                        varchar2(18 char)                   not null,
    pchseq                                       number                              not null,
    pcrseq                                       number                              not null,
    pihseq                                       number                              not null,
    pimseq                                       number                              not null,
    moe                                          varchar2(4 char)                    null,
    usagecode                                    varchar2(3 char)                    null,
    datab                                        varchar2(8 char)                    null,
    dated                                        varchar2(8 char)                    null);

/**/
/* Comments
/**/
comment on table lads_mat_pim is 'LADS Material Packaging Instruction MOE';
comment on column lads_mat_pim.matnr is 'Material Number';
comment on column lads_mat_pim.pchseq is 'PCH - generated sequence number';
comment on column lads_mat_pim.pcrseq is 'PCR - generated sequence number';
comment on column lads_mat_pim.pihseq is 'PIH - generated sequence number';
comment on column lads_mat_pim.pimseq is 'PIM - generated sequence number';
comment on column lads_mat_pim.moe is 'MOE code';
comment on column lads_mat_pim.usagecode is 'Item Usage Code';
comment on column lads_mat_pim.datab is 'MOE  Start date';
comment on column lads_mat_pim.dated is 'MOE End Date';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_pim
   add constraint lads_mat_pim_pk primary key (matnr, pchseq, pcrseq, pihseq, pimseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_pim to lads_app;
grant select, insert, update, delete on lads_mat_pim to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_pim for lads.lads_mat_pim;
