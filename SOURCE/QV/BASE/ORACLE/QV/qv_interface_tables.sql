/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : qv 
 Table   : qv_interface_tables
 Owner   : qv 
 Author  : Trevor Keon 

 Description
 -----------
 Qlikview Loader - qv_interface_tables 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2010/09   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table qv_interface_tables
(
  qit_interface   varchar2(32 char) not null,
  qit_table       varchar2(32 char) not null
);

/**/
/* Comments 
/**/
comment on table qv_interface_tables is 'QV Interface Table';
comment on column qv_interface_tables.qit_interface is 'Interface Table - interface';
comment on column qv_interface_tables.qit_table is 'Interface Table - tables impacted';

/**/
/* Primary Key Constraint 
/**/
alter table qv_interface_tables
   add constraint qv_interface_tables_pk primary key (qit_interface, qit_table);

/**/
/* Authority 
/**/
grant select, insert, update, delete on qv_interface_tables to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_interface_tables for qv.qv_interface_tables;
