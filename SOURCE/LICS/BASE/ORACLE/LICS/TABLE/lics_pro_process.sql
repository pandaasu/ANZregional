/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_pro_process
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_pro_process

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/08   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_pro_process
   (prp_process                  varchar2(32 char)               not null,
    prp_description              varchar2(128 char)              not null);

/**/
/* Comments
/**/
comment on table lics_pro_process is 'LICS Processing Process Table';
comment on column lics_pro_process.prp_process is 'Processing Process - process code';
comment on column lics_pro_process.prp_description is 'Processing Process - process description';

/**/
/* Primary Key Constraint
/**/
alter table lics_pro_process
   add constraint lics_pro_process_pk primary key (prp_process);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_pro_process to lics_app;

/**/
/* Synonym
/**/
create public synonym lics_pro_process for lics.lics_pro_process;
