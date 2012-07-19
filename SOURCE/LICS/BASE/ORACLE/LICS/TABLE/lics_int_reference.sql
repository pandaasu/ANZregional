/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_int_reference
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_int_reference

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/08   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_int_reference
   (inr_interface                varchar2(32 char)               not null,
    inr_reference                varchar2(64 char)               not null);

/**/
/* Comments
/**/
comment on table lics_int_reference is 'LICS Interface Reference Table';
comment on column lics_int_reference.inr_interface is 'Interface reference - interface identifier';
comment on column lics_int_reference.inr_reference is 'Interface reference - reference tag';

/**/
/* Primary Key Constraint
/**/
alter table lics_int_reference
   add constraint lics_int_reference_pk primary key (inr_interface, inr_reference);

/**/
/* Foreign Key Constraints
/**/
--alter table lics_int_reference
--   add constraint lics_int_reference_fk01 foreign key (inr_interface)
--      references lics_interface (int_interface);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_int_reference to lics_app;
grant select on lics_int_reference to lics_exec;

/**/
/* Synonym
/**/
create or replace public synonym lics_int_reference for lics.lics_int_reference;
