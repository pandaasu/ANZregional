/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_system
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - System Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_system
   (sys_code                        varchar2(64)                  not null,
    sys_value                       varchar2(256)                 not null,
    sys_upd_user                    varchar2(30)                  not null,
    sys_upd_date                    date                          not null);

/**/
/* Comments
/**/
comment on table psa.psa_system is 'System Table';
comment on column psa.psa_system.sys_code is 'System code';
comment on column psa.psa_system.sys_value is 'System value';
comment on column psa.psa_system.sys_upd_user is 'System last updated user';
comment on column psa.psa_system.sys_upd_date is 'System last updated date';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_system
   add constraint psa_system_pk primary key (sys_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_system to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_system for psa.psa_system;    