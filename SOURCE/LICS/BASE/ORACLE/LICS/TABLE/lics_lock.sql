/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_lock
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_lock

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_lock
   (loc_lock                     varchar2(128)                   not null,
    loc_session                  varchar2(24)                    not null,
    loc_user                     varchar2(30)                    not null,
    loc_time                     date                            not null);

/**/
/* Comments
/**/
comment on table lics_lock is 'LICS Lock Table';
comment on column lics_lock.loc_lock is 'Lock - lock name';
comment on column lics_lock.loc_session is 'Lock - lock session';
comment on column lics_lock.loc_user is 'Lock - lock user';
comment on column lics_lock.loc_time is 'Lock - lock time';

/**/
/* Primary Key Constraint
/**/
alter table lics_lock
   add constraint lics_lock_pk primary key (loc_lock);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_lock to lics_app;

/**/
/* Synonym
/**/
create public synonym lics_lock for lics.lics_lock;
