/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_das_code
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_das_code

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_das_code
   (dsc_system varchar2(32 char) not null,
    dsc_group varchar2(32 char) not null,
    dsc_code varchar2(32 char) not null,
    dsc_description varchar2(4000 char) not null,
    dsc_val_type varchar2(10 char) not null,
    dsc_val_data varchar2(10 char) not null,
    dsc_upd_user varchar2(30 char) not null,
    dsc_upd_date date not null);

/**/
/* Comments
/**/
comment on table lics_das_code is 'LICS Datastore Code Table';
comment on column lics_das_code.dsc_system is 'Datastore Code - system';
comment on column lics_das_code.dsc_group is 'Datastore Code - group';
comment on column lics_das_code.dsc_code is 'Datastore Code - code';
comment on column lics_das_code.dsc_description is 'Datastore Code - code description';
comment on column lics_das_code.dsc_val_type is 'Datastore Code - value type (*SINGLE,*LIST)';
comment on column lics_das_code.dsc_val_data is 'Datastore Code - value data (*UPPER,*MIXED,*NUMBER,*DATE)';
comment on column lics_das_code.dsc_upd_user is 'Datastore Code - update user';
comment on column lics_das_code.dsc_upd_date is 'Datastore Code - update date';

/**/
/* Primary Key Constraint
/**/
alter table lics_das_code
   add constraint lics_das_code_pk primary key (dsc_system, dsc_group, dsc_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_das_code to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym lics_das_code for lics.lics_das_code;
