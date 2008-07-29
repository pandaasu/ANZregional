/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_bnk
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_bnk

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_bnk
   (belnr                                        varchar2(35 char)                   not null,
    bnkseq                                       number                              not null,
    bcoun                                        varchar2(3 char)                    null,
    brnum                                        varchar2(17 char)                   null,
    bname                                        varchar2(70 char)                   null,
    baloc                                        varchar2(70 char)                   null,
    acnum                                        varchar2(30 char)                   null,
    acnam                                        varchar2(35 char)                   null);

/**/
/* Comments
/**/
comment on table lads_inv_bnk is 'LADS Invoice Bank';
comment on column lads_inv_bnk.belnr is 'IDOC document number';
comment on column lads_inv_bnk.bnkseq is 'BNK - generated sequence number';
comment on column lads_inv_bnk.bcoun is 'Country key';
comment on column lads_inv_bnk.brnum is 'Bank Key';
comment on column lads_inv_bnk.bname is 'Bank name';
comment on column lads_inv_bnk.baloc is 'Location of bank';
comment on column lads_inv_bnk.acnum is 'Account number in bank data';
comment on column lads_inv_bnk.acnam is 'Account holder in bank data';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_bnk
   add constraint lads_inv_bnk_pk primary key (belnr, bnkseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_bnk to lads_app;
grant select, insert, update, delete on lads_inv_bnk to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_bnk for lads.lads_inv_bnk;
