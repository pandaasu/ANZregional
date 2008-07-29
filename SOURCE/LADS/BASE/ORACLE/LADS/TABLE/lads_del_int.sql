/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_del_int
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_del_int

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_del_int
   (vbeln                                        varchar2(10 char)                   not null,
    detseq                                       number                              not null,
    intseq                                       number                              not null,
    atinn                                        number                              null,
    atnam                                        varchar2(30 char)                   null,
    atbez                                        varchar2(30 char)                   null,
    atwrt                                        varchar2(30 char)                   null,
    atwtb                                        varchar2(30 char)                   null,
    ewahr                                        number                              null);

/**/
/* Comments
/**/
comment on table lads_del_int is 'LADS Delivery Detail Internal Characteristic';
comment on column lads_del_int.vbeln is 'Sales and Distribution Document Number';
comment on column lads_del_int.detseq is 'DET - generated sequence number';
comment on column lads_del_int.intseq is 'INT - generated sequence number';
comment on column lads_del_int.atinn is 'Internal characteristic';
comment on column lads_del_int.atnam is 'Characteristic Name';
comment on column lads_del_int.atbez is 'Characteristic description';
comment on column lads_del_int.atwrt is 'Characteristic Value';
comment on column lads_del_int.atwtb is 'Characteristic value description';
comment on column lads_del_int.ewahr is 'Tolerance from';

/**/
/* Primary Key Constraint
/**/
alter table lads_del_int
   add constraint lads_del_int_pk primary key (vbeln, detseq, intseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_del_int to lads_app;
grant select, insert, update, delete on lads_del_int to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_del_int for lads.lads_del_int;
