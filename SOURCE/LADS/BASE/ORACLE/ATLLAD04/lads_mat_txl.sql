/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_txl
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_txl

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_txl
   (matnr                                        varchar2(18 char)                   not null,
    txhseq                                       number                              not null,
    txlseq                                       number                              not null,
    msgfn                                        varchar2(3 char)                    null,
    tdformat                                     varchar2(2 char)                    null,
    tdline                                       varchar2(132 char)                  null);

/**/
/* Comments
/**/
comment on table lads_mat_txl is 'LADS Material Text Line';
comment on column lads_mat_txl.matnr is 'Material Number';
comment on column lads_mat_txl.txhseq is 'TXH - generated sequence number';
comment on column lads_mat_txl.txlseq is 'TXL - generated sequence number';
comment on column lads_mat_txl.msgfn is 'Function';
comment on column lads_mat_txl.tdformat is 'Tag column';
comment on column lads_mat_txl.tdline is 'Text line';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_txl
   add constraint lads_mat_txl_pk primary key (matnr, txhseq, txlseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_txl to lads_app;
grant select, insert, update, delete on lads_mat_txl to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_txl for lads.lads_mat_txl;
