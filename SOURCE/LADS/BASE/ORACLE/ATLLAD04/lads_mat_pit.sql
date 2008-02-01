/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_pit
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_pit

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_pit
   (matnr                                        varchar2(18 char)                   not null,
    pchseq                                       number                              not null,
    pcrseq                                       number                              not null,
    pihseq                                       number                              not null,
    pitseq                                       number                              not null,
    spras                                        varchar2(1 char)                    null,
    content                                      varchar2(40 char)                   null);

/**/
/* Comments
/**/
comment on table lads_mat_pit is 'LADS Material Packaging Instruction Text';
comment on column lads_mat_pit.matnr is 'Material Number';
comment on column lads_mat_pit.pchseq is 'PCH - generated sequence number';
comment on column lads_mat_pit.pcrseq is 'PCR - generated sequence number';
comment on column lads_mat_pit.pihseq is 'PIH - generated sequence number';
comment on column lads_mat_pit.pitseq is 'PIT - generated sequence number';
comment on column lads_mat_pit.spras is 'Language Key';
comment on column lads_mat_pit.content is 'Short text of packing object';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_pit
   add constraint lads_mat_pit_pk primary key (matnr, pchseq, pcrseq, pihseq, pitseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_pit to lads_app;
grant select, insert, update, delete on lads_mat_pit to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_pit for lads.lads_mat_pit;
