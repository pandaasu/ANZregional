/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_pro_group
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_pro_group

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/08   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_pro_group
   (prg_group                    varchar2(32 char)               not null,
    prg_description              varchar2(128 char)              not null);

/**/
/* Comments
/**/
comment on table lics_pro_group is 'LICS Processing Group Table';
comment on column lics_pro_group.prg_group is 'Processing Group - group code';
comment on column lics_pro_group.prg_description is 'Processing Group - group description';

/**/
/* Primary Key Constraint
/**/
alter table lics_pro_group
   add constraint lics_pro_group_pk primary key (prg_group);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_pro_group to lics_app;

/**/
/* Synonym
/**/
create public synonym lics_pro_group for lics.lics_pro_group;
