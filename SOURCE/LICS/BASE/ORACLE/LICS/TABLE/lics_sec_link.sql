/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_sec_link
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_sec_link

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/05   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_sec_link
   (sel_menu                     varchar2(32 char)               not null,
    sel_sequence                 number                          not null,
    sel_type                     varchar2(4 char)                not null,
    sel_link                     varchar2(32 char)               not null);

/**/
/* Comments
/**/
comment on table lics_sec_link is 'LICS Security Link Table';
comment on column lics_sec_link.sel_menu is 'Security Link - menu code';
comment on column lics_sec_link.sel_sequence is 'Security Link - link sequence';
comment on column lics_sec_link.sel_type is 'Security Link - link type (*MNU, *OPT)';
comment on column lics_sec_link.sel_link is 'Security Link - link code';

/**/
/* Primary Key Constraint
/**/
alter table lics_sec_link
   add constraint lics_sec_link_pk primary key (sel_menu, sel_sequence);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_sec_link to lics_app;
grant select on lics_sec_link to lics_exec;

/**/
/* Synonym
/**/
create or replace public synonym lics_sec_link for lics.lics_sec_link;
