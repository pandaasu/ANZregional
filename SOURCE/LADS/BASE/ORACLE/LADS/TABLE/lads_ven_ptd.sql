/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_ven_ptd
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_ven_ptd

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_ven_ptd
   (lifnr                                        varchar2(10 char)                   not null,
    pohseq                                       number                              not null,
    ptxseq                                       number                              not null,
    ptdseq                                       number                              not null,
    tdformat                                     varchar2(2 char)                    null,
    tdline                                       varchar2(132 char)                  null);

/**/
/* Comments
/**/
comment on table lads_ven_ptd is 'LADS Vendor Purchasing Text Line';
comment on column lads_ven_ptd.lifnr is 'Account Number of the Vendor';
comment on column lads_ven_ptd.pohseq is 'POH - generated sequence number';
comment on column lads_ven_ptd.ptxseq is 'PTX - generated sequence number';
comment on column lads_ven_ptd.ptdseq is 'PTD - generated sequence number';
comment on column lads_ven_ptd.tdformat is 'Tag column';
comment on column lads_ven_ptd.tdline is 'Text line';

/**/
/* Primary Key Constraint
/**/
alter table lads_ven_ptd
   add constraint lads_ven_ptd_pk primary key (lifnr, pohseq, ptxseq, ptdseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_ven_ptd to lads_app;
grant select, insert, update, delete on lads_ven_ptd to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_ven_ptd for lads.lads_ven_ptd;
