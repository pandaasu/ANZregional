/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_htd
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_htd

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_htd
   (kunnr                                        varchar2(10 char)                   not null,
    hthseq                                       number                              not null,
    htdseq                                       number                              not null,
    tdformat                                     varchar2(2 char)                    null,
    tdline                                       varchar2(132 char)                  null);

/**/
/* Comments
/**/
comment on table lads_cus_htd is 'LADS Customer Text Line';
comment on column lads_cus_htd.kunnr is 'Customer Number';
comment on column lads_cus_htd.hthseq is 'HTH - generated sequence number';
comment on column lads_cus_htd.htdseq is 'HTD - generated sequence number';
comment on column lads_cus_htd.tdformat is 'Tag column';
comment on column lads_cus_htd.tdline is 'Text line';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_htd
   add constraint lads_cus_htd_pk primary key (kunnr, hthseq, htdseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_htd to lads_app;
grant select, insert, update, delete on lads_cus_htd to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_htd for lads.lads_cus_htd;
