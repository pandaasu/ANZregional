/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_ven_ptx
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_ven_ptx

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_ven_ptx
   (lifnr                                        varchar2(10 char)                   not null,
    pohseq                                       number                              not null,
    ptxseq                                       number                              not null,
    tdobject                                     varchar2(10 char)                   null,
    tdname                                       varchar2(70 char)                   null,
    tdid                                         varchar2(4 char)                    null,
    tdspras                                      varchar2(1 char)                    null,
    tdtexttype                                   varchar2(6 char)                    null,
    tdsprasiso                                   varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_ven_ptx is 'LADS Vendor Purchasing Text Header';
comment on column lads_ven_ptx.lifnr is 'Account Number of the Vendor';
comment on column lads_ven_ptx.pohseq is 'POH - generated sequence number';
comment on column lads_ven_ptx.ptxseq is 'PTX - generated sequence number';
comment on column lads_ven_ptx.tdobject is 'Texts: application object';
comment on column lads_ven_ptx.tdname is 'Name';
comment on column lads_ven_ptx.tdid is 'Text ID';
comment on column lads_ven_ptx.tdspras is 'Language Key';
comment on column lads_ven_ptx.tdtexttype is 'SAPscript: Format of Text';
comment on column lads_ven_ptx.tdsprasiso is 'Language according to ISO 639';

/**/
/* Primary Key Constraint
/**/
alter table lads_ven_ptx
   add constraint lads_ven_ptx_pk primary key (lifnr, pohseq, ptxseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_ven_ptx to lads_app;
grant select, insert, update, delete on lads_ven_ptx to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_ven_ptx for lads.lads_ven_ptx;
