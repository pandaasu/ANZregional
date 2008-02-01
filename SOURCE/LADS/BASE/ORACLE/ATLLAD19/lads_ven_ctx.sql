/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_ven_ctx
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_ven_ctx

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_ven_ctx
   (lifnr                                        varchar2(10 char)                   not null,
    ccdseq                                       number                              not null,
    ctxseq                                       number                              not null,
    tdobject                                     varchar2(10 char)                   null,
    tdname                                       varchar2(70 char)                   null,
    tdid                                         varchar2(4 char)                    null,
    tdspras                                      varchar2(1 char)                    null,
    tdtexttype                                   varchar2(6 char)                    null,
    tdsprasiso                                   varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_ven_ctx is 'LADS Vendor Company Text Header';
comment on column lads_ven_ctx.lifnr is 'Account Number of Vendor or Creditor';
comment on column lads_ven_ctx.ccdseq is 'CCD - generated sequence number';
comment on column lads_ven_ctx.ctxseq is 'CTX - generated sequence number';
comment on column lads_ven_ctx.tdobject is 'Texts: application object';
comment on column lads_ven_ctx.tdname is 'Name';
comment on column lads_ven_ctx.tdid is 'Text ID';
comment on column lads_ven_ctx.tdspras is 'Language Key';
comment on column lads_ven_ctx.tdtexttype is 'SAPscript: Format of Text';
comment on column lads_ven_ctx.tdsprasiso is 'Language according to ISO 639';

/**/
/* Primary Key Constraint
/**/
alter table lads_ven_ctx
   add constraint lads_ven_ctx_pk primary key (lifnr, ccdseq, ctxseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_ven_ctx to lads_app;
grant select, insert, update, delete on lads_ven_ctx to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_ven_ctx for lads.lads_ven_ctx;
