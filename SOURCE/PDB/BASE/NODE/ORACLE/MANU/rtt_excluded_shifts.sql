/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 Table   : rtt_excluded_shifts
 Owner   : manu 
 Author  : Daniel Owen

 Description 
 ----------- 
 Manufacturing - rtt_excluded_shifts

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/10   Daniel Owen    Created
 2008/10   Trevor Keon    Modified to use varchar2, primary key and synonym

*******************************************************************************/

/**/
/* Table creation 
/**/
create table manu.rtt_excluded_shifts
(
  shift_type_code  varchar2(10 char)                not null
);

/**/
/* Primary Key Constraint 
/**/
alter table manu.rtt_excluded_shifts add constraint rtt_excluded_shifts_pk primary key (shift_type_code);

/**/
/* Authority 
/**/
grant delete, insert, select, update on manu.rtt_excluded_shifts to manu_app;

/**/
/* Synonym 
/**/
create or replace public synonym rtt_excluded_shifts for manu.rtt_excluded_shifts;