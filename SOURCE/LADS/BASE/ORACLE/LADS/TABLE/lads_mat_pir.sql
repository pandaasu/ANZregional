/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_pir
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_pir

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_pir
   (matnr                                        varchar2(18 char)                   not null,
    pchseq                                       number                              not null,
    pcrseq                                       number                              not null,
    pihseq                                       number                              not null,
    pirseq                                       number                              not null,
    z_lcdid                                      varchar2(5 char)                    null,
    z_lcdnr                                      varchar2(18 char)                   null);

/**/
/* Comments
/**/
comment on table lads_mat_pir is 'LADS Material Packaging Instruction Regional';
comment on column lads_mat_pir.matnr is 'Material Number';
comment on column lads_mat_pir.pchseq is 'PCH - generated sequence number';
comment on column lads_mat_pir.pcrseq is 'PCR - generated sequence number';
comment on column lads_mat_pir.pihseq is 'PIH - generated sequence number';
comment on column lads_mat_pir.pirseq is 'PIR - generated sequence number';
comment on column lads_mat_pir.z_lcdid is 'Regional code Id';
comment on column lads_mat_pir.z_lcdnr is 'Regional code number';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_pir
   add constraint lads_mat_pir_pk primary key (matnr, pchseq, pcrseq, pihseq, pirseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_pir to lads_app;
grant select, insert, update, delete on lads_mat_pir to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_pir for lads.lads_mat_pir;
