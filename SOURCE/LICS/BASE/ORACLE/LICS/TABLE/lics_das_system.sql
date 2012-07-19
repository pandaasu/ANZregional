/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_das_system
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_das_system

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_das_system
   (dss_system varchar2(32 char) not null,
    dss_description varchar2(128 char) not null,
    dss_upd_user varchar2(30 char) not null,
    dss_upd_date date not null);

/**/
/* Comments
/**/
comment on table lics_das_system is 'LICS Datastore System Table';
comment on column lics_das_system.dss_system is 'Datastore System - system';
comment on column lics_das_system.dss_description is 'Datastore System - system description';
comment on column lics_das_system.dss_upd_user is 'Datastore System - update user';
comment on column lics_das_system.dss_upd_date is 'Datastore System - update date';

/**/
/* Primary Key Constraint
/**/
alter table lics_das_system
   add constraint lics_das_system_pk primary key (dss_system);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_das_system to lics_app;
grant select on lics_das_system to lics_exec;

/**/
/* Synonym
/**/
create or replace public synonym lics_das_system for lics.lics_das_system;
