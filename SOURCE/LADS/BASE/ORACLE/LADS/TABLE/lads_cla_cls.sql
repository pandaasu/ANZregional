/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cla_cls
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cla_cls

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cla_cls
   (obtab                                        varchar2(10 char)                   not null,
    objek                                        varchar2(50 char)                   not null,
    klart                                        varchar2(3 char)                    not null,
    clsseq                                       number                              not null,
    class                                        varchar2(18 char)                   null);

/**/
/* Comments
/**/
comment on table lads_cla_cls is 'LADS Classification Class';
comment on column lads_cla_cls.obtab is 'Name of database table for object';
comment on column lads_cla_cls.objek is 'Key of object to be classified';
comment on column lads_cla_cls.klart is 'Class type';
comment on column lads_cla_cls.clsseq is 'CLS - generated sequence number';
comment on column lads_cla_cls.class is 'Class Name';

/**/
/* Primary Key Constraint
/**/
alter table lads_cla_cls
   add constraint lads_cla_cls_pk primary key (obtab, objek, klart, clsseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cla_cls to lads_app;
grant select, insert, update, delete on lads_cla_cls to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cla_cls for lads.lads_cla_cls;
