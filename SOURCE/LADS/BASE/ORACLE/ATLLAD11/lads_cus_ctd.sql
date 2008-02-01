/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_ctd
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_ctd

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_ctd
   (kunnr                                        varchar2(10 char)                   not null,
    cudseq                                       number                              not null,
    cteseq                                       number                              not null,
    ctdseq                                       number                              not null,
    tdformat                                     varchar2(2 char)                    null,
    tdline                                       varchar2(132 char)                  null);

/**/
/* Comments
/**/
comment on table lads_cus_ctd is 'LADS Customer Company Text Line';
comment on column lads_cus_ctd.kunnr is 'Customer Number';
comment on column lads_cus_ctd.cudseq is 'CUD - generated sequence number';
comment on column lads_cus_ctd.cteseq is 'CTE - generated sequence number';
comment on column lads_cus_ctd.ctdseq is 'CTD - generated sequence number';
comment on column lads_cus_ctd.tdformat is 'Tag column';
comment on column lads_cus_ctd.tdline is 'Text line';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_ctd
   add constraint lads_cus_ctd_pk primary key (kunnr, cudseq, cteseq, ctdseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_ctd to lads_app;
grant select, insert, update, delete on lads_cus_ctd to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_ctd for lads.lads_cus_ctd;
