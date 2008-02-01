/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_grp_interface
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_grp_interface

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/08   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_grp_interface
   (gri_group                    varchar2(32 char)               not null,
    gri_interface                varchar2(32 char)               not null);

/**/
/* Comments
/**/
comment on table lics_grp_interface is 'LICS Group Interface Table';
comment on column lics_grp_interface.gri_group is 'Group Interface - group identifier';
comment on column lics_grp_interface.gri_interface is 'Group Interface - interface identifier';

/**/
/* Primary Key Constraint
/**/
alter table lics_grp_interface
   add constraint lics_grp_interface_pk primary key (gri_group, gri_interface);

/**/
/* Foreign Key Constraints
/**/
--alter table lics_grp_interface
--   add constraint lics_grp_interface_fk01 foreign key (gri_group)
--      references lics_group (gro_group);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_grp_interface to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym lics_grp_interface for lics.lics_grp_interface;
