/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_sec_interface
 Owner   : lics
 Author  : Linden Glen

 Description
 -----------
 Local Interface Control System - lics_sec_interface

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/05   Linden Glen    Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_sec_interface
   (sei_interface                varchar2(128 char)              not null,
    sei_user                     varchar2(32 char)               not null);

/**/
/* Comments
/**/
comment on table lics_sec_interface is 'LICS Security Interface Table';
comment on column lics_sec_interface.sei_user is 'Security Interface - User identifier';
comment on column lics_sec_interface.sei_interface is 'Security Interface - Interface identifier';

/**/
/* Primary Key Constraint
/**/
alter table lics_sec_interface
   add constraint lics_sec_interface_pk primary key (sei_interface, sei_user);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_sec_interface to lics_app;
grant select on lics_sec_interface to lics_exec;

/**/
/* Synonym
/**/
create or replace public synonym lics_sec_interface for lics.lics_sec_interface;
