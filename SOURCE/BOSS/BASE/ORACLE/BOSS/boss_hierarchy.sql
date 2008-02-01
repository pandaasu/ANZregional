/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : boss
 Table   : boss_hierarchy
 Owner   : boss
 Author  : Steve Gregan

 Description
 -----------
 Business Operation Scorecard System - Hierarchy

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/08   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table boss_hierarchy
   (hie_hierarchy varchar2(30 char) not null,
    hie_description varchar2(128 char) not null);

/**/
/* Comments
/**/
comment on table boss_hierarchy is 'BOSS Hierarchy Table';
comment on column boss_hierarchy.hie_hierarchy is 'Hierarchy - hierarchy code';
comment on column boss_hierarchy.hie_description is 'Hierarchy - hierarchy description';

/**/
/* Primary Key Constraint
/**/
alter table boss_hierarchy
   add constraint boss_hierarchy_pk primary key (hie_hierarchy);

/**/
/* Authority
/**/
grant select, insert, update, delete on boss_hierarchy to boss_app;

/**/
/* Synonym
/**/
create or replace public synonym boss_hierarchy for boss.boss_hierarchy;
