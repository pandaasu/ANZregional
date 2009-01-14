/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_str_parameter
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_str_parameter

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_str_parameter
   (stp_str_seqn          number                       not null,
    stp_par_code          varchar2(32 char)            not null,
    stp_par_value         varchar2(4000 char)          not null);

/**/
/* Comments
/**/
comment on table lics_str_parameter is 'LICS Stream Parameter Table';
comment on column lics_str_parameter.stp_str_seqn is 'Stream parameter - stream sequence';
comment on column lics_str_parameter.stp_par_code is 'Stream parameter - parameter code';
comment on column lics_str_parameter.stp_par_value is 'Stream parameter - parameter value';

/**/
/* Primary Key Constraint
/**/
alter table lics_str_parameter
   add constraint lics_str_parameter_pk primary key (stp_str_seqn, stp_par_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_str_parameter to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym lics_str_parameter for lics.lics_str_parameter;