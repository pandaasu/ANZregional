/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : boss
 Table   : boss_hie_object
 Owner   : boss
 Author  : Steve Gregan

 Description
 -----------
 Business Operation Scorecard System - Hierarchy Object

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/08   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table boss_hie_object
   (hio_hierarchy varchar2(30 char) not null,
    hio_object varchar2(30 char) not null,
    hio_parent varchar2(30 char) not null);

/**/
/* Comments
/**/
comment on table boss_hie_object is 'BOSS Hierarchy Object Table';
comment on column boss_hie_object.hio_hierarchy is 'Hierarchy Object - hierarchy code';
comment on column boss_hie_object.hio_object is 'Hierarchy Object - object code';
comment on column boss_hie_object.hio_parent is 'Hierarchy Object - parent code';

/**/
/* Primary Key Constraint
/**/
alter table boss_hie_object
   add constraint boss_hie_object_pk primary key (hio_hierarchy, hio_object);

/**/
/* Authority
/**/
grant select, insert, update, delete on boss_hie_object to boss_app;

/**/
/* Synonym
/**/
create or replace public synonym boss_hie_object for boss.boss_hie_object;
