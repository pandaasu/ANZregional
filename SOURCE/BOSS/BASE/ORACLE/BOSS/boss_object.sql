/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : boss
 Table   : boss_object
 Owner   : boss
 Author  : Steve Gregan

 Description
 -----------
 Business Operation Scorecard System - Object

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/08   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table boss_object
   (obj_object varchar2(30 char) not null,
    obj_description varchar2(128 char) not null,
    obj_timestamp date not null,
    obj_sequence number not null);

/**/
/* Comments
/**/
comment on table boss_object is 'BOSS Object Table';
comment on column boss_object.obj_object is 'Object - object code';
comment on column boss_object.obj_description is 'Object - object description';
comment on column boss_object.obj_timestamp is 'Object - object measure timestamp';
comment on column boss_object.obj_sequence is 'Object - object update sequence';

/**/
/* Primary Key Constraint
/**/
alter table boss_object
   add constraint boss_object_pk primary key (obj_object);

/**/
/* Authority
/**/
grant select, insert, update, delete on boss_object to boss_app;

/**/
/* Synonym
/**/
create or replace public synonym boss_object for boss.boss_object;
