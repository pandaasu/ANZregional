/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_del_htx
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_del_htx

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_del_htx
   (vbeln                                        varchar2(10 char)                   not null,
    htxseq                                       number                              not null,
    tdobject                                     varchar2(10 char)                   null,
    tdobname                                     varchar2(70 char)                   null,
    tdid                                         varchar2(4 char)                    null,
    tdspras                                      varchar2(1 char)                    null,
    tdtexttype                                   varchar2(6 char)                    null,
    langua_iso                                   varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_del_htx is 'LADS Delivery Text Header';
comment on column lads_del_htx.vbeln is 'Sales and Distribution Document Number';
comment on column lads_del_htx.htxseq is 'HTX - generated sequence number';
comment on column lads_del_htx.tdobject is 'Texts: application object';
comment on column lads_del_htx.tdobname is 'Name';
comment on column lads_del_htx.tdid is 'Text ID';
comment on column lads_del_htx.tdspras is 'Language';
comment on column lads_del_htx.tdtexttype is 'SAPscript: Format of Text';
comment on column lads_del_htx.langua_iso is 'Language key';

/**/
/* Primary Key Constraint
/**/
alter table lads_del_htx
   add constraint lads_del_htx_pk primary key (vbeln, htxseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_del_htx to lads_app;
grant select, insert, update, delete on lads_del_htx to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_del_htx for lads.lads_del_htx;
