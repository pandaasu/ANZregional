/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_sat
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_sat

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_sat
   (kunnr                                        varchar2(10 char)                   not null,
    sadseq                                       number                              not null,
    satseq                                       number                              not null,
    tdobject                                     varchar2(10 char)                   null,
    tdname                                       varchar2(70 char)                   null,
    tdid                                         varchar2(4 char)                    null,
    tdspras                                      varchar2(1 char)                    null,
    tdtexttype                                   varchar2(6 char)                    null,
    tdsprasiso                                   varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_cus_sat is 'LADS Customer Sales Area Text Header';
comment on column lads_cus_sat.kunnr is 'Customer Number';
comment on column lads_cus_sat.sadseq is 'SAD - generated sequence number';
comment on column lads_cus_sat.satseq is 'SAT - generated sequence number';
comment on column lads_cus_sat.tdobject is 'Texts: application object';
comment on column lads_cus_sat.tdname is 'Name';
comment on column lads_cus_sat.tdid is 'Text ID';
comment on column lads_cus_sat.tdspras is 'Language Key';
comment on column lads_cus_sat.tdtexttype is 'SAPscript: Format of Text';
comment on column lads_cus_sat.tdsprasiso is 'Language according to ISO 639';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_sat
   add constraint lads_cus_sat_pk primary key (kunnr, sadseq, satseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_sat to lads_app;
grant select, insert, update, delete on lads_cus_sat to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_sat for lads.lads_cus_sat;
