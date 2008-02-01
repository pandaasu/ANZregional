/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_cur
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_cur

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_cur
   (belnr                                        varchar2(35 char)                   not null,
    curseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    waerz                                        varchar2(3 char)                    null,
    waerq                                        varchar2(3 char)                    null,
    kurs                                         varchar2(12 char)                   null,
    datum                                        varchar2(8 char)                    null,
    zeit                                         varchar2(6 char)                    null,
    kurs_m                                       varchar2(12 char)                   null);

/**/
/* Comments
/**/
comment on table lads_inv_cur is 'LADS Invoice Currency';
comment on column lads_inv_cur.belnr is 'IDOC document number';
comment on column lads_inv_cur.curseq is 'CUR - generated sequence number';
comment on column lads_inv_cur.qualf is 'Qualifier currency';
comment on column lads_inv_cur.waerz is 'Three-digit character field for IDocs';
comment on column lads_inv_cur.waerq is 'Three-digit character field for IDocs';
comment on column lads_inv_cur.kurs is 'Character Field of Length 12';
comment on column lads_inv_cur.datum is 'IDOC: Date';
comment on column lads_inv_cur.zeit is 'IDOC: Time';
comment on column lads_inv_cur.kurs_m is 'Indirectly quoted exchange rate in an IDoc segment';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_cur
   add constraint lads_inv_cur_pk primary key (belnr, curseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_cur to lads_app;
grant select, insert, update, delete on lads_inv_cur to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_cur for lads.lads_inv_cur;
