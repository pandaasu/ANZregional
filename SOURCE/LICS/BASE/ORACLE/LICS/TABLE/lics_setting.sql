/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_setting
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_setting

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_setting
   (set_group varchar2(32 char) not null,
    set_code varchar2(32 char) not null,
    set_value varchar(256 char) not null);

/**/
/* Comments
/**/
comment on table lics_setting is 'LICS Setting Table';
comment on column lics_setting.set_group is 'Setting - group';
comment on column lics_setting.set_code is 'Setting - code';
comment on column lics_setting.set_value is 'Setting - value';

/**/
/* Primary Key Constraint
/**/
alter table lics_setting
   add constraint lics_setting_pk primary key (set_group, set_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_setting to lics_app;

/**/
/* Synonym
/**/
create public synonym lics_setting for lics.lics_setting;
