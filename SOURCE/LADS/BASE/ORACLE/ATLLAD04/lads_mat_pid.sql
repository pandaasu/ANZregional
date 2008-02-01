/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_pid
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_pid

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_pid
   (matnr                                        varchar2(18 char)                   not null,
    pchseq                                       number                              not null,
    pcrseq                                       number                              not null,
    pihseq                                       number                              not null,
    pidseq                                       number                              not null,
    packitem                                     number                              null,
    detail_itemtype                              varchar2(2 char)                    null,
    component                                    varchar2(20 char)                   null,
    trgqty                                       number                              null,
    minqty                                       number                              null,
    rndqty                                       number                              null,
    unitqty                                      varchar2(3 char)                    null,
    indmapaco                                    varchar2(1 char)                    null);

/**/
/* Comments
/**/
comment on table lads_mat_pid is 'LADS Material Packaging Instruction Detail';
comment on column lads_mat_pid.matnr is 'Material Number';
comment on column lads_mat_pid.pchseq is 'PCH - generated sequence number';
comment on column lads_mat_pid.pcrseq is 'PCR - generated sequence number';
comment on column lads_mat_pid.pihseq is 'PIH - generated sequence number';
comment on column lads_mat_pid.pidseq is 'PID - generated sequence number';
comment on column lads_mat_pid.packitem is 'Item number';
comment on column lads_mat_pid.detail_itemtype is 'Detailed item category';
comment on column lads_mat_pid.component is '"Component (gen.field for matl, packaging matl or pkg instr.)"';
comment on column lads_mat_pid.trgqty is 'Target quantity';
comment on column lads_mat_pid.minqty is 'Minimum quantity';
comment on column lads_mat_pid.rndqty is 'Rounding qty';
comment on column lads_mat_pid.unitqty is 'Unit of measure';
comment on column lads_mat_pid.indmapaco is 'Load carrier indicator';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_pid
   add constraint lads_mat_pid_pk primary key (matnr, pchseq, pcrseq, pihseq, pidseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_pid to lads_app;
grant select, insert, update, delete on lads_mat_pid to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_pid for lads.lads_mat_pid;
