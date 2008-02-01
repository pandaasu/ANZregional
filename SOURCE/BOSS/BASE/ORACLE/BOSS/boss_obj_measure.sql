/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : boss
 Table   : boss_obj_measure
 Owner   : boss
 Author  : Steve Gregan

 Description
 -----------
 Business Operation Scorecard System - Object Measure

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/08   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table boss_obj_measure
   (obm_object varchar2(30 char) not null,
    obm_sequence number not null,
    obm_measure varchar2(30 char) not null,
    obm_parent varchar2(30 char) not null,
    obm_description varchar2(128 char) not null,
    obm_type varchar2(10 char) not null,
    obm_alert varchar2(4 char) not null,
    obm_value varchar2(2000 char) not null);

/**/
/* Comments
/**/
comment on table boss_obj_measure is 'BOSS Object Measure Table';
comment on column boss_obj_measure.obm_object is 'Object Measure - object measure object';
comment on column boss_obj_measure.obm_sequence is 'Object Measure - object measure sequence';
comment on column boss_obj_measure.obm_measure is 'Object Measure - object measure code';
comment on column boss_obj_measure.obm_parent is 'Object Measure - object measure parent (*TOP,obm_measure)';
comment on column boss_obj_measure.obm_description is 'Object Measure - object measure description';
comment on column boss_obj_measure.obm_type is 'Object Measure - object measure type (*SWITCH,*DATE,*TIMESTAMP,*NUMBER,*PERCENT,*STRING)';
comment on column boss_obj_measure.obm_alert is 'Object Measure - measure alert (*NO,*YES)';
comment on column boss_obj_measure.obm_value is 'Object Measure - measure value';

/**/
/* Primary Key Constraint
/**/
alter table boss_obj_measure
   add constraint boss_obj_measure_pk primary key (obm_object, obm_sequence, obm_measure);

/**/
/* Authority
/**/
grant select, insert, update, delete on boss_obj_measure to boss_app;

/**/
/* Synonym
/**/
create or replace public synonym boss_obj_measure for boss.boss_obj_measure;
