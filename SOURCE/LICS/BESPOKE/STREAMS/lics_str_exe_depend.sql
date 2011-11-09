/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_str_exe_depend
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_str_exe_depend

 YYYY/MM   Author         Description
 -------   ------         -----------
 2011/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_str_exe_depend
   (std_exe_seqn          number                       not null,
    std_str_code          varchar2(32 char)            not null,
    std_tsk_code          varchar2(32 char)            not null,
    std_dep_code          varchar2(32 char)            not null);

/**/
/* Comments
/**/
comment on table lics_str_exe_depend is 'LICS Stream Execution Dependent Table';
comment on column lics_str_exe_depend.std_exe_seqn is 'Stream dependent - execution sequence';
comment on column lics_str_exe_depend.std_str_code is 'Stream dependent - stream code';
comment on column lics_str_exe_depend.std_tsk_code is 'Stream dependent - task code';
comment on column lics_str_exe_depend.std_dep_code is 'Stream dependent - dependent code (execution task)';

/**/
/* Primary Key Constraint
/**/
alter table lics_str_exe_depend
   add constraint lics_str_exe_depend_pk primary key (std_exe_seqn, std_tsk_code, std_dep_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_str_exe_depend to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym lics_str_exe_depend for lics.lics_str_exe_depend;