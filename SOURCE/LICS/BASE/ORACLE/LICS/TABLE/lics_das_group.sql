/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_das_group
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_das_group

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_das_group
   (dsg_system varchar2(32 char) not null,
    dsg_group varchar2(32 char) not null,
    dsg_description varchar2(128 char) not null,
    dsg_upd_user varchar2(30 char) not null,
    dsg_upd_date date not null);

/**/
/* Comments
/**/
comment on table lics_das_group is 'LICS Datastore Group Table';
comment on column lics_das_group.dsg_system is 'Datastore Group - system';
comment on column lics_das_group.dsg_group is 'Datastore Group - group';
comment on column lics_das_group.dsg_description is 'Datastore Group - group description';
comment on column lics_das_group.dsg_upd_user is 'Datastore Group - update user';
comment on column lics_das_group.dsg_upd_date is 'Datastore Group - update date';

/**/
/* Primary Key Constraint
/**/
alter table lics_das_group
   add constraint lics_das_group_pk primary key (dsg_system, dsg_group);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_das_group to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym lics_das_group for lics.lics_das_group;
