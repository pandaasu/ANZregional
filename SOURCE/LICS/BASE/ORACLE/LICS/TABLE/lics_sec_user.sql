/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_sec_user
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_sec_user

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/05   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_sec_user
   (seu_user                     varchar2(32 char)               not null,
    seu_description              varchar2(128 char)              not null,
    seu_menu                     varchar2(32 char)               not null,
    seu_status                   varchar2(1 char)                not null);

/**/
/* Comments
/**/
comment on table lics_sec_user is 'LICS Security User Table';
comment on column lics_sec_user.seu_user is 'Security User - user identifier';
comment on column lics_sec_user.seu_description is 'Security User - user description';
comment on column lics_sec_user.seu_menu is 'Security User - user menu';
comment on column lics_sec_user.seu_status is 'Security User - user status';

/**/
/* Primary Key Constraint
/**/
alter table lics_sec_user
   add constraint lics_sec_user_pk primary key (seu_user);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_sec_user to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym lics_sec_user for lics.lics_sec_user;
