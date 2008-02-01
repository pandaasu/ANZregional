/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_cte
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_cte

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_cte
   (kunnr                                        varchar2(10 char)                   not null,
    cudseq                                       number                              not null,
    cteseq                                       number                              not null,
    tdobject                                     varchar2(10 char)                   null,
    tdname                                       varchar2(70 char)                   null,
    tdid                                         varchar2(4 char)                    null,
    tdspras                                      varchar2(1 char)                    null,
    tdtexttype                                   varchar2(6 char)                    null,
    tdsprasiso                                   varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_cus_cte is 'LADS Customer Company Text Header';
comment on column lads_cus_cte.kunnr is 'Customer Number';
comment on column lads_cus_cte.cudseq is 'CUD - generated sequence number';
comment on column lads_cus_cte.cteseq is 'CTE - generated sequence number';
comment on column lads_cus_cte.tdobject is 'Texts: application object';
comment on column lads_cus_cte.tdname is 'Name';
comment on column lads_cus_cte.tdid is 'Text ID';
comment on column lads_cus_cte.tdspras is 'Language Key';
comment on column lads_cus_cte.tdtexttype is 'SAPscript: Format of Text';
comment on column lads_cus_cte.tdsprasiso is 'Language according to ISO 639';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_cte
   add constraint lads_cus_cte_pk primary key (kunnr, cudseq, cteseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_cte to lads_app;
grant select, insert, update, delete on lads_cus_cte to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_cte for lads.lads_cus_cte;
