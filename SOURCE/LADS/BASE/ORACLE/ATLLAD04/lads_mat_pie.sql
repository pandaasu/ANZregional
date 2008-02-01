/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_pie
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_pie

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_pie
   (matnr                                        varchar2(18 char)                   not null,
    pchseq                                       number                              not null,
    pcrseq                                       number                              not null,
    pihseq                                       number                              not null,
    pieseq                                       number                              not null,
    ean11                                        varchar2(18 char)                   null,
    eantp                                        varchar2(2 char)                    null,
    hpean                                        varchar2(1 char)                    null);

/**/
/* Comments
/**/
comment on table lads_mat_pie is 'LADS Material Packaging Instruction EAN';
comment on column lads_mat_pie.matnr is 'Material Number';
comment on column lads_mat_pie.pchseq is 'PCH - generated sequence number';
comment on column lads_mat_pie.pcrseq is 'PCR - generated sequence number';
comment on column lads_mat_pie.pihseq is 'PIH - generated sequence number';
comment on column lads_mat_pie.pieseq is 'PIE - generated sequence number';
comment on column lads_mat_pie.ean11 is 'International Article Number (EAN/UPC)';
comment on column lads_mat_pie.eantp is 'Category of International Article Number (EAN)';
comment on column lads_mat_pie.hpean is 'Indicator: Main EAN';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_pie
   add constraint lads_mat_pie_pk primary key (matnr, pchseq, pcrseq, pihseq, pieseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_pie to lads_app;
grant select, insert, update, delete on lads_mat_pie to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_pie for lads.lads_mat_pie;
