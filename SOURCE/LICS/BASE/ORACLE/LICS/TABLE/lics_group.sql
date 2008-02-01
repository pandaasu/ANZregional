/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_group
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_group

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/08   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_group
   (gro_group                    varchar2(32 char)               not null,
    gro_description              varchar2(128 char)              not null);

/**/
/* Comments
/**/
comment on table lics_group is 'LICS Group Table';
comment on column lics_group.gro_group is 'Group - group identifier';
comment on column lics_group.gro_description is 'Group - group description';

/**/
/* Primary Key Constraint
/**/
alter table lics_group
   add constraint lics_group_pk primary key (gro_group);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_group to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym lics_group for lics.lics_group;
