/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_hth
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_hth

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_hth
   (kunnr                                        varchar2(10 char)                   not null,
    hthseq                                       number                              not null,
    tdobject                                     varchar2(10 char)                   null,
    tdname                                       varchar2(70 char)                   null,
    tdid                                         varchar2(4 char)                    null,
    tdspras                                      varchar2(1 char)                    null,
    tdtexttype                                   varchar2(6 char)                    null,
    tdsprasiso                                   varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_cus_hth is 'LADS Customer Text Header';
comment on column lads_cus_hth.kunnr is 'Customer Number';
comment on column lads_cus_hth.hthseq is 'HTH - generated sequence number';
comment on column lads_cus_hth.tdobject is 'Texts: application object';
comment on column lads_cus_hth.tdname is 'Name';
comment on column lads_cus_hth.tdid is 'Text ID';
comment on column lads_cus_hth.tdspras is 'Language Key';
comment on column lads_cus_hth.tdtexttype is 'SAPscript: Format of Text';
comment on column lads_cus_hth.tdsprasiso is 'Language according to ISO 639';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_hth
   add constraint lads_cus_hth_pk primary key (kunnr, hthseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_hth to lads_app;
grant select, insert, update, delete on lads_cus_hth to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_hth for lads.lads_cus_hth;
