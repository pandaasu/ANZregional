/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : qv 
 Table   : qv_load_audit
 Owner   : qv 
 Author  : Trevor Keon 

 Description
 -----------
 Qlikview Loader - qv_load_audit 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2010/09   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table qv_load_audit
(
  qla_interface   varchar2(32 char) not null,
  qla_version     number not null,
  qla_user        varchar2(32 char) not null,
  qla_date        date
);

/**/
/* Comments 
/**/
comment on table qv_load_audit is 'QV Load Audit Table';
comment on column qv_load_audit.qla_interface is 'Audit Table - interface';
comment on column qv_load_audit.qla_version is 'Audit Table - load version';
comment on column qv_load_audit.qla_user is 'Audit Table - user who loaded data';
comment on column qv_load_audit.qla_date is 'Audit Table - date of load';

/**/
/* Primary Key Constraint 
/**/
alter table qv_load_audit
   add constraint qv_load_audit_pk primary key (qla_interface, qla_version);

/**/
/* Authority 
/**/
grant select, insert, update, delete on qv_load_audit to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_load_audit for qv.qv_load_audit;
