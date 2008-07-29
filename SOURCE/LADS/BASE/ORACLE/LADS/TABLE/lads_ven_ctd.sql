/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_ven_ctd
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_ven_ctd

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_ven_ctd
   (lifnr                                        varchar2(10 char)                   not null,
    ccdseq                                       number                              not null,
    ctxseq                                       number                              not null,
    ctdseq                                       number                              not null,
    tdformat                                     varchar2(2 char)                    null,
    tdline                                       varchar2(132 char)                  null);

/**/
/* Comments
/**/
comment on table lads_ven_ctd is 'LADS Vendor Company Text Line';
comment on column lads_ven_ctd.lifnr is 'Account Number of Vendor or Creditor';
comment on column lads_ven_ctd.ccdseq is 'CCD - generated sequence number';
comment on column lads_ven_ctd.ctxseq is 'CTX - generated sequence number';
comment on column lads_ven_ctd.ctdseq is 'CTD - generated sequence number';
comment on column lads_ven_ctd.tdformat is 'Tag column';
comment on column lads_ven_ctd.tdline is 'Text line';

/**/
/* Primary Key Constraint
/**/
alter table lads_ven_ctd
   add constraint lads_ven_ctd_pk primary key (lifnr, ccdseq, ctxseq, ctdseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_ven_ctd to lads_app;
grant select, insert, update, delete on lads_ven_ctd to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_ven_ctd for lads.lads_ven_ctd;
