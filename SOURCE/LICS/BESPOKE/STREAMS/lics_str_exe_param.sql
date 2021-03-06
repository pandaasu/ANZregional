/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_str_exe_param
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_str_exe_param

 YYYY/MM   Author         Description
 -------   ------         -----------
 2011/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_str_exe_param
   (stp_exe_seqn          number                       not null,
    stp_str_code          varchar2(32 char)            not null,
    stp_par_code          varchar2(32 char)            not null,
    stp_par_text          varchar2(128 char)           not null,
    stp_par_value         varchar2(64 char)            not null);

/**/
/* Comments
/**/
comment on table lics_str_exe_param is 'LICS Stream Parameter Table';
comment on column lics_str_exe_param.stp_exe_seqn is 'Stream parameter - execution sequence';
comment on column lics_str_exe_param.stp_str_code is 'Stream parameter - stream code';
comment on column lics_str_exe_param.stp_par_code is 'Stream parameter - parameter code';
comment on column lics_str_exe_param.stp_par_text is 'Stream parameter - parameter text';
comment on column lics_str_exe_param.stp_par_value is 'Stream parameter - parameter value (fixed value or supplied)';

/**/
/* Primary Key Constraint
/**/
alter table lics_str_exe_param
   add constraint lics_str_exe_param_pk primary key (stp_exe_seqn, stp_par_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_str_exe_param to lics_app;
grant select on lics_str_exe_param to lics_exec;
/**/
/* Synonym
/**/
create or replace public synonym lics_str_exe_param for lics.lics_str_exe_param;