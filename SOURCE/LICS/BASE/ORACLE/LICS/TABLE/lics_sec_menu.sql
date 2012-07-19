/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_sec_menu
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_sec_menu

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/05   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_sec_menu
   (sem_menu                     varchar2(32 char)               not null,
    sem_description              varchar2(128 char)              not null);

/**/
/* Comments
/**/
comment on table lics_sec_menu is 'LICS Security Menu Table';
comment on column lics_sec_menu.sem_menu is 'Security Menu - menu code';
comment on column lics_sec_menu.sem_description is 'Security Menu - menu description';

/**/
/* Primary Key Constraint
/**/
alter table lics_sec_menu
   add constraint lics_sec_menu_pk primary key (sem_menu);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_sec_menu to lics_app;
grant select on lics_sec_menu to lics_exec;

/**/
/* Synonym
/**/
create or replace public synonym lics_sec_menu for lics.lics_sec_menu;
