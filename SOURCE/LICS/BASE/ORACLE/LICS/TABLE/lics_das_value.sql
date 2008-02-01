/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_das_value
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_das_value

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_das_value
   (dsv_system varchar2(32 char) not null,
    dsv_group varchar2(32 char) not null,
    dsv_code varchar2(32 char) not null,
    dsv_sequence number not null,
    dsv_value varchar2(4000 char) not null);

/**/
/* Comments
/**/
comment on table lics_das_value is 'LICS Datastore Value Table';
comment on column lics_das_value.dsv_system is 'Datastore Value - system';
comment on column lics_das_value.dsv_group is 'Datastore Value - group';
comment on column lics_das_value.dsv_code is 'Datastore Value - code';
comment on column lics_das_value.dsv_sequence is 'Datastore Value - sequence';
comment on column lics_das_value.dsv_value is 'Datastore Value - value';

/**/
/* Primary Key Constraint
/**/
alter table lics_das_value
   add constraint lics_das_value_pk primary key (dsv_system, dsv_group, dsv_code, dsv_sequence);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_das_value to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym lics_das_value for lics.lics_das_value;
