/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_ven_txl
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_ven_txl

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_ven_txl
   (lifnr                                        varchar2(10 char)                   not null,
    txhseq                                       number                              not null,
    txlseq                                       number                              not null,
    tdformat                                     varchar2(2 char)                    null,
    tdline                                       varchar2(132 char)                  null);

/**/
/* Comments
/**/
comment on table lads_ven_txl is 'LADS Vendor Text Line';
comment on column lads_ven_txl.lifnr is 'Account Number of Vendor or Creditor';
comment on column lads_ven_txl.txhseq is 'TXH - generated sequence number';
comment on column lads_ven_txl.txlseq is 'TXL - generated sequence number';
comment on column lads_ven_txl.tdformat is 'Tag column';
comment on column lads_ven_txl.tdline is 'Text line';

/**/
/* Primary Key Constraint
/**/
alter table lads_ven_txl
   add constraint lads_ven_txl_pk primary key (lifnr, txhseq, txlseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_ven_txl to lads_app;
grant select, insert, update, delete on lads_ven_txl to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_ven_txl for lads.lads_ven_txl;
