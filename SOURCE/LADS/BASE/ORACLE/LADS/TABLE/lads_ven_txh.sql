/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_ven_txh
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_ven_txh

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_ven_txh
   (lifnr                                        varchar2(10 char)                   not null,
    txhseq                                       number                              not null,
    tdobject                                     varchar2(10 char)                   null,
    tdname                                       varchar2(70 char)                   null,
    tdid                                         varchar2(4 char)                    null,
    tdspras                                      varchar2(1 char)                    null,
    tdtexttype                                   varchar2(6 char)                    null,
    tdsprasiso                                   varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_ven_txh is 'LADS Vendor Text Header';
comment on column lads_ven_txh.lifnr is 'Account Number of Vendor or Creditor';
comment on column lads_ven_txh.txhseq is 'TXH - generated sequence number';
comment on column lads_ven_txh.tdobject is 'Texts: application object';
comment on column lads_ven_txh.tdname is 'Name';
comment on column lads_ven_txh.tdid is 'Text ID';
comment on column lads_ven_txh.tdspras is 'Language Key';
comment on column lads_ven_txh.tdtexttype is 'SAPscript: Format of Text';
comment on column lads_ven_txh.tdsprasiso is 'Language according to ISO 639';

/**/
/* Primary Key Constraint
/**/
alter table lads_ven_txh
   add constraint lads_ven_txh_pk primary key (lifnr, txhseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_ven_txh to lads_app;
grant select, insert, update, delete on lads_ven_txh to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_ven_txh for lads.lads_ven_txh;
