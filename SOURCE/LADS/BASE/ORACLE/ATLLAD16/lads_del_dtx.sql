/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_del_dtx
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_del_dtx

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_del_dtx
   (vbeln                                        varchar2(10 char)                   not null,
    detseq                                       number                              not null,
    dtxseq                                       number                              not null,
    tdobject                                     varchar2(10 char)                   null,
    tdobname                                     varchar2(70 char)                   null,
    tdid                                         varchar2(4 char)                    null,
    tdspras                                      varchar2(1 char)                    null,
    tdtexttype                                   varchar2(6 char)                    null,
    langua_iso                                   varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_del_dtx is 'LADS Delivery Detail Text Header';
comment on column lads_del_dtx.vbeln is 'Sales and Distribution Document Number';
comment on column lads_del_dtx.detseq is 'DET - generated sequence number';
comment on column lads_del_dtx.dtxseq is 'DTX - generated sequence number';
comment on column lads_del_dtx.tdobject is 'Texts: application object';
comment on column lads_del_dtx.tdobname is 'Name';
comment on column lads_del_dtx.tdid is 'Text ID';
comment on column lads_del_dtx.tdspras is 'Language';
comment on column lads_del_dtx.tdtexttype is 'SAPscript: Format of Text';
comment on column lads_del_dtx.langua_iso is 'Language key';

/**/
/* Primary Key Constraint
/**/
alter table lads_del_dtx
   add constraint lads_del_dtx_pk primary key (vbeln, detseq, dtxseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_del_dtx to lads_app;
grant select, insert, update, delete on lads_del_dtx to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_del_dtx for lads.lads_del_dtx;
