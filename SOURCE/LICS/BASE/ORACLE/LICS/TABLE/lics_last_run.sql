/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics 
 Table   : lics_last_run 
 Owner   : lics 
 Author  : Trevor Keon 

 Description
 -----------
 Local Interface Control System - lics_last_run 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_last_run
(
  lsr_interface   varchar2(32 char) not null,
  lsr_date        date
);

/**/
/* Comments 
/**/
comment on table lics_last_run is 'LICS Last Run Table';
comment on column lics_last_run.lsr_interface is 'Last Run - interface identifier';
comment on column lics_last_run.lsr_date is 'Last Run - date of last successful run';

/**/
/* Primary Key Constraint 
/**/
alter table lics_last_run
   add constraint lics_last_run_pk primary key (lsr_interface);

/**/
/* Authority 
/**/
grant select, insert, update, delete on lics_last_run to lics_app;

/**/
/* Synonym 
/**/
create or replace public synonym lics_last_run for lics.lics_last_run;
