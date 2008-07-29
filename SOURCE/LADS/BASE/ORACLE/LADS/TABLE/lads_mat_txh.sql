/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_txh
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_txh

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_txh
   (matnr                                        varchar2(18 char)                   not null,
    txhseq                                       number                              not null,
    msgfn                                        varchar2(3 char)                    null,
    tdobject                                     varchar2(10 char)                   null,
    tdname                                       varchar2(70 char)                   null,
    tdid                                         varchar2(4 char)                    null,
    tdspras                                      varchar2(1 char)                    null,
    tdtexttype                                   varchar2(6 char)                    null,
    spras_iso                                    varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_mat_txh is 'LADS Material Text Header';
comment on column lads_mat_txh.matnr is 'Material Number';
comment on column lads_mat_txh.txhseq is 'TXH - generated sequence number';
comment on column lads_mat_txh.msgfn is 'Function';
comment on column lads_mat_txh.tdobject is 'Texts: application object';
comment on column lads_mat_txh.tdname is 'Name';
comment on column lads_mat_txh.tdid is 'Text ID';
comment on column lads_mat_txh.tdspras is 'Language Key';
comment on column lads_mat_txh.tdtexttype is 'SAPscript: Format of Text';
comment on column lads_mat_txh.spras_iso is 'Language according to ISO 639';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_txh
   add constraint lads_mat_txh_pk primary key (matnr, txhseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_txh to lads_app;
grant select, insert, update, delete on lads_mat_txh to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_txh for lads.lads_mat_txh;
